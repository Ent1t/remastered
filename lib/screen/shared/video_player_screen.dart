import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoTitle;
  final String videoDescription;
  final String thumbnailPath;
  final String duration;
  final Color accentColor;
  final String tribalName;
  final String? videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoTitle,
    required this.videoDescription,
    required this.thumbnailPath,
    required this.duration,
    required this.accentColor,
    required this.tribalName,
    this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _showControls = true;
  bool _isVideoInitialized = false;
  bool _isVideoLoading = true;
  bool _isBuffering = false;
  String? _errorMessage;
  
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsOpacity;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsAnimationController, curve: Curves.easeInOut),
    );
    _controlsAnimationController.forward();
    
    _initializeVideo();
    _hideControlsAfterDelay();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() {
        _isVideoLoading = false;
        _errorMessage = 'No video URL provided';
      });
      debugPrint('ERROR: No video URL provided');
      return;
    }

    try {
      setState(() {
        _isVideoLoading = true;
        _errorMessage = null;
      });

      debugPrint('Initializing video: ${widget.videoUrl}');

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );

      // Add listener before initialization
      _videoController!.addListener(_videoListener);

      await _videoController!.initialize();
      
      debugPrint('Video initialized successfully');
      debugPrint('Video duration: ${_videoController!.value.duration}');
      debugPrint('Video size: ${_videoController!.value.size}');
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoLoading = false;
        });
      }

    } catch (e, stackTrace) {
      debugPrint('Error initializing video: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;

    final bool wasBuffering = _isBuffering;
    final bool isCurrentlyBuffering = _videoController!.value.isBuffering;
    
    setState(() {
      _isBuffering = isCurrentlyBuffering;
    });

    // Show/hide controls based on buffering state
    if (wasBuffering != isCurrentlyBuffering) {
      if (isCurrentlyBuffering) {
        _showControlsTemporarily();
      }
    }
    
    // Auto-hide controls if video is playing and not buffering
    if (_videoController!.value.isPlaying && 
        !_isBuffering && 
        _showControls) {
      _hideControlsAfterDelay();
    }

    // Handle video completion
    if (_videoController!.value.position >= _videoController!.value.duration) {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && 
          _videoController?.value.isPlaying == true && 
          !_isBuffering) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporarily() {
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      _controlsAnimationController.forward();
      if (_videoController?.value.isPlaying == true && !_isBuffering) {
        _hideControlsAfterDelay();
      }
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
    if (_videoController == null || !_isVideoInitialized) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
    
    _showControlsTemporarily();
  }

  void _seekTo(Duration position) {
    if (_videoController != null && _isVideoInitialized) {
      // Clamp position to valid range
      final duration = _videoController!.value.duration;
      final clampedPosition = position < Duration.zero 
          ? Duration.zero 
          : position > duration 
              ? duration 
              : position;
              
      _videoController!.seekTo(clampedPosition);
      _showControlsTemporarily();
    }
  }

  void _skipBackward() {
    if (_videoController == null || !_isVideoInitialized) return;
    
    HapticFeedback.lightImpact();
    final currentPosition = _videoController!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _seekTo(newPosition);
  }

  void _skipForward() {
    if (_videoController == null || !_isVideoInitialized) return;
    
    HapticFeedback.lightImpact();
    final currentPosition = _videoController!.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
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
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'URL: ${widget.videoUrl ?? 'No URL'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isVideoLoading = true;
                    _errorMessage = null;
                  });
                  _initializeVideo();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: widget.accentColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Container(
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
        child: widget.thumbnailPath.startsWith('http')
            ? Image.network(
                widget.thumbnailPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 60,
                    ),
                  );
                },
              )
            : Image.asset(
                widget.thumbnailPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 60,
                    ),
                  );
                },
              ),
      );
    }

    return Stack(
      children: [
        // Video Player
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain, // Changed from cover to contain to prevent cropping
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        
        // Buffering indicator
        if (_isBuffering)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        
        // Center play button when paused (and not buffering)
        if (!_videoController!.value.isPlaying && !_isBuffering && _showControls)
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
    );
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
                  aspectRatio: _isVideoInitialized && _videoController != null
                      ? _videoController!.value.aspectRatio
                      : 16 / 9,
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
                      child: _buildVideoPlayer(),
                    ),
                  ),
                ),
              ),
              
              // Top Controls
              if (_showControls)
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
                            const SizedBox(width: 48), // Maintains layout balance
                          ],
                        ),
                      ),
                    );
                  },
                ),
              
              // Bottom Controls
              if (_showControls && _isVideoInitialized && _videoController != null)
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
                                    _formatDuration(_videoController!.value.position),
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
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 12,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _videoController!.value.position.inMilliseconds.toDouble(),
                                        max: _videoController!.value.duration.inMilliseconds.toDouble(),
                                        onChanged: (value) {
                                          _seekTo(Duration(milliseconds: value.toInt()));
                                        },
                                        onChangeStart: (value) {
                                          // Pause video while seeking
                                          if (_videoController!.value.isPlaying) {
                                            _videoController!.pause();
                                          }
                                        },
                                        onChangeEnd: (value) {
                                          // Resume video after seeking if it was playing
                                          _videoController!.play();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _formatDuration(_videoController!.value.duration),
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
                                    onTap: _skipBackward,
                                  ),
                                  _buildControlButton(
                                    icon: _videoController!.value.isPlaying 
                                        ? Icons.pause 
                                        : Icons.play_arrow,
                                    onTap: _togglePlayPause,
                                    isMainButton: true,
                                  ),
                                  _buildControlButton(
                                    icon: Icons.forward_10,
                                    onTap: _skipForward,
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