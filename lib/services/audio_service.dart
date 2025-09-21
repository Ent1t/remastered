import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  late AudioPlayer _audioPlayer;
  String? _currentlyPlaying;
  bool _isPlaying = false;
  bool _isInitialized = false;

  String? get currentlyPlaying => _currentlyPlaying;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _audioPlayer = AudioPlayer();
      
      // Listen to player state changes
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        _isPlaying = state == PlayerState.playing;
        
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          _currentlyPlaying = null;
          _isPlaying = false;
        }
      });

      // Listen to player complete events
      _audioPlayer.onPlayerComplete.listen((_) {
        _currentlyPlaying = null;
        _isPlaying = false;
      });

      _isInitialized = true;
      print('AudioService initialized successfully');
    } catch (e) {
      print('Error initializing AudioService: $e');
      _isInitialized = false;
    }
  }

  // Play local audio file from assets
  Future<bool> playLocalAudio({
    required String audioPath,
    required String phraseKey,
  }) async {
    try {
      if (!_isInitialized) {
        print('AudioService not initialized');
        return false;
      }

      // Stop any currently playing audio
      await stopAudio();

      // Check if the audio file exists in assets
      if (!await _audioFileExists(audioPath)) {
        print('Audio file not found: $audioPath');
        return false;
      }

      // Play the audio file
      await _audioPlayer.play(AssetSource(audioPath.replaceFirst('assets/', '')));
      
      _currentlyPlaying = phraseKey;
      _isPlaying = true;
      
      print('Playing local audio: $audioPath for phrase: $phraseKey');
      return true;
      
    } catch (e) {
      print('Error playing local audio: $e');
      _currentlyPlaying = null;
      _isPlaying = false;
      return false;
    }
  }

  // Check if audio file exists in assets
  Future<bool> _audioFileExists(String audioPath) async {
    try {
      await rootBundle.load(audioPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stop currently playing audio
  Future<void> stopAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      _currentlyPlaying = null;
      _isPlaying = false;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Pause currently playing audio
  Future<void> pauseAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
        _isPlaying = false;
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  // Resume paused audio
  Future<void> resumeAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Get current audio position
  Future<Duration> getCurrentPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      print('Error getting current position: $e');
      return Duration.zero;
    }
  }

  // Get total audio duration
  Future<Duration> getDuration() async {
    try {
      return await _audioPlayer.getDuration() ?? Duration.zero;
    } catch (e) {
      print('Error getting duration: $e');
      return Duration.zero;
    }
  }

  // Seek to specific position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking to position: $e');
    }
  }

  // Preload multiple audio files for better performance
  Future<void> preloadAudioFiles(List<String> audioPaths) async {
    try {
      for (String audioPath in audioPaths) {
        if (await _audioFileExists(audioPath)) {
          // You can implement preloading logic here if needed
          // For now, we'll just verify the files exist
          print('Audio file verified: $audioPath');
        } else {
          print('Audio file missing: $audioPath');
        }
      }
    } catch (e) {
      print('Error preloading audio files: $e');
    }
  }

  // Legacy method for backward compatibility with TTS
  @deprecated
  Future<bool> playPhrase({
    required String text,
    required String language,
    required String phraseKey,
  }) async {
    // This method is deprecated in favor of playLocalAudio
    // You can implement TTS fallback here if needed
    print('playPhrase is deprecated. Use playLocalAudio instead.');
    return false;
  }

  // Get list of available audio files
  Future<List<String>> getAvailableAudioFiles(List<String> expectedFiles) async {
    List<String> availableFiles = [];
    
    for (String filePath in expectedFiles) {
      if (await _audioFileExists(filePath)) {
        availableFiles.add(filePath);
      }
    }
    
    return availableFiles;
  }

  // Check audio system health
  Future<Map<String, dynamic>> getAudioSystemStatus() async {
    return {
      'isInitialized': _isInitialized,
      'isPlaying': _isPlaying,
      'currentlyPlaying': _currentlyPlaying,
      'playerState': _audioPlayer.state.toString(),
    };
  }

  void dispose() {
    try {
      _audioPlayer.dispose();
      _currentlyPlaying = null;
      _isPlaying = false;
      _isInitialized = false;
      print('AudioService disposed');
    } catch (e) {
      print('Error disposing AudioService: $e');
    }
  }
}