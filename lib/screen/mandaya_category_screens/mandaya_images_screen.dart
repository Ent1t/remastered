// lib/screen/mandaya_category_screens/mandaya_images_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MandayaImagesScreen extends StatefulWidget {
  const MandayaImagesScreen({super.key});

  @override
  State<MandayaImagesScreen> createState() => _MandayaImagesScreenState();
}

class _MandayaImagesScreenState extends State<MandayaImagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<ImageCategory> _imageCategories = [
    ImageCategory(
      title: 'Traditional Ceremony',
      tag: 'Ceremony',
      imagePath: 'assets/images/mandaya_ceremony.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mandaya_ceremony_1.jpg',
          description: 'Sacred Mandaya ritual led by tribal shaman (Baylan) with traditional chants',
          location: 'Davao Oriental, Tarragona',
          date: 'March 18, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_ceremony_2.jpg',
          description: 'Community healing ceremony using traditional herbs and prayers',
          location: 'Mati City Cultural Center',
          date: 'April 25, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_ceremony_3.jpg',
          description: 'Harvest festival celebration with ancestral spirit offerings',
          location: 'Barangay Badas, Tarragona',
          date: 'May 12, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_ceremony_4.jpg',
          description: 'Traditional wedding ceremony with Dagmay textile exchange',
          location: 'Mandaya Ancestral Domain',
          date: 'June 8, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Village Life',
      tag: 'Lifestyle',
      imagePath: 'assets/images/mandaya_village.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mandaya_village_1.jpg',
          description: 'Daily activities in traditional Mandaya mountain village',
          location: 'Barangay Maputi, Boston',
          date: 'January 15, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_village_2.jpg',
          description: 'Children learning traditional games and cultural practices',
          location: 'Sitio Kapatagan, Caraga',
          date: 'February 22, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_village_3.jpg',
          description: 'Elders sharing oral traditions and ancestral wisdom',
          location: 'Tribal Council House, Mati',
          date: 'March 30, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_village_4.jpg',
          description: 'Sustainable farming practices in terraced mountainside fields',
          location: 'Highland Farms, Tarragona',
          date: 'April 18, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Dagmay Textiles',
      tag: 'Handicraft',
      imagePath: 'assets/images/mandaya_dagmay.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mandaya_dagmay_1.jpg',
          description: 'Intricate Dagmay weaving with traditional geometric patterns and symbols',
          location: 'Mandaya Weaving Center, Mati',
          date: 'July 20, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_dagmay_2.jpg',
          description: 'Master weaver demonstrating ancient abaca fiber preparation techniques',
          location: 'Cultural Heritage Workshop',
          date: 'August 14, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_dagmay_3.jpg',
          description: 'Collection of ceremonial Dagmay textiles with spiritual significance',
          location: 'Mandaya Cultural Museum',
          date: 'September 5, 2023',
        ),
      ],
    ),
    ImageCategory(
      title: 'Cultural Heritage',
      tag: 'Heritage',
      imagePath: 'assets/images/mandaya_heritage.jpg',
      images: [
        ImageItem(
          imagePath: 'assets/images/mandaya_heritage_1.jpg',
          description: 'Ancient tribal artifacts including ritual daggers and ceremonial items',
          location: 'Mandaya Heritage Center',
          date: 'October 10, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_heritage_2.jpg',
          description: 'Traditional musical instruments used in spiritual ceremonies',
          location: 'Cultural Arts Pavilion',
          date: 'November 18, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_heritage_3.jpg',
          description: 'Sacred ancestral totems and spiritual guardian symbols',
          location: 'Sacred Forest Shrine',
          date: 'December 25, 2023',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_heritage_4.jpg',
          description: 'Historical photographs documenting tribal leadership and traditions',
          location: 'Davao Oriental Archives',
          date: 'January 12, 2024',
        ),
        ImageItem(
          imagePath: 'assets/images/mandaya_heritage_5.jpg',
          description: 'Traditional pottery and basketry crafted using ancestral techniques',
          location: 'Craft Workshop, Baganga',
          date: 'February 20, 2024',
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
          accentColor: const Color(0xFF7FB069),
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
              'MANDAYA IMAGES',
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
            'assets/images/mandaya_featured.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7FB069),
                      Color(0xFF4A5D23),
                      Color(0xFF2F3E15),
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
            'Browse through a collection of historical and contemporary photographs showcasing the Mandaya people, their customs, and cultural expressions through time.',
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
                            Color(0xFF7FB069),
                            Color(0xFF4A5D23),
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
                        color: const Color(0xFF7FB069),
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