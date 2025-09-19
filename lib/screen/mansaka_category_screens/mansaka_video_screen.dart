// lib/screen/mansaka_category_screens/mansaka_video_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/video_player_screen.dart';

class MansakaVideoScreen extends StatefulWidget {
  const MansakaVideoScreen({super.key});

  @override
  State<MansakaVideoScreen> createState() => _MansakaVideoScreenState();
}

class _MansakaVideoScreenState extends State<MansakaVideoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample video data for Mansaka
  final List<VideoCategory> _videoCategories = [
    VideoCategory(
      title: 'Sacred Rituals',
      tag: 'Ritual',
      videos: [
        VideoItem(
          title: 'Ancestral Prayers',
          thumbnail: 'assets/videos/thumbnails/mansaka_ritual1.jpg',
          duration: '15:22',
        ),
        VideoItem(
          title: 'Healing Ceremony',
          thumbnail: 'assets/videos/thumbnails/mansaka_healing.jpg',
          duration: '9:45',
        ),
      ],
    ),
    VideoCategory(
      title: 'Traditional Music',
      tag: 'Music',
      videos: [
        VideoItem(
          title: 'Gong Ensemble',
          thumbnail: 'assets/videos/thumbnails/mansaka_gongs.jpg',
          duration: '6:30',
        ),
        VideoItem(
          title: 'Folk Songs',
          thumbnail: 'assets/videos/thumbnails/mansaka_songs.jpg',
          duration: '8:12',
        ),
      ],
    ),
    VideoCategory(
      title: 'Community Life',
      tag: 'Lifestyle',
      videos: [
        VideoItem(
          title: 'Tribal Council',
          thumbnail: 'assets/videos/thumbnails/mansaka_council.jpg',
          duration: '12:48',
        ),
        VideoItem(
          title: 'Youth Traditions',
          thumbnail: 'assets/videos/thumbnails/mansaka_youth.jpg',
          duration: '7:33',
        ),
      ],
    ),
  ];

  List<VideoCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _videoCategories;
    
    return _videoCategories.where((category) {
      return category.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             category.videos.any((video) => 
               video.title.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildHeader(),
              _buildSearchSection(),
              _buildFeaturedVideo(),
              _buildBrowseSection(),
              Expanded(child: _buildVideoCategories()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
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
          const Spacer(),
          const Text(
            'MANSAKA VIDEOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB19CD9).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Add filter functionality
              },
              icon: const Icon(
                Icons.tune,
                color: Color(0xFFB19CD9),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFB19CD9).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search videos',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedVideo() {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoTitle: 'Mansaka Heritage',
                    videoDescription: 'Exploring the spiritual traditions of the highlands',
                    thumbnailPath: 'assets/videos/thumbnails/mansaka_featured.jpg',
                    duration: '22:15',
                    accentColor: const Color(0xFFB19CD9),
                    tribalName: 'Mansaka',
                  ),
                ),
              );
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
                  child: Image.asset(
                    'assets/videos/thumbnails/mansaka_featured.jpg',
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
                      const Text(
                        'Featured: Mansaka Heritage',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Exploring the spiritual traditions of the highlands',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.video_library,
            color: Color(0xFFB19CD9),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Browse videos',
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

  Widget _buildVideoCategories() {
    final filteredCategories = _filteredCategories;
    
    if (filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return _buildCategorySection(category);
      },
    );
  }

  Widget _buildCategorySection(VideoCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFB19CD9).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB19CD9).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                category.tag,
                style: const TextStyle(
                  color: Color(0xFFB19CD9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.videos.length,
            itemBuilder: (context, index) {
              final video = category.videos[index];
              return _buildVideoCard(video);
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVideoCard(VideoItem video) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
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
                        child: Image.asset(
                          video.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 30,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF2A2A2A),
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoTitle: video.title,
          videoDescription: 'Traditional Mansaka cultural content',
          thumbnailPath: video.thumbnail,
          duration: video.duration,
          accentColor: const Color(0xFFB19CD9),
          tribalName: 'Mansaka',
        ),
      ),
    );
  }
}

class VideoCategory {
  final String title;
  final String tag;
  final List<VideoItem> videos;

  VideoCategory({
    required this.title,
    required this.tag,
    required this.videos,
  });
}

class VideoItem {
  final String title;
  final String thumbnail;
  final String duration;

  VideoItem({
    required this.title,
    required this.thumbnail,
    required this.duration,
  });
}