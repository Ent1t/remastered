import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'learn_more_screen/kagan_learn_more_screen.dart';
import 'kagan_category_screens/kagan_music_screen.dart';
import 'kagan_category_screens/kagan_video_screen.dart';
import 'kagan_category_screens/kagan_artifacts_screen.dart';
import 'kagan_category_screens/kagan_event_screen.dart';

class KaganCulturalDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? contentData;
  
  const KaganCulturalDetailScreen({super.key, this.contentData});

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hasQRContent 
                ? _buildQRContentSection(context, data, screenWidth, screenHeight)
                : _buildHeaderSection(context, screenWidth, screenHeight),
              SizedBox(height: (screenHeight * 0.03).clamp(12.0, 30.0)),
              if (!hasQRContent) _buildInfoSection(screenWidth, screenHeight),
              if (!hasQRContent) SizedBox(height: (screenHeight * 0.04).clamp(16.0, 40.0)),
              _buildCategoriesSection(context, screenWidth, screenHeight),
              SizedBox(height: (screenHeight * 0.05).clamp(20.0, 50.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRContentSection(BuildContext context, Map<String, dynamic> data, double screenWidth, double screenHeight) {
    String? fileUrl;
    if (data['file'] != null) {
      fileUrl = 'https://huni-cms.ionvop.com/uploads/${data['file']}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.05).clamp(12.0, 24.0),
              vertical: (screenHeight * 0.02).clamp(8.0, 20.0),
            ),
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
                      size: (screenWidth * 0.05).clamp(18.0, 24.0),
                    ),
                  ),
                ),
                SizedBox(width: (screenWidth * 0.04).clamp(12.0, 20.0)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: (screenWidth * 0.03).clamp(8.0, 16.0),
                      vertical: (screenHeight * 0.008).clamp(4.0, 10.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'KAGAN CONTENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (screenWidth * 0.05).clamp(16.0, 22.0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05).clamp(12.0, 24.0)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: (screenHeight * 0.3).clamp(200.0, 400.0),
            ),
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
                if (fileUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (screenHeight * 0.2).clamp(150.0, 250.0),
                        maxHeight: (screenHeight * 0.3).clamp(200.0, 300.0),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          fileUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: (screenHeight * 0.25).clamp(150.0, 250.0),
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
                              height: (screenHeight * 0.25).clamp(150.0, 250.0),
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
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: (screenWidth * 0.15).clamp(40.0, 60.0),
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: EdgeInsets.all((screenWidth * 0.05).clamp(12.0, 24.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'Kagan Cultural Content',
                        style: TextStyle(
                          color: const Color(0xFFE0D4BE),
                          fontSize: (screenWidth * 0.06).clamp(18.0, 28.0),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: (screenHeight * 0.015).clamp(8.0, 16.0)),

                      Wrap(
                        spacing: (screenWidth * 0.02).clamp(6.0, 12.0),
                        runSpacing: (screenHeight * 0.01).clamp(4.0, 8.0),
                        children: [
                          _buildMetadataChip(
                            label: 'Category',
                            value: data['category']?.toString().toUpperCase() ?? 'ARTIFACT',
                            color: const Color(0xFF8B7355),
                            screenWidth: screenWidth,
                          ),
                          _buildMetadataChip(
                            label: 'Tribe',
                            value: data['tribe']?.toString().toUpperCase() ?? 'KAGAN',
                            color: const Color(0xFF654321),
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),

                      SizedBox(height: (screenHeight * 0.02).clamp(10.0, 20.0)),

                      if (data['description'] != null && 
                          data['description'].toString().trim().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: const Color(0xFFE0D4BE),
                                fontSize: (screenWidth * 0.04).clamp(14.0, 20.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),
                            Text(
                              data['description'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                                height: 1.5,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                      SizedBox(height: (screenHeight * 0.025).clamp(12.0, 24.0)),

                      Container(
                        padding: EdgeInsets.all((screenWidth * 0.03).clamp(8.0, 16.0)),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: const Color(0xFFE0D4BE),
                              size: (screenWidth * 0.04).clamp(14.0, 20.0),
                            ),
                            SizedBox(width: (screenWidth * 0.02).clamp(6.0, 12.0)),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Content ID: ${data['id']}',
                                  style: TextStyle(
                                    color: const Color(0xFFE0D4BE),
                                    fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                                    fontWeight: FontWeight.w500,
                                  ),
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
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.02).clamp(6.0, 12.0),
        vertical: (screenWidth * 0.01).clamp(4.0, 8.0),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double screenWidth, double screenHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.35).clamp(250.0, 400.0),
        maxHeight: (screenHeight * 0.45).clamp(300.0, 500.0),
      ),
      child: Stack(
        children: [
          SizedBox(
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
                'assets/images/kagan.jpg',
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
          
          Container(
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
              padding: EdgeInsets.symmetric(
                horizontal: (screenWidth * 0.05).clamp(12.0, 24.0),
                vertical: (screenHeight * 0.02).clamp(8.0, 20.0),
              ),
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
                        size: (screenWidth * 0.05).clamp(18.0, 24.0),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth * 0.03).clamp(8.0, 16.0),
                          vertical: (screenHeight * 0.008).clamp(4.0, 10.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'KAGAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.09).clamp(28.0, 42.0),
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
                      ),
                      
                      SizedBox(height: (screenHeight * 0.02).clamp(10.0, 20.0)),
                      
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToLearnMore(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: (screenWidth * 0.005).clamp(2.0, 6.0),
                            vertical: (screenHeight * 0.001).clamp(1.0, 4.0),
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Learn more',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: (screenHeight * 0.03).clamp(12.0, 30.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05).clamp(12.0, 24.0)),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              icon: Icons.location_on,
              label: 'ORIGIN',
              value: 'Bukidnon,\nMisamis Oriental',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
          SizedBox(width: (screenWidth * 0.03).clamp(8.0, 16.0)),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.groups,
              label: 'POPULATION',
              value: '~50,000',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
          SizedBox(width: (screenWidth * 0.03).clamp(8.0, 16.0)),
          Expanded(
            child: _buildInfoCard(
              icon: Icons.language,
              label: 'LANGUAGE',
              value: 'Kagan',
              screenWidth: screenWidth,
              screenHeight: screenHeight,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.12).clamp(100.0, 150.0),
        maxHeight: (screenHeight * 0.18).clamp(120.0, 180.0),
      ),
      padding: EdgeInsets.all((screenWidth * 0.03).clamp(8.0, 16.0)),
      decoration: BoxDecoration(
        color: const Color(0xFF3A382F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0D4BE).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all((screenWidth * 0.015).clamp(4.0, 8.0)),
            decoration: BoxDecoration(
              color: const Color(0xFFE0D4BE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE0D4BE),
              size: (screenWidth * 0.045).clamp(16.0, 22.0),
            ),
          ),
          
          SizedBox(height: (screenHeight * 0.01).clamp(4.0, 10.0)),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFFE0D4BE),
                fontSize: (screenWidth * 0.02).clamp(9.0, 12.0),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          
          SizedBox(height: (screenHeight * 0.005).clamp(2.0, 6.0)),
          
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth * 0.025).clamp(10.0, 14.0),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.05).clamp(12.0, 24.0)),
          child: Row(
            children: [
              Icon(
                Icons.explore,
                color: const Color(0xFFE0D4BE),
                size: (screenWidth * 0.05).clamp(18.0, 24.0),
              ),
              SizedBox(width: (screenWidth * 0.02).clamp(6.0, 12.0)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'EXPLORE CATEGORIES',
                    style: TextStyle(
                      color: const Color(0xFFE0D4BE),
                      fontSize: (screenWidth * 0.04).clamp(14.0, 20.0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: (screenHeight * 0.025).clamp(12.0, 24.0)),
        
        _buildCategoryCard(
          title: 'MUSIC',
          imagePath: 'assets/images/kagan_music.jpg',
          gradientColors: const [Color(0xFF8B7355), Color(0xFF654321)],
          onTap: () => _navigateToMusic(context),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        
        _buildCategoryCard(
          title: 'VIDEO',
          imagePath: 'assets/images/kagan_video.jpg',
          gradientColors: const [Color(0xFF6B5B47), Color(0xFF4A3D2A)],
          onTap: () => _navigateToVideo(context),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        
        _buildCategoryCard(
          title: 'ARTIFACTS',
          imagePath: 'assets/images/kagan_artifacts.jpg',
          gradientColors: const [Color(0xFF5D4A37), Color(0xFF3D2F1F)],
          onTap: () => _navigateToArtifacts(context),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
        
        _buildCategoryCard(
          title: 'EVENTS',
          imagePath: 'assets/images/kagan_images.jpg',
          gradientColors: const [Color(0xFF3D2F1F), Color(0xFF2A1F14)],
          onTap: () => _navigateToImages(context),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: (screenHeight * 0.02).clamp(10.0, 20.0),
        left: (screenWidth * 0.05).clamp(12.0, 24.0),
        right: (screenWidth * 0.05).clamp(12.0, 24.0),
      ),
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.12).clamp(100.0, 140.0),
        maxHeight: (screenHeight * 0.18).clamp(120.0, 180.0),
      ),
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
                  width: (screenWidth * 0.3).clamp(100.0, 150.0),
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
                            size: (screenWidth * 0.1).clamp(32.0, 48.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                Expanded(
                  child: Container(
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (screenWidth * 0.02).clamp(6.0, 12.0),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.06).clamp(18.0, 28.0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
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
      case 'events':
        return Icons.event;
      case 'images':
        return Icons.photo_library;
      default:
        return Icons.category;
    }
  }
}