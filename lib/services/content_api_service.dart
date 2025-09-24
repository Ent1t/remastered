import 'dart:convert';
import 'package:http/http.dart' as http;

class ContentApiService {
  static const String _baseUrl = 'https://huni-cms.ionvop.com/api/';
  
  // Fetch all content with optional filters
  static Future<List<Map<String, dynamic>>> fetchContent({
    String? category,
    String? tribe,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    
    if (category != null) queryParams['category'] = category;
    if (tribe != null) queryParams['tribe'] = tribe;
    if (type != null) queryParams['type'] = type;
    
    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        throw Exception('Failed to load content: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Fetch single content item by ID
  static Future<Map<String, dynamic>?> fetchContentById(String id) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'id': id});
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load content: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get content by category (convenience method)
  static Future<List<Map<String, dynamic>>> fetchByCategory(String category) {
    return fetchContent(category: category);
  }
  
  // Get content by tribe (convenience method)
  static Future<List<Map<String, dynamic>>> fetchByTribe(String tribe) {
    return fetchContent(tribe: tribe);
  }
  
  // Get content by type (convenience method)
  static Future<List<Map<String, dynamic>>> fetchByType(String type) {
    return fetchContent(type: type);
  }
}