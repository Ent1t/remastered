// 2. Updated Ata Manobo Detail Screen with Navigation
// lib/screen/ata_manobo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import your future screens here
// import 'ata_manobo_learn_more_screen.dart';
// import 'category_screens/ata_manobo_music_screen.dart';
// import 'category_screens/ata_manobo_video_screen.dart';
// import 'category_screens/ata_manobo_artifacts_screen.dart';
// import 'category_screens/ata_manobo_images_screen.dart';

class AtaManoboCulturalDetailScreen extends StatelessWidget {
  const AtaManoboCulturalDetailScreen({super.key});

  // Navigation methods
  void _navigateToLearnMore(BuildContext context) {
    // TODO: Uncomment when screen is created
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const AtaManoboCulturalLearnMoreScreen(),
    //   ),
    // );
    
    // Temporary placeholder navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Learn More screen will be implemented soon!'),
        backgroundColor: Color(0xFFD4A574),
      ),
    );
  }

  void _navigateToMusic(BuildContext context) {
    // TODO: Uncomment when screen is created
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const AtaManoboMusicScreen(),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Music screen will be implemented soon!'),
        backgroundColor: Color(0xFFD4A574),
      ),
    );
  }

  void _navigateToVideo(BuildContext context) {
    // TODO: Uncomment when screen is created
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const AtaManoboVideoScreen(),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video screen will be implemented soon!'),
        backgroundColor: Color(0xFFD4A574),
      ),
    );
  }

  void _navigateToArtifacts(BuildContext context) {
    // TODO: Uncomment when screen is created
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const AtaManoboArtifactsScreen(),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Artifacts screen will be implemented soon!'),
        backgroundColor: Color(0xFFD4A574),
      ),
    );
  }

  void _navigateToImages(BuildContext context) {
    // TODO: Uncomment when screen is created
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const AtaManoboImagesScreen(),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Images screen will be implemented soon!'),
        backgroundColor: Color(0xFFD4A574),
      ),
    );
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildInfoSection(),
              const SizedBox(height: 32),
              _buildCategoriesSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          // Background Image
          Container(
            height: 350,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.asset(
                'assets/images/ata_manobo_header.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B4513),
                          Color(0xFF654321),
                          Color(0xFF2F1B14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Dark Overlay
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          
          // Content Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
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
                  
                  // Title and Learn More
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATA MANOBO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Learn More Button - NOW FUNCTIONAL
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToLearnMore(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Learn more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.location_on,
              label: 'ORIGIN',
              value: 'Bukidnon,\nMisamis Oriental',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.groups,
              label: 'POPULATION',
              value: '~50,000',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.language,
              label: 'LANGUAGE',
              value: 'Ata\nManobo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4A574),
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4A574),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.explore,
                color: Color(0xFFD4A574),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  color: Color(0xFFD4A574),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        _buildCategoryCard(
          title: 'MUSIC',
          imagePath: 'assets/images/ata_manobo_music.jpg',
          gradientColors: const [Color(0xFF8B7355), Color(0xFF654321)],
          onTap: () => _navigateToMusic(context),
        ),
        
        _buildCategoryCard(
          title: 'VIDEO',
          imagePath: 'assets/images/ata_manobo_video.jpg',
          gradientColors: const [Color(0xFF6B5B47), Color(0xFF4A3D2A)],
          onTap: () => _navigateToVideo(context),
        ),
        
        _buildCategoryCard(
          title: 'ARTIFACTS',
          imagePath: 'assets/images/ata_manobo_artifacts.jpg',
          gradientColors: const [Color(0xFF5A6B7A), Color(0xFF3D4A5C)],
          onTap: () => _navigateToArtifacts(context),
        ),
        
        _buildCategoryCard(
          title: 'IMAGES',
          imagePath: 'assets/images/ata_manobo_images.jpg',
          gradientColors: const [Color(0xFF7A5A6B), Color(0xFF5C3D4A)],
          onTap: () => _navigateToImages(context),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      height: 120,
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
              onTap();
            },
            child: Row(
              children: [
                // Left side - Image
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradientColors,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(title),
                            color: Colors.white.withOpacity(0.7),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Right side - Title with gradient background
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          gradientColors[0].withOpacity(0.8),
                          gradientColors[1].withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
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

  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'video':
        return Icons.play_circle_outline;
      case 'artifacts':
        return Icons.museum;
      case 'images':
        return Icons.photo_library;
      default:
        return Icons.category;
    }
  }
}