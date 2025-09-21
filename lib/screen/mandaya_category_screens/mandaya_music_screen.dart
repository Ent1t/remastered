// lib/screen/mandaya_category_screens/mandaya_music_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this dependency

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
  String? _selectedCategory;
  
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
  bool _isLoading = false;

  // Sample data for Mandaya music
  final List<MusicTrack> _allTracks = [
    MusicTrack(
      title: 'Dagit Song',
      description: 'Epic chant telling ancient Mandaya legends',
      category: 'Traditional',
      imagePath: 'assets/images/mandaya_dagit.jpg',
      artist: 'Elder Dagit',
      audioPath: 'audio/mandaya_dagit.mp3',
    ),
    MusicTrack(
      title: 'Gimbal Dance',
      description: 'Rhythmic music for the traditional Mandaya dance',
      category: 'Ceremonial',
      imagePath: 'assets/images/mandaya_gimbal.jpg',
      artist: 'Dance Troupe',
      audioPath: 'audio/mandaya_gimbal.mp3',
    ),
    MusicTrack(
      title: 'River Song',
      description: 'Folk song about the sacred rivers of Davao Oriental',
      category: 'Folk',
      imagePath: 'assets/images/mandaya_river.jpg',
      artist: 'River Singers',
      audioPath: 'audio/mandaya_river.mp3',
    ),
    MusicTrack(
      title: 'Ancestor Calling',
      description: 'Spiritual chant to communicate with ancestors',
      category: 'Spiritual',
      imagePath: 'assets/images/mandaya_ancestor.jpg',
      artist: 'Spirit Caller',
      audioPath: 'audio/mandaya_ancestor.mp3',
    ),
    MusicTrack(
      title: 'Harvest Festival',
      description: 'Celebratory music for the annual harvest',
      category: 'Traditional',
      imagePath: 'assets/images/mandaya_festival.jpg',
      artist: 'Festival Chorus',
      audioPath: 'audio/mandaya_festival.mp3',
    ),
    MusicTrack(
      title: 'Weaving Song',
      description: 'Work song sung while creating traditional textiles',
      category: 'Folk',
      imagePath: 'assets/images/mandaya_weaving.jpg',
      artist: 'Weaver Women',
      audioPath: 'audio/mandaya_weaving.mp3',
    ),
  ];

  List<String> get _categories => ['All', 'Traditional', 'Ceremonial', 'Folk', 'Spiritual'];

  List<MusicTrack> get _filteredTracks {
    List<MusicTrack> tracks = _allTracks;
    
    if (_selectedCategory != null && _selectedCategory != 'All') {
      tracks = tracks.where((track) => track.category == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      tracks = tracks.where((track) =>
          track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          track.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          track.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    return tracks;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _setupAudioPlayer();
    _setupScrollController();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
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
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        _isLoading = state == PlayerState.playing && _currentPosition == Duration.zero;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
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
              // Header that shows/hides based on scroll and search focus
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: (_isHeaderVisible || _isSearchFocused) ? 80 : 0,
                child: (_isHeaderVisible || _isSearchFocused) ? _buildHeader(context) : const SizedBox.shrink(),
              ),
              
              // Flexible content area
              Expanded(
                child: _isSearchFocused 
                    ? _buildSearchResults()
                    : _buildMainContent(),
              ),
              
              // Inline Music Player at the bottom
              if (_currentTrack != null) _buildInlineMusicPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button - hide when searching
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 0 : 48,
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
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
          
          // Dynamic spacing
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 0 : 16,
          ),
          
          // Search bar - expands when focused
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
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
                        ? const Color(0xFF7FB069)
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
          
          // Cancel button when searching
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
                        _selectedCategory = 'All';
                        _isHeaderVisible = true;
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF7FB069),
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
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),
        SliverToBoxAdapter(
          child: _buildCategoriesFilter(),
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
          child: SizedBox(height: _currentTrack != null ? 120 : 20),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _buildResultsText(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: _searchQuery.isEmpty && _selectedCategory == 'All'
              ? Center(
                  child: Text(
                    'Start typing to search or select a category...',
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
                            _searchQuery.isNotEmpty 
                                ? 'Try different keywords'
                                : 'No tracks in this category',
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
                        bottom: MediaQuery.of(context).viewInsets.bottom + (_currentTrack != null ? 120 : 20),
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
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
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
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    'Experience the rich musical traditions of the Mandaya people. From epic dagit chants to ceremonial dances, each melody tells the story of their ancestral heritage and connection to nature.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
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

  Widget _buildCategoriesFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: const Color(0xFF7FB069),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFF7FB069)
                    : const Color(0xFF7FB069).withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategory = selected ? category : 'All';
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicCard(MusicTrack track) {
    final isCurrentTrack = _currentTrack?.title == track.title;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentTrack 
            ? const Color(0xFF7FB069).withOpacity(0.1)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.mediumImpact();
            _togglePlayPause(track);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF7FB069).withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      track.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          color: Color(0xFF7FB069),
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FB069).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          track.category,
                          style: const TextStyle(
                            color: Color(0xFF7FB069),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _togglePlayPause(track);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FB069),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isLoading && isCurrentTrack
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isCurrentTrack && _isPlaying 
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
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
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Track info with close button
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF7FB069).withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _currentTrack!.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.music_note,
                        color: Color(0xFF7FB069),
                        size: 25,
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTrack!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentTrack!.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Control buttons
              IconButton(
                onPressed: () {
                  _seekTo(Duration(seconds: (_currentPosition.inSeconds - 10).clamp(0, _totalDuration.inSeconds)));
                },
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 20),
              ),
              
              IconButton(
                onPressed: () => _togglePlayPause(_currentTrack!),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF7FB069),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              IconButton(
                onPressed: () {
                  _seekTo(Duration(seconds: (_currentPosition.inSeconds + 30).clamp(0, _totalDuration.inSeconds)));
                },
                icon: const Icon(Icons.forward_30, color: Colors.white, size: 20),
              ),
              
              // Close button
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF7FB069),
                  inactiveTrackColor: const Color(0xFF7FB069).withOpacity(0.3),
                  thumbColor: const Color(0xFF7FB069),
                  overlayColor: const Color(0xFF7FB069).withOpacity(0.3),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
              
              // Time labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
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

  String _buildResultsText() {
    String text = '${_filteredTracks.length} result${_filteredTracks.length == 1 ? '' : 's'}';
    
    if (_searchQuery.isNotEmpty && _selectedCategory != 'All') {
      text += ' for "$_searchQuery" in $_selectedCategory';
    } else if (_searchQuery.isNotEmpty) {
      text += ' for "$_searchQuery"';
    } else if (_selectedCategory != 'All') {
      text += ' in $_selectedCategory';
    }
    
    return text;
  }

  Future<void> _togglePlayPause(MusicTrack track) async {
    try {
      if (_currentTrack?.title != track.title) {
        setState(() {
          _currentTrack = track;
          _isLoading = true;
        });
        
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(track.audioPath));
      } else {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _closeMusicPlayer() async {
    await _audioPlayer.stop();
    setState(() {
      _currentTrack = null;
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _isLoading = false;
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

// MusicTrack model with audio path
class MusicTrack {
  final String title;
  final String description;
  final String category;
  final String imagePath;
  final String artist;
  final String audioPath;

  MusicTrack({
    required this.title,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.artist,
    required this.audioPath,
  });
}