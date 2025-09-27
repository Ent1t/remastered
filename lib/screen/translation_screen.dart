import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _selectedSourceLanguage = 'English';
  String _selectedTargetLanguage = 'Kagan';
  
  late AudioService _audioService;
  String? currentlyPlayingPhrase;
  bool isPlaying = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _sourceLanguages = ['English', 'Cebuano'];
  final List<String> _targetLanguages = ['Kagan', 'Mansaka', 'Mandaya'];

  // Audio file paths for each phrase and language combination
  final Map<String, String> _audioFilePaths = {
    // Signature Phrase - standalone audio (no language suffix)
    'Mabuhay og Madayaw': 'assets/audio/signature_mabuhay_og_madayaw.mp3.mp3',
    
    // Greetings
    'Hello_English': 'assets/audio/english/greetings_hello_english.mp3',
    'Hello_Cebuano': 'assets/audio/greetings_hello_cebuano.mp3',
    'Hello_Kagan': 'assets/audio/greetings_hello_kagan.mp3',
    'Hello_Mansaka': 'assets/audio/greetings_hello_mansaka.mp3',
    'Hello_Mandaya': 'assets/audio/greetings_hello_mandaya.mp3',
    
    'Good morning_English': 'assets/audio/english/greetings_goodmorning_english.mp3',
    'Good morning_Cebuano': 'assets/audio/greetings_goodmorning_cebuano.mp3',
    'Good morning_Kagan': 'assets/audio/greetings_goodmorning_kagan.mp3',
    'Good morning_Mansaka': 'assets/audio/greetings_goodmorning_mansaka.mp3',
    'Good morning_Mandaya': 'assets/audio/greetings_goodmorning_mandaya.mp3',
    
    'Good day_English': 'assets/audio/english/greetings_goodday_english.mp3',
    'Good day_Cebuano': 'assets/audio/greetings_goodday_cebuano.mp3',
    'Good day_Kagan': 'assets/audio/greetings_goodday_kagan.mp3',
    'Good day_Mansaka': 'assets/audio/greetings_goodday_mansaka.mp3',
    'Good day_Mandaya': 'assets/audio/greetings_goodday_mandaya.mp3',
    
    'How are you?_English': 'assets/audio/english/greetings_howareyou_english.mp3',
    'How are you?_Cebuano': 'assets/audio/greetings_howareyou_cebuano.mp3',
    'How are you?_Kagan': 'assets/audio/greetings_howareyou_kagan.mp3',
    'How are you?_Mansaka': 'assets/audio/greetings_howareyou_mansaka.mp3',
    'How are you?_Mandaya': 'assets/audio/greetings_howareyou_mandaya.mp3',
    
    // Basic Phrases
    'Thank you_English': 'assets/audio/english/basic_thankyou_english.mp3',
    'Thank you_Cebuano': 'assets/audio/basic_thankyou_cebuano.mp3',
    'Thank you_Kagan': 'assets/audio/basic_thankyou_kagan.mp3',
    'Thank you_Mansaka': 'assets/audio/basic_thankyou_mansaka.mp3',
    'Thank you_Mandaya': 'assets/audio/basic_thankyou_mandaya.mp3',
    
    'Thank you very much_English': 'assets/audio/english/basic_thankyouverymuch_english.mp3',
    'Thank you very much_Cebuano': 'assets/audio/basic_thankyouverymuch_cebuano.mp3',
    'Thank you very much_Kagan': 'assets/audio/basic_thankyouverymuch_kagan.mp3',
    'Thank you very much_Mansaka': 'assets/audio/basic_thankyouverymuch_mansaka.mp3',
    'Thank you very much_Mandaya': 'assets/audio/basic_thankyouverymuch_mandaya.mp3',
    
    'Please_English': 'assets/audio/english/basic_please_english.mp3',
    'Please_Cebuano': 'assets/audio/basic_please_cebuano.mp3',
    'Please_Kagan': 'assets/audio/basic_please_kagan.mp3',
    'Please_Mansaka': 'assets/audio/basic_please_mansaka.mp3',
    'Please_Mandaya': 'assets/audio/basic_please_mandaya.mp3',
    
    'Excuse me_English': 'assets/audio/english/basic_excuseme_english.mp3',
    'Excuse me_Cebuano': 'assets/audio/basic_excuseme_cebuano.mp3',
    'Excuse me_Kagan': 'assets/audio/basic_excuseme_kagan.mp3',
    'Excuse me_Mansaka': 'assets/audio/basic_excuseme_mansaka.mp3',
    'Excuse me_Mandaya': 'assets/audio/basic_excuseme_mandaya.mp3',
    
    // Questions
    'What is your name?_English': 'assets/audio/english/questions_whatisyourname_english.mp3',
    'What is your name?_Cebuano': 'assets/audio/questions_whatisyourname_cebuano.mp3',
    'What is your name?_Kagan': 'assets/audio/questions_whatisyourname_kagan.mp3',
    'What is your name?_Mansaka': 'assets/audio/questions_whatisyourname_mansaka.mp3',
    'What is your name?_Mandaya': 'assets/audio/questions_whatisyourname_mandaya.mp3',
    
    'Where are you from?_English': 'assets/audio/english/questions_whereareyoufrom_english.mp3',
    'Where are you from?_Cebuano': 'assets/audio/questions_whereareyoufrom_cebuano.mp3',
    'Where are you from?_Kagan': 'assets/audio/questions_whereareyoufrom_kagan.mp3',
    'Where are you from?_Mansaka': 'assets/audio/questions_whereareyoufrom_mansaka.mp3',
    'Where are you from?_Mandaya': 'assets/audio/questions_whereareyoufrom_mandaya.mp3',
    
    // Numbers
    'One_English': 'assets/audio/english/numbers_one_english.mp3',
    'One_Cebuano': 'assets/audio/numbers_one_cebuano.mp3',
    'One_Kagan': 'assets/audio/numbers_one_kagan.mp3',
    'One_Mansaka': 'assets/audio/numbers_one_mansaka.mp3',
    'One_Mandaya': 'assets/audio/numbers_one_mandaya.mp3',
    
    'Two_English': 'assets/audio/english/numbers_two_english.mp3',
    'Two_Cebuano': 'assets/audio/numbers_two_cebuano.mp3',
    'Two_Kagan': 'assets/audio/numbers_two_kagan.mp3',
    'Two_Mansaka': 'assets/audio/numbers_two_mansaka.mp3',
    'Two_Mandaya': 'assets/audio/numbers_two_mandaya.mp3',
    
    'Three_English': 'assets/audio/english/numbers_three_english.mp3',
    'Three_Cebuano': 'assets/audio/numbers_three_cebuano.mp3',
    'Three_Kagan': 'assets/audio/numbers_three_kagan.mp3',
    'Three_Mansaka': 'assets/audio/numbers_three_mansaka.mp3',
    'Three_Mandaya': 'assets/audio/numbers_three_mandaya.mp3',
  };

  // Local phrase data - optimized for offline use
  final Map<String, Map<String, Map<String, String>>> _phrases = {
    'Signature Phrase': {
      'Mabuhay og Madayaw': {
        'English': 'Mabuhay og Madayaw',
        'Cebuano': 'Mabuhay og Madayaw',
        'Kagan': 'Mabuhay og Madayaw',
        'Mansaka': 'Mabuhay og Madayaw',
        'Mandaya': 'Mabuhay og Madayaw',
      },
    },
    'Greetings': {
      'Hello': {
        'English': 'Hello',
        'Cebuano': 'Hello',
        'Kagan': 'Maayong adlaw',
        'Mansaka': 'Maayong adlaw',
        'Mandaya': 'Maayong adlaw',
      },
      'Good morning': {
        'English': 'Good morning',
        'Cebuano': 'Maayong buntag',
        'Kagan': 'Maayong ugma',
        'Mansaka': 'Maayong ugma',
        'Mandaya': 'Maayong ugma',
      },
      'Good day': {
        'English': 'Good day',
        'Cebuano': 'Maayong adlaw',
        'Kagan': 'Maayong adlaw',
        'Mansaka': 'Maayong adlaw',
        'Mandaya': 'Maayong adlaw',
      },
      'How are you?': {
        'English': 'How are you?',
        'Cebuano': 'Kumusta ka?',
        'Kagan': 'Kumusta ikaw?',
        'Mansaka': 'Kumusta ikaw?',
        'Mandaya': 'Kumusta ikaw?',
      },
    },
    'Basic Phrases': {
      'Thank you': {
        'English': 'Thank you',
        'Cebuano': 'Salamat',
        'Kagan': 'Salamat',
        'Mansaka': 'Salamat',
        'Mandaya': 'Salamat',
      },
      'Thank you very much': {
        'English': 'Thank you very much',
        'Cebuano': 'Salamat kaayo',
        'Kagan': 'Salamat kaayo',
        'Mansaka': 'Salamat kaayo',
        'Mandaya': 'Salamat kaayo',
      },
      'Please': {
        'English': 'Please',
        'Cebuano': 'Palihog',
        'Kagan': 'Palihog',
        'Mansaka': 'Palihog',
        'Mandaya': 'Palihog',
      },
      'Excuse me': {
        'English': 'Excuse me',
        'Cebuano': 'Excuse me',
        'Kagan': 'Pasaylua',
        'Mansaka': 'Pasaylua',
        'Mandaya': 'Pasaylua',
      },
    },
    'Questions': {
      'What is your name?': {
        'English': 'What is your name?',
        'Cebuano': 'Unsa imo ngalan?',
        'Kagan': 'Anu su ngaran mo?',
        'Mansaka': 'Anu su ngaran mo?',
        'Mandaya': 'Anu su ngaran mo?',
      },
      'Where are you from?': {
        'English': 'Where are you from?',
        'Cebuano': 'Taga asa ka?',
        'Kagan': 'Hain ka ginghalinan?',
        'Mansaka': 'Hain ka ginghalinan?',
        'Mandaya': 'Hain ka ginghalinan?',
      },
    },
    'Numbers': {
      'One': {
        'English': 'One',
        'Cebuano': 'Isa',
        'Kagan': 'Isa',
        'Mansaka': 'Isa',
        'Mandaya': 'Isa',
      },
      'Two': {
        'English': 'Two',
        'Cebuano': 'Duha',
        'Kagan': 'Duwa',
        'Mansaka': 'Duwa',
        'Mandaya': 'Duwa',
      },
      'Three': {
        'English': 'Three',
        'Cebuano': 'Tulo',
        'Kagan': 'Tulu',
        'Mansaka': 'Tulu',
        'Mandaya': 'Tulu',
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _initializeAudio();
  }

  void _initializeAudio() async {
    await _audioService.initialize();
  }

  // Check if audio file exists for the given phrase and language
  bool _hasAudioFile(String phraseKey, String language) {
    final audioKey = '${phraseKey}_$language';
    return _audioFilePaths.containsKey(audioKey);
  }

  // Get audio file path for the given phrase and language
  String? _getAudioFilePath(String phraseKey, String language) {
    final audioKey = '${phraseKey}_$language';
    return _audioFilePaths[audioKey];
  }

  Future<void> _playLocalAudio(String phraseKey, String language) async {
    try {
      final audioPath = _getAudioFilePath(phraseKey, language);
      if (audioPath == null) {
        _showAudioNotAvailableMessage(phraseKey, language);
        return;
      }

      setState(() {
        currentlyPlayingPhrase = '${phraseKey}_$language';
        isPlaying = true;
      });

      // Play local audio file
      bool success = await _audioService.playLocalAudio(
        audioPath: audioPath,
        phraseKey: '${phraseKey}_$language',
      );

      if (!success) {
        setState(() {
          currentlyPlayingPhrase = null;
          isPlaying = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to play audio file'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      HapticFeedback.lightImpact();
      _updatePlayingStatus();
      
    } catch (e) {
      print('Error playing local audio: $e');
      setState(() {
        currentlyPlayingPhrase = null;
        isPlaying = false;
      });
    }
  }

  Future<void> _playStandaloneAudio(String phraseKey) async {
    try {
      final audioPath = _audioFilePaths[phraseKey];
      if (audioPath == null) {
        _showAudioNotAvailableMessage(phraseKey, 'standalone');
        return;
      }

      setState(() {
        currentlyPlayingPhrase = phraseKey;
        isPlaying = true;
      });

      // Play local audio file
      bool success = await _audioService.playLocalAudio(
        audioPath: audioPath,
        phraseKey: phraseKey,
      );

      if (!success) {
        setState(() {
          currentlyPlayingPhrase = null;
          isPlaying = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to play audio file'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      HapticFeedback.lightImpact();
      _updatePlayingStatus();
      
    } catch (e) {
      print('Error playing standalone audio: $e');
      setState(() {
        currentlyPlayingPhrase = null;
        isPlaying = false;
      });
    }
  }

  void _showAudioNotAvailableMessage(String phraseKey, String language) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio not available for "$phraseKey" in $language'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _updatePlayingStatus() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _audioService.currentlyPlaying != currentlyPlayingPhrase) {
        setState(() {
          currentlyPlayingPhrase = _audioService.currentlyPlaying;
          isPlaying = _audioService.isPlaying;
        });
        
        if (isPlaying) {
          _updatePlayingStatus();
        }
      }
    });
  }

  Future<void> _stopAudio() async {
    await _audioService.stopAudio();
    setState(() {
      currentlyPlayingPhrase = null;
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content with background
            _buildScrollableContent(),
            
            // Show offline indicator if needed
            if (!_isConnectedToInternet()) _buildOfflineIndicator(),
          ],
        ),
      ),
    );
  }

  // Signature phrase section - standalone display
  Widget _buildSignatureWelcomeSection(MapEntry<String, Map<String, Map<String, String>>> categoryEntry) {
    final phraseEntry = categoryEntry.value.entries.first;
    final phraseKey = phraseEntry.key;
    
    return Column(
      children: [
        // Signature Welcome Card with unique design
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFEADCB6).withOpacity(0.3),
                const Color(0xFFD4AF37).withOpacity(0.2),
                const Color(0xFFEADCB6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEADCB6).withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEADCB6).withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with cultural pattern
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADCB6).withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.5)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Color(0xFFEADCB6),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Cultural Signature Phrase',
                          style: TextStyle(
                            color: Color(0xFFEADCB6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.celebration,
                          color: Color(0xFFEADCB6),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFEADCB6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content area - single phrase display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10.5)),
                ),
                child: _buildSingleSignaturePhrase(phraseKey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSignaturePhrase(String phraseKey) {
    // Check if there's a standalone audio file (without language suffix)
    bool hasStandaloneAudio = _audioFilePaths.containsKey(phraseKey);
    
    // If no standalone audio, try to find audio for the phrase in available languages
    String? availableLanguage;
    if (!hasStandaloneAudio) {
      for (String lang in [..._sourceLanguages, ..._targetLanguages]) {
        if (_hasAudioFile(phraseKey, lang)) {
          availableLanguage = lang;
          break;
        }
      }
    }
    
    final isCurrentlyPlaying = hasStandaloneAudio
        ? currentlyPlayingPhrase == phraseKey
        : availableLanguage != null && currentlyPlayingPhrase == '${phraseKey}_$availableLanguage';
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                'FEATURED CULTURAL PHRASE',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFFEADCB6).withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                phraseKey,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFEADCB6),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.headphones,
                    size: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to hear pronunciation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              if (availableLanguage == null && !hasStandaloneAudio) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_off,
                      size: 12,
                      color: Colors.orange.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Audio not available',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        if (availableLanguage != null || hasStandaloneAudio) ...[
          const SizedBox(width: 16),
          
          GestureDetector(
            onTap: () {
              if (isCurrentlyPlaying) {
                _stopAudio();
              } else {
                if (hasStandaloneAudio) {
                  _playStandaloneAudio(phraseKey);
                } else {
                  _playLocalAudio(phraseKey, availableLanguage!);
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentlyPlaying
                    ? Colors.red.withOpacity(0.2)
                    : const Color(0xFFEADCB6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isCurrentlyPlaying
                      ? Colors.red.withOpacity(0.5)
                      : const Color(0xFFEADCB6).withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrentlyPlaying
                        ? Colors.red.withOpacity(0.3)
                        : const Color(0xFFEADCB6).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isCurrentlyPlaying
                    ? const Icon(
                        Icons.stop_rounded,
                        color: Colors.red,
                        size: 32,
                        key: ValueKey('stop_signature'),
                      )
                    : const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFEADCB6),
                        size: 32,
                        key: ValueKey('play_signature'),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Placeholder for internet connectivity check
  bool _isConnectedToInternet() {
    return false; // Assuming offline-first approach
  }

  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.offline_bolt,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      clipBehavior: Clip.none,
      child: Column(
        children: [
          // Single Zone with background image
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tribal_pattern.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Title Section
                    _buildTitleSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Signature Phrase Section
                    _buildSignatureWelcomeSection(_phrases.entries.firstWhere((entry) => entry.key == 'Signature Phrase')),
                    
                    const SizedBox(height: 30),
                    
                    // Language Selection Section
                    _buildLanguageSelectionSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Audio Status Indicator (only when playing)
                    if (isPlaying) _buildAudioStatusIndicator(),
                    
                    // Rest of the Phrases
                    ..._phrases.entries.where((entry) => entry.key != 'Signature Phrase').map((categoryEntry) {
                      return _buildCategorySection(categoryEntry);
                    }),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indigenous Language',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        const Text(
          'Phrase Book',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 3,
              color: const Color(0xFFEADCB6),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.offline_bolt,
              color: Color(0xFFEADCB6),
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              'Works Offline',
              style: TextStyle(
                color: Color(0xFFEADCB6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEADCB6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language Selection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildLanguageDropdown(
            value: _selectedSourceLanguage,
            items: _sourceLanguages,
            hint: 'Select source language',
            onChanged: (value) {
              setState(() {
                _selectedSourceLanguage = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (_sourceLanguages.contains(_selectedTargetLanguage)) {
                  setState(() {
                    String temp = _selectedSourceLanguage;
                    _selectedSourceLanguage = _selectedTargetLanguage;
                    _selectedTargetLanguage = temp;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADCB6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEADCB6).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: Color(0xFFEADCB6),
                  size: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildLanguageDropdown(
            value: _selectedTargetLanguage,
            items: _targetLanguages,
            hint: 'Select target language',
            onChanged: (value) {
              setState(() {
                _selectedTargetLanguage = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white70)),
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items: items.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAudioStatusIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEADCB6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEADCB6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEADCB6)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Playing: ${currentlyPlayingPhrase?.replaceAll('_', ' - ') ?? 'Audio'}',
              style: const TextStyle(
                color: Color(0xFFEADCB6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _stopAudio,
            child: const Icon(
              Icons.stop,
              color: Color(0xFFEADCB6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(MapEntry<String, Map<String, Map<String, String>>> categoryEntry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(categoryEntry.key),
                color: const Color(0xFFEADCB6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                categoryEntry.key,
                style: const TextStyle(
                  color: Color(0xFFEADCB6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        ...categoryEntry.value.entries.map((phraseEntry) {
          return _buildPhraseCard(phraseEntry);
        }),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhraseCard(MapEntry<String, Map<String, String>> phraseEntry) {
    final sourceText = phraseEntry.value[_selectedSourceLanguage] ?? phraseEntry.key;
    final targetText = phraseEntry.value[_selectedTargetLanguage] ?? phraseEntry.key;
    final phraseKey = phraseEntry.key;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildPhraseRow(
            language: _selectedSourceLanguage,
            text: sourceText,
            phraseKey: phraseKey,
            isSource: true,
            textColor: Colors.white70,
          ),
          
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
          
          _buildPhraseRow(
            language: _selectedTargetLanguage,
            text: targetText,
            phraseKey: phraseKey,
            isSource: false,
            textColor: const Color(0xFFEADCB6),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseRow({
    required String language,
    required String text,
    required String phraseKey,
    required bool isSource,
    required Color textColor,
  }) {
    final isCurrentlyPlaying = currentlyPlayingPhrase == '${phraseKey}_$language';
    final hasAudio = _hasAudioFile(phraseKey, language);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!hasAudio)
                      Icon(
                        Icons.volume_off,
                        size: 12,
                        color: Colors.orange.withOpacity(0.7),
                      ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: textColor,
                    fontWeight: isSource ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: hasAudio ? () {
              if (isCurrentlyPlaying) {
                _stopAudio();
              } else {
                _playLocalAudio(phraseKey, language);
              }
            } : () {
              _showAudioNotAvailableMessage(phraseKey, language);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentlyPlaying 
                    ? Colors.red.withOpacity(0.2)
                    : hasAudio 
                        ? textColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isCurrentlyPlaying
                    ? const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: 24,
                        key: ValueKey('stop'),
                      )
                    : hasAudio
                        ? Icon(
                            isSource ? Icons.play_circle_outline : Icons.play_circle_filled,
                            color: textColor,
                            size: 24,
                            key: const ValueKey('play'),
                          )
                        : const Icon(
                            Icons.volume_off,
                            color: Colors.grey,
                            size: 24,
                            key: ValueKey('no_audio'),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural welcome':
        return Icons.celebration;
      case 'greetings':
        return Icons.waving_hand;
      case 'basic phrases':
        return Icons.chat_bubble_outline;
      case 'questions':
        return Icons.help_outline;
      case 'numbers':
        return Icons.numbers;
      case 'food':
        return Icons.restaurant;
      case 'directions':
        return Icons.directions;
      default:
        return Icons.translate;
    }
  }
}