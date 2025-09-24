// lib/screen/mansaka_category_screens/mansaka_video_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared/video_player_screen.dart';

class MansakaVideoScreen extends StatefulWidget {
  const MansakaVideoScreen({super.key});

  @override
  State<MansakaVideoScreen> createState() => _MansakaVideoScreenState();
}

class _MansakaVideoScreenState extends State<MansakaVideoScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  
  // Scroll controller and visibility state
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _lastScrollOffset = 0;

  // API and loading state
  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/content/';
  static const String _uploadsBaseUrl = 'https://huni-cms.ionvop.com/uploads/';
  List<VideoItem> _allVideos = [];
  bool _isLoading = true;
  String? _errorMessage;
  VideoItem? _featuredVideo;

  List<VideoItem> get _filteredVideos {
    if (_searchQuery.isEmpty) {
      return _allVideos;
    }
    
    return _allVideos.where((video) =>
        video.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        video.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        video.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _fetchVideos();
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

  Future<void> _fetchVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('Fetching videos from: $_baseUrl');
      debugPrint('Attempting URL: ${_baseUrl}category=video&tribe=mansaka');

      // Try multiple approaches to get data
      List<String> urls = [
        '${_baseUrl}category=video&tribe=mansaka',  // Original attempt
        '$_baseUrl?category=video&tribe=mansaka', // With query parameter format
        '$_baseUrl?tribe=mansaka',                // Just tribe filter
        _baseUrl,                              // All content
      ];

      http.Response? successResponse;
      
      for (String url in urls) {
        try {
          debugPrint('Trying URL: $url');
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 15));
          
          debugPrint('Response status for $url: ${response.statusCode}');
          debugPrint('Response body preview: ${response.body.substring(0, response.body.length < 200 ? response.body.length : 200)}...');
          
          if (response.statusCode == 200) {
            successResponse = response;
            break;
          }
        } catch (e) {
          debugPrint('Error with URL $url: $e');
          continue;
        }
      }

      if (successResponse == null) {
        throw Exception('All API endpoints failed to respond');
      }

      final Map<String, dynamic> jsonData = json.decode(successResponse.body);
      debugPrint('Parsed JSON keys: ${jsonData.keys.toList()}');
      
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }

      dynamic videoDataRaw = jsonData['data'];
      List<dynamic> videoData = [];
      
      if (videoDataRaw is List) {
        videoData = videoDataRaw;
      } else if (videoDataRaw != null) {
        videoData = [videoDataRaw];
      }

      debugPrint('Found ${videoData.length} items in response');

      final List<VideoItem> fetchedVideos = [];

      for (var item in videoData) {
        if (item == null) continue;
        
        debugPrint('Processing item: ${item.toString()}');
        
        // STRICT VALIDATION - Only include items that have ALL required fields from the API spec:
        
        // 1. Validate all required fields exist
        final id = item['id'];
        final userId = item['user_id'];
        final title = item['title']?.toString();
        final category = item['category']?.toString();
        final tribe = item['tribe']?.toString();
        final description = item['description']?.toString();
        final file = item['file']?.toString();
        final isArchived = item['is_archived'];
        final time = item['time']?.toString();
        
        // Check if any required field is missing
        if (id == null || userId == null || title == null || title.isEmpty ||
            category == null || category.isEmpty || tribe == null || tribe.isEmpty ||
            file == null || file.isEmpty || isArchived == null || time == null) {
          debugPrint('Skipping item - missing required fields:');
          debugPrint('  id: $id, user_id: $userId, title: $title');
          debugPrint('  category: $category, tribe: $tribe, file: $file');
          debugPrint('  is_archived: $isArchived, time: $time');
          continue;
        }
        
        // 2. Must be Mansaka tribe
        if (tribe.toLowerCase() != 'mansaka') {
          debugPrint('Skipping item - not Mansaka tribe: $tribe');
          continue;
        }

        // 3. Must NOT be archived
        if (isArchived != 0) {
          debugPrint('Skipping item - is archived: $title');
          continue;
        }

        // 4. Determine file type
        final fileType = _determineFileType(file);

        final videoItem = VideoItem(
          id: id.toString(),
          title: title,
          thumbnail: _buildThumbnailUrl(file),
          duration: _formatDuration(item['duration']), // This might not be in API response
          description: description ?? 'No description available',
          category: _mapCategory(category),
          file: file,
          fileType: fileType,
        );
        
        debugPrint('✅ Valid item added: $title (ID: $id, Category: $category, Type: $fileType)');
        fetchedVideos.add(videoItem);
      }

      debugPrint('Final video count after filtering: ${fetchedVideos.length}');

      setState(() {
        _allVideos = fetchedVideos;
        _featuredVideo = fetchedVideos.isNotEmpty ? fetchedVideos.first : null;
        _isLoading = false;
      });

      if (fetchedVideos.isEmpty) {
        debugPrint('No videos found - this might be expected if there are no Mansaka videos in the database');
      }

    } catch (e, stackTrace) {
      debugPrint('Error fetching videos: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load videos: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  String _buildThumbnailUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'assets/videos/thumbnails/default_thumbnail.jpg';
    }
    
    final String lowerFilename = filename.toLowerCase();
    
    // Check if it's a video file
    const videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv', '.flv', '.wmv'];
    bool isVideoFile = videoExtensions.any((ext) => lowerFilename.endsWith(ext));
    
    if (isVideoFile) {
      // For video files, you might want to generate thumbnails or use a placeholder
      return 'assets/videos/thumbnails/default_thumbnail.jpg';
    }
    
    // Check if it's an image file that can be used as thumbnail
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    bool isImageFile = imageExtensions.any((ext) => lowerFilename.endsWith(ext));
    
    if (isImageFile) {
      return '$_uploadsBaseUrl$filename';
    }
    
    return 'assets/videos/thumbnails/default_thumbnail.jpg';
  }

  FileType _determineFileType(String? filename) {
    if (filename == null || filename.isEmpty) {
      return FileType.unknown;
    }
    
    final String lowerFilename = filename.toLowerCase();
    
    const videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv', '.flv', '.wmv'];
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    const audioExtensions = ['.mp3', '.wav', '.aac', '.ogg', '.m4a'];
    
    if (videoExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.video;
    } else if (imageExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.image;
    } else if (audioExtensions.any((ext) => lowerFilename.endsWith(ext))) {
      return FileType.audio;
    }
    
    return FileType.unknown;
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return '--:--';
    
    if (duration is String) {
      if (duration.contains(':')) return duration;
      final int? seconds = int.tryParse(duration);
      if (seconds != null) {
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      }
    }
    
    if (duration is int) {
      final minutes = duration ~/ 60;
      final remainingSeconds = duration % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    
    return '--:--';
  }

  String _mapCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'artifact':
        return 'Cultural Artifact';
      case 'instrument':
        return 'Traditional Instrument';
      case 'audio':
        return 'Audio Recording';
      case 'image':
        return 'Image';
      default:
        return 'Media';
    }
  }

  Future<void> _refreshVideos() async {
    await _fetchVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
                      ? const Color(0xFFB19CD9) 
                      : const Color(0xFFB19CD9).withOpacity(0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isSearchFocused 
                        ? const Color(0xFFB19CD9)
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
                        _isHeaderVisible = true;
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFB19CD9),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Mansaka videos...',
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
      return Center(
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
              'Failed to load videos',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshVideos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB19CD9),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Mansaka videos available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshVideos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB19CD9),
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVideos,
      color: const Color(0xFFB19CD9),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (_featuredVideo != null)
            SliverToBoxAdapter(
              child: _buildFeaturedVideo(),
            ),
          SliverToBoxAdapter(
            child: _buildBrowseSection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = _allVideos[index];
                  return _buildVideoCard(video);
                },
                childCount: _allVideos.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredVideos.length} result${_filteredVideos.length == 1 ? '' : 's'} for "$_searchQuery"',
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
              : _filteredVideos.isEmpty
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
                            'No videos found',
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
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = _filteredVideos[index];
                        return _buildVideoCard(video);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFeaturedVideo() {
    if (_featuredVideo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _playVideo(_featuredVideo!);
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB19CD9),
                        Color(0xFF8B6DB0),
                      ],
                    ),
                  ),
                  child: _featuredVideo!.thumbnail.startsWith('http')
                      ? Image.network(
                          _featuredVideo!.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 60,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          _featuredVideo!.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 60,
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured: ${_featuredVideo!.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _featuredVideo!.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
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

  Widget _buildBrowseSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.video_library,
            color: Color(0xFFB19CD9),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Browse Mansaka videos',
            style: TextStyle(
              color: Color(0xFFB19CD9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _playVideo(video);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFB19CD9),
                              Color(0xFF8B6DB0),
                            ],
                          ),
                        ),
                        child: video.thumbnail.startsWith('http')
                            ? Image.network(
                                video.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                video.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            video.fileType == FileType.video 
                                ? Icons.play_arrow
                                : video.fileType == FileType.audio
                                    ? Icons.music_note
                                    : Icons.image,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF2A2A2A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            video.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB19CD9).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video.category,
                            style: const TextStyle(
                              color: Color(0xFFB19CD9),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  void _playVideo(VideoItem video) {
    // Validate that we have a playable video file
    if (video.file.isEmpty || video.fileType != FileType.video) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            video.fileType == FileType.audio 
                ? 'This is an audio file. Audio player not implemented yet.'
                : video.fileType == FileType.image
                    ? 'This is an image file, not a video.'
                    : 'Cannot play this file type.',
          ),
          backgroundColor: const Color(0xFFB19CD9),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoTitle: video.title,
          videoDescription: video.description,
          thumbnailPath: video.thumbnail,
          duration: video.duration,
          accentColor: const Color(0xFFB19CD9),
          tribalName: 'Mansaka',
          videoUrl: '$_uploadsBaseUrl${video.file}',
        ),
      ),
    );
  }
}

// Enum for file types
enum FileType {
  video,
  audio,
  image,
  unknown,
}

class VideoItem {
  final String id;
  final String title;
  final String thumbnail;
  final String duration;
  final String description;
  final String category;
  final String file;
  final FileType fileType;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.description,
    required this.category,
    required this.file,
    required this.fileType,
  });
}