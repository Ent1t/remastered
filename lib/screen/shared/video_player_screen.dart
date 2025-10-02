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

    if (wasBuffering != isCurrentlyBuffering) {
      if (isCurrentlyBuffering) {
        _showControlsTemporarily();
      }
    }
    
    if (_videoController!.value.isPlaying && 
        !_isBuffering && 
        _showControls) {
      _hideControlsAfterDelay();
    }

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

  Widget _buildVideoPlayer(double screenWidth, double screenHeight) {
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: (screenWidth * 0.1).clamp(35.0, 60.0),
                height: (screenWidth * 0.1).clamp(35.0, 60.0),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: (screenHeight * 0.025).clamp(12.0, 24.0)),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth * 0.04).clamp(14.0, 20.0),
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.05).clamp(16.0, 32.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: (screenWidth * 0.15).clamp(50.0, 80.0),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(16.0, 24.0)),
                Text(
                  'Failed to load video',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.045).clamp(16.0, 22.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),
                Text(
                  'URL: ${widget.videoUrl ?? 'No URL'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: (screenWidth * 0.03).clamp(10.0, 14.0),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: (screenHeight * 0.04).clamp(24.0, 32.0)),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: (screenWidth * 0.06).clamp(20.0, 32.0),
                      vertical: (screenHeight * 0.015).clamp(10.0, 16.0),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                    ),
                  ),
                ),
              ],
            ),
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
                  return Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: (screenWidth * 0.15).clamp(50.0, 80.0),
                    ),
                  );
                },
              )
            : Image.asset(
                widget.thumbnailPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: (screenWidth * 0.15).clamp(50.0, 80.0),
                    ),
                  );
                },
              ),
      );
    }

    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        
        if (_isBuffering)
          Center(
            child: SizedBox(
              width: (screenWidth * 0.1).clamp(35.0, 60.0),
              height: (screenWidth * 0.1).clamp(35.0, 60.0),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
        
        if (!_videoController!.value.isPlaying && !_isBuffering && _showControls)
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: EdgeInsets.all((screenWidth * 0.06).clamp(20.0, 30.0)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: widget.accentColor,
                  size: (screenWidth * 0.12).clamp(40.0, 60.0),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _showControlsTemporarily,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: AspectRatio(
                        aspectRatio: _isVideoInitialized && _videoController != null
                            ? _videoController!.value.aspectRatio
                            : 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              (screenWidth * 0.03).clamp(10.0, 16.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: (screenWidth * 0.05).clamp(15.0, 30.0),
                                offset: Offset(
                                  0,
                                  (screenHeight * 0.015).clamp(8.0, 15.0),
                                ),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              (screenWidth * 0.03).clamp(10.0, 16.0),
                            ),
                            child: _buildVideoPlayer(screenWidth, screenHeight),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  if (_showControls)
                    AnimatedBuilder(
                      animation: _controlsOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _controlsOpacity.value,
                          child: Container(
                            padding: EdgeInsets.all(
                              (screenWidth * 0.05).clamp(16.0, 24.0),
                            ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: (screenWidth * 0.05).clamp(18.0, 24.0),
                                    ),
                                  ),
                                ),
                                SizedBox(width: (screenWidth * 0.03).clamp(10.0, 16.0)),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                        child: Text(
                                          widget.tribalName.toUpperCase(),
                                          style: TextStyle(
                                            color: widget.accentColor,
                                            fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: (screenHeight * 0.008).clamp(4.0, 8.0)),
                                      Text(
                                        widget.videoTitle,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  
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
                              padding: EdgeInsets.all(
                                (screenWidth * 0.05).clamp(16.0, 24.0),
                              ),
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
                                  Row(
                                    children: [
                                      Text(
                                        _formatDuration(_videoController!.value.position),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: (screenWidth * 0.03).clamp(10.0, 16.0)),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: widget.accentColor,
                                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                                            thumbColor: widget.accentColor,
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: (screenWidth * 0.015).clamp(5.0, 8.0),
                                            ),
                                            trackHeight: (screenWidth * 0.008).clamp(3.0, 4.0),
                                            overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: (screenWidth * 0.03).clamp(10.0, 16.0),
                                            ),
                                          ),
                                          child: Slider(
                                            value: _videoController!.value.position.inMilliseconds.toDouble(),
                                            max: _videoController!.value.duration.inMilliseconds.toDouble(),
                                            onChanged: (value) {
                                              _seekTo(Duration(milliseconds: value.toInt()));
                                            },
                                            onChangeStart: (value) {
                                              if (_videoController!.value.isPlaying) {
                                                _videoController!.pause();
                                              }
                                            },
                                            onChangeEnd: (value) {
                                              _videoController!.play();
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: (screenWidth * 0.03).clamp(10.0, 16.0)),
                                      Text(
                                        _formatDuration(_videoController!.value.duration),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: (screenHeight * 0.025).clamp(12.0, 24.0)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildControlButton(
                                        icon: Icons.replay_10,
                                        onTap: _skipBackward,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                      ),
                                      _buildControlButton(
                                        icon: _videoController!.value.isPlaying 
                                            ? Icons.pause 
                                            : Icons.play_arrow,
                                        onTap: _togglePlayPause,
                                        isMainButton: true,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                      ),
                                      _buildControlButton(
                                        icon: Icons.forward_10,
                                        onTap: _skipForward,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
    bool isMainButton = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          isMainButton 
            ? (screenWidth * 0.04).clamp(14.0, 20.0)
            : (screenWidth * 0.03).clamp(10.0, 16.0),
        ),
        decoration: BoxDecoration(
          color: isMainButton 
            ? widget.accentColor.withOpacity(0.2)
            : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: isMainButton
            ? Border.all(
                color: widget.accentColor, 
                width: (screenWidth * 0.006).clamp(2.0, 3.0),
              )
            : null,
        ),
        child: Icon(
          icon,
          color: isMainButton ? widget.accentColor : Colors.white,
          size: isMainButton 
            ? (screenWidth * 0.08).clamp(28.0, 40.0)
            : (screenWidth * 0.06).clamp(20.0, 28.0),
        ),
      ),
    );
  }
}