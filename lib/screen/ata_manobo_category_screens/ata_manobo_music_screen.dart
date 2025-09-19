// lib/screen/ata_manobo_category_screens/ata_manobo_music_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../music_player_screen.dart'; // Import the music player screen

class AtaManoboMusicScreen extends StatefulWidget {
  const AtaManoboMusicScreen({super.key});

  @override
  State<AtaManoboMusicScreen> createState() => _AtaManoboMusicScreenState();
}

class _AtaManoboMusicScreenState extends State<AtaManoboMusicScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample data for Ata Manobo music
  final List<MusicTrack> _allTracks = [
    MusicTrack(
      title: 'Harvest Song',
      description: 'Song sung during rice harvest celebrations',
      category: 'Traditional',
      imagePath: 'assets/images/ata_manobo_harvest.jpg',
      artist: 'Matt Gamar',
    ),
    MusicTrack(
      title: 'War Chant',
      description: 'Ancient chant performed before battles',
      category: 'Ceremonial',
      imagePath: 'assets/images/ata_manobo_war_chant.jpg',
      artist: 'Elder Manobo',
    ),
    MusicTrack(
      title: 'Lullaby',
      description: 'Traditional song for children',
      category: 'Folk',
      imagePath: 'assets/images/ata_manobo_lullaby.jpg',
      artist: 'Maria Santos',
    ),
    MusicTrack(
      title: 'Spirit Dance',
      description: 'Sacred music for ancestral rituals',
      category: 'Spiritual',
      imagePath: 'assets/images/ata_manobo_spirit.jpg',
      artist: 'Datu Lumad',
    ),
    MusicTrack(
      title: 'Wedding Song',
      description: 'Ceremonial music for marriage rituals',
      category: 'Ceremonial',
      imagePath: 'assets/images/ata_manobo_wedding.jpg',
      artist: 'Tribal Ensemble',
    ),
    MusicTrack(
      title: 'Mountain Echo',
      description: 'Folk song about the sacred mountains',
      category: 'Folk',
      imagePath: 'assets/images/ata_manobo_mountain.jpg',
      artist: 'Mountain Singers',
    ),
  ];

  List<String> get _categories => ['Traditional', 'Ceremonial', 'Folk', 'Spiritual'];

  List<MusicTrack> get _filteredTracks {
    if (_searchQuery.isEmpty) {
      return _allTracks;
    }
    return _allTracks.where((track) =>
        track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        track.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF0d0d0d),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildHeroSection(),
              _buildCategoriesFilter(),
              Expanded(child: _buildMusicList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
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
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search in playlist (Spotify ripoff)',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/images/ata_manobo_music_hero.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD4A574),
                        Color(0xFFB8935F),
                        Color(0xFF8B7355),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Dark Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Discover the traditional musical heritage of the Ata Manobo people. Each song carries deep cultural meaning and connects the community to their ancestors through rhythm and melody.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: const Color(0xFFD4A574),
              side: BorderSide(
                color: const Color(0xFFD4A574).withOpacity(0.3),
              ),
              onSelected: (selected) {
                // Add filter functionality here
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTracks.length,
      itemBuilder: (context, index) {
        final track = _filteredTracks[index];
        return _buildMusicCard(track);
      },
    );
  }

  Widget _buildMusicCard(MusicTrack track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.mediumImpact();
            _playTrack(track);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Track Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFD4A574).withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      track.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          color: Color(0xFFD4A574),
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Track Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A574).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          track.category,
                          style: const TextStyle(
                            color: Color(0xFFD4A574),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Play Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _playTrack(track);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _playTrack(MusicTrack track) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MusicPlayerScreen(
          track: track,
          themeColor: const Color(0xFFD4A574), // Ata Manobo theme color
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}