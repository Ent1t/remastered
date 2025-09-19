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

  // Language codes for TTS
  final Map<String, String> _languageCodes = {
    'English': 'en-US',
    'Cebuano': 'fil-PH',
    'Kagan': 'fil-PH',
    'Mansaka': 'fil-PH',
    'Mandaya': 'fil-PH',
  };

  // Local phrase data
  final Map<String, Map<String, Map<String, String>>> _phrases = {
    'Greetings': {
      'Hello': {
        'English': 'Hello',
        'Cebuano': 'Kumusta',
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
      'Please': {
        'English': 'Please',
        'Cebuano': 'Palihog',
        'Kagan': 'Palihog',
        'Mansaka': 'Palihog',
        'Mandaya': 'Palihog',
      },
      'Excuse me': {
        'English': 'Excuse me',
        'Cebuano': 'Pasensya na',
        'Kagan': 'Pasaylua',
        'Mansaka': 'Pasaylua',
        'Mandaya': 'Pasaylua',
      },
    },
    'Questions': {
      'What is your name?': {
        'English': 'What is your name?',
        'Cebuano': 'Unsa imong ngalan?',
        'Kagan': 'Anu su ngaran mo?',
        'Mansaka': 'Anu su ngaran mo?',
        'Mandaya': 'Anu su ngaran mo?',
      },
      'Where are you from?': {
        'English': 'Where are you from?',
        'Cebuano': 'Asa ka gikan?',
        'Kagan': 'Hain ka ginghalinan?',
        'Mansaka': 'Hain ka ginghalinan?',
        'Mandaya': 'Hain ka ginghalinan?',
      },
      'How much is this?': {
        'English': 'How much is this?',
        'Cebuano': 'Pila ni?',
        'Kagan': 'Pira kini?',
        'Mansaka': 'Pira kini?',
        'Mandaya': 'Pira kini?',
      },
    },
    'Numbers': {
      'One': {
        'English': 'One',
        'Cebuano': 'Usa',
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
      'Four': {
        'English': 'Four',
        'Cebuano': 'Upat',
        'Kagan': 'Upat',
        'Mansaka': 'Upat',
        'Mandaya': 'Upat',
      },
      'Five': {
        'English': 'Five',
        'Cebuano': 'Lima',
        'Kagan': 'Lima',
        'Mansaka': 'Lima',
        'Mandaya': 'Lima',
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

  Future<void> _speakText(String text, String language, String phraseKey) async {
    try {
      setState(() {
        currentlyPlayingPhrase = phraseKey;
        isPlaying = true;
      });

      bool success = await _audioService.playPhrase(
        text: text,
        language: language,
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
              content: Text('Unable to play audio'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      HapticFeedback.lightImpact();
      _updatePlayingStatus();
      
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        currentlyPlayingPhrase = null;
        isPlaying = false;
      });
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
                    const SizedBox(height: 40), // Reduced top spacing
                    
                    // Title Section
                    _buildTitleSection(),
                    
                    const SizedBox(height: 40),
                    
                    // Language Selection Section
                    _buildLanguageSelectionSection(),
                    
                    const SizedBox(height: 40),
                    
                    // Phrases Section
                    _buildPhrasesSection(),
                    
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

  Widget _buildTopAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'PHRASE TRANSLATOR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            if (isPlaying)
              GestureDetector(
                onTap: _stopAudio,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
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
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 3,
          color: const Color(0xFFEADCB6),
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
              'Playing: ${currentlyPlayingPhrase ?? 'Audio'}',
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

  Widget _buildPhrasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Phrases',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        ..._phrases.entries.map((categoryEntry) {
          return _buildCategorySection(categoryEntry);
        }),
      ],
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
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
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
            onTap: () {
              if (isCurrentlyPlaying) {
                _stopAudio();
              } else {
                _speakText(text, language, '${phraseKey}_$language');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentlyPlaying 
                    ? Colors.red.withOpacity(0.2)
                    : textColor.withOpacity(0.1),
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
                    : Icon(
                        isSource ? Icons.play_circle_outline : Icons.play_circle_filled,
                        color: textColor,
                        size: 24,
                        key: const ValueKey('play'),
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