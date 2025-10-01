import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KaganMusicScreen extends StatefulWidget {
  const KaganMusicScreen({super.key});

  @override
  State<KaganMusicScreen> createState() => _KaganMusicScreenState();
}

class _KaganMusicScreenState extends State<KaganMusicScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _lastScrollOffset = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  MusicTrack? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoadingAudio = false;

  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/content/';
  static const String _uploadsBaseUrl = 'https://huni-cms.ionvop.com/uploads/';
  List<MusicTrack> _allTracks = [];
  bool _isLoading = true;
  String? _errorMessage;
  MusicTrack? _featuredTrack;

  Map<String, Duration> _durationCache = {};
  SharedPreferences? _prefs;
  Set<String> _loadingDurations = {};

  List<MusicTrack> get _filteredTracks {
    if (_searchQuery.isEmpty) {
      return _allTracks;
    }
    
    return _allTracks.where((track) =>
        track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        track.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        track.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Responsive helpers
  EdgeInsets _getContentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 800) return const EdgeInsets.symmetric(horizontal: 32);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  double _getHeroHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (width >= 800) return height * 0.35;
    if (width >= 600) return 250;
    return 200;
  }

  double _getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 800) return 100;
    if (width >= 600) return 90;
    return 80;
  }

  double _getPlayerHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 140;
    return 120;
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _setupAudioPlayer();
    _setupScrollController();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _fetchMusicTracks();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadDurationCache();
  }

  void _loadDurationCache() {
    if (_prefs == null) return;
    
    final cacheJson = _prefs!.getString('music_duration_cache');
    if (cacheJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(cacheJson);
        _durationCache = decoded.map((key, value) => 
          MapEntry(key, Duration(milliseconds: value as int))
        );
        debugPrint('Loaded ${_durationCache.length} cached durations');
      } catch (e) {
        debugPrint('Error loading duration cache: $e');
      }
    }
  }

  Future<void> _saveDurationCache() async {
    if (_prefs == null) return;
    
    try {
      final cacheJson = json.encode(
        _durationCache.map((key, value) => 
          MapEntry(key, value.inMilliseconds)
        )
      );
      await _prefs!.setString('music_duration_cache', cacheJson);
      debugPrint('Saved ${_durationCache.length} durations to cache');
    } catch (e) {
      debugPrint('Error saving duration cache: $e');
    }
  }

  Duration? _getCachedDuration(String trackId) {
    return _durationCache[trackId];
  }

  Future<void> _cacheDuration(String trackId, Duration duration) async {
    _durationCache[trackId] = duration;
    await _saveDurationCache();
  }

  Future<void> _loadTrackDuration(MusicTrack track) async {
    if (_durationCache.containsKey(track.id) || _loadingDurations.contains(track.id)) {
      return;
    }

    _loadingDurations.add(track.id);

    try {
      final tempPlayer = AudioPlayer();
      
      if (track.isNetworkSource) {
        await tempPlayer.setSourceUrl(track.audioPath);
      } else {
        await tempPlayer.setSource(AssetSource(track.audioPath));
      }

      Duration? duration;
      int attempts = 0;
      while (duration == null && attempts < 10) {
        duration = await tempPlayer.getDuration();
        if (duration == null) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
        attempts++;
      }

      if (duration != null && duration.inMilliseconds > 0) {
        await _cacheDuration(track.id, duration);
        if (mounted) {
          setState(() {
            final index = _allTracks.indexWhere((t) => t.id == track.id);
            if (index != -1) {
              _allTracks[index] = track.copyWith(duration: duration);
            }
          });
        }
        debugPrint('Cached duration for ${track.title}: ${_formatDuration(duration)}');
      }

      await tempPlayer.dispose();
    } catch (e) {
      debugPrint('Error loading duration for ${track.title}: $e');
    } finally {
      _loadingDurations.remove(track.id);
    }
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;
      final isScrollingDown = currentOffset > _lastScrollOffset;
      final shouldHideHeader = isScrollingDown && currentOffset > 100;
      final shouldShowHeader = !isScrollingDown || currentOffset <= 50;

      if (_isHeaderVisible && shouldHideHeader && !_isSearchFocused) {
        setState(() {
          _isHeaderVisible = false;
        });
      } else if (!_isHeaderVisible && shouldShowHeader) {
        setState(() {
          _isHeaderVisible = true;
        });
      }

      _lastScrollOffset = currentOffset;
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
      
      if (_currentTrack != null && duration.inMilliseconds > 0) {
        _cacheDuration(_currentTrack!.id, duration);
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoadingAudio = state == PlayerState.playing && _currentPosition == Duration.zero;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  Future<void> _fetchMusicTracks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('Fetching Kagan music tracks from: $_baseUrl');
      
      const String apiUrl = '$_baseUrl?tribe=kagan';
      debugPrint('API URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }

      if (!jsonData.containsKey('data')) {
        throw Exception('API response missing "data" field');
      }

      final dynamic rawData = jsonData['data'];
      List<dynamic> contentItems = [];
      
      if (rawData is List) {
        contentItems = rawData;
      } else if (rawData is Map) {
        contentItems = [rawData];
      } else {
        throw Exception('Unexpected data format in API response');
      }

      debugPrint('Found ${contentItems.length} content items');

      final List<MusicTrack> musicTracks = [];

      for (var item in contentItems) {
        if (item == null || item is! Map<String, dynamic>) {
          debugPrint('Skipping invalid item: $item');
          continue;
        }
        
        debugPrint('Processing item: ${item.toString()}');
        
        final dynamic id = item['id'];
        final dynamic userId = item['user_id'];
        final String? title = item['title']?.toString();
        final String? category = item['category']?.toString();
        final String? tribe = item['tribe']?.toString();
        final String? description = item['description']?.toString();
        final String? file = item['file']?.toString();
        final dynamic isArchived = item['is_archived'];
        final String? time = item['time']?.toString();
        
        if (id == null || 
            userId == null || 
            title == null || title.isEmpty ||
            category == null || category.isEmpty ||
            tribe == null || tribe.isEmpty ||
            file == null || file.isEmpty ||
            isArchived == null ||
            time == null || time.isEmpty) {
          debugPrint('Skipping item with missing required fields');
          continue;
        }
        
        if (tribe.toLowerCase() != 'kagan') {
          debugPrint('Skipping non-Kagan item: $tribe');
          continue;
        }

        if (isArchived != 0) {
          debugPrint('Skipping archived item: $title');
          continue;
        }

        final fileType = _determineFileType(file);
        
        if (!_isAudioContent(file, category)) {
          debugPrint('Skipping non-audio content: $file (category: $category, type: $fileType)');
          continue;
        }

        final cachedDuration = _getCachedDuration(id.toString());

        final musicTrack = MusicTrack(
          id: id.toString(),
          title: title,
          description: description ?? 'No description available',
          category: _mapCategory(category),
          imagePath: _buildThumbnailUrl(file, category),
          artist: _extractArtist(description, title),
          audioPath: '$_uploadsBaseUrl$file',
          file: file,
          fileType: fileType,
          isNetworkSource: true,
          duration: cachedDuration,
        );
        
        debugPrint('✅ Added music track: $title (ID: $id, Category: $category, Cached Duration: ${cachedDuration != null ? _formatDuration(cachedDuration) : 'Not cached'})');
        musicTracks.add(musicTrack);

        if (cachedDuration == null) {
          _loadTrackDuration(musicTrack);
        }
      }

      debugPrint('Final music track count: ${musicTracks.length}');

      setState(() {
        _allTracks = musicTracks;
        _featuredTrack = musicTracks.isNotEmpty ? musicTracks.first : null;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      debugPrint('Error fetching music tracks: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load music tracks: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  bool _isAudioContent(String filename, String category) {
    final String lowerFilename = filename.toLowerCase();
    final String lowerCategory = category.toLowerCase();
    
    const audioExtensions = ['.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac'];
    const videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv'];
    
    final hasAudioExtension = audioExtensions.any((ext) => lowerFilename.endsWith(ext));
    final hasVideoExtension = videoExtensions.any((ext) => lowerFilename.endsWith(ext));
    
    const musicCategories = ['audio', 'music', 'song', 'instrument', 'ceremony'];
    final isMusicCategory = musicCategories.any((cat) => lowerCategory.contains(cat));
    
    return hasAudioExtension || (hasVideoExtension && isMusicCategory);
  }

  String _buildThumbnailUrl(String filename, String category) {
    if (_isAudioContent(filename, category)) {
      return 'assets/images/kagan_default_music.jpg';
    }
    
    final String lowerFilename = filename.toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    
    if (imageExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return '$_uploadsBaseUrl$filename';
    }
    
    return 'assets/images/kagan_default_music.jpg';
  }

  FileType _determineFileType(String filename) {
    final String lowerFilename = filename.toLowerCase();
    
    const videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv', '.flv', '.wmv'];
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    const audioExtensions = ['.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac'];
    
    if (audioExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.audio;
    } else if (videoExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.video;
    } else if (imageExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.image;
    }
    
    return FileType.unknown;
  }

  String _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'audio':
        return 'Traditional Music';
      case 'instrument':
        return 'Instrumental';
      case 'ceremony':
        return 'Ceremonial';
      case 'video':
        return 'Audio/Video';
      case 'music':
        return 'Music';
      case 'song':
        return 'Song';
      default:
        return category;
    }
  }

  String _extractArtist(String? description, String title) {
    if (description != null && description.isNotEmpty) {
      final RegExp artistPattern = RegExp(r'(?:by|artist|performed by|sung by)\s+([^,\.\-\n]+)', caseSensitive: false);
      final match = artistPattern.firstMatch(description);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
      
      if (description.length < 50 && 
          !description.toLowerCase().contains(RegExp(r'\b(the|a|an|and|or|but|in|on|at|to|for|of|with|by)\b'))) {
        return description.trim();
      }
    }
    
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains(RegExp(r'\b(elder|traditional|ancestral|ancient)\b'))) {
      return 'Kagan Elders';
    } else if (lowerTitle.contains(RegExp(r'\b(ritual|ceremony|ceremonial|sacred)\b'))) {
      return 'Tribal Ensemble';
    } else if (lowerTitle.contains(RegExp(r'\b(instrument|instrumental|music)\b'))) {
      return 'Kagan Musicians';
    }
    
    return 'Kagan Artist';
  }

  Future<void> _refreshMusicTracks() async {
    await _fetchMusicTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF0d0d0d),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: (_isHeaderVisible || _isSearchFocused) ? 80 : 0,
                child: (_isHeaderVisible || _isSearchFocused) ? _buildHeader(context) : const SizedBox.shrink(),
              ),
              
              Expanded(
                child: _isSearchFocused 
                    ? _buildSearchResults()
                    : _buildMainContent(),
              ),
              
              if (_currentTrack != null) _buildInlineMusicPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final padding = _getContentPadding(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding.horizontal / 2,
        vertical: 16,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused && width < 600 ? 0 : 48,
            child: _isSearchFocused && width < 600
                ? const SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused && width < 600 ? 0 : 16,
          ),
          
          Expanded(
            child: Container(
              height: 48,
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isSearchFocused 
                      ? const Color(0xFFD4A574) 
                      : const Color(0xFFD4A574).withOpacity(0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: 'Search music tracks...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isSearchFocused 
                        ? const Color(0xFFD4A574)
                        : Colors.white.withOpacity(0.6),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 80 : 0,
            child: _isSearchFocused
                ? TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() {
                        _searchQuery = '';
                        _isHeaderVisible = true;
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFD4A574),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Kagan music tracks...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      final padding = _getContentPadding(context);
      return Center(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load music tracks',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshMusicTracks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allTracks.isEmpty) {
      final padding = _getContentPadding(context);
      return Center(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Kagan music tracks available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new music content',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshMusicTracks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A574),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMusicTracks,
      color: const Color(0xFFD4A574),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeroSection(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = _filteredTracks[index];
                return _buildMusicCard(track);
              },
              childCount: _filteredTracks.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: _currentTrack != null ? _getPlayerHeight(context) + 20 : 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final padding = _getContentPadding(context);
    
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding.horizontal / 2,
              vertical: 8,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredTracks.length} result${_filteredTracks.length == 1 ? '' : 's'} for "$_searchQuery"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: _searchQuery.isEmpty
              ? Center(
                  child: Text(
                    'Start typing to search...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                )
              : _filteredTracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tracks found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + (_currentTrack != null ? _getPlayerHeight(context) + 20 : 20),
                      ),
                      itemCount: _filteredTracks.length,
                      itemBuilder: (context, index) {
                        final track = _filteredTracks[index];
                        return _buildMusicCard(track);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final height = _getHeroHeight(context);
    final padding = _getContentPadding(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.fromLTRB(
        padding.horizontal / 2,
        16,
        padding.horizontal / 2,
        16,
      ),
      height: height,
      constraints: const BoxConstraints(maxWidth: 1200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/kagan_music_hero.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD4A574),
                        Color(0xFFB8935F),
                        Color(0xFF8B7355),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(width >= 600 ? 24 : 20),
                child: Container(
                  padding: EdgeInsets.all(width >= 600 ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'Discover the traditional musical heritage of the Kagan people. Each song carries deep cultural meaning and connects the community to their ancestors through rhythm and melody.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: width >= 600 ? 16 : 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicCard(MusicTrack track) {
    final isCurrentTrack = _currentTrack?.id == track.id;
    final hasDuration = track.duration != null;
    final isLoadingDuration = _loadingDurations.contains(track.id);
    final width = MediaQuery.of(context).size.width;
    final padding = _getContentPadding(context);
    final cardHeight = _getCardHeight(context);
    
    // Responsive sizing
    final imageSize = width >= 800 ? 80.0 : width >= 600 ? 70.0 : 60.0;
    final titleFontSize = width >= 800 ? 17.0 : width >= 600 ? 16.0 : 16.0;
    final descriptionFontSize = width >= 800 ? 15.0 : width >= 600 ? 14.0 : 14.0;
    final categoryFontSize = width >= 800 ? 13.0 : 12.0;
    final buttonSize = width >= 800 ? 48.0 : width >= 600 ? 44.0 : 40.0;
    final iconSize = width >= 800 ? 28.0 : width >= 600 ? 26.0 : 24.0;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: padding.horizontal / 2,
        vertical: 6,
      ),
      constraints: const BoxConstraints(maxWidth: 1000),
      decoration: BoxDecoration(
        color: isCurrentTrack 
            ? const Color(0xFFD4A574).withOpacity(0.1)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTrack 
              ? const Color(0xFFD4A574)
              : const Color(0xFFD4A574).withOpacity(0.2),
          width: isCurrentTrack ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.mediumImpact();
            _togglePlayPause(track);
          },
          child: Padding(
            padding: EdgeInsets.all(width >= 600 ? 14 : 12),
            child: Row(
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFD4A574).withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track.imagePath.startsWith('http')
                        ? Image.network(
                            track.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: const Color(0xFFD4A574),
                                size: imageSize * 0.5,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            track.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: const Color(0xFFD4A574),
                                size: imageSize * 0.5,
                              );
                            },
                          ),
                  ),
                ),
                
                SizedBox(width: width >= 600 ? 18 : 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: TextStyle(
                          color: isCurrentTrack 
                              ? const Color(0xFFD4A574)
                              : Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: descriptionFontSize,
                        ),
                        maxLines: width >= 800 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A574).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              track.category,
                              style: TextStyle(
                                color: const Color(0xFFD4A574),
                                fontSize: categoryFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (width >= 600)
                            Flexible(
                              child: Text(
                                '• ${track.artist}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: categoryFontSize,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (hasDuration)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 10,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(track.duration!),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isLoadingDuration)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: width >= 600 ? 12 : 8),
                
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _togglePlayPause(track);
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(buttonSize / 2),
                    ),
                    child: Center(
                      child: _isLoadingAudio && isCurrentTrack
                          ? SizedBox(
                              width: iconSize * 0.75,
                              height: iconSize * 0.75,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              isCurrentTrack && _isPlaying 
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: iconSize,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineMusicPlayer() {
    final width = MediaQuery.of(context).size.width;
    final playerHeight = _getPlayerHeight(context);
    final isTablet = width >= 600;
    final isDesktop = width >= 800;
    
    final imageSize = isDesktop ? 60.0 : isTablet ? 55.0 : 50.0;
    final titleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final artistFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final iconSize = isDesktop ? 22.0 : isTablet ? 21.0 : 20.0;
    final playButtonSize = isDesktop ? 44.0 : isTablet ? 42.0 : 40.0;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD4A574),
            width: 2,
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFD4A574).withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _currentTrack!.imagePath.startsWith('http')
                        ? Image.network(
                            _currentTrack!.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: const Color(0xFFD4A574),
                                size: imageSize * 0.5,
                              );
                            },
                          )
                        : Image.asset(
                            _currentTrack!.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: const Color(0xFFD4A574),
                                size: imageSize * 0.5,
                              );
                            },
                          ),
                  ),
                ),
                
                SizedBox(width: isDesktop ? 16 : 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTrack!.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentTrack!.artist,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: artistFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                if (isTablet) ...[
                  IconButton(
                    onPressed: () {
                      _seekTo(Duration(seconds: (_currentPosition.inSeconds - 10).clamp(0, _totalDuration.inSeconds)));
                    },
                    icon: Icon(Icons.replay_10, color: Colors.white, size: iconSize),
                  ),
                ],
                
                IconButton(
                  onPressed: () => _togglePlayPause(_currentTrack!),
                  icon: Container(
                    width: playButtonSize,
                    height: playButtonSize,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4A574),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
                
                if (isTablet) ...[
                  IconButton(
                    onPressed: () {
                      _seekTo(Duration(seconds: (_currentPosition.inSeconds + 30).clamp(0, _totalDuration.inSeconds)));
                    },
                    icon: Icon(Icons.forward_30, color: Colors.white, size: iconSize),
                  ),
                ],
                
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _closeMusicPlayer();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: isDesktop ? 18 : 16,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? 12 : 8),
            
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4A574),
                    inactiveTrackColor: const Color(0xFFD4A574).withOpacity(0.3),
                    thumbColor: const Color(0xFFD4A574),
                    overlayColor: const Color(0xFFD4A574).withOpacity(0.3),
                    trackHeight: isDesktop ? 5 : 4,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: isDesktop ? 7 : 6,
                    ),
                  ),
                  child: Slider(
                    value: _totalDuration.inMilliseconds > 0 
                        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                        : 0.0,
                    onChanged: (value) {
                      final position = Duration(
                        milliseconds: (value * _totalDuration.inMilliseconds).round(),
                      );
                      _seekTo(position);
                    },
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 18 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isDesktop ? 13 : 12,
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isDesktop ? 13 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayPause(MusicTrack track) async {
    try {
      if (_currentTrack?.id != track.id) {
        setState(() {
          _currentTrack = track;
          _isLoadingAudio = true;
        });
        
        await _audioPlayer.stop();
        
        if (track.isNetworkSource) {
          await _audioPlayer.play(UrlSource(track.audioPath));
        } else {
          await _audioPlayer.play(AssetSource(track.audioPath));
        }
      } else {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play audio: ${track.title}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _togglePlayPause(track),
            ),
          ),
        );
      }
      
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  void _closeMusicPlayer() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrack = null;
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _isLoadingAudio = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

enum FileType {
  video,
  audio,
  image,
  unknown,
}

class MusicTrack {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imagePath;
  final String artist;
  final String audioPath;
  final String file;
  final FileType fileType;
  final bool isNetworkSource;
  final Duration? duration;

  MusicTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.artist,
    required this.audioPath,
    required this.file,
    required this.fileType,
    this.isNetworkSource = false,
    this.duration,
  });

  MusicTrack copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imagePath,
    String? artist,
    String? audioPath,
    String? file,
    FileType? fileType,
    bool? isNetworkSource,
    Duration? duration,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      artist: artist ?? this.artist,
      audioPath: audioPath ?? this.audioPath,
      file: file ?? this.file,
      fileType: fileType ?? this.fileType,
      isNetworkSource: isNetworkSource ?? this.isNetworkSource,
      duration: duration ?? this.duration,
    );
  }
}