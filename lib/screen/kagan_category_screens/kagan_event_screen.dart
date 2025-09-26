import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KaganEventScreen extends StatefulWidget {
  const KaganEventScreen({super.key});

  @override
  State<KaganEventScreen> createState() => _KaganEventScreenState();
}

class _KaganEventScreenState extends State<KaganEventScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // All images in a flat list
  final List<ImageItem> _allImages = [
    // Traditional Ceremony images
    ImageItem(
      imagePath: 'assets/images/kagan_ceremony_1.jpg',
      description: 'Traditional Kagan wedding ceremony with elders performing ancient rituals',
      location: 'Barangay Tugbok, Davao City',
      date: 'March 15, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_ceremony_2.jpg',
      description: 'Sacred blessing ritual conducted by tribal elder',
      location: 'Mt. Apo Cultural Center',
      date: 'April 20, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_ceremony_3.jpg',
      description: 'Community gathering for harvest thanksgiving ceremony',
      location: 'Marilog District, Davao City',
      date: 'May 10, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_ceremony_4.jpg',
      description: 'Traditional dance performance during cultural festival',
      location: 'Tribal Cultural Center',
      date: 'June 5, 2023',
    ),
    // Village Life images
    ImageItem(
      imagePath: 'assets/images/kagan_village_1.jpg',
      description: 'Daily life in traditional Kagan village settlement',
      location: 'Calinan District, Davao City',
      date: 'January 12, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_village_2.jpg',
      description: 'Children playing traditional games in the village',
      location: 'Barangay Wangan, Calinan',
      date: 'February 18, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_village_3.jpg',
      description: 'Village elders sharing stories and wisdom',
      location: 'Tribal Council Hall',
      date: 'March 22, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_village_4.jpg',
      description: 'Traditional farming practices in terraced fields',
      location: 'Highland Village, Marilog',
      date: 'April 8, 2023',
    ),
    // Traditional Textiles images
    ImageItem(
      imagePath: 'assets/images/kagan_textiles_1.jpg',
      description: 'Intricate handwoven textiles with traditional patterns',
      location: 'Weaving Center, Tugbok',
      date: 'July 14, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_textiles_2.jpg',
      description: 'Master weaver creating ceremonial cloth',
      location: 'Heritage Craft Workshop',
      date: 'August 3, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_textiles_3.jpg',
      description: 'Collection of traditional Kagan garments and accessories',
      location: 'Cultural Heritage Museum',
      date: 'September 11, 2023',
    ),
    // Cultural Heritage images
    ImageItem(
      imagePath: 'assets/images/kagan_heritage_1.jpg',
      description: 'Ancient tribal artifacts and ceremonial tools',
      location: 'Heritage Collection Center',
      date: 'October 5, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_heritage_2.jpg',
      description: 'Traditional musical instruments used in rituals',
      location: 'Cultural Arts Center',
      date: 'November 12, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_heritage_3.jpg',
      description: 'Sacred tribal totems and spiritual symbols',
      location: 'Sacred Grove, Mt. Apo',
      date: 'December 20, 2023',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_heritage_4.jpg',
      description: 'Historical photographs of tribal leaders',
      location: 'Archive Documentation Center',
      date: 'January 8, 2024',
    ),
    ImageItem(
      imagePath: 'assets/images/kagan_heritage_5.jpg',
      description: 'Traditional pottery and crafted vessels',
      location: 'Pottery Workshop, Calinan',
      date: 'February 15, 2024',
    ),
  ];

  // Search functionality for all images
  List<ImageItem> get _filteredImages {
    if (_searchQuery.isEmpty) {
      return _allImages;
    }
    return _allImages.where((image) {
      return image.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             image.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             image.date.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get _isSearching => _searchQuery.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImageViewer(ImageItem image, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageViewerBottomSheet(
        images: [image], // Show only the selected image
        initialIndex: 0,
        accentColor: const Color(0xFFD4A574),
      ),
    );
  }

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
                      const SizedBox(height: 20),
                      if (!_isSearching) ...[
                        _buildFeaturedImage(),
                        const SizedBox(height: 24),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        _buildAllImagesSection(),
                      ] else ...[
                        _buildSearchResultsHeader(),
                      ],
                      const SizedBox(height: 20),
                      _buildImageGrid(),
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
              'KAGAN EVENTS',
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
            hintText: 'Search images',
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
            'assets/images/kagan_featured.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4A574),
                      Color(0xFF8B4513),
                      Color(0xFF654321),
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
            'Browse through a collection of historical and contemporary photographs showcasing the Kagan people, their customs, and cultural expressions through time.',
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

  Widget _buildAllImagesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'All Images (${_allImages.length})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Search Results (${_filteredImages.length})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_filteredImages.isEmpty) {
      return _buildNoResults();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _filteredImages.length,
        itemBuilder: (context, index) {
          return _buildImageCard(_filteredImages[index], index);
        },
      ),
    );
  }

  Widget _buildImageCard(ImageItem image, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showImageViewer(image, index);
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
            image.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4A574),
                      Color(0xFF8B4513),
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
              'No images found',
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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
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
          if (widget.images.length > 1) _buildPageIndicator(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(imageItem),
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
                      imageItem.imagePath,
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
                              Icons.image,
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
          SizedBox(height: 30 + MediaQuery.of(context).viewInsets.bottom * 0.1),
        ],
      ),
    );
  }

  void _showFullScreenImage(ImageItem imageItem) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImageViewer(
            image: imageItem,
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

class FullScreenImageViewer extends StatefulWidget {
  final ImageItem image;
  final Color accentColor;

  const FullScreenImageViewer({
    super.key,
    required this.image,
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
                  widget.image.imagePath,
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
                          Icons.image,
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
                                  widget.image.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.image.location,
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
                                Icons.calendar_today,
                                color: widget.accentColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.image.date,
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