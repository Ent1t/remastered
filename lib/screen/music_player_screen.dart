// lib/screen/music_player_screen.dart
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
  final double _totalDuration = 240.0; // 4 minutes in seconds
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
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAlbumArt(),
              const SizedBox(height: 30),
              _buildTrackInfo(),
              const SizedBox(height: 40),
              _buildProgressBar(),
              const SizedBox(height: 40),
              _buildControlButtons(),
              const SizedBox(height: 30),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'PLAYING FROM PLAYLIST',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.track.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Add more options functionality
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
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
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 80,
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

  Widget _buildTrackInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            widget.track.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Matt Gamar', // Artist name from the image
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.themeColor,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: widget.themeColor,
              overlayColor: widget.themeColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 4,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isShuffled = !_isShuffled;
            });
          },
          child: Icon(
            Icons.shuffle,
            color: _isShuffled ? widget.themeColor : Colors.white.withOpacity(0.6),
            size: 24,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            // Previous track functionality
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.skip_previous,
              color: Colors.white.withOpacity(0.8),
              size: 32,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _togglePlayPause();
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: widget.themeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.themeColor.withOpacity(0.4),
                  blurRadius: 15,
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
                  size: 32,
                );
              },
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            // Next track functionality
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.skip_next,
              color: Colors.white.withOpacity(0.8),
              size: 32,
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
          child: Icon(
            Icons.repeat,
            color: _isRepeated ? widget.themeColor : Colors.white.withOpacity(0.6),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Share functionality
            },
            child: Icon(
              Icons.share_outlined,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFavorited = !_isFavorited;
              });
            },
            child: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? widget.themeColor : Colors.white.withOpacity(0.6),
              size: 28,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Add to playlist functionality
            },
            child: Icon(
              Icons.playlist_add,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

// Updated MusicTrack class to include artist
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