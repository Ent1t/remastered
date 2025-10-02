// lib/screen/mandaya_category_screens/mandaya_video_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../shared/video_player_screen.dart';
import '../../utils/video_metadata_cache.dart';

class MandayaVideoScreen extends StatefulWidget {
  const MandayaVideoScreen({super.key});

  @override
  State<MandayaVideoScreen> createState() => _MandayaVideoScreenState();
}

class _MandayaVideoScreenState extends State<MandayaVideoScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;
  double _lastScrollOffset = 0;

  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/content/';
  static const String _uploadsBaseUrl = 'https://huni-cms.ionvop.com/uploads/';
  List<VideoItem> _allVideos = [];
  bool _isLoading = true;
  String? _errorMessage;
  VideoItem? _featuredVideo;
  
  final Set<String> _loadingMetadata = {};

  List<VideoItem> get _filteredVideos {
    if (_searchQuery.isEmpty) {
      return _allVideos;
    }
    
    return _allVideos.where((video) =>
        video.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        video.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        video.category.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // Enhanced responsive helper methods (from Kagan)
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 2;
  }

  // FIXED: More flexible childAspectRatio that accounts for content
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(context);
    
    // Calculate available width per item
    final horizontalPadding = _getHorizontalPadding(context);
    final spacing = _getGridSpacing(context);
    final availableWidth = width - (horizontalPadding * 2) - (spacing * (crossAxisCount - 1));
    final itemWidth = availableWidth / crossAxisCount;
    
    // Dynamic height based on item width - more generous for smaller screens
    final itemHeight = itemWidth * 1.4; // Increased from 1.35 to 1.4 for more vertical room
    
    return itemWidth / itemHeight;
  }

  // FIXED: Responsive padding that scales more conservatively
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return width * 0.025; // 2.5% of width
    if (width > 800) return width * 0.02; // 2% of width
    return width * 0.04; // 4% of width (reduced from fixed 16)
  }

  // NEW: Responsive grid spacing
  double _getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 16;
    if (width > 800) return 12;
    return 10; // Reduced from 16 to save space on small screens
  }

  // FIXED: More conservative featured video height
  double _getFeaturedVideoHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isLandscape = width > height;
    
    // Use percentage of screen height for better scaling
    if (width > 1200) return height * 0.35;
    if (width > 800) return height * 0.3;
    if (isLandscape) return height * 0.35;
    return height * 0.25; // Reduced from fixed 200
  }

  double _getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return baseSize * 1.15;
    if (width > 800) return baseSize * 1.08;
    if (width < 360) return baseSize * 0.95; // Scale down on very small screens
    return baseSize;
  }

  // NEW: Responsive header height
  double _getHeaderHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 80;
    if (width < 360) return 65;
    return 72;
  }

  // NEW: Responsive vertical spacing
  double _getVerticalSpacing(BuildContext context, double baseSpacing) {
    final height = MediaQuery.of(context).size.height;
    if (height < 700) return baseSpacing * 0.75; // Reduce on short screens
    return baseSpacing;
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

      List<String> urls = [
        '${_baseUrl}category=video&tribe=mandaya',
        '$_baseUrl?category=video&tribe=mandaya',
        '$_baseUrl?tribe=mandaya',
        _baseUrl,
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

      final List<VideoItem> fetchedVideos = [];

      for (var item in videoData) {
        if (item == null) continue;
        
        final id = item['id'];
        final userId = item['user_id'];
        final title = item['title']?.toString();
        final category = item['category']?.toString();
        final tribe = item['tribe']?.toString();
        final description = item['description']?.toString();
        final file = item['file']?.toString();
        final isArchived = item['is_archived'];
        final time = item['time']?.toString();
        
        if (id == null || userId == null || title == null || title.isEmpty ||
            category == null || category.isEmpty || tribe == null || tribe.isEmpty ||
            file == null || file.isEmpty || isArchived == null || time == null) {
          continue;
        }
        
        if (tribe.toLowerCase() != 'mandaya') {
          continue;
        }

        if (isArchived != 0) {
          continue;
        }

        final fileType = _determineFileType(file);
        final videoUrl = '$_uploadsBaseUrl$file';
        
        final cachedDuration = await VideoMetadataCache.getDuration(id.toString());
        final cachedThumbnail = await VideoMetadataCache.getThumbnail(id.toString());

        final videoItem = VideoItem(
          id: id.toString(),
          title: title,
          thumbnail: cachedThumbnail ?? _buildThumbnailUrl(file),
          duration: cachedDuration ?? '--:--',
          description: description ?? 'No description available',
          category: _mapCategory(category),
          file: file,
          fileType: fileType,
          videoUrl: videoUrl,
        );
        
        debugPrint('✅ Valid item added: $title (Cached: duration=${cachedDuration != null}, thumbnail=${cachedThumbnail != null})');
        fetchedVideos.add(videoItem);
      }

      setState(() {
        _allVideos = fetchedVideos;
        _featuredVideo = fetchedVideos.isNotEmpty ? fetchedVideos.first : null;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      debugPrint('Error fetching videos: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load videos: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideoMetadata(VideoItem video) async {
    if (video.fileType != FileType.video || 
        video.duration != '--:--' || 
        _loadingMetadata.contains(video.id)) {
      return;
    }
    
    _loadingMetadata.add(video.id);
    
    VideoPlayerController? tempController;
    try {
      debugPrint('📥 Loading metadata for: ${video.title}');
      
      tempController = VideoPlayerController.networkUrl(
        Uri.parse(video.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      
      await tempController.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout loading video metadata');
        },
      );
      
      if (tempController.value.duration.inSeconds > 0) {
        final minutes = tempController.value.duration.inMinutes;
        final seconds = tempController.value.duration.inSeconds % 60;
        final duration = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        await VideoMetadataCache.saveDuration(video.id, duration);
        
        if (mounted) {
          setState(() {
            video.duration = duration;
          });
        }
        debugPrint('✅ Duration loaded and cached for ${video.title}: $duration');
      }
      
      try {
        final thumbnailDir = await getApplicationDocumentsDirectory();
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: video.videoUrl,
          thumbnailPath: '${thumbnailDir.path}/thumbnails',
          imageFormat: ImageFormat.JPEG,
          maxWidth: 320,
          quality: 75,
          timeMs: 1000,
        );
        
        if (thumbnailPath != null && await File(thumbnailPath).exists()) {
          await VideoMetadataCache.saveThumbnail(video.id, thumbnailPath);
          
          if (mounted) {
            setState(() {
              video.thumbnail = thumbnailPath;
            });
          }
          debugPrint('✅ Thumbnail generated and cached for ${video.title}');
        }
      } catch (e) {
        debugPrint('⚠️ Error generating thumbnail for ${video.title}: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Error loading metadata for ${video.title}: $e');
      if (mounted) {
        setState(() {
          video.duration = 'N/A';
        });
      }
    } finally {
      tempController?.dispose();
      _loadingMetadata.remove(video.id);
    }
  }

  String _buildThumbnailUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'assets/videos/thumbnails/default_thumbnail.jpg';
    }
    
    final String lowerFilename = filename.toLowerCase();
    const videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv', '.flv', '.wmv'];
    bool isVideoFile = videoExtensions.any((ext) => lowerFilename.endsWith(ext));
    
    if (isVideoFile) {
      return 'assets/videos/thumbnails/default_thumbnail.jpg';
    }
    
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
    _loadingMetadata.clear();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getHorizontalPadding(context);
    final headerHeight = _getHeaderHeight(context);
    
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
              // FIXED: Dynamic header height
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: (_isHeaderVisible || _isSearchFocused) ? headerHeight : 0,
                child: (_isHeaderVisible || _isSearchFocused) 
                    ? _buildHeader(context, horizontalPadding) 
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: _isSearchFocused 
                    ? _buildSearchResults(horizontalPadding)
                    : _buildMainContent(horizontalPadding),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double horizontalPadding) {
    final verticalPadding = _getVerticalSpacing(context, 12);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: verticalPadding
      ),
      child: Row(
        children: [
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSearchFocused ? 0 : 12, // Reduced from 16
          ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getFontSize(context, 14),
                ),
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: _getFontSize(context, 14),
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
                        fontSize: _getFontSize(context, 14),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(double horizontalPadding) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
            ),
            SizedBox(height: _getVerticalSpacing(context, 16)),
            Text(
              'Loading Mandaya videos...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: _getFontSize(context, 14),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              SizedBox(height: _getVerticalSpacing(context, 16)),
              Text(
                'Failed to load videos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: _getFontSize(context, 18),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: _getVerticalSpacing(context, 8)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: _getFontSize(context, 14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: _getVerticalSpacing(context, 24)),
              ElevatedButton(
                onPressed: _refreshVideos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7FB069),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: _getVerticalSpacing(context, 12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: _getFontSize(context, 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_allVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: _getVerticalSpacing(context, 16)),
            Text(
              'No Mandaya videos available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: _getFontSize(context, 18),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: _getVerticalSpacing(context, 8)),
            Text(
              'Check back later for new content',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: _getFontSize(context, 14),
              ),
            ),
            SizedBox(height: _getVerticalSpacing(context, 24)),
            ElevatedButton(
              onPressed: _refreshVideos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FB069),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: _getVerticalSpacing(context, 12),
                ),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(fontSize: _getFontSize(context, 14)),
              ),
            ),
          ],
        ),
      );
    }

    final gridSpacing = _getGridSpacing(context);

    return RefreshIndicator(
      onRefresh: _refreshVideos,
      color: const Color(0xFF7FB069),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (_featuredVideo != null)
            SliverToBoxAdapter(
              child: _buildFeaturedVideo(horizontalPadding),
            ),
          SliverToBoxAdapter(
            child: _buildBrowseSection(horizontalPadding),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: gridSpacing,
                mainAxisSpacing: gridSpacing,
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
          SliverToBoxAdapter(
            child: SizedBox(height: _getVerticalSpacing(context, 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(double horizontalPadding) {
    final gridSpacing = _getGridSpacing(context);
    
    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, 
              vertical: _getVerticalSpacing(context, 8)
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${_filteredVideos.length} result${_filteredVideos.length == 1 ? '' : 's'} for "$_searchQuery"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: _getFontSize(context, 14),
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      fontSize: _getFontSize(context, 16),
                    ),
                  ),
                )
              : _filteredVideos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: _getVerticalSpacing(context, 16)),
                          Text(
                            'No videos found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: _getFontSize(context, 18),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: _getVerticalSpacing(context, 8)),
                          Text(
                            'Try different keywords',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: _getFontSize(context, 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: _getChildAspectRatio(context),
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
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

  Widget _buildFeaturedVideo(double horizontalPadding) {
    if (_featuredVideo == null) return const SizedBox.shrink();

    final featuredHeight = _getFeaturedVideoHeight(context);
    final cardPadding = horizontalPadding * 0.75; // Proportional padding

    return Container(
      margin: EdgeInsets.all(cardPadding),
      height: featuredHeight,
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
                        Color(0xFF7FB069),
                        Color(0xFF5D8A47),
                      ],
                    ),
                  ),
                  child: _buildThumbnailImage(_featuredVideo!),
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
                  bottom: cardPadding,
                  left: cardPadding,
                  right: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Featured: ${_featuredVideo!.title}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _getVerticalSpacing(context, 4)),
                      Text(
                        _featuredVideo!.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: _getFontSize(context, 14),
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

  Widget _buildBrowseSection(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: _getVerticalSpacing(context, 12)
      ),
      child: Row(
        children: [
          const Icon(
            Icons.video_library,
            color: Color(0xFF7FB069),
            size: 20,
          ),
          SizedBox(width: _getVerticalSpacing(context, 8)),
          Flexible(
            child: Text(
              'Browse Mandaya videos',
              style: TextStyle(
                color: const Color(0xFF7FB069),
                fontSize: _getFontSize(context, 16),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Complete video card rewrite with proper constraints (from Kagan)
  Widget _buildVideoCard(VideoItem video) {
    return VisibilityDetector(
      key: Key('video_${video.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && video.duration == '--:--') {
          _loadVideoMetadata(video);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate heights dynamically based on available space
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          
          // Image should take 60% of card height
          final imageHeight = cardHeight * 0.6;
          // Info section takes remaining 40%
          final infoHeight = cardHeight * 0.4;
          
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // FIXED: Use SizedBox with explicit height instead of Expanded
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
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
                                    Color(0xFF7FB069),
                                    Color(0xFF5D8A47),
                                  ],
                                ),
                              ),
                              child: _buildThumbnailImage(video),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (video.duration == '--:--' && _loadingMetadata.contains(video.id))
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: SizedBox(
                                          width: 8,
                                          height: 8,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                      ),
                                    Text(
                                      video.duration,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _getFontSize(context, 10),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(cardWidth * 0.08), // Proportional padding
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
                                  size: cardWidth * 0.15, // Proportional icon size
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // FIXED: Use SizedBox with explicit height - NO Flexible/Expanded
                      SizedBox(
                        height: infoHeight,
                        width: double.infinity,
                        child: Container(
                          padding: EdgeInsets.all(cardWidth * 0.035), // Reduced padding
                          color: const Color(0xFF2A2A2A),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // FIXED: Removed Flexible wrappers - direct Text with constraints
                              Text(
                                video.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _getFontSize(context, 12), // Reduced from 13
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: cardHeight * 0.005), // Reduced spacing
                              Text(
                                video.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: _getFontSize(context, 10), // Reduced from 11
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // FIXED: Spacer pushes category to bottom naturally
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: cardWidth * 0.02, // Reduced padding
                                  vertical: cardHeight * 0.006, // Reduced padding
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7FB069).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  video.category,
                                  style: TextStyle(
                                    color: const Color(0xFF7FB069),
                                    fontSize: _getFontSize(context, 9), // Reduced from 10
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
        },
      ),
    );
  }

  Widget _buildThumbnailImage(VideoItem video) {
    if (video.thumbnail.startsWith('/data') || video.thumbnail.startsWith('/storage')) {
      return Image.file(
        File(video.thumbnail),
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
      );
    }
    
    if (video.thumbnail.startsWith('http')) {
      return Image.network(
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
      );
    }
    
    return Image.asset(
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
    );
  }

  void _playVideo(VideoItem video) {
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
          backgroundColor: const Color(0xFF7FB069),
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
          accentColor: const Color(0xFF7FB069),
          tribalName: 'Mandaya',
          videoUrl: video.videoUrl,
        ),
      ),
    );
  }
}

enum FileType {
  video,
  audio,
  image,
  unknown,
}

class VideoItem {
  final String id;
  final String title;
  String thumbnail;
  String duration;
  final String description;
  final String category;
  final String file;
  final FileType fileType;
  final String videoUrl;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.description,
    required this.category,
    required this.file,
    required this.fileType,
    required this.videoUrl,
  });
}