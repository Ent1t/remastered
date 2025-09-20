// lib/screen/mandaya_category_screens/mandaya_artifacts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MandayaArtifactsScreen extends StatefulWidget {
  const MandayaArtifactsScreen({super.key});

  @override
  State<MandayaArtifactsScreen> createState() => _MandayaArtifactsScreenState();
}

class _MandayaArtifactsScreenState extends State<MandayaArtifactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ArtifactCategory> _categories = [
    ArtifactCategory(
      title: 'Jewelry & Adornments',
      subtitle: 'Sacred Beadwork & Personal Items',
      imagePath: 'assets/images/mandaya_jewelry.jpg',
      gradientColors: [const Color(0xFF7FB069), const Color(0xFF5D8A47)],
      artifacts: [
        ArtifactItem(
          name: 'Dagmay Sacred Beads',
          description: 'Multi-colored glass bead necklace worn by Mandaya women during ceremonies and festivals',
          material: 'Glass beads, brass wire, cotton thread',
          origin: 'Caraga Village, Davao Oriental',
          age: 'Circa 1900-1930',
          significance: 'Symbol of feminine beauty and social status',
          imagePath: 'assets/artifacts/mandaya_dagmay_beads.jpg',
        ),
        ArtifactItem(
          name: 'Tribal Wedding Crown',
          description: 'Elaborate headdress made of silver coins and beads, worn by brides during wedding ceremonies',
          material: 'Silver coins, colored beads, bamboo frame',
          origin: 'Boston, Davao Oriental',
          age: 'Early 20th century',
          significance: 'Marks the transition to married life and prosperity',
          imagePath: 'assets/artifacts/mandaya_wedding_crown.jpg',
        ),
        ArtifactItem(
          name: 'Ceremonial Arm Bands',
          description: 'Woven arm bands with geometric patterns worn by warriors and tribal leaders',
          material: 'Abaca fiber, natural dyes, brass ornaments',
          origin: 'Cateel, Davao Oriental',
          age: 'Late 19th century',
          significance: 'Indicates warrior rank and tribal affiliation',
          imagePath: 'assets/artifacts/mandaya_arm_bands.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Traditional Weapons',
      subtitle: 'Hunting & Ceremonial Arms',
      imagePath: 'assets/images/mandaya_weapons.jpg',
      gradientColors: [const Color(0xFF6B8E23), const Color(0xFF556B2F)],
      artifacts: [
        ArtifactItem(
          name: 'Bagani War Spear',
          description: 'Traditional spear with iron tip used by Mandaya warriors for tribal defense and hunting',
          material: 'Bamboo shaft, iron spearhead, rattan binding',
          origin: 'Bagani Settlement, Cateel',
          age: 'Mid-19th century',
          significance: 'Symbol of warrior status and tribal protection',
          imagePath: 'assets/artifacts/mandaya_bagani_spear.jpg',
        ),
        ArtifactItem(
          name: 'Mandaya Kris Blade',
          description: 'Wavy ceremonial dagger with carved handle, used in rituals and as a symbol of authority',
          material: 'Steel blade, hardwood handle with brass inlay',
          origin: 'Traditional Blacksmith, Mati',
          age: 'Circa 1880-1900',
          significance: 'Spiritual protection and leadership symbol',
          imagePath: 'assets/artifacts/mandaya_kris_blade.jpg',
        ),
        ArtifactItem(
          name: 'Hunting Bow Set',
          description: 'Traditional bow with bamboo arrows used for hunting deer and wild boar in the mountains',
          material: 'Bamboo bow, rattan string, bamboo arrows',
          origin: 'Mountain Hunters, Tarragona',
          age: 'Early 1900s',
          significance: 'Essential hunting tool for forest survival',
          imagePath: 'assets/artifacts/mandaya_bow_set.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Ritual Objects',
      subtitle: 'Ceremonial & Spiritual Items',
      imagePath: 'assets/images/mandaya_ritual.jpg',
      gradientColors: [const Color(0xFF8FBC8F), const Color(0xFF6B8E6B)],
      artifacts: [
        ArtifactItem(
          name: 'Balyan Healing Bowl',
          description: 'Sacred wooden bowl used by traditional healers for preparing herbal medicines',
          material: 'Carved kamagong wood, natural resin finish',
          origin: 'Healing Center, Governor Generoso',
          age: 'Late 19th century',
          significance: 'Connection to ancestral healing wisdom',
          imagePath: 'assets/artifacts/mandaya_healing_bowl.jpg',
        ),
        ArtifactItem(
          name: 'Ancestral Spirit Jar',
          description: 'Ceramic vessel used to store offerings for deceased ancestors during memorial rituals',
          material: 'Fired clay, natural pigments, bamboo lid',
          origin: 'Pottery Workshop, Baganga',
          age: 'Circa 1870-1890',
          significance: 'Bridge between living and ancestral spirits',
          imagePath: 'assets/artifacts/mandaya_spirit_jar.jpg',
        ),
        ArtifactItem(
          name: 'Ritual Dance Mask',
          description: 'Carved mask representing forest spirits, worn during harvest ceremonies',
          material: 'Light wood, natural pigments, animal hair',
          origin: 'Ceremonial Carver, San Isidro',
          age: 'Early 20th century',
          significance: 'Invokes forest spirits for good harvest',
          imagePath: 'assets/artifacts/mandaya_dance_mask.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Daily Use Tools',
      subtitle: 'Agricultural & Household Items',
      imagePath: 'assets/images/mandaya_tools.jpg',
      gradientColors: [const Color(0xFF9ACD32), const Color(0xFF7B9A2D)],
      artifacts: [
        ArtifactItem(
          name: 'Abaca Fiber Beater',
          description: 'Wooden tool used to process abaca fibers for making traditional textiles',
          material: 'Hardwood handle, bamboo beater head',
          origin: 'Textile Village, Lupon',
          age: 'Late 19th century',
          significance: 'Essential for traditional fiber processing',
          imagePath: 'assets/artifacts/mandaya_fiber_beater.jpg',
        ),
        ArtifactItem(
          name: 'Traditional Loom Frame',
          description: 'Wooden frame loom used for weaving Mandaya textiles with geometric patterns',
          material: 'Bamboo frame, wooden heddles, abaca string',
          origin: 'Weaving Center, Manay',
          age: 'Early 1900s',
          significance: 'Preservation of textile weaving traditions',
          imagePath: 'assets/artifacts/mandaya_loom_frame.jpg',
        ),
        ArtifactItem(
          name: 'Coconut Shell Ladle',
          description: 'Carved coconut shell used as a serving ladle and water dipper in daily cooking',
          material: 'Polished coconut shell, bamboo handle',
          origin: 'Village Craftsman, Caraga',
          age: 'Mid-20th century',
          significance: 'Sustainable use of natural materials',
          imagePath: 'assets/artifacts/mandaya_coconut_ladle.jpg',
        ),
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
             category.artifacts.any((artifact) => 
                artifact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                artifact.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                artifact.material.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  List<ArtifactItem> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    
    List<ArtifactItem> results = [];
    for (var category in _categories) {
      for (var artifact in category.artifacts) {
        if (artifact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artifact.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artifact.material.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artifact.origin.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artifact.age.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            artifact.significance.toLowerCase().contains(_searchQuery.toLowerCase())) {
          results.add(artifact);
        }
      }
    }
    return results;
  }

  bool get _isSearching => _searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      if (_isSearching) ...[
                        const SizedBox(height: 20),
                        _buildSearchResults(),
                      ] else ...[
                        const SizedBox(height: 20),
                        _buildFeaturedImage(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildBrowseSection(),
                        const SizedBox(height: 20),
                        _buildArtifactCategories(),
                      ],
                      SizedBox(height: 40 + MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
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
              'MANDAYA ARTIFACTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7FB069).withOpacity(0.3),
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
            hintText: 'Search artifacts',
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
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
          child: Image.asset(
            'assets/images/mandaya_artifacts_featured.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7FB069),
                      Color(0xFF6B8E23),
                      Color(0xFF556B2F),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.museum,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover authentic Mandaya artifacts - physical objects that tell the story of this indigenous tribe\'s rich cultural heritage, craftsmanship, and daily life.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Browse artifacts',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildArtifactCategories() {
    if (_searchQuery.isNotEmpty && _filteredCategories.isEmpty) {
      return _buildNoResults();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_filteredCategories[index]);
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results (${_searchResults.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return _buildSearchResultCard(_searchResults[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(ArtifactItem artifact, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showSearchResultViewer(artifact, index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            artifact.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7FB069),
                      Color(0xFF6B8E23),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.museum,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSearchResultViewer(ArtifactItem artifact, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArtifactViewerBottomSheet(
        artifacts: [artifact],
        initialIndex: 0,
        accentColor: const Color(0xFF7FB069),
      ),
    );
  }

  Widget _buildCategoryCard(ArtifactCategory category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showArtifactGallery(category);
      },
      child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
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
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF2A2A2A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FB069),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.artifacts.length} artifacts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'jewelry & adornments':
        return Icons.diamond;
      case 'traditional weapons':
        return Icons.security;
      case 'ritual objects':
        return Icons.auto_awesome;
      case 'daily use tools':
        return Icons.build;
      default:
        return Icons.museum;
    }
  }

  void _showArtifactGallery(ArtifactCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtifactGalleryScreen(
          category: category,
          accentColor: const Color(0xFF7FB069),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final ArtifactItem artifact;
  final Color accentColor;

  const FullScreenImageViewer({
    super.key,
    required this.artifact,
    required this.accentColor,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  widget.artifact.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accentColor.withOpacity(0.7),
                            widget.accentColor,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.museum,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.artifact.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.artifact.origin,
                                  style: TextStyle(
                                    color: widget.accentColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tap to zoom • Pinch to scale • Drag to pan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: widget.accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.artifact.age,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtifactCategory {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;
  final List<ArtifactItem> artifacts;

  ArtifactCategory({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
    required this.artifacts,
  });
}

class ArtifactItem {
  final String name;
  final String description;
  final String material;
  final String origin;
  final String age;
  final String significance;
  final String imagePath;

  ArtifactItem({
    required this.name,
    required this.description,
    required this.material,
    required this.origin,
    required this.age,
    required this.significance,
    required this.imagePath,
  });
}

class ArtifactGalleryScreen extends StatelessWidget {
  final ArtifactCategory category;
  final Color accentColor;

  const ArtifactGalleryScreen({
    super.key,
    required this.category,
    required this.accentColor,
  });

  void _showArtifactViewer(BuildContext context, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArtifactViewerBottomSheet(
        artifacts: category.artifacts,
        initialIndex: initialIndex,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: GridView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: category.artifacts.length,
                  itemBuilder: (context, index) {
                    return _buildArtifactCard(category.artifacts[index], index, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Expanded(
            child: Text(
              category.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(ArtifactItem artifact, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showArtifactViewer(context, index);
      },
      child: Container(
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
          child: Image.asset(
            artifact.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.7),
                      accentColor,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.museum,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ArtifactViewerBottomSheet extends StatefulWidget {
  final List<ArtifactItem> artifacts;
  final int initialIndex;
  final Color accentColor;

  const ArtifactViewerBottomSheet({
    super.key,
    required this.artifacts,
    required this.initialIndex,
    required this.accentColor,
  });

  @override
  State<ArtifactViewerBottomSheet> createState() => _ArtifactViewerBottomSheetState();
}

class _ArtifactViewerBottomSheetState extends State<ArtifactViewerBottomSheet> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: keyboardHeight > 0 
          ? screenHeight * 0.95 - keyboardHeight 
          : screenHeight * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                HapticFeedback.selectionClick();
              },
              itemCount: widget.artifacts.length,
              itemBuilder: (context, index) {
                return _buildArtifactCard(widget.artifacts[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          SizedBox(height: 20 + keyboardHeight * 0.1),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Artifact Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(ArtifactItem artifact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(artifact),
            child: Container(
              height: 250,
              width: double.infinity,
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
                    Image.asset(
                      artifact.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.accentColor.withOpacity(0.7),
                                widget.accentColor,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.museum,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
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
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artifact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  artifact.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMetadataRow(Icons.build, 'Material', artifact.material),
                const SizedBox(height: 8),
                _buildMetadataRow(Icons.location_on, 'Origin', artifact.origin),
                const SizedBox(height: 8),
                _buildMetadataRow(Icons.access_time, 'Age', artifact.age),
                const SizedBox(height: 8),
                _buildMetadataRow(Icons.star, 'Significance', artifact.significance),
              ],
            ),
          ),
          SizedBox(height: 30 + MediaQuery.of(context).viewInsets.bottom * 0.1),
        ],
      ),
    );
  }

  void _showFullScreenImage(ArtifactItem artifact) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImageViewer(
            artifact: artifact,
            accentColor: widget.accentColor,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: widget.accentColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: widget.accentColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.artifacts.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? widget.accentColor
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}