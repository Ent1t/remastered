import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'qr_scanner_screen.dart';
import 'translation_screen.dart';
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
  
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _backButtonFadeController;
  late Animation<double> _backButtonFadeAnimation;
  
  bool _showScrollIndicator = true;
  bool _userHasScrolled = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _backButtonFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
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
    
    _backButtonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backButtonFadeController,
      curve: Curves.easeInOut,
    ));
    
    _startInitialAnimations();
    _scrollController.addListener(_onScroll);
  }
  
  void _startInitialAnimations() {
    _fadeController.reset();
    _backButtonFadeController.forward();
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
    if (_currentIndex == 0 && _scrollController.offset > 10 && _showScrollIndicator && !_userHasScrolled) {
      _userHasScrolled = true;
      _hideScrollIndicator();
    }
    
    if (_currentIndex == 0) {
      if (_scrollController.offset <= 5) {
        if (_backButtonFadeController.status != AnimationStatus.forward && 
            _backButtonFadeController.status != AnimationStatus.completed) {
          _backButtonFadeController.forward();
        }
      } else {
        if (_backButtonFadeController.status != AnimationStatus.reverse && 
            _backButtonFadeController.status != AnimationStatus.dismissed) {
          _backButtonFadeController.reverse();
        }
      }
    }
  }

  void _showScrollIndicatorForCurrentTab() {
    if (mounted) {
      setState(() {
        _showScrollIndicator = true;
        _userHasScrolled = false;
      });
      _fadeController.reset();
      _backButtonFadeController.forward();
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
            _currentIndex == 0 
              ? _buildWelcomeScreenWithScrollingBackgrounds() 
              : _currentIndex == 1 
                ? const TribesScreen()
                : const TranslationScreen(),
            
            if (_currentIndex == 0)
              Positioned(
                top: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _backButtonFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _backButtonFadeAnimation.value,
                      child: _buildBackButton(),
                    );
                  },
                ),
              ),
            
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
                                        color: const Color.fromARGB(255, 230, 223, 200).withOpacity(0.6),
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReturnToLoginDialog();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 216, 188).withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 8,
            ),
            SizedBox(width: 2),
            Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnToLoginDialog() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2a2a2a),
                  Color(0xFF1a1a1a),
                  Color(0xFF0d0d0d),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFD4AF37),
                    size: 35,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Return to Login?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Information:',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Name: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.userData['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Role: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.userData['role'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.userData['school'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'School: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.userData['school'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Going back will allow you to change your name, role, or school information. Are you sure you want to return to the login screen?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Stay Here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          _returnToLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDF8D7),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _returnToLogin() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  Widget _buildWelcomeScreenWithScrollingBackgrounds() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;
    
    // Adaptive zone heights based on orientation
    final zone1Height = isLandscape 
        ? (screenHeight * 0.50).clamp(250.0, double.infinity)
        : (screenHeight * 0.35).clamp(200.0, double.infinity);
    
    final zone2Height = isLandscape
        ? (screenHeight * 0.90).clamp(500.0, double.infinity)
        : (screenHeight * 0.65).clamp(400.0, double.infinity);
    
    final zone3Height = isLandscape
        ? (screenHeight * 0.20).clamp(100.0, 200.0)
        : (screenHeight * 0.15).clamp(80.0, 150.0);
    
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ZONE 1 - Top content section
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: zone1Height,
            ),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (screenWidth * 0.06).clamp(16.0, 30.0),
                vertical: (screenHeight * 0.015).clamp(8.0, 20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: (screenHeight * 0.015).clamp(8.0, 20.0)),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: (screenWidth * 0.08).clamp(20.0, 40.0),
                        vertical: (screenHeight * 0.02).clamp(12.0, 25.0),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'HUNI SA TRIBU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.06).clamp(16.0, 28.0),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          SizedBox(height: (screenHeight * 0.01).clamp(4.0, 12.0)),
                          Padding(
                            padding: EdgeInsets.only(left: (screenWidth * 0.07).clamp(12.0, 30.0)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Cultural Heritage Museum',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: (screenHeight * 0.02).clamp(12.0, 25.0)),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Your Portal to a',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.05).clamp(14.0, 22.0),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Rich Heritage.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (screenWidth * 0.06).clamp(16.0, 26.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: (screenHeight * 0.015).clamp(8.0, 20.0)),
                ],
              ),
            ),
          ),
          
          Container(
            width: double.infinity,
            height: 3,
            color: Colors.white.withOpacity(0.3),
          ),
          
          // ZONE 2 - Journey begins section
          Container(
            constraints: BoxConstraints(
              minHeight: zone2Height,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cultural_background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
              ),
              child: Padding(
                padding: EdgeInsets.all((screenWidth * 0.06).clamp(16.0, 30.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: (screenHeight * 0.01).clamp(8.0, 15.0)),
                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Your journey',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.045).clamp(14.0, 20.0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'begins with a scan.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (screenWidth * 0.045).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Scan QR codes on museum exhibits to ',
                                    ),
                                    TextSpan(
                                      text: 'explore',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' the rich culture of indigenous tribes',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: (screenHeight * 0.04).clamp(20.0, 50.0)),
                    
                    // QR Scanner Card - Responsive with constraints
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxSize = isLandscape 
                            ? screenHeight * 0.5 
                            : constraints.maxWidth * 0.7;
                        final containerSize = maxSize.clamp(200.0, 300.0);
                        
                        return Container(
                          width: containerSize,
                          height: containerSize,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFFE0D4BE),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _openQRScanner();
                                    },
                                    child: _buildQRScanButton(containerSize),
                                  ),
                                ),
                                
                                SizedBox(height: (screenHeight * 0.03).clamp(15.0, 30.0)),
                                
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _openQRScanner();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: (screenWidth * 0.04).clamp(12.0, 20.0),
                                        vertical: (screenHeight * 0.01).clamp(6.0, 12.0),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'SCAN HERE',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFFE0D4BE),
                                            fontSize: (screenWidth * 0.045).clamp(14.0, 20.0),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: (screenHeight * 0.03).clamp(15.0, 40.0)),
                  ],
                ),
              ),
            ),
          ),
          
          // ZONE 3 - About the Tribes header
          Container(
            constraints: BoxConstraints(
              minHeight: zone3Height,
            ),
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
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ABOUT THE TRIBES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (screenWidth * 0.08).clamp(20.0, 36.0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        shadows: const [
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
            ),
          ),
          
          // ZONE 4 - Tribe Cards Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black,
                  Colors.black,
                ],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/mandaya_main.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.06).clamp(16.0, 30.0)),
                child: Column(
                  children: [
                    SizedBox(height: (screenHeight * 0.05).clamp(20.0, 50.0)),
                    _buildTribeCard(
                      title: "KAGAN",
                      description: "The Kagan people are known for their rich cultural heritage and traditional practices. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/ata_manobo.jpg",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: (screenHeight * 0.03).clamp(15.0, 30.0)),
                    _buildTribeCard(
                      title: "MANDAYA",
                      description: "The Mandaya tribe is one of the major indigenous groups in Mindanao, primarily found in Davao Oriental. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/mandaya.jpg",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: (screenHeight * 0.03).clamp(15.0, 30.0)),
                    _buildTribeCard(
                      title: "MANSAKA",
                      description: "The Mansaka people are skilled in various traditional crafts and have a deep connection with nature. They are masters of traditional music and dance ceremonies.",
                      imagePath: "assets/images/mansaka.jpg",
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isLandscape: isLandscape,
                    ),
                    SizedBox(height: (screenHeight * 0.1).clamp(40.0, 100.0)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanButton(double containerSize) {
    final buttonSize = (containerSize * 0.35).clamp(60.0, 120.0);
    final innerSize = buttonSize * 0.9;
    final gridSize = buttonSize * 0.35;
    
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: const BoxDecoration(
              color: Color(0xCC010100),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
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
                width: gridSize,
                height: gridSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
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
    required double screenWidth,
    required double screenHeight,
    required bool isLandscape,
  }) {
    // Adaptive image height for landscape - increased for better visibility
    final imageHeight = isLandscape 
        ? (screenHeight * 0.50).clamp(250.0, 450.0)
        : (screenHeight * 0.25).clamp(150.0, 300.0);
    
    // Use contain in landscape to show full image, cover in portrait
    final imageFit = isLandscape ? BoxFit.contain : BoxFit.cover;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: (screenHeight * 0.01).clamp(6.0, 15.0),
        horizontal: (screenWidth * 0.01).clamp(4.0, 10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: (screenHeight * 0.015).clamp(8.0, 20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFFDBCCB5),
                      fontSize: (screenWidth * 0.07).clamp(20.0, 32.0),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.008).clamp(4.0, 10.0)),
                Container(
                  width: (screenWidth * 0.2).clamp(60.0, 100.0),
                  height: 3,
                  color: const Color(0xFFEADCB6),
                ),
              ],
            ),
          ),
          
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
                  Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            imagePath,
                            fit: imageFit,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
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
                        if (!isLandscape)
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
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all((screenWidth * 0.05).clamp(12.0, 24.0)),
                    child: Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFFC5C6C7),
                        fontSize: (screenWidth * 0.04).clamp(13.0, 18.0),
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
          
          Padding(
            padding: EdgeInsets.only(top: (screenHeight * 0.02).clamp(12.0, 25.0)),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildExploreButton(title, screenWidth, screenHeight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreButton(String title, double screenWidth, double screenHeight) {
    final buttonWidth = (screenWidth * 0.3).clamp(90.0, 130.0);
    final buttonHeight = (screenHeight * 0.045).clamp(35.0, 55.0);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: buttonHeight * 1.5,
          width: constraints.maxWidth,
          child: Stack(
            children: [
              Positioned(
                right: buttonWidth * 1.4,
                top: 0,
                child: Container(
                  width: buttonWidth * 1.3,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(200, 96, 95, 91),
                        Color.fromARGB(200, 96, 95, 91),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              
              Positioned(
                right: buttonWidth * 0.7,
                top: 0,
                child: Container(
                  width: buttonWidth * 1.15,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 148, 147, 145),
                        Color.fromARGB(255, 148, 147, 145),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              Positioned(
                right: (screenWidth * 0.02).clamp(6.0, 15.0),
                top: 0,
                child: Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8D7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF8B6F47),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _exploreMore(title);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Explore more',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
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
      },
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
    _backButtonFadeController.dispose();
    super.dispose();
  }
}