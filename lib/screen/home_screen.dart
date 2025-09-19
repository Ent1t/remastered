import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for haptic feedback
import 'qr_scanner_screen.dart'; // Add this import
import 'translation_screen.dart'; // ADD THIS IMPORT
import 'tribes_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.userData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers for scroll indicator
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _showScrollIndicator = true;
  bool _userHasScrolled = false; // Track if user has scrolled

  // Background zone heights (adjusted for better proportions)
  static const double zone1Height = 303.0; // Increased to fix 17px overflow
  static const double zone2Height = 560.0; // Increased to show full QR content
  static const double zone3Height = 130.0; // "About the Tribes" header section
  // Zone 4 continues for the rest of the scrollable content

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    
    // Start pulsing animation and keep it running until user scrolls
    _pulseController.repeat(reverse: true);
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

  void _onScroll() {
    // Hide scroll indicator when user starts scrolling (only on home screen)
    if (_currentIndex == 0 && _scrollController.offset > 10 && _showScrollIndicator && !_userHasScrolled) {
      _userHasScrolled = true; // Mark that user has scrolled
      _hideScrollIndicator();
    }
  }

  void _showScrollIndicatorForCurrentTab() {
    // Reset and show scroll indicator when switching to home tab
    if (mounted) {
      setState(() {
        _showScrollIndicator = true;
        _userHasScrolled = false; // Reset scroll tracking
      });
      _fadeController.reset();
      _pulseController.repeat(reverse: true);
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
              ? _buildWelcomeScreenWithScrollingBackgrounds() 
              : _currentIndex == 1 
                ? const TribesScreen()
                : const TranslationScreen(),
            
            // Scroll Indicator - Only visible on Home screen and when user hasn't scrolled
            if (_currentIndex == 0 && _showScrollIndicator)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: IgnorePointer(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'Scroll down to explore',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildAnimatedArrow(0),
                                      const SizedBox(width: 16),
                                      _buildAnimatedArrow(200),
                                      const SizedBox(width: 16),
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

  Widget _buildWelcomeScreenWithScrollingBackgrounds() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ZONE 1 - Top content section with background image
          Container(
            height: zone1Height - 50, // Leave space for the divider
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_png '), // Add your image path here
                fit: BoxFit.cover,
                opacity: 0.3, // Adjust opacity as needed
              ),
            ),
            child: Container(
              // Optional: Add overlay for better text readability
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Adjust overlay opacity as needed
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15), // Reduced from 20
                    
                    // Main Title Box
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), // Reduced from 20
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Padding(
                              padding: EdgeInsets.only(left: 28),
                              child: Text(
                                'Cultural Heritage Museum',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                              ),  
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25), // Reduced from 30
                    
                    // Portal Text
                    const Align(
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
                  ],
                ),
              ),
            ),
          ),
          
          // Divider line between Zone 1 and Zone 2
          Container(
            width: double.infinity,
            height: 3,
            color: Colors.white.withOpacity(0.3),
          ),
          
          // ZONE 2 - Journey begins section with background image
          Container(
            height: zone2Height - 50,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cultural_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            child: Container(
              // Very light overlay to maintain some text readability
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5), // Reduced from 13 - move text higher
                    
                    // Journey begins text - moved higher
                    const Align(
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
                          SizedBox(height: 5), // Reduced from 16 - move text higher
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
                    
                    const SizedBox(height: 35), // Reduced from 50 - move QR scanner higher
                    
                    // QR Scanner Card - transparent with border and black overlay inside
                    Container(
                      width: 280, // Same width
                      height: 280, // Increased height from 200 to 280
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Fully transparent background
                        border: Border.all(
                          color: const Color(0xFFE0D4BE), // Border color as requested
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8), // Less rounded for more box-like
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        // Black overlay inside the border
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), // Slightly smaller radius to stay inside border
                          color: Colors.black.withOpacity(0.6), // Darker black overlay
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // QR Scanner Button - Made bigger
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _openQRScanner();
                                },
                                child: _buildQRScanButton(),
                              ),
                            ),
                            
                            const SizedBox(height: 30), // Increased spacing for taller container
                            
                            // Scan Here text with better contrast
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'SCAN HERE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFE0D4BE),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black.withOpacity(0.8),
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30), // Extra bottom padding
                  ],
                ),
              ),
            ),
          ),
          
          // ZONE 3 - About the Tribes header section with background and black overlay
          Container(
            height: zone3Height,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cultural_section_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.4, 
              ),
              border: Border(
                top: BorderSide(color: Colors.white, width: 1.0),
                bottom: BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
            child: Container(
              // Black overlay for Zone 3
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Black overlay for better text visibility
              ),
              child: const Center(
                child: Text(
                  'ABOUT THE TRIBES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black,
                        offset: Offset(0, 2),
                      ),
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // ZONE 4 - Tribe Cards Section with background image
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 0, 0, 0), 
                  Color.fromARGB(255, 0, 0, 0), 
                  Colors.black,
                ],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/mandaya_main.jpg'), // New background image for Zone 4
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildTribeCard(
                      title: "KAGAN",
                      description: "The Kagan people are known for their rich cultural heritage and traditional practices. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/ata_manobo.jpg",
                    ),
                    const SizedBox(height: 30),
                    _buildTribeCard(
                      title: "MANDAYA",
                      description: "The Mandaya tribe is one of the major indigenous groups in Mindanao, primarily found in Davao Oriental. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/mandaya.jpg",
                    ),
                    const SizedBox(height: 30),
                    _buildTribeCard(
                      title: "MANSAKA",
                      description: "The Mansaka people are skilled in various traditional crafts and have a deep connection with nature. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/mansaka.jpg",
                    ),
                    const SizedBox(height: 100), // Extra space at bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanButton() {
    return SizedBox(
      width: 140, // Increased from 100
      height: 140, // Increased from 100
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow circle
          Container(
            width: 140, // Increased from 100
            height: 140, // Increased from 100
            decoration: const BoxDecoration(
              color: Color(0xCC010100),
              shape: BoxShape.circle,
            ),
          ),
          // Main circle
          Container(
            width: 126, // Increased from 90 (140 * 0.9)
            height: 126, // Increased from 90
            decoration: BoxDecoration(
              color: const Color(0xDD8E714B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 50, // Increased from 35
                height: 50, // Increased from 35
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 3, // Increased spacing for better visibility
                    crossAxisSpacing: 3, // Increased spacing for better visibility
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool shouldFill = [0, 1, 2, 4, 5, 7, 8, 9, 10, 12, 14, 15].contains(index);
                    return Container(
                      decoration: BoxDecoration(
                        color: shouldFill ? const Color(0xFFEADCB6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),
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
          duration: const Duration(milliseconds: 1500),
          tween: Tween<double>(
            begin: 0.0,
            end: _pulseController.isAnimating ? 1.0 : 0.0,
          ),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 4 * value),
              child: Opacity(
                opacity: 1.0 - (value * 0.3),
                child: const Icon(
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFDBCCB5),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 3,
                  color: const Color(0xFFEADCB6),
                ),
              ],
            ),
          ),
          
          // Gray card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Image section
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
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
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFFC5C6C7),
                        fontSize: 16,
                        fontFamily: 'Regular',
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
          
          // Explore more button
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildExploreButton(title),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreButton(String title) {
    return SizedBox(
      height: 50, // Increased height to accommodate layers
      child: Stack(
        children: [
            // Bottom layer (darkest shadow)
        Positioned(
          right: 205,
          top: 0,
          child: Container(
            width: 140,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                 // Color(0xFF232322),
                 // Color(0xFF898987),
                  Color.fromARGB(200, 96, 95, 91),
                  Color.fromARGB(200, 96, 95, 91),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
        // Second layer
        Positioned(
          right: 110,
          top: 0,
          child: Container(
            width: 140,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 148, 147, 145),
                  Color.fromARGB(255, 148, 147, 145),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

          // Main button (top layer)
          Positioned(
            right: 8,
            top: 0,
            child: Container(
              width: 140,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8D7), // Main button color  FFA0845C
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8B6F47), // Slight highlight border  FF8B6F47
                  width: 1,
                ),
              ),
              child: Material(
                color: const Color.fromARGB(0, 0, 0, 0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _exploreMore(title);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Explore more',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000A00),
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
          if (index == 0) {
            _showScrollIndicatorForCurrentTab();
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFFF4EBAF),
        unselectedItemColor: const Color(0xFFF4EBAF),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFFBFFE6),
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFFFBFFE6),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 0 ? const Color(0xFFF4EBAF).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 1 ? const Color(0xFFF4EBAF).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups),
            ),
            label: 'Tribes',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 2 ? const Color(0xFFF4EBAF).withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.translate),
            ),
            label: 'Translate',
          ),
        ],
      ),
    );
  }

  void _exploreMore(String tribeName) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = 1;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      // Add logic here to scroll to specific tribe if needed
    });
  }

  void _openQRScanner() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const QRScannerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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