import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MandayaMusicScreen extends StatefulWidget {
  const MandayaMusicScreen({super.key});

  @override
  State<MandayaMusicScreen> createState() => _MandayaMusicScreenState();
}

class _MandayaMusicScreenState extends State<MandayaMusicScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  
  // Scroll controller and visibility state
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _lastScrollOffset = 0;

  // Audio player related variables
  final AudioPlayer _audioPlayer = AudioPlayer();
  MusicTrack? _currentTrack;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoadingAudio = false;

  // API and loading state
  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/content/';
  static const String _uploadsBaseUrl = 'https://huni-cms.ionvop.com/uploads/';
  List<MusicTrack> _allTracks = [];
  bool _isLoading = true;
  String? _errorMessage;
  MusicTrack? _featuredTrack;

  // Duration cache
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
    
    final cacheJson = _prefs!.getString('mandaya_music_duration_cache');
    if (cacheJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(cacheJson);
        _durationCache = decoded.map((key, value) => 
          MapEntry(key, Duration(milliseconds: value as int))
        );
        debugPrint('Loaded ${_durationCache.length} cached Mandaya durations');
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
      await _prefs!.setString('mandaya_music_duration_cache', cacheJson);
      debugPrint('Saved ${_durationCache.length} Mandaya durations to cache');
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

      debugPrint('Fetching Mandaya music tracks from: $_baseUrl');
      
      const String apiUrl = '$_baseUrl?tribe=mandaya';
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
        
        if (tribe.toLowerCase() != 'mandaya') {
          debugPrint('Skipping non-Mandaya item: $tribe');
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
      return 'assets/images/mandaya_default_music.jpg';
    }
    
    final String lowerFilename = filename.toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    
    if (imageExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return '$_uploadsBaseUrl$filename';
    }
    
    return 'assets/images/mandaya_default_music.jpg';
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
      return 'Mandaya Elders';
    } else if (lowerTitle.contains(RegExp(r'\b(ritual|ceremony|ceremonial|sacred)\b'))) {
      return 'Tribal Ensemble';
    } else if (lowerTitle.contains(RegExp(r'\b(instrument|instrumental|music)\b'))) {
      return 'Mandaya Musicians';
    }
    
    return 'Mandaya Artist';
  }

  Future<void> _refreshMusicTracks() async {
    await _fetchMusicTracks();
  }

  // Helper method to get responsive values
  double _getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1024) return tablet;
    return desktop;
  }

  // Helper method to check if device is tablet or larger
  bool _isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

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
                height: (_isHeaderVisible || _isSearchFocused) 
                    ? _getResponsiveValue(context, mobile: 80, tablet: 90, desktop: 100)
                    : 0,
                child: (_isHeaderVisible || _isSearchFocused) 
                    ? _buildHeader(context) 
                    : const SizedBox.shrink(),
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
    final isTablet = _isTabletOrLarger(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 0 : (isTablet ? 56 : 48),
            child: _isSearchFocused 
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                  ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 0 : 16,
          ),
          
          Expanded(
            child: Container(
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                border: Border.all(
                  color: _isSearchFocused 
                      ? const Color(0xFF7FB069) 
                      : const Color(0xFF7FB069).withOpacity(0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                ),
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: 'Search music tracks...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isTablet ? 16 : 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isSearchFocused 
                        ? const Color(0xFF7FB069)
                        : Colors.white.withOpacity(0.6),
                    size: isTablet ? 26 : 22,
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
                            size: isTablet ? 24 : 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
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
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: const Color(0xFF7FB069),
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 16 : 14,
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
    final isTablet = _isTabletOrLarger(context);
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isTablet ? 60 : 48,
              height: isTablet ? 60 : 48,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'Loading Mandaya music tracks...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 48 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isTablet ? 80 : 64,
                color: Colors.white.withOpacity(0.5),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'Failed to load music tracks',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton(
                onPressed: _refreshMusicTracks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FB069),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: isTablet ? 16 : 12,
                  ),
                  textStyle: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 48 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_outlined,
                size: isTablet ? 80 : 64,
                color: Colors.white.withOpacity(0.5),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'No Mandaya music tracks available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                'Check back later for new music content',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton(
                onPressed: _refreshMusicTracks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FB069),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: isTablet ? 16 : 12,
                  ),
                  textStyle: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                  ),
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
      color: const Color(0xFF7FB069),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeroSection(),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsiveValue(context, mobile: 0, tablet: 24, desktop: 48),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _filteredTracks[index];
                  return _buildMusicCard(track);
                },
                childCount: _filteredTracks.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: _currentTrack != null ? 140 : 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final isTablet = _isTabletOrLarger(context);
    
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredTracks.length} result${_filteredTracks.length == 1 ? '' : 's'} for "$_searchQuery"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isTablet ? 16 : 14,
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
                      fontSize: isTablet ? 18 : 16,
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
                            size: isTablet ? 64 : 48,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: isTablet ? 20 : 16),
                          Text(
                            'No tracks found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            'Try different keywords',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                        left: isTablet ? 24 : 0,
                        right: isTablet ? 24 : 0,
                        bottom: MediaQuery.of(context).viewInsets.bottom + (_currentTrack != null ? 140 : 20),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final height = isDesktop ? 300.0 : (isTablet ? 250.0 : 200.0);
    final margin = EdgeInsets.symmetric(
      horizontal: isDesktop ? 48 : (isTablet ? 24 : 16),
      vertical: isTablet ? 20 : 16,
    );
    
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/mandaya_music_hero.jpg',
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
                        Color(0xFF7FB069),
                        Color(0xFF6B8E23),
                        Color(0xFF556B2F),
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
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'Experience the rich musical traditions of the Mandaya people. From epic dagit chants to ceremonial dances, each melody tells the story of their ancestral heritage and connection to nature.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: isDesktop ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
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
    final isTablet = _isTabletOrLarger(context);
    
    final cardPadding = isTablet ? 16.0 : 12.0;
    final imageSize = isTablet ? 70.0 : 60.0;
    final playButtonSize = isTablet ? 48.0 : 40.0;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 0 : 16,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: isCurrentTrack 
            ? const Color(0xFF7FB069).withOpacity(0.1)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: isCurrentTrack 
              ? const Color(0xFF7FB069)
              : const Color(0xFF7FB069).withOpacity(0.2),
          width: isCurrentTrack ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: () {
            HapticFeedback.mediumImpact();
            _togglePlayPause(track);
          },
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    color: const Color(0xFF7FB069).withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    child: track.imagePath.startsWith('http')
                        ? Image.network(
                            track.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: const Color(0xFF7FB069),
                                size: isTablet ? 35 : 30,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
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
                                color: const Color(0xFF7FB069),
                                size: isTablet ? 35 : 30,
                              );
                            },
                          ),
                  ),
                ),
                
                SizedBox(width: isTablet ? 20 : 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: TextStyle(
                          color: isCurrentTrack 
                              ? const Color(0xFF7FB069)
                              : Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        track.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isTablet ? 15 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : 8,
                              vertical: isTablet ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7FB069).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                            ),
                            child: Text(
                              track.category,
                              style: TextStyle(
                                color: const Color(0xFF7FB069),
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '• ${track.artist}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: isTablet ? 13 : 12,
                            ),
                          ),
                          if (hasDuration)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 8 : 6,
                                vertical: isTablet ? 4 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: isTablet ? 12 : 10,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  SizedBox(width: isTablet ? 5 : 4),
                                  Text(
                                    _formatDuration(track.duration!),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: isTablet ? 12 : 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isLoadingDuration)
                            SizedBox(
                              width: isTablet ? 14 : 12,
                              height: isTablet ? 14 : 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: isTablet ? 12 : 8),
                
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _togglePlayPause(track);
                  },
                  child: Container(
                    width: playButtonSize,
                    height: playButtonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FB069),
                      borderRadius: BorderRadius.circular(playButtonSize / 2),
                    ),
                    child: _isLoadingAudio && isCurrentTrack
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: isTablet ? 2.5 : 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isCurrentTrack && _isPlaying 
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: isTablet ? 28 : 24,
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
    final isTablet = _isTabletOrLarger(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        border: Border(
          top: BorderSide(
            color: Color(0xFF7FB069),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 60.0 : 50.0,
                height: isTablet ? 60.0 : 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  color: const Color(0xFF7FB069).withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  child: _currentTrack!.imagePath.startsWith('http')
                      ? Image.network(
                          _currentTrack!.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note,
                              color: const Color(0xFF7FB069),
                              size: isTablet ? 30 : 25,
                            );
                          },
                        )
                      : Image.asset(
                          _currentTrack!.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.music_note,
                              color: const Color(0xFF7FB069),
                              size: isTablet ? 30 : 25,
                            );
                          },
                        ),
                ),
              ),
              
              SizedBox(width: isTablet ? 16 : 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTrack!.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isTablet ? 4 : 2),
                    Text(
                      _currentTrack!.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isTablet ? 14 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              if (isDesktop) ...[
                IconButton(
                  onPressed: () {
                    _seekTo(Duration(seconds: (_currentPosition.inSeconds - 10).clamp(0, _totalDuration.inSeconds)));
                  },
                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 24),
                ),
              ],
              
              IconButton(
                iconSize: isTablet ? 24 : 20,
                onPressed: () => _togglePlayPause(_currentTrack!),
                icon: Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF7FB069),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
              
              if (isDesktop) ...[
                IconButton(
                  onPressed: () {
                    _seekTo(Duration(seconds: (_currentPosition.inSeconds + 30).clamp(0, _totalDuration.inSeconds)));
                  },
                  icon: const Icon(Icons.forward_30, color: Colors.white, size: 24),
                ),
              ],
              
              IconButton(
                iconSize: isTablet ? 20 : 16,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _closeMusicPlayer();
                },
                icon: Container(
                  padding: EdgeInsets.all(isTablet ? 6 : 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: isTablet ? 18 : 16,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isTablet ? 12 : 8),
          
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF7FB069),
                  inactiveTrackColor: const Color(0xFF7FB069).withOpacity(0.3),
                  thumbColor: const Color(0xFF7FB069),
                  overlayColor: const Color(0xFF7FB069).withOpacity(0.3),
                  trackHeight: isTablet ? 5 : 4,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: isTablet ? 8 : 6,
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
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isTablet ? 13 : 12,
                      ),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isTablet ? 13 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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