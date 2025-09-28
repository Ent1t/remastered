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

      // FIX 1: Handle the asset path correctly
      // Remove 'assets/' prefix for AssetSource since audioplayers expects relative path from assets
      String assetPath = audioPath;
      if (assetPath.startsWith('assets/')) {
        assetPath = assetPath.substring(7); // Remove 'assets/' prefix
      }

      // Play the audio file
      await _audioPlayer.play(AssetSource(assetPath));
      
      _currentlyPlaying = phraseKey;
      _isPlaying = true;
      
      print('Playing local audio: $assetPath for phrase: $phraseKey');
      return true;
      
    } catch (e) {
      print('Error playing local audio: $e');
      print('Attempted path: $audioPath');
      _currentlyPlaying = null;
      _isPlaying = false;
      return false;
    }
  }

  // FIX 2: Improved asset existence check with better error handling
  Future<bool> _audioFileExists(String audioPath) async {
    try {
      final ByteData data = await rootBundle.load(audioPath);
      print('Audio file found: $audioPath (${data.lengthInBytes} bytes)');
      return true;
    } catch (e) {
      print('Audio file check failed for: $audioPath - Error: $e');
      
      // FIX 3: Try alternative path formats if first attempt fails
      if (audioPath.startsWith('assets/')) {
        // Try without 'assets/' prefix
        try {
          final String altPath = audioPath.substring(7);
          await rootBundle.load(altPath);
          print('Audio file found with alternative path: $altPath');
          return true;
        } catch (e2) {
          print('Alternative path also failed: altPath - Error: $e2');
        }
      } else {
        // Try with 'assets/' prefix
        try {
          final String altPath = 'assets/$audioPath';
          await rootBundle.load(altPath);
          print('Audio file found with assets prefix: $altPath');
          return true;
        } catch (e2) {
          print('Assets prefix path also failed: assets/$audioPath - Error: $e2');
        }
      }
      
      return false;
    }
  }

  // FIX 4: Improved stop method with better state handling
  Future<void> stopAudio() async {
    try {
      // Check current state before attempting to stop
      final currentState = _audioPlayer.state;
      print('Current player state before stop: $currentState');
      
      if (currentState == PlayerState.playing || 
          currentState == PlayerState.paused) {
        await _audioPlayer.stop();
        print('Audio stopped successfully');
      }
      
      _currentlyPlaying = null;
      _isPlaying = false;
    } catch (e) {
      print('Error stopping audio: $e');
      // Force reset state even if stop fails
      _currentlyPlaying = null;
      _isPlaying = false;
    }
  }

  // Pause currently playing audio
  Future<void> pauseAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
        _isPlaying = false;
        print('Audio paused');
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
        print('Audio resumed');
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

  // FIX 5: Enhanced preload with detailed logging
  Future<void> preloadAudioFiles(List<String> audioPaths) async {
    print('Preloading ${audioPaths.length} audio files...');
    int foundCount = 0;
    int missingCount = 0;
    
    try {
      for (String audioPath in audioPaths) {
        if (await _audioFileExists(audioPath)) {
          foundCount++;
          print('✅ Audio file verified: $audioPath');
        } else {
          missingCount++;
          print('❌ Audio file missing: $audioPath');
        }
      }
      
      print('Preload summary: $foundCount found, $missingCount missing');
    } catch (e) {
      print('Error preloading audio files: $e');
    }
  }

  // FIX 6: Debug method to list all available assets
  Future<List<String>> debugListAssets() async {
    List<String> availableAssets = [];
    
    try {
      // This is a basic implementation - you might need to manually list expected files
      // since Flutter doesn't provide a direct way to list all assets at runtime
      print('Debug: Checking asset availability...');
      
      // You can expand this list with all your expected audio files
      List<String> expectedFiles = [
        'assets/audio/signature_mabuhay_og_madayaw.mp3',
        'assets/audio/english/greetings_hello_english.mp3',
        'assets/audio/english/basic_thankyou_english.mp3',
        // Add more files as needed
      ];
      
      for (String file in expectedFiles) {
        if (await _audioFileExists(file)) {
          availableAssets.add(file);
        }
      }
      
    } catch (e) {
      print('Error listing assets: $e');
    }
    
    return availableAssets;
  }

  // Get list of available audio files
  Future<List<String>> getAvailableAudioFiles(List<String> expectedFiles) async {
    List<String> availableFiles = [];
    
    for (String filePath in expectedFiles) {
      if (await _audioFileExists(filePath)) {
        availableFiles.add(filePath);
      }
    }
    
    print('Available files: ${availableFiles.length}/${expectedFiles.length}');
    return availableFiles;
  }

  // Check audio system health
  Future<Map<String, dynamic>> getAudioSystemStatus() async {
    return {
      'isInitialized': _isInitialized,
      'isPlaying': _isPlaying,
      'currentlyPlaying': _currentlyPlaying,
      'playerState': _audioPlayer.state.toString(),
      'timestamp': DateTime.now().toString(),
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