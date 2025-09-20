// lib/screen/mansaka_category_screens/mansaka_images_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MansakaImagesScreen extends StatefulWidget {
  const MansakaImagesScreen({super.key});

  @override
  State<MansakaImagesScreen> createState() => _MansakaImagesScreenState();
}

class _MansakaImagesScreenState extends State<MansakaImagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<ImageCategory> _imageCategories = [
    ImageCategory(
      title: 'Traditional Ceremony',
      tag: 'Ceremony',
      imagePath: 'assets/images/mansaka_ceremony.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mansaka_ceremony_1.jpg',
          description: 'Mansaka ritual ceremony honoring ancestral spirits with traditional offerings',
          location: 'Compostela Valley, Monkayo',
          date: 'March 22, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_ceremony_2.jpg',
          description: 'Sacred blessing ritual performed by tribal elder using ancient chants',
          location: 'Nabunturan Cultural Center',
          date: 'April 28, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_ceremony_3.jpg',
          description: 'Community thanksgiving ceremony for successful harvest season',
          location: 'Barangay Mamangan, Compostela',
          date: 'May 15, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_ceremony_4.jpg',
          description: 'Traditional wedding ceremony with exchange of ancestral beads',
          location: 'Mansaka Ancestral Territory',
          date: 'June 12, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Village Life',
      tag: 'Lifestyle',
      imagePath: 'assets/images/mansaka_village.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mansaka_village_1.jpg',
          description: 'Daily life in traditional Mansaka mountain community',
          location: 'Sitio Libcatan, New Bataan',
          date: 'January 20, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_village_2.jpg',
          description: 'Children participating in traditional cultural games and learning',
          location: 'Barangay Andap, Monkayo',
          date: 'February 25, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_village_3.jpg',
          description: 'Tribal council meeting with elders sharing wisdom and traditions',
          location: 'Community Hall, Pantukan',
          date: 'April 3, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_village_4.jpg',
          description: 'Traditional agriculture practices in mountainous terrain',
          location: 'Highland Farms, Maragusan',
          date: 'April 20, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Traditional Crafts',
      tag: 'Handicraft',
      imagePath: 'assets/images/mansaka_crafts.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mansaka_crafts_1.jpg',
          description: 'Intricate beadwork and jewelry crafting using traditional techniques',
          location: 'Mansaka Craft Center, Pantukan',
          date: 'July 25, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_crafts_2.jpg',
          description: 'Master craftsman creating traditional weapons and ceremonial tools',
          location: 'Heritage Workshop, Monkayo',
          date: 'August 18, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_crafts_3.jpg',
          description: 'Collection of handwoven baskets and traditional containers',
          location: 'Cultural Arts Center',
          date: 'September 8, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Cultural Heritage',
      tag: 'Heritage',
      imagePath: 'assets/images/mansaka_heritage.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mansaka_heritage_1.jpg',
          description: 'Ancient tribal artifacts including ceremonial daggers and ritual items',
          location: 'Mansaka Heritage Museum',
          date: 'October 15, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_heritage_2.jpg',
          description: 'Traditional musical instruments used in spiritual and cultural ceremonies',
          location: 'Cultural Heritage Center',
          date: 'November 22, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_heritage_3.jpg',
          description: 'Sacred ancestral totems and protective spiritual symbols',
          location: 'Sacred Grove, Mt. Diwalwal',
          date: 'December 30, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_heritage_4.jpg',
          description: 'Historical documentation of tribal leaders and cultural practices',
          location: 'Compostela Valley Archives',
          date: 'January 18, 2024',
        ),
        ImageItem(
          imagePath: 'assets/images/mansaka_heritage_5.jpg',
          description: 'Traditional pottery and carved wooden vessels from ancestral times',
          location: 'Craft Heritage Workshop',
          date: 'February 25, 2024',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openImageGallery(ImageCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          category: category,
          accentColor: const Color(0xFFB19CD9),
        ),
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildFeaturedImage(),
                    const SizedBox(height: 24),
                    _buildDescription(),
                    const SizedBox(height: 32),
                    _buildBrowseSection(),
                    const SizedBox(height: 20),
                    _buildImageCategories(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
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
              'MANSAKA IMAGES',
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
            color: const Color(0xFFB19CD9).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search an Image',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.6),
            ),
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
            'assets/images/mansaka_featured.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB19CD9),
                      Color(0xFF5D4E75),
                      Color(0xFF3F325A),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
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
            'Browse through a collection of historical and contemporary photographs showcasing the Mansaka people, their customs, and cultural expressions through time.',
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
        'Browse images',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageCategories() {
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
        itemCount: _imageCategories.length,
        itemBuilder: (context, index) {
          final category = _imageCategories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(ImageCategory category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _openImageGallery(category);
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB19CD9),
                            Color(0xFF5D4E75),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
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
                        color: const Color(0xFFB19CD9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.tag,
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
}

class ImageCategory {
  final String title;
  final String tag;
  final String imagePath;
  final List<ImageItem> images;

  ImageCategory({
    required this.title,
    required this.tag,
    required this.imagePath,
    required this.images,
  });
}

class ImageItem {
  final String imagePath;
  final String description;
  final String location;
  final String date;

  ImageItem({
    required this.imagePath,
    required this.description,
    required this.location,
    required this.date,
  });
}

class ImageGalleryScreen extends StatelessWidget {
  final ImageCategory category;
  final Color accentColor;

  const ImageGalleryScreen({
    super.key,
    required this.category,
    required this.accentColor,
  });

  void _showImageViewer(BuildContext context, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageViewerBottomSheet(
        images: category.images,
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
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: category.images.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(category.images[index], index, context);
                },
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

  Widget _buildImageItem(ImageItem imageItem, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showImageViewer(context, index);
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
            imageItem.imagePath,
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
                    Icons.image,
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
}

class ImageViewerBottomSheet extends StatefulWidget {
  final List<ImageItem> images;
  final int initialIndex;
  final Color accentColor;

  const ImageViewerBottomSheet({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.accentColor,
  });

  @override
  State<ImageViewerBottomSheet> createState() => _ImageViewerBottomSheetState();
}

class _ImageViewerBottomSheetState extends State<ImageViewerBottomSheet> {
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
      height: MediaQuery.of(context).size.height * 0.8,
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
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return _buildImageCard(widget.images[index]);
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
            'Image Gallery',
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

  Widget _buildImageCard(ImageItem imageItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
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
                  imageItem.imagePath,
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
                          Icons.image,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    );
                  },
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
                  imageItem.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMetadataRow(Icons.location_on, 'Location', imageItem.location),
                const SizedBox(height: 8),
                _buildMetadataRow(Icons.calendar_today, 'Date', imageItem.date),
              ],
            ),
          ),
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
        widget.images.length,
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