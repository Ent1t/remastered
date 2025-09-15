import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TribesScreen extends StatefulWidget {
  const TribesScreen({super.key});

  @override
  State<TribesScreen> createState() => _TribesScreenState();
}

class _TribesScreenState extends State<TribesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Dark background with subtle pattern
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    // Subtle background pattern
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INDIGENOUS TRIBES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Explore Cultural\nHeritage',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          height: 1.3,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tribe Cards
                _buildTribeCard(
                  tribeName: 'ATA MANOBO',
                  description: 'Known for their rich oral tradition and intricate beadwork',
                  categories: '4 Categories',
                  imagePath: 'assets/images/ata_manobo_main.jpg',
                  onTap: () => _navigateToTribeDetail('Ata Manobo'),
                ),
                
                const SizedBox(height: 20),
                
                _buildTribeCard(
                  tribeName: 'MANSAKA',
                  description: 'Renowned for their traditional weaving and agricultural practices',
                  categories: '4 Categories',
                  imagePath: 'assets/images/mansaka_main.jpg',
                  onTap: () => _navigateToTribeDetail('Mansaka'),
                ),
                
                const SizedBox(height: 20),
                
                _buildTribeCard(
                  tribeName: 'MANDAYA',
                  description: 'Masters of traditional music and dance ceremonies',
                  categories: '4 Categories',
                  imagePath: 'assets/images/mandaya_main.jpg',
                  onTap: () => _navigateToTribeDetail('Mandaya'),
                ),
                
                // Bottom padding to ensure last card is fully visible
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTribeCard({
    required String tribeName,
    required String description,
    required String categories,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 180, // Increased height slightly for better layout
      decoration: BoxDecoration(
        // Linear gradient with 80% fill (433D34 to 836F50)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF433D34).withOpacity(0.8), // 80% opacity
            const Color(0xFF836F50).withOpacity(0.8), // 80% opacity
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback background matching the gradient
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF433D34),
                          Color(0xFF836F50),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.people,
                        size: 60,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Overlay with the specified gradient (80% opacity)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF433D34).withOpacity(0.8), // 80% opacity
                    const Color(0xFF836F50).withOpacity(0.8), // 80% opacity
                  ],
                ),
              ),
            ),
            
            // Content Layout - Using Positioned for precise placement
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Content - Takes most of the space
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Title with F8F4E6 color
                          Text(
                            tribeName,
                            style: const TextStyle(
                              color: Color(0xFFF8F4E6), // Specified title color
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description with C5C6C7 color
                          Text(
                            description,
                            style: const TextStyle(
                              color: Color(0xFFC5C6C7), // Specified text color
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Categories with FBFFE6 color
                          Text(
                            categories,
                            style: const TextStyle(
                              color: Color(0xFFFBFFE6), // Specified categories color
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Click Here Button - Positioned at bottom right
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94937C).withOpacity(0.3), // 30% fill
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF94937C), // Full color for border
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'CLICK HERE',
                    style: TextStyle(
                      color: Color(0xFFF8F4E6), // Same as title color for visibility
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            
            // Tap overlay for entire card
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTap();
                },
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTribeDetail(String tribeName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          TribeDetailScreen(tribeName: tribeName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// Tribe Detail Screen
class TribeDetailScreen extends StatelessWidget {
  final String tribeName;

  const TribeDetailScreen({
    super.key,
    required this.tribeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tribeName.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/${tribeName.toLowerCase().replaceAll(' ', '_')}_detail.jpg',
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tribeName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Description Section
              Text(
                'About $tribeName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _getTribeDescription(tribeName),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Categories Section
              const Text(
                'Cultural Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildCategoryGrid(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    List<Map<String, dynamic>> categories = [
      {'name': 'Traditional Clothing', 'icon': Icons.checkroom, 'color': const Color(0xFF8B4513)},
      {'name': 'Music & Dance', 'icon': Icons.music_note, 'color': const Color(0xFF654321)},
      {'name': 'Arts & Crafts', 'icon': Icons.palette, 'color': const Color(0xFF2F4F4F)},
      {'name': 'Language', 'icon': Icons.translate, 'color': const Color(0xFF8B7355)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: category['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category['color'].withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to category detail
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'],
                  color: category['color'],
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  category['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTribeDescription(String tribeName) {
    switch (tribeName.toLowerCase()) {
      case 'ata manobo':
        return 'The Ata-Manobo people are an indigenous group found in the mountainous regions of Mindanao. They are known for their rich oral traditions, intricate beadwork, and deep spiritual connection with nature. Their culture emphasizes community cooperation, respect for elders, and sustainable living practices that have been passed down through generations.';
      case 'mansaka':
        return 'The Mansaka tribe is renowned for their exceptional weaving skills and agricultural practices. They inhabit the eastern part of Davao and are known for their colorful traditional clothing, particularly their beautifully woven fabrics. The Mansaka people maintain strong cultural traditions while adapting to modern life.';
      case 'mandaya':
        return 'The Mandaya people are masters of traditional music and dance ceremonies. They are one of the major indigenous groups in Mindanao, primarily found in Davao Oriental. Known for their dagmay (traditional cloth), musical instruments, and elaborate festivals that celebrate their rich cultural heritage and spiritual beliefs.';
      default:
        return 'This indigenous tribe has a rich cultural heritage that includes traditional practices, unique art forms, and deep spiritual connections to their ancestral lands. They continue to preserve their customs and traditions while navigating the challenges of the modern world.';
    }
  }
}