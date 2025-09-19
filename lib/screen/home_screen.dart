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
    
    // Remove the auto-hide timer - now only hides when user scrolls
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
      
      // No auto-hide timer - only hides when user scrolls
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content based on current index - FIXED THIS SECTION
            _currentIndex == 0 
              ? _buildWelcomeScreen() 
              : _currentIndex == 1 
                ? const TribesScreen() // CHANGED: Now shows actual TribesScreen widget
                : const TranslationScreen(), // CHANGED: Now shows actual TranslationScreen
            
            // Scroll Indicator - Only visible on Home screen and when user hasn't scrolled
            if (_currentIndex == 0 && _showScrollIndicator)
              Positioned(
                bottom: 8, // Position above bottom navigation
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

  Widget _buildWelcomeScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
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
                image: const AssetImage('assets/images/cultural_background.jpg'), // Add your background
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
          
          // Main Content with Limited Bouncing Scroll
          SingleChildScrollView(
            controller: _scrollController,
            // Apply limited bouncing scroll physics
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            clipBehavior: Clip.none, // Allow slight overscroll
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top content section with padding
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Main Title Box
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                                padding: EdgeInsets.only(left: 28), // Tab-like spacing
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
                      
                      const SizedBox(height: 40),
                      
                      // Portal Text - aligned to the left
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
                      
                      const SizedBox(height: 20), // Reduced spacing between cards
                    ],
                  ),
                ),
                
                // FIXED: Full-width divider line - moved outside padding
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                
                // NEW: Background image section between divider and "About the Tribes"
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Background image - FULL WIDTH
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: const AssetImage('assets/images/cultural_section_bg.jpg'), // Add your background image
                            fit: BoxFit.cover,
                            opacity: 0.4,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                        child: Container(
                          // Fallback gradient background if image fails to load
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF1a4a3a), // Dark green
                                Color(0xFF2d5a4a),
                                Color(0xFF0F2419), // Very dark green
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Dark overlay for text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Content with padding restored
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            
                            // Journey begins text
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
                            
                            const SizedBox(height: 40),
                            
                            // QR Scanner Card with enhanced styling for background image
                            Container(
                              width: 280,
                              height: 300,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0D4BE), // Container background
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4), // Slightly more shadow for contrast
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Semi-transparent overlay (40% fill)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0x66252525), // 40% opacity of 252525
                                    ),
                                  ),
                                  
                                  // Background pattern for QR card
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: const AssetImage('assets/images/tribal_pattern.jpg'),
                                        fit: BoxFit.cover,
                                        opacity: 0.3,
                                        onError: (exception, stackTrace) {},
                                      ),
                                    ),
                                  ),
                                  
                                  // QR Scanner content - FUNCTIONAL WITH NAVIGATION
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Centered circular scan button - NOW FUNCTIONAL
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigate to QR Scanner Screen with haptic feedback
                                            HapticFeedback.lightImpact();
                                            _openQRScanner();
                                          },
                                          child: SizedBox(
                                            width: 140,
                                            height: 140,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Shadow/border circle (outer) - IMPROVED TRANSPARENCY
                                                Container(
                                                  width: 140,
                                                  height: 140,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xCC010100), // Increased opacity for better visibility
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                // Main circle body with better transparency
                                                Container(
                                                  width: 130,
                                                  height: 130,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xDD8E714B), // Slightly more opaque main body
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
                                                    // QR icon - PERFECTLY CENTERED
                                                    child: SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: GridView.builder(
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                              color: shouldFill ? const Color(0xFFEADCB6) : Colors.transparent,
                                                              borderRadius: BorderRadius.circular(1),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                
                                                // Ripple effect overlay for tap feedback
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      // Handle QR scan action with haptic feedback
                                                      HapticFeedback.lightImpact();
                                                      _openQRScanner();
                                                    },
                                                    borderRadius: BorderRadius.circular(65),
                                                    splashColor: const Color(0xFFD4AF37).withOpacity(0.3),
                                                    highlightColor: const Color(0xFFD4AF37).withOpacity(0.1),
                                                    child: const SizedBox(
                                                      width: 130,
                                                      height: 130,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 30),
                                      
                                      // Scan Here text - PERFECTLY CENTERED WITH ENHANCED STYLING
                                      Center(
                                        child: Text(
                                          'SCAN HERE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFFFFEFBB),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 2,
                                                color: Colors.black.withOpacity(0.5),
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // UPDATED: About the Tribes Section - FULL WIDTH
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      // About the Tribes Header with background image - FULL WIDTH
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Stack(
                          children: [
                            // Background image - FULL WIDTH
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.asset(
                                'assets/images/tribes_header_bg.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Enhanced fallback gradient background
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF2C1810), // Dark brown
                                          Color(0xFF8B4513), // Medium brown
                                          Color(0xFF654321), // Darker brown
                                          Color(0xFF2F1B14), // Very dark brown
                                          Color(0xFF1a0f0a), // Almost black brown
                                        ],
                                        stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Add a subtle pattern overlay for texture
                                        Container(
                                          decoration: BoxDecoration(
                                            backgroundBlendMode: BlendMode.overlay,
                                            color: Colors.black.withOpacity(0.1),
                                          ),
                                        ),
                                        // Add some geometric patterns for tribal feel
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: TribalPatternPainter(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            // Enhanced dark overlay for better text visibility
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.6),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Side gradient for edge blending
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Title text with enhanced styling
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Main title with enhanced shadow and glow effect
                                  Text(
                                    'ABOUT THE TRIBES',
                                    style: TextStyle(
                                      color: const Color(0xFFF8F4E6), // Light cream color
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Abril Fatface',
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Colors.black.withOpacity(0.9),
                                          offset: const Offset(0, 2),
                                        ),
                                        Shadow(
                                          blurRadius: 16,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(0, 4),
                                        ),
                                        // Add a subtle glow
                                        Shadow(
                                          blurRadius: 20,
                                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Add a subtle underline accent
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 120,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0xFFD4AF37),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Enhanced separator line - FULL WIDTH
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 1,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tribe Cards Section with padding restored
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildTribeCard(
                        title: "ATA-MANOBO",
                        description: "The Ata-Manobo people are known for their rich cultural heritage and traditional practices. They are masters of traditional music and dance ceremonies.",
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
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
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
          // Title header outside and above the card with Poppins font
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFDBCCB5), // Light beige color
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins', // Poppins font
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 3,
                  color: const Color(0xFFEADCB6), // Light golden beige underline
                ),
              ],
            ),
          ),
          
          // Gray card with rounded corners
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A), // Gray background matching image
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
                        // Image (replace with your actual image)
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback when image doesn't exist
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
                  
                  // Text section with Regular font and updated color
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFFC5C6C7), // Light gray color
                        fontSize: 16,
                        fontFamily: 'Regular', // Regular font
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
          
          // Enhanced layered "Explore more" button
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Stack(
                children: [
                  // Background layer 4 (furthest back - darkest shadow)
                  Positioned(
                    right: 0,
                    top: 8,
                    child: Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1810), // Very dark brown
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Background layer 3 (third layer)
                  Positioned(
                    right: 2,
                    top: 6,
                    child: Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2317), // Dark brown
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Background layer 2 (second layer)
                  Positioned(
                    right: 4,
                    top: 3,
                    child: Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D4A37), // Medium brown
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Main button (front layer)
                  Container(
                    width: 130,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7355), // Light brown/beige
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _exploreMore(title);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Explore more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
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
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000A00), // Very dark green background
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
        selectedItemColor: const Color(0xFFF4EBAF), // Light cream color for selected icons
        unselectedItemColor: const Color(0xFFF4EBAF), // Same light cream color for all icons
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFFBFFE6), // Light cream color for selected labels
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFFFBFFE6), // Light cream color for unselected labels
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

  // FIXED: Removed dialog popup from explore more button
  void _exploreMore(String tribeName) {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    // Navigate directly to tribes section without showing dialog
    setState(() {
      _currentIndex = 1; // Switch to Tribes tab
    });
    
    // Optional: Add a brief delay to show the tab switch animation
    // then scroll to the relevant tribe section if needed
    Future.delayed(const Duration(milliseconds: 300), () {
      // You can add logic here to scroll to specific tribe if the TribesScreen supports it
      // For example, if TribesScreen has a method to focus on a specific tribe
    });
  }

  // UPDATED QR Scanner method - now properly navigates to QR Scanner Screen
  void _openQRScanner() {
    // Add haptic feedback for better user experience
    HapticFeedback.mediumImpact();
    
    // Navigate to QR Scanner Screen with smooth transition
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const QRScannerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide up transition
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

// Custom painter for tribal patterns
class TribalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw some subtle geometric tribal patterns
    final path = Path();
    
    // Draw diamond patterns
    for (int i = 0; i < 5; i++) {
      double x = (size.width / 5) * i;
      double y = size.height / 2;
      
      path.moveTo(x, y - 20);
      path.lineTo(x + 15, y);
      path.lineTo(x, y + 20);
      path.lineTo(x - 15, y);
      path.close();
    }
    
    // Draw zigzag patterns
    path.moveTo(0, size.height * 0.3);
    for (int i = 0; i < 20; i++) {
      double x = (size.width / 20) * i;
      double y = size.height * 0.3 + (i % 2 == 0 ? -5 : 5);
      path.lineTo(x, y);
    }
    
    path.moveTo(0, size.height * 0.7);
    for (int i = 0; i < 20; i++) {
      double x = (size.width / 20) * i;
      double y = size.height * 0.7 + (i % 2 == 0 ? 5 : -5);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}