import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class MusicPlayerScreen extends StatefulWidget {
  final MusicTrack track;
  final Color themeColor;

  const MusicPlayerScreen({
    super.key,
    required this.track,
    this.themeColor = const Color(0xFFD4A574),
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isFavorited = false;
  bool _isShuffled = false;
  bool _isRepeated = false;
  double _currentPosition = 0.0;
  final double _totalDuration = 240.0;
  Timer? _progressTimer;
  
  late AnimationController _playButtonController;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _playButtonController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _playButtonController.forward();
      _rotationController.repeat();
      _startProgressTimer();
    } else {
      _playButtonController.reverse();
      _rotationController.stop();
      _stopProgressTimer();
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPosition < _totalDuration) {
        setState(() {
          _currentPosition += 1;
        });
      } else {
        _stopProgressTimer();
        setState(() {
          _isPlaying = false;
          _currentPosition = 0;
        });
        _playButtonController.reverse();
        _rotationController.reset();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
  }

  void _seekTo(double position) {
    setState(() {
      _currentPosition = position;
    });
  }

  String _formatDuration(double seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
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
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).viewPadding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildHeader(screenWidth, screenHeight),
                    SizedBox(height: (screenHeight * 0.025).clamp(15.0, 25.0)),
                    _buildAlbumArt(screenWidth, screenHeight),
                    SizedBox(height: (screenHeight * 0.04).clamp(20.0, 35.0)),
                    _buildTrackInfo(screenWidth, screenHeight),
                    SizedBox(height: (screenHeight * 0.05).clamp(25.0, 45.0)),
                    _buildProgressBar(screenWidth, screenHeight),
                    SizedBox(height: (screenHeight * 0.05).clamp(25.0, 45.0)),
                    _buildControlButtons(screenWidth, screenHeight),
                    const Spacer(),
                    _buildBottomControls(screenWidth, screenHeight),
                    SizedBox(height: ((bottomPadding > 0 ? bottomPadding + 20 : 40).toDouble()).clamp(30.0, 60.0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.05).clamp(16.0, 24.0),
        vertical: (screenHeight * 0.015).clamp(8.0, 16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
          Flexible(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'PLAYING FROM PLAYLIST',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: (screenWidth * 0.03).clamp(10.0, 13.0),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: (screenHeight * 0.003).clamp(2.0, 4.0)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.track.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.1).clamp(30.0, 50.0),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withOpacity(0.3),
                blurRadius: (screenWidth * 0.075).clamp(20.0, 35.0),
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: (screenWidth * 0.05).clamp(15.0, 25.0),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Image.asset(
                    widget.track.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.themeColor,
                              widget.themeColor.withOpacity(0.7),
                              widget.themeColor.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: (screenWidth * 0.2).clamp(60.0, 90.0),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.1).clamp(30.0, 50.0),
      ),
      child: Column(
        children: [
          Text(
            widget.track.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.06).clamp(20.0, 28.0),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: (screenHeight * 0.01).clamp(6.0, 10.0)),
          Text(
            widget.track.artist ?? 'Unknown Artist',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.1).clamp(30.0, 50.0),
      ),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.themeColor,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: widget.themeColor,
              overlayColor: widget.themeColor.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: (screenWidth * 0.015).clamp(5.0, 8.0),
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: (screenWidth * 0.04).clamp(14.0, 18.0),
              ),
              trackHeight: (screenWidth * 0.01).clamp(3.0, 5.0),
            ),
            child: Slider(
              value: _currentPosition,
              max: _totalDuration,
              onChanged: _seekTo,
              onChangeStart: (value) {
                _stopProgressTimer();
              },
              onChangeEnd: (value) {
                if (_isPlaying) {
                  _startProgressTimer();
                }
              },
            ),
          ),
          SizedBox(height: (screenHeight * 0.01).clamp(6.0, 10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: (screenHeight * 0.015).clamp(8.0, 14.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isShuffled = !_isShuffled;
              });
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              child: Icon(
                Icons.shuffle,
                color: _isShuffled ? widget.themeColor : Colors.white.withOpacity(0.6),
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.03).clamp(10.0, 14.0)),
              child: Icon(
                Icons.skip_previous,
                color: Colors.white.withOpacity(0.8),
                size: (screenWidth * 0.08).clamp(28.0, 36.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              _togglePlayPause();
            },
            child: Container(
              width: (screenWidth * 0.175).clamp(60.0, 80.0),
              height: (screenWidth * 0.175).clamp(60.0, 80.0),
              decoration: BoxDecoration(
                color: widget.themeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withOpacity(0.4),
                    blurRadius: (screenWidth * 0.0375).clamp(12.0, 18.0),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _playButtonController,
                builder: (context, child) {
                  return Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: (screenWidth * 0.08).clamp(28.0, 36.0),
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.03).clamp(10.0, 14.0)),
              child: Icon(
                Icons.skip_next,
                color: Colors.white.withOpacity(0.8),
                size: (screenWidth * 0.08).clamp(28.0, 36.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isRepeated = !_isRepeated;
              });
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              child: Icon(
                Icons.repeat,
                color: _isRepeated ? widget.themeColor : Colors.white.withOpacity(0.6),
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.1).clamp(30.0, 50.0),
        vertical: (screenHeight * 0.015).clamp(8.0, 14.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              child: Icon(
                Icons.share_outlined,
                color: Colors.white.withOpacity(0.6),
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFavorited = !_isFavorited;
              });
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              child: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? widget.themeColor : Colors.white.withOpacity(0.6),
                size: (screenWidth * 0.07).clamp(24.0, 32.0),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 10.0)),
              child: Icon(
                Icons.playlist_add,
                color: Colors.white.withOpacity(0.6),
                size: (screenWidth * 0.06).clamp(20.0, 28.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MusicTrack {
  final String title;
  final String description;
  final String category;
  final String imagePath;
  final String? artist;

  MusicTrack({
    required this.title,
    required this.description,
    required this.category,
    required this.imagePath,
    this.artist,
  });
}