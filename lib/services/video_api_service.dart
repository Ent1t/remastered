import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic API response wrapper that matches your existing code structure
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.error,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      isSuccess: true,
      data: data,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse<T>(
      isSuccess: false,
      error: message,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

/// Video item model that matches your existing VideoItem structure
class VideoItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String videoUrl;
  final String description;
  final String category;
  final String tribe;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.videoUrl,
    required this.description,
    required this.category,
    required this.tribe,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Video',
      thumbnailUrl: _buildThumbnailUrl(json['file']),
      duration: json['duration'] ?? '--:--',
      videoUrl: _buildVideoUrl(json['file']),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      tribe: json['tribe'] ?? '',
      type: json['type'] ?? 'video',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Build thumbnail URL from file path
  static String _buildThumbnailUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';
    if (filePath.startsWith('http')) return filePath;
    
    // Generate thumbnail path - you might need to adjust this based on your server setup
    final fileName = filePath.split('/').last;
    final nameWithoutExt = fileName.split('.').first;
    return 'https://huni-cms.ionvop.com/uploads/thumbnails/${nameWithoutExt}_thumb.jpg';
  }

  /// Build video URL from file path
  static String _buildVideoUrl(String? filePath) {
    if (filePath == null || filePath.isEmpty) return '';
    if (filePath.startsWith('http')) return filePath;
    return 'https://huni-cms.ionvop.com/uploads/$filePath';
  }

  /// Parse datetime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        try {
          return DateTime.parse(dateValue.replaceAll(' ', 'T'));
        } catch (e) {
          return null;
        }
      }
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration': duration,
      'description': description,
      'category': category,
      'tribe': tribe,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Main API service class for interacting with your PHP API
class VideoApiService {
  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/';
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch videos from the PHP API with optional filters
  static Future<ApiResponse<List<VideoItem>>> fetchVideos({
    String? tribe,
    String? category,
    String? type = 'video',
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      // Use the exact parameter names your PHP API expects
      if (tribe != null) queryParams['tribe'] = tribe;
      if (category != null && category != 'All') queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('VideoApiService: Making request to: $uri'); // Debug log

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      print('VideoApiService: Response status: ${response.statusCode}'); // Debug log
      print('VideoApiService: Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Your PHP API returns {"data": [...]} format
        final List<dynamic> dataList = jsonData['data'] ?? [];
        
        final videos = dataList
            .map((item) {
              try {
                return VideoItem.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('VideoApiService: Error parsing video item: $e');
                return null;
              }
            })
            .where((video) => video != null)
            .cast<VideoItem>()
            .toList();

        return ApiResponse.success(videos);

      } else if (response.statusCode == 404) {
        return ApiResponse.success([]); // No videos found
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // Use default error message if JSON parsing fails
        }
        
        return ApiResponse.error(errorMessage, response.statusCode);
      }

    } on http.ClientException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } on FormatException catch (e) {
      return ApiResponse.error('Invalid JSON response: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Fetch a specific video by ID
  static Future<ApiResponse<VideoItem?>> fetchVideoById(String videoId) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {'id': videoId});
      
      print('VideoApiService: Fetching video by ID: $uri'); // Debug log
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'];
        
        if (data != null) {
          final video = VideoItem.fromJson(data);
          return ApiResponse.success(video);
        } else {
          return ApiResponse.success(null);
        }
      } else if (response.statusCode == 404) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }

    } catch (e) {
      return ApiResponse.error('Failed to fetch video: ${e.toString()}');
    }
  }

  /// Fetch available categories from the API
  static Future<ApiResponse<List<String>>> fetchCategories({
    String? tribe,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (tribe != null) queryParams['tribe'] = tribe;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('VideoApiService: Fetching categories: $uri'); // Debug log

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        
        // Extract unique categories from the data
        final categories = <String>{'All'};
        for (var item in dataList) {
          final category = item['category']?.toString();
          if (category != null && category.isNotEmpty) {
            categories.add(category);
          }
        }

        final categoryList = categories.toList();
        print('VideoApiService: Found categories: $categoryList'); // Debug log
        
        return ApiResponse.success(categoryList);

      } else {
        // Return default categories if API fails
        final defaultCategories = ['All', 'Dance', 'Ceremony', 'Lifestyle', 'Music', 'Crafts'];
        print('VideoApiService: Using default categories due to API error'); // Debug log
        return ApiResponse.success(defaultCategories);
      }

    } catch (e) {
      // Return default categories if there's an error
      final defaultCategories = ['All', 'Dance', 'Ceremony', 'Lifestyle', 'Music', 'Crafts'];
      print('VideoApiService: Using default categories due to error: $e'); // Debug log
      return ApiResponse.success(defaultCategories);
    }
  }

  /// Search videos with a query string
  static Future<ApiResponse<List<VideoItem>>> searchVideos({
    required String query,
    String? tribe,
    String? category,
    String? type = 'video',
  }) async {
    try {
      // First fetch all videos with filters, then search locally
      // Since your PHP API doesn't have search functionality yet
      final videosResponse = await fetchVideos(
        tribe: tribe,
        category: category,
        type: type,
      );
      
      if (!videosResponse.isSuccess || videosResponse.data == null) {
        return ApiResponse.error(videosResponse.error ?? 'Failed to fetch videos for search');
      }
      
      final allVideos = videosResponse.data!;
      final searchQuery = query.toLowerCase();
      
      // Filter videos based on search query
      final filteredVideos = allVideos.where((video) {
        return video.title.toLowerCase().contains(searchQuery) ||
               video.description.toLowerCase().contains(searchQuery) ||
               video.category.toLowerCase().contains(searchQuery);
      }).toList();
      
      print('VideoApiService: Search for "$query" found ${filteredVideos.length} results'); // Debug log
      
      return ApiResponse.success(filteredVideos);
      
    } catch (e) {
      return ApiResponse.error('Search error: ${e.toString()}');
    }
  }

  /// Fetch all content types (not just videos) - useful for future features
  static Future<ApiResponse<List<Map<String, dynamic>>>> fetchAllContent({
    String? category,
    String? tribe,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (category != null && category != 'All') queryParams['category'] = category;
      if (tribe != null) queryParams['tribe'] = tribe;
      if (type != null) queryParams['type'] = type;
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        
        final content = dataList
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        
        return ApiResponse.success(content);
      } else {
        return ApiResponse.error('HTTP Error: ${response.statusCode}', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Get content statistics - useful for dashboard/analytics
  static Future<ApiResponse<Map<String, int>>> getContentStats({
    String? tribe,
  }) async {
    try {
      final contentResponse = await fetchAllContent(tribe: tribe);
      
      if (!contentResponse.isSuccess || contentResponse.data == null) {
        return ApiResponse.error('Failed to fetch content for stats');
      }
      
      final content = contentResponse.data!;
      final stats = <String, int>{};
      
      // Count by type
      for (var item in content) {
        final type = item['type']?.toString() ?? 'unknown';
        stats[type] = (stats[type] ?? 0) + 1;
      }
      
      // Add total count
      stats['total'] = content.length;
      
      return ApiResponse.success(stats);
      
    } catch (e) {
      return ApiResponse.error('Stats error: ${e.toString()}');
    }
  }
}