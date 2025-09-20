// Updated lib/screen/mandaya_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: Import your future screens here when created
import 'learn_more_screen/mandaya_learn_more_screen.dart';
import 'mandaya_category_screens/mandaya_music_screen.dart';
import 'mandaya_category_screens/mandaya_video_screen.dart';
import 'mandaya_category_screens/mandaya_artifacts_screen.dart';
import 'mandaya_category_screens/mandaya_images_screen.dart';

class MandayaCulturalDetailScreen extends StatelessWidget {
  const MandayaCulturalDetailScreen({super.key});

  // Navigation methods
  void _navigateToLearnMore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MandayaCulturalLearnMoreScreen(),
      ),
    );
  }

  void _navigateToMusic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MandayaMusicScreen(),
      ),
    );
  }

  void _navigateToVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MandayaVideoScreen(),
      ),
    );
  }

  void _navigateToArtifacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MandayaArtifactsScreen(),
      ),
    );
  }

  void _navigateToImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MandayaImagesScreen(),
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
      height: 280, // Reduced from 350
      child: Stack(
        children: [
          // Background Image
          SizedBox(
            height: 280, // Reduced from 350
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF8FC475), // Brighter green border
                    width: 2,
                  ),
                ),
              ),
              child: Image.asset(
                'assets/images/mandaya.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4A5D23),
                          Color(0xFF2F3E15),
                          Color(0xFF1A2209),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF8FC475), // Brighter green border
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Dark Overlay
          Container(
            height: 280, // Reduced from 350
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
                  
                  // Title only (Learn More moved to bottom)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MANDAYA title with minimal container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MANDAYA',
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
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Learn More Button - moved to bottom left
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0), // Tab spacing like MS Word
                      child: GestureDetector(
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
                    ),
                  ),
                  
                  const SizedBox(height: 16),
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
              value: 'Davao Oriental,\nCaraga Region',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.groups,
              label: 'POPULATION',
              value: '~40,000',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.language,
              label: 'LANGUAGE',
              value: 'Mandaya',
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
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Original color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8FC475).withOpacity(0.3), // Brighter green border
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8FC475).withOpacity(0.2), // Brighter green accent
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8FC475), // Brighter green icon
              size: 18,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8FC475), // Brighter green label
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                color: Color(0xFF8FC475), // Brighter green color
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  color: Color(0xFF8FC475), // Brighter green color
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
          imagePath: 'assets/images/mandaya_music.jpg',
          gradientColors: const [Color(0xFF7FB069), Color(0xFF5D8A47)],
          onTap: () => _navigateToMusic(context),
        ),
        
        _buildCategoryCard(
          title: 'VIDEO',
          imagePath: 'assets/images/mandaya_video.jpg',
          gradientColors: const [Color(0xFF6B8E23), Color(0xFF556B2F)],
          onTap: () => _navigateToVideo(context),
        ),
        
        _buildCategoryCard(
          title: 'ARTIFACTS',
          imagePath: 'assets/images/mandaya_artifacts.jpg',
          gradientColors: const [Color(0xFF8FBC8F), Color(0xFF6B8E6B)],
          onTap: () => _navigateToArtifacts(context),
        ),
        
        _buildCategoryCard(
          title: 'IMAGES',
          imagePath: 'assets/images/mandaya_images.jpg',
          gradientColors: const [Color(0xFF9ACD32), Color(0xFF7B9A2D)],
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