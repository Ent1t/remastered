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
    'Mabuhay og Madayaw': 'assets/audio/sbom.mp3',
    
    // Greetings
    'Hello_English': 'assets/audio/english/ghe.mp3',
    'Hello_Cebuano': 'assets/audio/cebuano/ghc.mp3',
    'Hello_Kagan': 'assets/audio/kagan/greetings_hello_kagan.mp3',
    'Hello_Mansaka': 'assets/audio/mansaka/greetings_hello_mansaka.mp3',
    'Hello_Mandaya': 'assets/audio/mandaya/greetings_hello_mandaya.mp3',
    
    'Good morning_English': 'assets/audio/english/ggme.mp3',
    'Good morning_Cebuano': 'assets/audio/cebuano/gmbc.mp3',
    'Good morning_Kagan': 'assets/audio/kagan/greetings_goodmorning_kagan.mp3',
    'Good morning_Mansaka': 'assets/audio/mansaka/greetings_goodmorning_mansaka.mp3',
    'Good morning_Mandaya': 'assets/audio/mandaya/greetings_goodmorning_mandaya.mp3',
    
    'Good day_English': 'assets/audio/english/ggde.mp3',
    'Good day_Cebuano': 'assets/audio/cebuano/gmac.mp3',
    'Good day_Kagan': 'assets/audio/kagan/greetings_goodday_kagan.mp3',
    'Good day_Mansaka': 'assets/audio/mansaka/greetings_goodday_mansaka.mp3',
    'Good day_Mandaya': 'assets/audio/mandaya/greetings_goodday_mandaya.mp3',
    
    'How are you?_English': 'assets/audio/english/ghaye.mp3',
    'How are you?_Cebuano': 'assets/audio/cebuano/gkkc.mp3',
    'How are you?_Kagan': 'assets/audio/kagan/greetings_howareyou_kagan.mp3',
    'How are you?_Mansaka': 'assets/audio/mansaka/greetings_howareyou_mansaka.mp3',
    'How are you?_Mandaya': 'assets/audio/mandaya/greetings_howareyou_mandaya.mp3',
    
    // Basic Phrases
    'Thank you_English': 'assets/audio/english/btye.mp3',
    'Thank you_Cebuano': 'assets/audio/cebuano/bsc.mp3',
    'Thank you_Kagan': 'assets/audio/kagan/basic_thankyou_kagan.mp3',
    'Thank you_Mansaka': 'assets/audio/mansaka/basic_thankyou_mansaka.mp3',
    'Thank you_Mandaya': 'assets/audio/mandaya/basic_thankyou_mandaya.mp3',
    
    'Thank you very much_English': 'assets/audio/english/btyvme.mp3',
    'Thank you very much_Cebuano': 'assets/audio/cebuano/bsalamatkc.mp3',
    'Thank you very much_Kagan': 'assets/audio/kagan/basic_thankyouverymuch_kagan.mp3',
    'Thank you very much_Mansaka': 'assets/audio/mansaka/basic_thankyouverymuch_mansaka.mp3',
    'Thank you very much_Mandaya': 'assets/audio/mandaya/basic_thankyouverymuch_mandaya.mp3',
    
    'Please_English': 'assets/audio/english/bpe.mp3',
    'Please_Cebuano': 'assets/audio/cebuano/bpalihugc.mp3',
    'Please_Kagan': 'assets/audio/kagan/basic_please_kagan.mp3',
    'Please_Mansaka': 'assets/audio/mansaka/basic_please_mansaka.mp3',
    'Please_Mandaya': 'assets/audio/mandaya/basic_please_mandaya.mp3',
    
    'Excuse me_English': 'assets/audio/english/beme.mp3',
    'Excuse me_Cebuano': 'assets/audio/cebuano/bemc.mp3',
    'Excuse me_Kagan': 'assets/audio/kagan/basic_excuseme_kagan.mp3',
    'Excuse me_Mansaka': 'assets/audio/mansaka/basic_excuseme_mansaka.mp3',
    'Excuse me_Mandaya': 'assets/audio/mandaya/basic_excuseme_mandaya.mp3',
    
    // Questions
    'What is your name?_English': 'assets/audio/english/qwiyne.mp3',
    'What is your name?_Cebuano': 'assets/audio/cebuano/qunsainc.mp3',
    'What is your name?_Kagan': 'assets/audio/kagan/uestions_whatisyourname_kagan.mp3',
    'What is your name?_Mansaka': 'assets/audio/mansaka/questions_whatisyourname_mansaka.mp3',
    'What is your name?_Mandaya': 'assets/audio/mandaya/questions_whatisyourname_mandaya.mp3',
    
    'Where are you from?_English': 'assets/audio/english/qwayfe.mp3',
    'Where are you from?_Cebuano': 'assets/audio/cebuano/qtakc.mp3',
    'Where are you from?_Kagan': 'assets/audio/kagan/questions_whereareyoufrom_kagan.mp3',
    'Where are you from?_Mansaka': 'assets/audio/mansaka/questions_whereareyoufrom_mansaka.mp3',
    'Where are you from?_Mandaya': 'assets/audio/mandaya/questions_whereareyoufrom_mandaya.mp3',
    
    // Numbers
    'One_English': 'assets/audio/english/noe.mp3',
    'One_Cebuano': 'assets/audio/cebuano/nic.mp3',
    'One_Kagan': 'assets/audio/kagan/numbers_one_kagan.mp3',
    'One_Mansaka': 'assets/audio/mansaka/numbers_one_mansaka.mp3',
    'One_Mandaya': 'assets/audio/mandaya/numbers_one_mandaya.mp3',
    
    'Two_English': 'assets/audio/english/ntwoe.mp3',
    'Two_Cebuano': 'assets/audio/cebuano/nduhac.mp3',
    'Two_Kagan': 'assets/audio/kagan/numbers_two_kagan.mp3',
    'Two_Mansaka': 'assets/audio/mansaka/numbers_two_mansaka.mp3',
    'Two_Mandaya': 'assets/audio/mandaya/numbers_two_mandaya.mp3',
    
    'Three_English': 'assets/audio/english/nthreee.mp3',
    'Three_Cebuano': 'assets/audio/cebuano/ntuloc.mp3',
    'Three_Kagan': 'assets/audio/kagan/numbers_three_kagan.mp3',
    'Three_Mansaka': 'assets/audio/mansaka/numbers_three_mansaka.mp3',
    'Three_Mandaya': 'assets/audio/mandaya/numbers_three_mandaya.mp3',
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

  bool _hasAudioFile(String phraseKey, String language) {
    final audioKey = '${phraseKey}_$language';
    return _audioFilePaths.containsKey(audioKey);
  }

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

      final currentPhraseKey = '${phraseKey}_$language';

      setState(() {
        currentlyPlayingPhrase = currentPhraseKey;
        isPlaying = true;
      });

      bool success = await _audioService.playLocalAudio(
        audioPath: audioPath,
        phraseKey: currentPhraseKey,
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
        return;
      }

      HapticFeedback.lightImpact();
      _startAudioStatusMonitoring(currentPhraseKey);
      
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
        return;
      }

      HapticFeedback.lightImpact();
      _startAudioStatusMonitoring(phraseKey);
      
    } catch (e) {
      print('Error playing standalone audio: $e');
      setState(() {
        currentlyPlayingPhrase = null;
        isPlaying = false;
      });
    }
  }

  void _startAudioStatusMonitoring(String expectedPhraseKey) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      bool audioServiceIsPlaying = _audioService.isPlaying;
      String? audioServiceCurrentPhrase = _audioService.currentlyPlaying;
      
      if (!audioServiceIsPlaying || audioServiceCurrentPhrase != expectedPhraseKey) {
        if (currentlyPlayingPhrase == expectedPhraseKey) {
          setState(() {
            currentlyPlayingPhrase = null;
            isPlaying = false;
          });
        }
      } else {
        _startAudioStatusMonitoring(expectedPhraseKey);
      }
    });
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
            _buildScrollableContent(),
            if (!_isConnectedToInternet()) _buildOfflineIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureWelcomeSection(
    MapEntry<String, Map<String, Map<String, String>>> categoryEntry,
    double screenWidth,
    double screenHeight,
  ) {
    final phraseEntry = categoryEntry.value.entries.first;
    final phraseKey = phraseEntry.key;
    
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: (screenHeight * 0.02).clamp(12.0, 25.0)),
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: (screenHeight * 0.015).clamp(8.0, 18.0),
                  horizontal: (screenWidth * 0.04).clamp(12.0, 20.0),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADCB6).withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.celebration,
                          color: const Color(0xFFEADCB6),
                          size: (screenWidth * 0.04).clamp(14.0, 20.0),
                        ),
                        SizedBox(width: (screenWidth * 0.015).clamp(4.0, 8.0)),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Cultural Signature Phrase',
                              style: TextStyle(
                                color: const Color(0xFFEADCB6),
                                fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: (screenWidth * 0.015).clamp(4.0, 8.0)),
                        Icon(
                          Icons.celebration,
                          color: const Color(0xFFEADCB6),
                          size: (screenWidth * 0.04).clamp(14.0, 20.0),
                        ),
                      ],
                    ),
                    SizedBox(height: (screenHeight * 0.005).clamp(2.0, 6.0)),
                    Container(
                      width: (screenWidth * 0.15).clamp(40.0, 80.0),
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
              
              Container(
                padding: EdgeInsets.all((screenWidth * 0.05).clamp(12.0, 24.0)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10.5)),
                ),
                child: _buildSingleSignaturePhrase(phraseKey, screenWidth, screenHeight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleSignaturePhrase(String phraseKey, double screenWidth, double screenHeight) {
    bool hasStandaloneAudio = _audioFilePaths.containsKey(phraseKey);
    
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'FEATURED CULTURAL PHRASE',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.025).clamp(10.0, 12.0),
                    color: const Color(0xFFEADCB6).withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: (screenHeight * 0.015).clamp(8.0, 16.0)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  phraseKey,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.06).clamp(18.0, 28.0),
                    color: const Color(0xFFEADCB6),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.headphones,
                    size: (screenWidth * 0.035).clamp(12.0, 16.0),
                    color: Colors.white.withOpacity(0.6),
                  ),
                  SizedBox(width: (screenWidth * 0.01).clamp(4.0, 8.0)),
                  Flexible(
                    child: Text(
                      'Tap to hear pronunciation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (screenWidth * 0.03).clamp(10.0, 14.0),
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              if (availableLanguage == null && !hasStandaloneAudio) ...[
                SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_off,
                      size: (screenWidth * 0.03).clamp(10.0, 14.0),
                      color: Colors.orange.withOpacity(0.7),
                    ),
                    SizedBox(width: (screenWidth * 0.01).clamp(4.0, 8.0)),
                    Flexible(
                      child: Text(
                        'Audio not available',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.025).clamp(10.0, 12.0),
                          color: Colors.orange.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        if (availableLanguage != null || hasStandaloneAudio) ...[
          SizedBox(width: (screenWidth * 0.04).clamp(12.0, 20.0)),
          
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
              padding: EdgeInsets.all((screenWidth * 0.04).clamp(12.0, 18.0)),
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
                    ? Icon(
                        Icons.stop_rounded,
                        color: Colors.red,
                        size: (screenWidth * 0.08).clamp(24.0, 36.0),
                        key: const ValueKey('stop_signature'),
                      )
                    : Icon(
                        Icons.play_arrow_rounded,
                        color: const Color(0xFFEADCB6),
                        size: (screenWidth * 0.08).clamp(24.0, 36.0),
                        key: const ValueKey('play_signature'),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _isConnectedToInternet() {
    return false;
  }

  Widget _buildOfflineIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (screenWidth * 0.02).clamp(8.0, 12.0),
          vertical: (screenWidth * 0.01).clamp(4.0, 8.0),
        ),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.offline_bolt,
              color: Colors.white,
              size: (screenWidth * 0.04).clamp(14.0, 18.0),
            ),
            SizedBox(width: (screenWidth * 0.01).clamp(4.0, 6.0)),
            Text(
              'Offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      clipBehavior: Clip.none,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: screenHeight,
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
                padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.06).clamp(16.0, 30.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: (screenHeight * 0.05).clamp(20.0, 50.0)),
                    
                    _buildTitleSection(screenWidth, screenHeight),
                    
                    SizedBox(height: (screenHeight * 0.04).clamp(16.0, 40.0)),
                    
                    _buildSignatureWelcomeSection(
                      _phrases.entries.firstWhere((entry) => entry.key == 'Signature Phrase'),
                      screenWidth,
                      screenHeight,
                    ),
                    
                    SizedBox(height: (screenHeight * 0.04).clamp(16.0, 40.0)),
                    
                    _buildLanguageSelectionSection(screenWidth, screenHeight),
                    
                    SizedBox(height: (screenHeight * 0.04).clamp(16.0, 40.0)),
                    
                    if (isPlaying) _buildAudioStatusIndicator(screenWidth, screenHeight),
                    
                    ..._phrases.entries.where((entry) => entry.key != 'Signature Phrase').map((categoryEntry) {
                      return _buildCategorySection(categoryEntry, screenWidth, screenHeight);
                    }),
                    
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

  Widget _buildTitleSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Indigenous Language',
            style: TextStyle(
              color: Colors.white70,
              fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Phrase Book',
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.07).clamp(20.0, 32.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: (screenHeight * 0.01).clamp(6.0, 12.0)),
        Row(
          children: [
            Container(
              width: (screenWidth * 0.2).clamp(60.0, 100.0),
              height: 3,
              color: const Color(0xFFEADCB6),
            ),
            SizedBox(width: (screenWidth * 0.02).clamp(6.0, 10.0)),
            Icon(
              Icons.offline_bolt,
              color: const Color(0xFFEADCB6),
              size: (screenWidth * 0.04).clamp(14.0, 18.0),
            ),
            SizedBox(width: (screenWidth * 0.01).clamp(4.0, 6.0)),
            Flexible(
              child: Text(
                'Works Offline',
                style: TextStyle(
                  color: const Color(0xFFEADCB6),
                  fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelectionSection(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all((screenWidth * 0.05).clamp(12.0, 24.0)),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Language Selection',
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: (screenHeight * 0.02).clamp(10.0, 20.0)),
          
          _buildLanguageDropdown(
            value: _selectedSourceLanguage,
            items: _sourceLanguages,
            hint: 'Select source language',
            onChanged: (value) {
              setState(() {
                _selectedSourceLanguage = value!;
              });
            },
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          
          SizedBox(height: (screenHeight * 0.02).clamp(10.0, 20.0)),
          
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
                padding: EdgeInsets.all((screenWidth * 0.03).clamp(10.0, 14.0)),
                decoration: BoxDecoration(
                  color: const Color(0xFFEADCB6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEADCB6).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.swap_vert,
                  color: const Color(0xFFEADCB6),
                  size: (screenWidth * 0.06).clamp(20.0, 28.0),
                ),
              ),
            ),
          ),
          
          SizedBox(height: (screenHeight * 0.02).clamp(10.0, 20.0)),
          
          _buildLanguageDropdown(
            value: _selectedTargetLanguage,
            items: _targetLanguages,
            hint: 'Select target language',
            onChanged: (value) {
              setState(() {
                _selectedTargetLanguage = value!;
              });
            },
            screenWidth: screenWidth,
            screenHeight: screenHeight,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: (screenWidth * 0.04).clamp(12.0, 18.0)),
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
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.white70,
              fontSize: (screenWidth * 0.035).clamp(13.0, 16.0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          style: TextStyle(
            color: Colors.white,
            fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
          ),
          items: items.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(
                language,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAudioStatusIndicator(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.only(bottom: (screenHeight * 0.025).clamp(12.0, 30.0)),
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.04).clamp(12.0, 18.0),
        vertical: (screenHeight * 0.015).clamp(8.0, 16.0),
      ),
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
          SizedBox(
            width: (screenWidth * 0.05).clamp(18.0, 24.0),
            height: (screenWidth * 0.05).clamp(18.0, 24.0),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEADCB6)),
            ),
          ),
          SizedBox(width: (screenWidth * 0.03).clamp(10.0, 14.0)),
          Expanded(
            child: Text(
              'Playing: ${currentlyPlayingPhrase?.replaceAll('_', ' - ') ?? 'Audio'}',
              style: TextStyle(
                color: const Color(0xFFEADCB6),
                fontWeight: FontWeight.w500,
                fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          GestureDetector(
            onTap: _stopAudio,
            child: Icon(
              Icons.stop,
              color: const Color(0xFFEADCB6),
              size: (screenWidth * 0.05).clamp(18.0, 24.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    MapEntry<String, Map<String, Map<String, String>>> categoryEntry,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: (screenHeight * 0.015).clamp(8.0, 18.0)),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(categoryEntry.key),
                color: const Color(0xFFEADCB6),
                size: (screenWidth * 0.05).clamp(18.0, 24.0),
              ),
              SizedBox(width: (screenWidth * 0.02).clamp(6.0, 10.0)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    categoryEntry.key,
                    style: TextStyle(
                      color: const Color(0xFFEADCB6),
                      fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        ...categoryEntry.value.entries.map((phraseEntry) {
          return _buildPhraseCard(phraseEntry, screenWidth, screenHeight);
        }),
        
        SizedBox(height: (screenHeight * 0.025).clamp(12.0, 30.0)),
      ],
    );
  }

  Widget _buildPhraseCard(
    MapEntry<String, Map<String, String>> phraseEntry,
    double screenWidth,
    double screenHeight,
  ) {
    final sourceText = phraseEntry.value[_selectedSourceLanguage] ?? phraseEntry.key;
    final targetText = phraseEntry.value[_selectedTargetLanguage] ?? phraseEntry.key;
    final phraseKey = phraseEntry.key;
    
    return Container(
      margin: EdgeInsets.only(bottom: (screenHeight * 0.015).clamp(8.0, 18.0)),
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
            screenWidth: screenWidth,
            screenHeight: screenHeight,
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
            screenWidth: screenWidth,
            screenHeight: screenHeight,
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
    required double screenWidth,
    required double screenHeight,
  }) {
    final isCurrentlyPlaying = currentlyPlayingPhrase == '${phraseKey}_$language';
    final hasAudio = _hasAudioFile(phraseKey, language);
    
    return Padding(
      padding: EdgeInsets.all((screenWidth * 0.04).clamp(12.0, 18.0)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        language,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.03).clamp(11.0, 14.0),
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: (screenWidth * 0.02).clamp(6.0, 10.0)),
                    if (!hasAudio)
                      Icon(
                        Icons.volume_off,
                        size: (screenWidth * 0.03).clamp(10.0, 14.0),
                        color: Colors.orange.withOpacity(0.7),
                      ),
                  ],
                ),
                SizedBox(height: (screenHeight * 0.005).clamp(2.0, 6.0)),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                    color: textColor,
                    fontWeight: isSource ? FontWeight.w500 : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          
          SizedBox(width: (screenWidth * 0.03).clamp(10.0, 14.0)),
          
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
              padding: EdgeInsets.all((screenWidth * 0.02).clamp(8.0, 12.0)),
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
                    ? Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: (screenWidth * 0.06).clamp(20.0, 28.0),
                        key: const ValueKey('stop'),
                      )
                    : hasAudio
                        ? Icon(
                            isSource ? Icons.play_circle_outline : Icons.play_circle_filled,
                            color: textColor,
                            size: (screenWidth * 0.06).clamp(20.0, 28.0),
                            key: const ValueKey('play'),
                          )
                        : Icon(
                            Icons.volume_off,
                            color: Colors.grey,
                            size: (screenWidth * 0.06).clamp(20.0, 28.0),
                            key: const ValueKey('no_audio'),
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