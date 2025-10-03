import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MansakaEventScreen extends StatefulWidget {
  const MansakaEventScreen({super.key});

  @override
  State<MansakaEventScreen> createState() => _MansakaEventScreenState();
}

class _MansakaEventScreenState extends State<MansakaEventScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // API and loading state
  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/content/';
  static const String _uploadsBaseUrl = 'https://huni-cms.ionvop.com/uploads/';
  List<EventItem> _allEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EventItem> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return _allEvents;
    }
    return _allEvents.where((event) {
      return event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             event.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('Fetching Mansaka events from: $_baseUrl');
      
      const String apiUrl = '$_baseUrl?tribe=mansaka&category=event';
      debugPrint('API URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('API returned status code: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']);
      }

      if (!jsonData.containsKey('data')) {
        throw Exception('API response missing "data" field');
      }

      final dynamic rawData = jsonData['data'];
      List<dynamic> contentItems = [];
      
      if (rawData is List) {
        contentItems = rawData;
      } else if (rawData is Map) {
        contentItems = [rawData];
      } else {
        throw Exception('Unexpected data format in API response');
      }

      debugPrint('Found ${contentItems.length} content items');

      final List<EventItem> events = [];

      for (var item in contentItems) {
        if (item == null || item is! Map<String, dynamic>) {
          debugPrint('Skipping invalid item: $item');
          continue;
        }
        
        debugPrint('Processing item: ${item.toString()}');
        
        final dynamic id = item['id'];
        final dynamic userId = item['user_id'];
        final String? title = item['title']?.toString();
        final String? category = item['category']?.toString();
        final String? tribe = item['tribe']?.toString();
        final String? description = item['description']?.toString();
        final String? file = item['file']?.toString();
        final dynamic isArchived = item['is_archived'];
        final String? time = item['time']?.toString();
        
        if (id == null || 
            userId == null || 
            title == null || title.isEmpty ||
            category == null || category.isEmpty ||
            tribe == null || tribe.isEmpty ||
            file == null || file.isEmpty ||
            isArchived == null ||
            time == null || time.isEmpty) {
          debugPrint('Skipping item with missing required fields');
          continue;
        }
        
        if (tribe.toLowerCase() != 'mansaka') {
          debugPrint('Skipping non-Mansaka item: $tribe');
          continue;
        }

        if (isArchived != 0) {
          debugPrint('Skipping archived item: $title');
          continue;
        }

        if (category.toLowerCase() != 'event' && !_isImageContent(file)) {
          debugPrint('Skipping non-event content: $file (category: $category)');
          continue;
        }

        final event = EventItem(
          id: id.toString(),
          name: title,
          description: description ?? 'No description available',
          imagePath: '$_uploadsBaseUrl$file',
          file: file,
          location: 'Davao Region, Philippines',
          date: _formatDate(time),
          isNetworkSource: true,
        );
        
        debugPrint('✅ Added event: $title (ID: $id, Category: $category)');
        events.add(event);
      }

      debugPrint('Final event count: ${events.length}');

      setState(() {
        _allEvents = events;
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      debugPrint('Error fetching events: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load events: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  bool _isImageContent(String filename) {
    final String lowerFilename = filename.toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return imageExtensions.any((ext) => lowerFilename.endsWith(ext));
  }

  String _formatDate(String timeString) {
    try {
      final DateTime dateTime = DateTime.parse(timeString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return timeString;
    }
  }

  Future<void> _refreshEvents() async {
    await _fetchEvents();
  }

  // Responsive helper methods
  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  double _getHorizontalPadding(double width) {
    if (width >= 1200) return 40;
    if (width >= 900) return 32;
    if (width >= 600) return 24;
    return 20;
  }

  double _getFeaturedImageHeight(double width) {
    if (width >= 1200) return 300;
    if (width >= 900) return 250;
    if (width >= 600) return 220;
    return 200;
  }

  double _getHeaderFontSize(double width) {
    if (width >= 900) return 24;
    if (width >= 600) return 22;
    return 20;
  }

  double _getDescriptionFontSize(double width) {
    if (width >= 900) return 18;
    if (width >= 600) return 17;
    return 16;
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
                child: _isLoading 
                    ? _buildLoadingState()
                    : _errorMessage != null 
                        ? _buildErrorState()
                        : _allEvents.isEmpty
                            ? _buildEmptyState()
                            : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Mansaka events...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _getHorizontalPadding(MediaQuery.of(context).size.width),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB19CD9),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mansaka events available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB19CD9),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(width);

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: const Color(0xFFB19CD9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Center content for large screens
          final maxWidth = constraints.maxWidth > 1400 ? 1400.0 : constraints.maxWidth;
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(horizontalPadding),
                    const SizedBox(height: 20),
                    _buildFeaturedImage(horizontalPadding, width),
                    const SizedBox(height: 24),
                    _buildDescription(horizontalPadding, width),
                    const SizedBox(height: 32),
                    _buildBrowseSection(horizontalPadding),
                    const SizedBox(height: 20),
                    _buildEventsGrid(horizontalPadding, width),
                    SizedBox(height: 40 + MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(width);
    final fontSize = _getHeaderFontSize(width);

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
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
              'MANSAKA EVENTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search events',
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

  Widget _buildFeaturedImage(double horizontalPadding, double width) {
    final height = _getFeaturedImageHeight(width);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        height: height,
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
            'assets/images/mansaka_eve.jpg',
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
                    Icons.event,
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

  Widget _buildDescription(double horizontalPadding, double width) {
    final fontSize = _getDescriptionFontSize(width);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse through a collection of historical and contemporary photographs showcasing Mansaka events, ceremonies, and cultural celebrations that preserve their rich heritage.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: fontSize,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseSection(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        'Browse events (${_filteredEvents.length})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventsGrid(double horizontalPadding, double width) {
    if (_filteredEvents.isEmpty) {
      return _buildNoResults(horizontalPadding);
    }

    final crossAxisCount = _getCrossAxisCount(width);
    final spacing = width >= 900 ? 20.0 : 16.0;
    final childAspectRatio = width >= 600 ? 0.9 : 0.85;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_filteredEvents[index], index);
        },
      ),
    );
  }

  Widget _buildNoResults(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              'No events found',
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

  Widget _buildEventCard(EventItem event, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showEventViewer(event, index);
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
                child: event.isNetworkSource
                    ? Image.network(
                        event.imagePath,
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
                                Icons.event,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        event.imagePath,
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
                                Icons.event,
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
                      event.name,
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
                      event.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _showEventViewer(EventItem event, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventViewerBottomSheet(
        events: _filteredEvents,
        initialIndex: index,
        accentColor: const Color(0xFFB19CD9),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class EventItem {
  final String? id;
  final String name;
  final String description;
  final String imagePath;
  final String? file;
  final String location;
  final String date;
  final bool isNetworkSource;

  EventItem({
    this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.file,
    required this.location,
    required this.date,
    this.isNetworkSource = false,
  });
}

class EventViewerBottomSheet extends StatefulWidget {
  final List<EventItem> events;
  final int initialIndex;
  final Color accentColor;

  const EventViewerBottomSheet({
    super.key,
    required this.events,
    required this.initialIndex,
    required this.accentColor,
  });

  @override
  State<EventViewerBottomSheet> createState() => _EventViewerBottomSheetState();
}

class _EventViewerBottomSheetState extends State<EventViewerBottomSheet> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxWidth = screenWidth > 800 ? 800.0 : screenWidth;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(isTablet),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  HapticFeedback.selectionClick();
                },
                itemCount: widget.events.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(widget.events[index], isTablet);
                },
              ),
            ),
            _buildPageIndicator(),
            SizedBox(height: 20 + keyboardHeight * 0.1),
          ],
        ),
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

  Widget _buildHeader(bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          Text(
            'Event Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 20 : 18,
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

  Widget _buildEventCard(EventItem event, bool isTablet) {
    final horizontalPadding = isTablet ? 32.0 : 20.0;
    final imageHeight = isTablet ? 350.0 : 250.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(event),
            child: Container(
              height: imageHeight,
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
                    event.isNetworkSource
                        ? Image.network(
                            event.imagePath,
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
                                    Icons.event,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFF2A2A2A),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            event.imagePath,
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
                                    Icons.event,
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
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30 + MediaQuery.of(context).viewInsets.bottom * 0.1),
        ],
      ),
    );
  }

  void _showFullScreenImage(EventItem event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImageViewer(
            event: event,
            accentColor: widget.accentColor,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.events.length,
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
  final EventItem event;
  final Color accentColor;

  const FullScreenImageViewer({
    super.key,
    required this.event,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

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
                child: widget.event.isNetworkSource
                    ? Image.network(
                        widget.event.imagePath,
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
                                Icons.event,
                                color: Colors.white,
                                size: 100,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.7,
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB19CD9)),
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.event.imagePath,
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
                                Icons.event,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 20,
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
                                  widget.event.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Mansaka Event',
                                  style: TextStyle(
                                    color: widget.accentColor,
                                    fontSize: isTablet ? 16 : 14,
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
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                      child: Text(
                        'Tap to zoom • Pinch to scale • Drag to pan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isTablet ? 14 : 12,
                        ),
                        textAlign: TextAlign.center,
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