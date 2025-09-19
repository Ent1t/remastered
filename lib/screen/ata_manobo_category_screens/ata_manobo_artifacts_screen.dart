// lib/screen/ata_manobo_category_screens/ata_manobo_artifacts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AtaManoboArtifactsScreen extends StatefulWidget {
  const AtaManoboArtifactsScreen({super.key});

  @override
  State<AtaManoboArtifactsScreen> createState() => _AtaManoboArtifactsScreenState();
}

class _AtaManoboArtifactsScreenState extends State<AtaManoboArtifactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ArtifactCategory> _categories = [
    ArtifactCategory(
      title: 'Jewelry',
      subtitle: 'Sacred Beadwork',
      imagePath: 'assets/images/ata_manobo_jewelry.jpg',
      gradientColors: [const Color(0xFFD4A574), const Color(0xFFB8935F)],
      items: [
        'Traditional Necklaces',
        'Sacred Beads',
        'Ceremonial Bracelets',
        'Ritual Earrings',
        'Wedding Jewelry',
      ],
    ),
    ArtifactCategory(
      title: 'Weapons',
      subtitle: 'Traditional Arms',
      imagePath: 'assets/images/ata_manobo_weapons.jpg',
      gradientColors: [const Color(0xFF8B4513), const Color(0xFF654321)],
      items: [
        'Hunting Spears',
        'Ceremonial Daggers',
        'Traditional Bows',
        'Arrows with Poison Tips',
        'Shields and Armor',
      ],
    ),
    ArtifactCategory(
      title: 'Ritual',
      subtitle: 'Ceremonial Objects',
      imagePath: 'assets/images/ata_manobo_ritual.jpg',
      gradientColors: [const Color(0xFF654321), const Color(0xFF4A3728)],
      items: [
        'Prayer Bowls',
        'Incense Burners',
        'Sacred Masks',
        'Ceremonial Staffs',
        'Ritual Cloths',
      ],
    ),
    ArtifactCategory(
      title: 'Tools',
      subtitle: 'Daily Use Items',
      imagePath: 'assets/images/ata_manobo_tools.jpg',
      gradientColors: [const Color(0xFF8B7355), const Color(0xFF6B5B47)],
      items: [
        'Farming Tools',
        'Weaving Looms',
        'Cooking Utensils',
        'Hunting Implements',
        'Construction Tools',
      ],
    ),
  ];

  List<ArtifactCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }
    return _categories.where((category) {
      return category.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             category.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             category.items.any((item) => 
                item.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
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
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoriesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
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
          const Expanded(
            child: Text(
              'Ata Manobo Artifacts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4A574).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search an artifact',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.6),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Explore the material culture of the Ata Manobo tribe through their handcrafted tools, ceremonial objects, and daily-use items that tell stories of their way of life.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
            ],
            Expanded(
              child: _filteredCategories.isEmpty
                  ? _buildNoResults()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(_filteredCategories[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No artifacts found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ArtifactCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showArtifactDetails(category);
            },
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      category.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: category.gradientColors,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(category.title),
                              color: Colors.white.withOpacity(0.7),
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Dark Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Content
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow Icon
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'jewelry':
        return Icons.diamond;
      case 'weapons':
        return Icons.security;
      case 'ritual':
        return Icons.auto_awesome;
      case 'tools':
        return Icons.build;
      default:
        return Icons.museum;
    }
  }

  void _showArtifactDetails(ArtifactCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a1a),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.subtitle,
                          style: const TextStyle(
                            color: Color(0xFFD4A574),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Items in this category:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: category.items.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD4A574).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(category.title),
                                      color: const Color(0xFFD4A574),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        category.items[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white.withOpacity(0.4),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ArtifactCategory {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;
  final List<String> items;

  ArtifactCategory({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
    required this.items,
  });
}