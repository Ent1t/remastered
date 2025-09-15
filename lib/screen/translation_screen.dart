import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../services/audio_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _selectedSourceLanguage = 'English';
  String _selectedTargetLanguage = 'Ata Manobo';
  
  late AudioService _audioService;
  String? currentlyPlayingPhrase;
  bool isPlaying = false;
  bool isLoading = true;
  String? errorMessage;

  final List<String> _sourceLanguages = ['English', 'Cebuano'];
  final List<String> _targetLanguages = ['Ata Manobo', 'Mansaka', 'Mandaya'];

  // Language codes for TTS
  final Map<String, String> _languageCodes = {
    'English': 'en-US',
    'Cebuano': 'fil-PH',
    'Ata Manobo': 'fil-PH',
    'Mansaka': 'fil-PH',
    'Mandaya': 'fil-PH',
  };

  // Data from API or fallback
  final Map<String, Map<String, Map<String, String>>> _phrases = {};
  List<dynamic> _categories = [];
  List<dynamic> _phrasesData = [];
  List<dynamic> _languages = [];

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _initializeAudio();
    _loadDataFromAPI();
  }

  void _initializeAudio() async {
    await _audioService.initialize();
  }

  Future<void> _loadDataFromAPI() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // First, let's test what endpoints are available
      await _testEndpoints();
      
      // Try to fetch all required data
      bool success = await _tryFetchFromAPI();
      
      if (!success) {
        // If API fails, use fallback data
        print('API failed, using fallback data');
        _useFallbackData();
      }

      // Organize data into the expected structure
      _organizePhraseData();

    } catch (e) {
      print('Error in _loadDataFromAPI: $e');
      // Use fallback data if API completely fails
      _useFallbackData();
      _organizePhraseData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testEndpoints() async {
    // Test which endpoints are available
    List<String> testEndpoints = [
      'languages',
      'categories', 
      'phrases',
      'language', // singular
      'category',  // singular
      'phrase',    // singular
    ];

    for (String endpoint in testEndpoints) {
      try {
        final response = await http.get(
          Uri.parse('${Config.baseUrl}$endpoint'),
          headers: {'Content-Type': 'application/json'},
        );
        print('Endpoint $endpoint: Status ${response.statusCode}');
        if (response.statusCode == 200) {
          print('Available endpoint found: $endpoint');
        }
      } catch (e) {
        print('Error testing endpoint $endpoint: $e');
      }
    }
  }

  Future<bool> _tryFetchFromAPI() async {
    try {
      bool hasData = false;
      
      // Try to fetch languages
      try {
        await _fetchLanguages();
        hasData = true;
      } catch (e) {
        print('Languages fetch failed: $e');
      }

      // Try to fetch categories  
      try {
        await _fetchCategories();
        hasData = true;
      } catch (e) {
        print('Categories fetch failed: $e');
      }

      // Try to fetch phrases
      try {
        await _fetchPhrases();
        hasData = true;
      } catch (e) {
        print('Phrases fetch failed: $e');
      }

      return hasData;
    } catch (e) {
      print('API fetch completely failed: $e');
      return false;
    }
  }

  Future<void> _fetchLanguages() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}languages'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _languages = data['data'] ?? data ?? [];
    } else {
      throw Exception('Languages endpoint failed: ${response.statusCode}');
    }
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}categories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _categories = data['data'] ?? data ?? [];
    } else {
      throw Exception('Categories endpoint failed: ${response.statusCode}');
    }
  }

  Future<void> _fetchPhrases() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}phrases'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _phrasesData = data['data'] ?? data ?? [];
    } else {
      throw Exception('Phrases endpoint failed: ${response.statusCode}');
    }
  }

  void _useFallbackData() {
    // Fallback data when API is not available
    _languages = [
      {'id': 1, 'name': 'English', 'code': 'en'},
      {'id': 2, 'name': 'Cebuano', 'code': 'ceb'},
      {'id': 3, 'name': 'Ata Manobo', 'code': 'atm'},
      {'id': 4, 'name': 'Mansaka', 'code': 'msk'},
      {'id': 5, 'name': 'Mandaya', 'code': 'mry'},
    ];

    _categories = [
      {'id': 1, 'name': 'Greetings'},
      {'id': 2, 'name': 'Basic Phrases'},
      {'id': 3, 'name': 'Questions'},
      {'id': 4, 'name': 'Numbers'},
    ];

    _phrasesData = [
      {
        'id': 1,
        'category_id': 1,
        'key': 'Hello',
        'english': 'Hello',
        'en': 'Hello',
        'ceb': 'Kumusta',
        'atm': 'Maayong adlaw',
        'msk': 'Maayong adlaw',
        'mry': 'Maayong adlaw',
      },
      {
        'id': 2,
        'category_id': 1,
        'key': 'Good morning',
        'english': 'Good morning',
        'en': 'Good morning',
        'ceb': 'Maayong buntag',
        'atm': 'Maayong ugma',
        'msk': 'Maayong ugma',
        'mry': 'Maayong ugma',
      },
      {
        'id': 3,
        'category_id': 1,
        'key': 'How are you?',
        'english': 'How are you?',
        'en': 'How are you?',
        'ceb': 'Kumusta ka?',
        'atm': 'Kumusta ikaw?',
        'msk': 'Kumusta ikaw?',
        'mry': 'Kumusta ikaw?',
      },
      {
        'id': 4,
        'category_id': 2,
        'key': 'Thank you',
        'english': 'Thank you',
        'en': 'Thank you',
        'ceb': 'Salamat',
        'atm': 'Salamat',
        'msk': 'Salamat',
        'mry': 'Salamat',
      },
      {
        'id': 5,
        'category_id': 2,
        'key': 'Please',
        'english': 'Please',
        'en': 'Please',
        'ceb': 'Palihog',
        'atm': 'Palihog',
        'msk': 'Palihog',
        'mry': 'Palihog',
      },
      {
        'id': 6,
        'category_id': 3,
        'key': 'What is your name?',
        'english': 'What is your name?',
        'en': 'What is your name?',
        'ceb': 'Unsa imong ngalan?',
        'atm': 'Anu su ngaran mo?',
        'msk': 'Anu su ngaran mo?',
        'mry': 'Anu su ngaran mo?',
      },
      {
        'id': 7,
        'category_id': 3,
        'key': 'Where are you from?',
        'english': 'Where are you from?',
        'en': 'Where are you from?',
        'ceb': 'Asa ka gikan?',
        'atm': 'Hain ka ginghalinan?',
        'msk': 'Hain ka ginghalinan?',
        'mry': 'Hain ka ginghalinan?',
      },
      {
        'id': 8,
        'category_id': 4,
        'key': 'One',
        'english': 'One',
        'en': 'One',
        'ceb': 'Usa',
        'atm': 'Isa',
        'msk': 'Isa',
        'mry': 'Isa',
      },
      {
        'id': 9,
        'category_id': 4,
        'key': 'Two',
        'english': 'Two',
        'en': 'Two',
        'ceb': 'Duha',
        'atm': 'Duwa',
        'msk': 'Duwa',
        'mry': 'Duwa',
      },
      {
        'id': 10,
        'category_id': 4,
        'key': 'Three',
        'english': 'Three',
        'en': 'Three',
        'ceb': 'Tulo',
        'atm': 'Tulu',
        'msk': 'Tulu',
        'mry': 'Tulu',
      },
    ];

    setState(() {
      errorMessage = null;
    });
  }

  void _organizePhraseData() {
    _phrases.clear();
    
    // Group phrases by category
    for (var category in _categories) {
      String categoryName = category['name'] ?? 'Unknown';
      int categoryId = category['id'] ?? 0;
      
      _phrases[categoryName] = {};
      
      // Find phrases for this category
      var categoryPhrases = _phrasesData.where((phrase) => 
        phrase['category_id'] == categoryId).toList();
      
      for (var phrase in categoryPhrases) {
        String phraseKey = phrase['key'] ?? phrase['english'] ?? 'Unknown';
        _phrases[categoryName]![phraseKey] = {};
        
        // Add translations for each language
        for (var language in _languages) {
          String langName = language['name'] ?? '';
          String langCode = language['code'] ?? '';
          
          // Map language codes to display names
          String displayName = _getLanguageDisplayName(langCode);
          if (displayName.isNotEmpty) {
            String translation = phrase[langCode] ?? phrase['english'] ?? phraseKey;
            _phrases[categoryName]![phraseKey]![displayName] = translation;
          }
        }
        
        // Ensure English is included
        if (!_phrases[categoryName]![phraseKey]!.containsKey('English')) {
          _phrases[categoryName]![phraseKey]!['English'] = phrase['english'] ?? phraseKey;
        }
      }
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
      case 'english':
        return 'English';
      case 'ceb':
      case 'cebuano':
        return 'Cebuano';
      case 'atm':
      case 'ata_manobo':
        return 'Ata Manobo';
      case 'msk':
      case 'mansaka':
        return 'Mansaka';
      case 'mry':
      case 'mandaya':
        return 'Mandaya';
      default:
        return '';
    }
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

  Future<void> _refreshData() async {
    await _loadDataFromAPI();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrase Book'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
          if (isPlaying)
            IconButton(
              onPressed: _stopAudio,
              icon: const Icon(Icons.stop),
              color: Colors.red,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading phrases...'),
          ],
        ),
      );
    }

    if (_phrases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.translate_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No phrases available'),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: $errorMessage',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Apply bouncing physics and proper scroll behavior like tribes screen
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Same bouncing effect as tribes screen
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Match tribes screen padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Top spacing like tribes screen
          
          _buildLanguageSelectionSection(),
          
          const SizedBox(height: 32.0),
          
          if (isPlaying) _buildAudioStatusIndicator(),
          
          Text(
            'Common Phrases',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          const SizedBox(height: 16.0),
          
          ..._phrases.entries.map((categoryEntry) {
            return _buildCategorySection(categoryEntry);
          }),
          
          // Bottom padding to ensure last content is fully visible (like tribes screen)
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language Selection',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16.0),
        
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
        
        const SizedBox(height: 12.0),
        
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
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.swap_vert,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12.0),
        
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAudioStatusIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Playing: ${currentlyPlayingPhrase ?? 'Audio'}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _stopAudio,
            child: const Icon(
              Icons.stop,
              color: Colors.amber,
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(categoryEntry.key),
                color: Colors.amber[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                categoryEntry.key,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        ...categoryEntry.value.entries.map((phraseEntry) {
          return _buildPhraseCard(phraseEntry);
        }),
        
        const SizedBox(height: 16.0),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhraseRow(
            language: _selectedSourceLanguage,
            text: sourceText,
            phraseKey: phraseKey,
            isSource: true,
            textColor: Colors.grey[800]!,
          ),
          
          Divider(
            color: Colors.grey[300]!.withOpacity(0.3),
            height: 1,
          ),
          
          _buildPhraseRow(
            language: _selectedTargetLanguage,
            text: targetText,
            phraseKey: phraseKey,
            isSource: false,
            textColor: Colors.blue[700]!,
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
                    color: Colors.grey[600],
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
                    ? Colors.red.withOpacity(0.1)
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