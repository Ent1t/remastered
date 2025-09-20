import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KaganArtifactsScreen extends StatefulWidget {
  const KaganArtifactsScreen({super.key});

  @override
  State<KaganArtifactsScreen> createState() => _KaganArtifactsScreenState();
}

class _KaganArtifactsScreenState extends State<KaganArtifactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ArtifactCategory> _categories = [
    ArtifactCategory(
      title: 'Jewelry & Adornments',
      subtitle: 'Sacred Beadwork & Personal Items',
      imagePath: 'assets/images/kagan_jewelry.jpg',
      gradientColors: [const Color(0xFFD4A574), const Color(0xFFB8935F)],
      artifacts: [
        ArtifactItem(
          name: 'Tubà Sacred Necklace',
          description: 'Multi-layered brass and gold bead necklace worn by tribal leaders during important ceremonies',
          material: 'Brass beads, gold accents, cotton thread',
          origin: 'Tugbok Village, Davao City',
          age: 'Circa 1890-1920',
          significance: 'Symbol of leadership and spiritual authority',
          imagePath: 'assets/artifacts/kagan_tuba_necklace.jpg',
        ),
        ArtifactItem(
          name: 'Ceremonial Ear Weights',
          description: 'Heavy brass ear ornaments that gradually stretch the earlobes as a sign of beauty and status',
          material: 'Hammered brass, silver inlay',
          origin: 'Calinan District, Davao City',
          age: 'Late 19th century',
          significance: 'Marker of social status and tribal identity',
          imagePath: 'assets/artifacts/kagan_ear_weights.jpg',
        ),
        ArtifactItem(
          name: 'Wedding Anklet Set',
          description: 'Intricate silver anklets with traditional geometric patterns, worn during marriage ceremonies',
          material: 'Sterling silver, brass bells',
          origin: 'Marilog District, Davao City',
          age: 'Early 20th century',
          significance: 'Symbol of marital commitment and fertility',
          imagePath: 'assets/artifacts/kagan_wedding_anklets.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Traditional Weapons',
      subtitle: 'Hunting & Ceremonial Arms',
      imagePath: 'assets/images/kagan_weapons.jpg',
      gradientColors: [const Color(0xFF8B4513), const Color(0xFF654321)],
      artifacts: [
        ArtifactItem(
          name: 'Bangkaw War Spear',
          description: 'Long ceremonial spear with iron tip, used in tribal warfare and hunting large game',
          material: 'Bamboo shaft, forged iron tip, rattan binding',
          origin: 'Mt. Apo Foothills',
          age: 'Mid-19th century',
          significance: 'Symbol of warrior status and tribal protection',
          imagePath: 'assets/artifacts/kagan_bangkaw_spear.jpg',
        ),
        ArtifactItem(
          name: 'Kris Ceremonial Dagger',
          description: 'Wavy-bladed ritual dagger with carved wooden handle, used in spiritual ceremonies',
          material: 'Damascus steel blade, kamagong wood handle',
          origin: 'Tribal Blacksmith, Tugbok',
          age: 'Circa 1880',
          significance: 'Spiritual protection and ancestral connection',
          imagePath: 'assets/artifacts/kagan_kris_dagger.jpg',
        ),
        ArtifactItem(
          name: 'Hunting Bow and Arrows',
          description: 'Traditional bow with poison-tipped arrows used for hunting wild boar and deer',
          material: 'Bamboo bow, rattan string, wooden arrows',
          origin: 'Highland Hunting Grounds',
          age: 'Early 1900s',
          significance: 'Essential tool for survival and food procurement',
          imagePath: 'assets/artifacts/kagan_bow_arrows.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Ritual Objects',
      subtitle: 'Ceremonial & Spiritual Items',
      imagePath: 'assets/images/kagan_ritual.jpg',
      gradientColors: [const Color(0xFF654321), const Color(0xFF4A3728)],
      artifacts: [
        ArtifactItem(
          name: 'Baylan Prayer Bowl',
          description: 'Sacred wooden bowl used by shamans for water rituals and ancestor communication',
          material: 'Carved narra wood, brass inlay',
          origin: 'Sacred Grove, Mt. Apo',
          age: 'Late 19th century',
          significance: 'Bridge between physical and spiritual worlds',
          imagePath: 'assets/artifacts/kagan_prayer_bowl.jpg',
        ),
        ArtifactItem(
          name: 'Ancestral Spirit Mask',
          description: 'Carved wooden mask representing tribal ancestors, worn during spiritual ceremonies',
          material: 'Kamagong wood, natural pigments, animal hair',
          origin: 'Ritual Workshop, Calinan',
          age: 'Circa 1870-1900',
          significance: 'Channels ancestral spirits during ceremonies',
          imagePath: 'assets/artifacts/kagan_spirit_mask.jpg',
        ),
        ArtifactItem(
          name: 'Incense Burner Staff',
          description: 'Wooden staff with metal bowl for burning sacred herbs during healing rituals',
          material: 'Bamboo shaft, brass bowl, carved decorations',
          origin: 'Tribal Healer Collection',
          age: 'Early 20th century',
          significance: 'Purification and healing ceremonies',
          imagePath: 'assets/artifacts/kagan_incense_staff.jpg',
        ),
      ],
    ),
    ArtifactCategory(
      title: 'Daily Use Tools',
      subtitle: 'Agricultural & Household Items',
      imagePath: 'assets/images/kagan_tools.jpg',
      gradientColors: [const Color(0xFF8B7355), const Color(0xFF6B5B47)],
      artifacts: [
        ArtifactItem(
          name: 'Rice Terracing Hoe',
          description: 'Iron-bladed hoe with wooden handle, used for cultivating mountain rice terraces',
          material: 'Forged iron blade, hardwood handle',
          origin: 'Highland Farms, Marilog',
          age: 'Late 19th century',
          significance: 'Essential tool for rice cultivation and survival',
          imagePath: 'assets/artifacts/kagan_rice_hoe.jpg',
        ),
        ArtifactItem(
          name: 'Traditional Weaving Loom',
          description: 'Wooden frame loom used for weaving traditional textiles and ceremonial cloths',
          material: 'Bamboo frame, wooden heddles, cotton strings',
          origin: 'Weaving Center, Tugbok',
          age: 'Early 1900s',
          significance: 'Creation of cultural identity through textiles',
          imagePath: 'assets/artifacts/kagan_weaving_loom.jpg',
        ),
        ArtifactItem(
          name: 'Coconut Grater Stool',
          description: 'Low wooden stool with metal grater blade for processing coconut meat',
          material: 'Narra wood, iron grater blade',
          origin: 'Village Craftsman, Calinan',
          age: 'Mid-20th century',
          significance: 'Daily food preparation and community gathering',
          imagePath: 'assets/artifacts/kagan_coconut_grater.jpg',
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
              'KAGAN ARTIFACTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
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
                'Discover authentic Kagan artifacts - physical objects that tell the story of this indigenous tribe\'s rich cultural heritage, craftsmanship, and daily life.',
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
              _showArtifactGallery(category);
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
                    right: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A574).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${category.artifacts.length} artifacts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
          accentColor: const Color(0xFFD4A574),
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
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
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
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF2A2A2A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artifact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artifact.age,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          const SizedBox(height: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            artifact.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
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
                  artifact.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildMetadataRow(Icons.build, 'Material', artifact.material),
                const SizedBox(height: 12),
                
                _buildMetadataRow(Icons.location_on, 'Origin', artifact.origin),
                const SizedBox(height: 12),
                
                _buildMetadataRow(Icons.access_time, 'Age', artifact.age),
                const SizedBox(height: 12),
                
                _buildMetadataRow(Icons.star, 'Significance', artifact.significance),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
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
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
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