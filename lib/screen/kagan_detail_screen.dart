import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import your future screens here
import 'learn_more_screen/kagan_learn_more_screen.dart';
import 'kagan_category_screens/kagan_music_screen.dart';
import 'kagan_category_screens/kagan_video_screen.dart';
import 'kagan_category_screens/kagan_artifacts_screen.dart';
import 'kagan_category_screens/kagan_event_screen.dart';

class KaganCulturalDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? contentData;
  
  const KaganCulturalDetailScreen({super.key, this.contentData});

  // Navigation methods
  void _navigateToLearnMore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KaganCulturalLearnMoreScreen(),
      ),
    );
  }

  void _navigateToMusic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KaganMusicScreen(),
      ),
    );
  }

  void _navigateToVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KaganVideoScreen(),
      ),
    );
  }
  
  void _navigateToArtifacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KaganArtifactsScreen(),
      ),
    );
  }

  void _navigateToImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KaganEventScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get content data from route arguments if not passed directly
    final data = contentData ?? 
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Check if we have QR scanned content data
    final bool hasQRContent = data != null && data.isNotEmpty;
    
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
              // Show QR content section if available, otherwise show regular header
              hasQRContent 
                ? _buildQRContentSection(context, data)
                : _buildHeaderSection(context),
              const SizedBox(height: 24),
              // Only show info section if no QR content (to avoid duplication)
              if (!hasQRContent) _buildInfoSection(),
              if (!hasQRContent) const SizedBox(height: 32),
              // Always show categories section
              _buildCategoriesSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // New method to display QR scanned content
  Widget _buildQRContentSection(BuildContext context, Map<String, dynamic> data) {
    String? fileUrl;
    if (data['file'] != null) {
      fileUrl = 'https://huni-cms.ionvop.com/uploads/${data['file']}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button and title
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'KAGAN CONTENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // QR Content Display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0D4BE).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                if (fileUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        fileUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE0D4BE),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF8B4513),
                                  Color(0xFF654321),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Content information
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        data['title'] ?? 'Kagan Cultural Content',
                        style: const TextStyle(
                          color: Color(0xFFE0D4BE),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Metadata row
                      Row(
                        children: [
                          _buildMetadataChip(
                            label: 'Category',
                            value: data['category']?.toString().toUpperCase() ?? 'ARTIFACT',
                            color: const Color(0xFF8B7355),
                          ),
                          const SizedBox(width: 8),
                          _buildMetadataChip(
                            label: 'Tribe',
                            value: data['tribe']?.toString().toUpperCase() ?? 'KAGAN',
                            color: const Color(0xFF654321),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description
                      if (data['description'] != null && 
                          data['description'].toString().trim().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                color: Color(0xFFE0D4BE),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['description'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Content ID info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.qr_code,
                              color: Color(0xFFE0D4BE),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Content ID: ${data['id']}',
                              style: const TextStyle(
                                color: Color(0xFFE0D4BE),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for metadata chips
  Widget _buildMetadataChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0D4BE),
                    width: 2,
                  ),
                ),
              ),
                child: Image.asset(
                  'assets/images/kagan_main.jpg',
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
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE0D4BE),
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
                  
                  // Title and Learn More with Container Box
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KAGAN title with minimal container
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
                          'KAGAN',
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
                      
                      const SizedBox(height: 16),
                      
                      // Learn More Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToLearnMore(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
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
              value: 'Kagan',
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
      height: 120, // Reduced height for smaller overall size
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF3A382F), // Fill color as specified
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0D4BE).withOpacity(0.3), // New border color
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              color: const Color(0xFFE0D4BE).withOpacity(0.2), // New accent color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE0D4BE), // New icon color
              size: 18, // Reduced icon size
            ),
          ),
          
          const SizedBox(height: 8), // Reduced spacing
          
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE0D4BE), // New label color
              fontSize: 8, // Reduced label size
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 4), // Reduced spacing
          
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10, // Reduced value size
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
                color: Color(0xFFE0D4BE), // Updated to new color
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  color: Color(0xFFE0D4BE), // Updated to new color
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
          imagePath: 'assets/images/kagan_music.jpg',
          gradientColors: const [Color(0xFF8B7355), Color(0xFF654321)],
          onTap: () => _navigateToMusic(context),
        ),
        
        _buildCategoryCard(
          title: 'VIDEO',
          imagePath: 'assets/images/kagan_video.jpg',
          gradientColors: const [Color(0xFF6B5B47), Color(0xFF4A3D2A)],
          onTap: () => _navigateToVideo(context),
        ),
        
        _buildCategoryCard(
          title: 'ARTIFACTS',
          imagePath: 'assets/images/kagan_artifacts.jpg',
          gradientColors: const [Color(0xFF5D4A37), Color(0xFF3D2F1F)], // Darker browns - 3rd level
          onTap: () => _navigateToArtifacts(context),
        ),
        
        _buildCategoryCard(
          title: 'EVENTS',
          imagePath: 'assets/images/kagan_images.jpg',
          gradientColors: const [Color(0xFF3D2F1F), Color(0xFF2A1F14)], // Darkest browns - 4th level
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