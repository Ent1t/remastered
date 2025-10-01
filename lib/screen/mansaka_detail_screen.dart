// Responsive lib/screen/mansaka_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'learn_more_screen/mansaka_learn_more_screen.dart';
import 'mansaka_category_screens/mansaka_music_screen.dart';
import 'mansaka_category_screens/mansaka_video_screen.dart';
import 'mansaka_category_screens/mansaka_artifacts_screen.dart';
import 'mansaka_category_screens/mansaka_event_screen.dart';

class MansakaCulturalDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? contentData;
  
  const MansakaCulturalDetailScreen({super.key, this.contentData});

  // Navigation methods
  void _navigateToLearnMore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MansakaCulturalLearnMoreScreen(),
      ),
    );
  }

  void _navigateToMusic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MansakaMusicScreen(),
      ),
    );
  }

  void _navigateToVideo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MansakaVideoScreen(),
      ),
    );
  }

  void _navigateToArtifacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MansakaArtifactsScreen(),
      ),
    );
  }

  void _navigateToImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MansakaEventScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final maxWidth = isTablet ? 800.0 : size.width;
    
    final data = contentData ?? 
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hasQRContent 
                    ? _buildQRContentSection(context, data, size, isTablet)
                    : _buildHeaderSection(context, size, isTablet),
                  SizedBox(height: size.height * 0.03),
                  if (!hasQRContent) _buildInfoSection(size, isTablet),
                  if (!hasQRContent) SizedBox(height: size.height * 0.04),
                  _buildCategoriesSection(context, size, isTablet),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRContentSection(BuildContext context, Map<String, dynamic> data, Size size, bool isTablet) {
    String? fileUrl;
    if (data['file'] != null) {
      fileUrl = 'https://huni-cms.ionvop.com/uploads/${data['file']}';
    }

    final horizontalPadding = isTablet ? 40.0 : 20.0;
    final imageHeight = size.height * 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
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
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: isTablet ? 24 : 20,
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
                    child: Text(
                      'MANSAKA CONTENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
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

        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC4A8E8).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fileUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Image.network(
                        fileUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: imageHeight,
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFC4A8E8),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: imageHeight,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF5D4E75),
                                  Color(0xFF3F325A),
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

                Padding(
                  padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Mansaka Cultural Content',
                        style: TextStyle(
                          color: const Color(0xFFC4A8E8),
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: isTablet ? 16 : 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetadataChip(
                            label: 'Category',
                            value: data['category']?.toString().toUpperCase() ?? 'ARTIFACT',
                            color: const Color(0xFFB19CD9),
                            isTablet: isTablet,
                          ),
                          _buildMetadataChip(
                            label: 'Tribe',
                            value: data['tribe']?.toString().toUpperCase() ?? 'MANSAKA',
                            color: const Color(0xFF9B59B6),
                            isTablet: isTablet,
                          ),
                        ],
                      ),

                      SizedBox(height: isTablet ? 20 : 16),

                      if (data['description'] != null && 
                          data['description'].toString().trim().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: const Color(0xFFC4A8E8),
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            Text(
                              data['description'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 16 : 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: isTablet ? 24 : 20),

                      Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: const Color(0xFFC4A8E8),
                              size: isTablet ? 20 : 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Content ID: ${data['id']}',
                                style: TextStyle(
                                  color: const Color(0xFFC4A8E8),
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
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

  Widget _buildMetadataChip({
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
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
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Size size, bool isTablet) {
    final headerHeight = size.height * 0.35;
    final horizontalPadding = isTablet ? 40.0 : 20.0;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        children: [
          SizedBox(
            height: headerHeight,
            width: double.infinity,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFC4A8E8),
                    width: 2,
                  ),
                ),
              ),
              child: Image.asset(
                'assets/images/mansaka.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5D4E75),
                          Color(0xFF3F325A),
                          Color(0xFF2A1F3D),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFC4A8E8),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          Container(
            height: headerHeight,
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
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MANSAKA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 48 : 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: const [
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
                  
                  SizedBox(height: isTablet ? 20 : 16),
                  
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: isTablet ? 20.0 : 16.0),
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
                          child: Text(
                            'Learn more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 20 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Size size, bool isTablet) {
    final horizontalPadding = isTablet ? 40.0 : 20.0;
    final cardHeight = isTablet ? 140.0 : 120.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.location_on,
              label: 'ORIGIN',
              value: 'Davao de Oro,\nCompostela Valley',
              cardHeight: cardHeight,
              isTablet: isTablet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.groups,
              label: 'POPULATION',
              value: '~60,000',
              cardHeight: cardHeight,
              isTablet: isTablet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.language,
              label: 'LANGUAGE',
              value: 'Mansaka',
              cardHeight: cardHeight,
              isTablet: isTablet,
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
    required double cardHeight,
    required bool isTablet,
  }) {
    return Container(
      height: cardHeight,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC4A8E8).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              color: const Color(0xFFC4A8E8).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC4A8E8),
              size: isTablet ? 22 : 18,
            ),
          ),
          
          SizedBox(height: isTablet ? 10 : 8),
          
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFC4A8E8),
              fontSize: isTablet ? 10 : 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          
          SizedBox(height: isTablet ? 6 : 4),
          
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 12 : 10,
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

  Widget _buildCategoriesSection(BuildContext context, Size size, bool isTablet) {
    final horizontalPadding = isTablet ? 40.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Icon(
                Icons.explore,
                color: const Color(0xFFC4A8E8),
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'EXPLORE CATEGORIES',
                style: TextStyle(
                  color: const Color(0xFFC4A8E8),
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isTablet ? 24 : 20),
        
      _buildCategoryCard(
        title: 'MUSIC',
        imagePath: 'assets/images/mansaka_music.jpg',
        gradientColors: const [Color(0xFFB19CD9), Color(0xFF9B59B6)],
        onTap: () => _navigateToMusic(context),
        horizontalPadding: horizontalPadding,
        isTablet: isTablet,
      ),
      
      _buildCategoryCard(
        title: 'VIDEO',
        imagePath: 'assets/images/mansaka_video.jpg',
        gradientColors: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        onTap: () => _navigateToVideo(context),
        horizontalPadding: horizontalPadding,
        isTablet: isTablet,
      ),
      
      _buildCategoryCard(
        title: 'ARTIFACTS',
        imagePath: 'assets/images/mansaka_artifacts.jpg',
        gradientColors: const [Color(0xFF8E44AD), Color(0xFF663399)],
        onTap: () => _navigateToArtifacts(context),
        horizontalPadding: horizontalPadding,
        isTablet: isTablet,
      ),
      
      _buildCategoryCard(
        title: 'EVENTS',
        imagePath: 'assets/images/mansaka_images.jpg',
        gradientColors: const [Color(0xFF663399), Color(0xFF4A1A4A)],
        onTap: () => _navigateToImages(context),
        horizontalPadding: horizontalPadding,
        isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required double horizontalPadding,
    required bool isTablet,
  }) {
    final cardHeight = isTablet ? 140.0 : 120.0;
    final imageWidth = isTablet ? 140.0 : 120.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16, left: horizontalPadding, right: horizontalPadding),
      height: cardHeight,
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
                SizedBox(
                  width: imageWidth,
                  height: cardHeight,
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
                            size: isTablet ? 50 : 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                Expanded(
                  child: Container(
                    height: cardHeight,
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 28 : 24,
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