// lib/screen/shared/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoTitle;
  final String videoDescription;
  final String thumbnailPath;
  final String duration;
  final Color accentColor;
  final String tribalName;

  const VideoPlayerScreen({
    super.key,
    required this.videoTitle,
    required this.videoDescription,
    required this.thumbnailPath,
    required this.duration,
    required this.accentColor,
    required this.tribalName,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _showControls = true;
  double _currentPosition = 0.0;
  final double _totalDuration = 100.0;
  
  late AnimationController _controlsAnimationController;
  late AnimationController _playButtonController;
  late Animation<double> _controlsOpacity;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controlsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsAnimationController, curve: Curves.easeInOut),
    );
    _controlsAnimationController.forward();
    
    // Auto-hide controls after 3 seconds
    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _playButtonController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _controlsAnimationController.forward();
    if (_isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  void _hideControls() {
    _controlsAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _playButtonController.forward();
      _simulateVideoProgress();
      _hideControlsAfterDelay();
    } else {
      _playButtonController.reverse();
    }
  }

  void _simulateVideoProgress() {
    if (_isPlaying && _currentPosition < _totalDuration) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _isPlaying) {
          setState(() {
            _currentPosition += 1.0;
          });
          _simulateVideoProgress();
        }
      });
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _showControlsTemporarily,
          child: Stack(
            children: [
              // Video Content Area
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Video placeholder with thumbnail
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.accentColor.withOpacity(0.8),
                                  widget.accentColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              widget.thumbnailPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: widget.accentColor.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Dark overlay when paused
                          if (!_isPlaying)
                            Container(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          // Center play button
                          if (!_isPlaying)
                            Center(
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: widget.accentColor,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Top Controls
              AnimatedBuilder(
                animation: _controlsOpacity,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.tribalName.toUpperCase(),
                                style: TextStyle(
                                  color: widget.accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                widget.videoTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                // TODO: Add share functionality
                              },
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _controlsOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controlsOpacity.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress Bar
                            Row(
                              children: [
                                Text(
                                  _formatDuration(_currentPosition),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: widget.accentColor,
                                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                                      thumbColor: widget.accentColor,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      trackHeight: 3,
                                    ),
                                    child: Slider(
                                      value: _currentPosition,
                                      max: _totalDuration,
                                      onChanged: (value) {
                                        setState(() {
                                          _currentPosition = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Control Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildControlButton(
                                  icon: Icons.replay_10,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _currentPosition = (_currentPosition - 10).clamp(0, _totalDuration);
                                    });
                                  },
                                ),
                                _buildControlButton(
                                  icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                                  onTap: _togglePlayPause,
                                  isMainButton: true,
                                ),
                                _buildControlButton(
                                  icon: Icons.forward_10,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _currentPosition = (_currentPosition + 10).clamp(0, _totalDuration);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isMainButton = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMainButton ? 16 : 12),
        decoration: BoxDecoration(
          color: isMainButton 
            ? widget.accentColor.withOpacity(0.2)
            : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: isMainButton
            ? Border.all(color: widget.accentColor, width: 2)
            : null,
        ),
        child: Icon(
          icon,
          color: isMainButton ? widget.accentColor : Colors.white,
          size: isMainButton ? 32 : 24,
        ),
      ),
    );
  }
}