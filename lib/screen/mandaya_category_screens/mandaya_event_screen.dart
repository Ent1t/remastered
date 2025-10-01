// lib/screen/mandaya_category_screens/mandaya_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MandayaEventScreen extends StatefulWidget {
  const MandayaEventScreen({super.key});

  @override
  State<MandayaEventScreen> createState() => _MandayaEventScreenState();
}

class _MandayaEventScreenState extends State<MandayaEventScreen> {
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

  // Responsive helper methods
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Desktop
    if (width >= 900) return 3;  // Tablet landscape
    if (width >= 600) return 2;  // Tablet portrait
    return 2;                     // Mobile
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 40;
    if (width >= 600) return 30;
    return 20;
  }

  double _getFeaturedImageHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 300;
    if (width >= 600) return 250;
    return 200;
  }

  double _getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return baseSize * 1.2;
    if (width >= 600) return baseSize * 1.1;
    return baseSize;
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

      debugPrint('Fetching Mandaya events from: $_baseUrl');
      
      const String apiUrl = '$_baseUrl?tribe=mandaya&category=event';
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
        
        if (tribe.toLowerCase() != 'mandaya') {
          debugPrint('Skipping non-Mandaya item: $tribe');
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
          location: 'Davao Oriental, Philippines',
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Mandaya events...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: _getFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: _getFontSize(context, 64),
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: _getFontSize(context, 18),
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
                  fontSize: _getFontSize(context, 14),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FB069),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: _getFontSize(context, 24),
                  vertical: _getFontSize(context, 12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: _getFontSize(context, 14)),
              ),
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
            size: _getFontSize(context, 64),
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mandaya events available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: _getFontSize(context, 18),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: _getFontSize(context, 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FB069),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: _getFontSize(context, 24),
                vertical: _getFontSize(context, 12),
              ),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(fontSize: _getFontSize(context, 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final horizontalPadding = _getHorizontalPadding(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: const Color(0xFF7FB069),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1400 : double.infinity,
              ),
              child: Center(
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
                    _buildEventsGrid(),
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
    final horizontalPadding = _getHorizontalPadding(context);
    
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
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: _getFontSize(context, 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'MANDAYA EVENTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: _getFontSize(context, 20),
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
    final horizontalPadding = _getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: _getFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: 'Search events',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: _getFontSize(context, 16),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.6),
              size: _getFontSize(context, 24),
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
                      size: _getFontSize(context, 24),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: _getFontSize(context, 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    final horizontalPadding = _getHorizontalPadding(context);
    final imageHeight = _getFeaturedImageHeight(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        height: imageHeight,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1200),
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
            'assets/images/mandaya_events_featured.jpg',
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
                child: Center(
                  child: Icon(
                    Icons.event,
                    color: Colors.white,
                    size: _getFontSize(context, 60),
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
    final horizontalPadding = _getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse through a collection of historical and contemporary photographs showcasing Mandaya events, ceremonies, and cultural celebrations that preserve their rich heritage.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: _getFontSize(context, 16),
                height: 1.6,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseSection() {
    final horizontalPadding = _getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        'Browse events (${_filteredEvents.length})',
        style: TextStyle(
          color: Colors.white,
          fontSize: _getFontSize(context, 20),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    if (_filteredEvents.isEmpty) {
      return _buildNoResults();
    }

    final horizontalPadding = _getHorizontalPadding(context);
    final crossAxisCount = _getCrossAxisCount(context);
    final spacing = MediaQuery.of(context).size.width >= 900 ? 20.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.85,
          ),
          itemCount: _filteredEvents.length,
          itemBuilder: (context, index) {
            return _buildEventCard(_filteredEvents[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final horizontalPadding = _getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.search_off,
              size: _getFontSize(context, 64),
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: _getFontSize(context, 18),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: _getFontSize(context, 14),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventItem event, int index) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;
    
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
                                  Color(0xFF7FB069),
                                  Color(0xFF4A5D23),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.event,
                                color: Colors.white,
                                size: isLargeScreen ? 50 : 40,
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
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
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
                                  Color(0xFF7FB069),
                                  Color(0xFF4A5D23),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.event,
                                color: Colors.white,
                                size: isLargeScreen ? 50 : 40,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                color: const Color(0xFF2A2A2A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getFontSize(context, 14),
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
                        fontSize: _getFontSize(context, 12),
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
        accentColor: const Color(0xFF7FB069),
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

  double _getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return baseSize * 1.2;
    if (width >= 600) return baseSize * 1.1;
    return baseSize;
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 40;
    if (width >= 600) return 30;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.9;
    
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
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
                return _buildEventCard(widget.events[index]);
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
    final horizontalPadding = _getHorizontalPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Row(
        children: [
          Text(
            'Event Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: _getFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: _getFontSize(context, 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    final horizontalPadding = _getHorizontalPadding(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth >= 900 ? 350.0 : screenWidth >= 600 ? 300.0 : 250.0;
    
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
              constraints: const BoxConstraints(maxWidth: 800),
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
                                child: Center(
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: _getFontSize(context, 60),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
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
                                child: Center(
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: _getFontSize(context, 60),
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
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: _getFontSize(context, 16),
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
            constraints: const BoxConstraints(maxWidth: 800),
            padding: EdgeInsets.all(_getFontSize(context, 16)),
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
                    fontSize: _getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: _getFontSize(context, 14),
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
    final indicatorSize = MediaQuery.of(context).size.width >= 600 ? 10.0 : 8.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.events.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: indicatorSize,
          height: indicatorSize,
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

  double _getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return baseSize * 1.2;
    if (width >= 600) return baseSize * 1.1;
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(isLargeScreen ? 40 : 20),
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
                            child: Center(
                              child: Icon(
                                Icons.event,
                                color: Colors.white,
                                size: _getFontSize(context, 100),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FB069)),
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
                            child: Center(
                              child: Icon(
                                Icons.event,
                                color: Colors.white,
                                size: _getFontSize(context, 100),
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
                        horizontal: isLargeScreen ? 30 : 20,
                        vertical: isLargeScreen ? 20 : 16,
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
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: _getFontSize(context, 28),
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
                                    fontSize: _getFontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Mandaya Event',
                                  style: TextStyle(
                                    color: widget.accentColor,
                                    fontSize: _getFontSize(context, 14),
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
                      padding: EdgeInsets.all(isLargeScreen ? 30 : 20),
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
                          fontSize: _getFontSize(context, 12),
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