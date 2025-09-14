import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late FlutterTts _flutterTts;
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  String? _currentlyPlaying;

  // Language codes for TTS
  static const Map<String, String> _languageCodes = {
    'English': 'en-US',
    'Cebuano': 'fil-PH',
    'Ata Manobo': 'fil-PH',
    'Mansaka': 'fil-PH',
    'Mandaya': 'fil-PH',
  };

  // TTS settings for different languages
  static const Map<String, Map<String, double>> _languageSettings = {
    'English': {'speechRate': 0.5, 'pitch': 1.0},
    'Cebuano': {'speechRate': 0.4, 'pitch': 1.1},
    'Ata Manobo': {'speechRate': 0.4, 'pitch': 1.1},
    'Mansaka': {'speechRate': 0.4, 'pitch': 1.1},
    'Mandaya': {'speechRate': 0.4, 'pitch': 1.1},
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    _audioPlayer = AudioPlayer();

    // Configure TTS
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    // Set up TTS handlers
    _flutterTts.setCompletionHandler(() {
      _currentlyPlaying = null;
    });

    _flutterTts.setErrorHandler((msg) {
      print('TTS Error: $msg');
      _currentlyPlaying = null;
    });

    // Set up audio player handlers
    _audioPlayer.onPlayerComplete.listen((event) {
      _currentlyPlaying = null;
    });

    _isInitialized = true;
  }

  Future<bool> playPhrase({
    required String text,
    required String language,
    required String phraseKey,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any current playback
      await stopAudio();

      _currentlyPlaying = phraseKey;

      // Try to play recorded audio first
      String audioPath = _getAudioFilePath(phraseKey, language);
      bool hasRecordedAudio = await _checkAudioFileExists(audioPath);

      if (hasRecordedAudio) {
        await _audioPlayer.play(AssetSource(audioPath));
        return true;
      } else {
        // Fallback to TTS
        return await _playTTS(text, language);
      }
    } catch (e) {
      print('Error playing phrase: $e');
      _currentlyPlaying = null;
      return false;
    }
  }

  Future<bool> _playTTS(String text, String language) async {
    try {
      // Set language
      String languageCode = _languageCodes[language] ?? 'en-US';
      await _flutterTts.setLanguage(languageCode);

      // Set language-specific settings
      Map<String, double> settings = _languageSettings[language] ?? 
          {'speechRate': 0.5, 'pitch': 1.0};
      
      await _flutterTts.setSpeechRate(settings['speechRate']!);
      await _flutterTts.setPitch(settings['pitch']!);

      // Speak the text
      int result = await _flutterTts.speak(text);
      return result == 1; // 1 means success
    } catch (e) {
      print('TTS Error: $e');
      return false;
    }
  }

  String _getAudioFilePath(String phraseKey, String language) {
    String fileKey = phraseKey
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('?', '')
        .replaceAll('\'', '')
        .replaceAll('!', '');
    
    String langCode = language.toLowerCase().replaceAll(' ', '_');
    return 'audio/$langCode/$fileKey.mp3';
  }

  Future<bool> _checkAudioFileExists(String path) async {
    try {
      // For now, return false to use TTS
      // In production, you would check if the asset file exists
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopAudio() async {
    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();
      _currentlyPlaying = null;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  String? get currentlyPlaying => _currentlyPlaying;
  bool get isPlaying => _currentlyPlaying != null;

  Future<void> dispose() async {
    await stopAudio();
    _audioPlayer.dispose();
  }
}