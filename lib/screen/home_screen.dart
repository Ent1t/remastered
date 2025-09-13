import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  
  // Animation controllers for scroll indicator
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _showScrollIndicator = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start the initial animations
    _startInitialAnimations();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }
  
  void _startInitialAnimations() {
    // Start with full opacity
    _fadeController.reset();
    
    // Start pulsing animation
    _pulseController.repeat(reverse: true);
    
    // Auto-hide after 3 seconds if user hasn't scrolled
    Future.delayed(Duration(seconds: 3), () {
      if (_showScrollIndicator && mounted) {
        _hideScrollIndicator();
      }
    });
  }
  
  void _hideScrollIndicator() {
    if (_showScrollIndicator && mounted) {
      setState(() {
        _showScrollIndicator = false;
      });
      _pulseController.stop();
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content based on current index
            _currentIndex == 0 
              ? _buildWelcomeScreen() 
              : _currentIndex == 1 
                ? _buildTribesContent()
                : _buildTranslationContent(),
            
            // Scroll Indicator - Only visible on Home screen
            if (_currentIndex == 0)
              Positioned(
                bottom: 80, // Position above bottom navigation
                left: 0,
                right: 0,
                child: IgnorePointer( // Prevents interference with scrolling
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Color(0xFFD4AF37).withOpacity(0.6),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Scroll down to explore',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildAnimatedArrow(0),
                                      SizedBox(width: 16),
                                      _buildAnimatedArrow(200),
                                      SizedBox(width: 16),
                                      _buildAnimatedArrow(400),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Background with cultural pattern/image
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a4a3a), // Dark green
            Color(0xFF2d5a4a),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern/texture overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              // Add your cultural background image here
              image: DecorationImage(
                image: AssetImage('assets/images/cultural_background.jpg'), // Add your background
                fit: BoxFit.cover,
                opacity: 0.3,
                onError: (exception, stackTrace) {},
              ),
            ),
          ),
          
          // Dark overlay for text visibility
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          
          // Main Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  
                  // Main Title Box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'HUNI SA TRIBU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Cultural Heritage Museum',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Portal Text - aligned to the left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Portal to a',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'Rich Heritage.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Divider line
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Journey begins text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'begins with a scan.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Scan QR codes on museum exhibits to ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'explore',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'the rich culture of indigenous tribes',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // QR Scanner Card
                  Container(
                    width: 280,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern for QR card
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage('assets/images/tribal_pattern.jpg'), // Add tribal pattern
                              fit: BoxFit.cover,
                              opacity: 0.4,
                              onError: (exception, stackTrace) {},
                            ),
                          ),
                        ),
                        
                        // QR Scanner content
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // QR Icon with brown/golden background
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFB8860B), // Dark golden rod
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // QR code pattern
                                      Container(
                                        width: 60,
                                        height: 60,
                                        child: GridView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 2,
                                            crossAxisSpacing: 2,
                                          ),
                                          itemCount: 16,
                                          itemBuilder: (context, index) {
                                            // Create QR-like pattern
                                            bool shouldFill = [0, 1, 2, 4, 5, 7, 8, 9, 10, 12, 14, 15].contains(index);
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: shouldFill ? Colors.white : Colors.transparent,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: 20),
                                
                                // Scan Here button
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'SCAN HERE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
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
                  
                  SizedBox(height: 60),
                  
                  // Tribe Cards Section (scrollable content)
                  _buildTribeCard(
                    title: "ATA-MANOBO",
                    description: "The Ata-Manobo people are known for their rich cultural heritage and traditional practices. They are masters of traditional music and dance ceremonies.",
                    imagePath: "assets/images/atamanon.jpg",
                  ),
                  SizedBox(height: 30),
                  _buildTribeCard(
                    title: "MANDAYA",
                    description: "The Mandaya tribe is one of the major indigenous groups in Mindanao, primarily found in Davao Oriental. They are masters of traditional music and dance ceremonies.",
                    imagePath: "assets/images/mandaya.jpg",
                  ),
                  SizedBox(height: 30),
                  _buildTribeCard(
                    title: "MANSAKA",
                    description: "The Mansaka people are skilled in various traditional crafts and have a deep connection with nature. They are masters of traditional music and dance ceremonies.",
                    imagePath: "assets/images/mansaka.jpg",
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedArrow(int delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 1500),
          tween: Tween<double>(
            begin: 0.0,
            end: _pulseController.isAnimating ? 1.0 : 0.0,
          ),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 4 * value),
              child: Opacity(
                opacity: 1.0 - (value * 0.3),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTribeCard({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title header outside and above the card
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFD4AF37), // Golden color
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 3,
                  color: Color(0xFFD4AF37), // Golden underline
                ),
              ],
            ),
          ),
          
          // Gray card with rounded corners
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF4A4A4A), // Gray background matching image
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Image section
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Image (replace with your actual image)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback when image doesn't exist
                              return Container(
                                decoration: BoxDecoration(
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
                                  child: Icon(
                                    Icons.image,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay for text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Text section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Explore more button outside and below the card
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _exploreMore(title);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4AF37), // Golden color
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Explore more',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTribesContent() {
    return Center(
      child: Text(
        'Tribes Screen\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTranslationContent() {
    return Center(
      child: Text(
        'Translation Screen\n(To be implemented)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2d5a4a),
            Color(0xFF1a4a3a),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Only reset scroll indicator if switching to home screen
          if (index == 0) {
            _showScrollIndicatorForCurrentTab();
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFFD4AF37),
        unselectedItemColor: Colors.white60,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 0 ? Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 1 ? Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.groups),
            ),
            label: 'Tribes',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 2 ? Color(0xFFD4AF37).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.translate),
            ),
            label: 'Translate',
          ),
        ],
      ),
    );
  }

  void _exploreMore(String tribeName) {
    // Navigate to tribes section or show detailed information
    setState(() {
      _currentIndex = 1; // Switch to Tribes tab
    });
    
    // You can also navigate to a detailed tribe screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF404040),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            tribeName,
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Exploring detailed information about $tribeName tribe. This will navigate to the comprehensive tribe details page.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Continue Exploring',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onScroll() {
    // Hide scroll indicator when user starts scrolling (only on home screen)
    if (_currentIndex == 0 && _scrollController.offset > 10 && _showScrollIndicator) {
      _hideScrollIndicator();
    }
  }

  void _showScrollIndicatorForCurrentTab() {
    // Reset and show scroll indicator when switching to home tab
    if (mounted) {
      setState(() {
        _showScrollIndicator = true;
      });
      _fadeController.reset();
      _pulseController.repeat(reverse: true);
      
      // Auto-hide after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (_showScrollIndicator && mounted) {
          _hideScrollIndicator();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}