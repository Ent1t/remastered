import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kagan_detail_screen.dart';
import 'mansaka_detail_screen.dart';
import 'mandaya_detail_screen.dart';

class TribesScreen extends StatefulWidget {
  const TribesScreen({super.key});

  @override
  State<TribesScreen> createState() => _TribesScreenState();
}

class _TribesScreenState extends State<TribesScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.05).clamp(16.0, 30.0),
              vertical: (screenHeight * 0.015).clamp(12.0, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: (screenHeight * 0.015).clamp(8.0, 16.0)),
                
                // Header Section
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: (screenHeight * 0.15).clamp(100.0, 150.0),
                  ),
                  padding: EdgeInsets.all((screenWidth * 0.06).clamp(16.0, 30.0)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'INDIGENOUS TRIBES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.065).clamp(20.0, 28.0),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: (screenHeight * 0.02).clamp(8.0, 16.0)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Explore Cultural\nHeritage',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: (screenWidth * 0.045).clamp(14.0, 20.0),
                            fontWeight: FontWeight.w300,
                            height: 1.3,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: (screenHeight * 0.04).clamp(20.0, 32.0)),
                
                // Tribe Cards
                _buildTribeCard(
                  tribeName: 'KAGAN',
                  description: 'Known for their rich oral tradition and intricate beadwork',
                  categories: '4 Categories',
                  imagePath: 'assets/images/kagan_d.jpg',
                  onTap: () => _navigateToKaganDetail(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                SizedBox(height: (screenHeight * 0.025).clamp(16.0, 24.0)),
                
                _buildTribeCard(
                  tribeName: 'MANSAKA',
                  description: 'Renowned for their traditional weaving and agricultural practices',
                  categories: '4 Categories',
                  imagePath: 'assets/images/mansaka_main.jpg',
                  onTap: () => _navigateToMansakaDetail(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                SizedBox(height: (screenHeight * 0.025).clamp(16.0, 24.0)),
                
                _buildTribeCard(
                  tribeName: 'MANDAYA',
                  description: 'Masters of traditional music and dance ceremonies',
                  categories: '4 Categories',
                  imagePath: 'assets/images/mandaya_main.jpg',
                  onTap: () => _navigateToMandayaDetail(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                
                SizedBox(height: (screenHeight * 0.04).clamp(20.0, 32.0)),
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: (screenHeight * 0.22).clamp(140.0, 200.0),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF433D34).withOpacity(0.8),
            const Color(0xFF836F50).withOpacity(0.8),
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
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF433D34).withOpacity(0.8),
                      const Color(0xFF836F50).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side - Image
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: (screenWidth * 0.3).clamp(80.0, 140.0),
                      maxWidth: (screenWidth * 0.35).clamp(100.0, 160.0),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
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
                                size: (screenWidth * 0.1).clamp(32.0, 48.0),
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Right side - Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all((screenWidth * 0.05).clamp(12.0, 20.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      tribeName,
                                      style: TextStyle(
                                        color: const Color(0xFFF8F4E6),
                                        fontSize: (screenWidth * 0.045).clamp(14.0, 20.0),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: (screenHeight * 0.005).clamp(4.0, 8.0)),
                                  Container(
                                    height: 2,
                                    width: (screenWidth * 0.15).clamp(40.0, 60.0),
                                    color: const Color(0xFFF8F4E6),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),
                              
                              Text(
                                description,
                                style: TextStyle(
                                  color: const Color(0xFFC5C6C7),
                                  fontSize: (screenWidth * 0.032).clamp(11.0, 14.0),
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              SizedBox(height: (screenHeight * 0.01).clamp(6.0, 10.0)),
                              
                              Text(
                                categories,
                                style: TextStyle(
                                  color: const Color(0xFFFBFFE6),
                                  fontSize: (screenWidth * 0.028).clamp(10.0, 12.0),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onTap();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (screenWidth * 0.04).clamp(12.0, 20.0),
                                  vertical: (screenHeight * 0.01).clamp(6.0, 12.0),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF94937C).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF94937C),
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
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'CLICK HERE',
                                    style: TextStyle(
                                      color: const Color(0xFFF8F4E6),
                                      fontSize: (screenWidth * 0.025).clamp(9.0, 12.0),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
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
                ],
              ),
              
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
                  child: const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToKaganDetail() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const KaganCulturalDetailScreen(),
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

  void _navigateToMansakaDetail() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const MansakaCulturalDetailScreen(),
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

  void _navigateToMandayaDetail() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const MandayaCulturalDetailScreen(),
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

class TribeDetailScreen extends StatelessWidget {
  final String tribeName;

  const TribeDetailScreen({
    super.key,
    required this.tribeName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: (screenWidth * 0.06).clamp(20.0, 28.0),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            tribeName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.05).clamp(16.0, 22.0),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
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
          padding: EdgeInsets.all((screenWidth * 0.05).clamp(16.0, 30.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Container(
                height: (screenHeight * 0.3).clamp(180.0, 300.0),
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
                                size: (screenWidth * 0.2).clamp(48.0, 80.0),
                                color: Colors.white.withOpacity(0.3),
                              ),
                              SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: (screenWidth * 0.05).clamp(16.0, 30.0)
                                  ),
                                  child: Text(
                                    tribeName.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: (screenWidth * 0.06).clamp(18.0, 26.0),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
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
              
              SizedBox(height: (screenHeight * 0.04).clamp(20.0, 32.0)),
              
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'About $tribeName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.06).clamp(18.0, 26.0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
              
              Text(
                _getTribeDescription(tribeName),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: (screenWidth * 0.04).clamp(13.0, 16.0),
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
              
              SizedBox(height: (screenHeight * 0.04).clamp(20.0, 32.0)),
              
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cultural Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.05).clamp(16.0, 22.0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              SizedBox(height: (screenHeight * 0.02).clamp(12.0, 20.0)),
              
              _buildCategoryGrid(screenWidth, screenHeight),
              
              SizedBox(height: (screenHeight * 0.05).clamp(24.0, 40.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(double screenWidth, double screenHeight) {
    List<Map<String, dynamic>> categories = [
      {'name': 'Traditional Clothing', 'icon': Icons.checkroom, 'color': const Color(0xFF8B4513)},
      {'name': 'Music & Dance', 'icon': Icons.music_note, 'color': const Color(0xFF654321)},
      {'name': 'Arts & Crafts', 'icon': Icons.palette, 'color': const Color(0xFF2F4F4F)},
      {'name': 'Language', 'icon': Icons.translate, 'color': const Color(0xFF8B7355)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: (screenWidth * 0.04).clamp(12.0, 20.0),
        mainAxisSpacing: (screenHeight * 0.02).clamp(12.0, 20.0),
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(categories[index], screenWidth, screenHeight);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, double screenWidth, double screenHeight) {
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
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all((screenWidth * 0.04).clamp(10.0, 20.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'],
                  color: category['color'],
                  size: (screenWidth * 0.1).clamp(32.0, 48.0),
                ),
                SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      category['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (screenWidth * 0.035).clamp(11.0, 14.0),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  String _getTribeDescription(String tribeName) {
    switch (tribeName.toLowerCase()) {
      case 'kagan':
        return 'The Kagan people are an indigenous group found in the mountainous regions of Mindanao. They are known for their rich oral traditions, intricate beadwork, and deep spiritual connection with nature. Their culture emphasizes community cooperation, respect for elders, and sustainable living practices that have been passed down through generations.';
      case 'mansaka':
        return 'The Mansaka tribe is renowned for their exceptional weaving skills and agricultural practices. They inhabit the eastern part of Davao and are known for their colorful traditional clothing, particularly their beautifully woven fabrics. The Mansaka people maintain strong cultural traditions while adapting to modern life.';
      case 'mandaya':
        return 'The Mandaya people are masters of traditional music and dance ceremonies. They are one of the major indigenous groups in Mindanao, primarily found in Davao Oriental. Known for their dagmay (traditional cloth), musical instruments, and elaborate festivals that celebrate their rich cultural heritage and spiritual beliefs.';
      default:
        return 'This indigenous tribe has a rich cultural heritage that includes traditional practices, unique art forms, and deep spiritual connections to their ancestral lands. They continue to preserve their customs and traditions while navigating the challenges of the modern world.';
    }
  }
}