import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class VideoMetadataCache {
  static const String _durationCacheKey = 'video_durations_cache';
  static const String _thumbnailCacheKey = 'video_thumbnails_cache';
  
  static final Map<String, String> _durationMemoryCache = {};
  static final Map<String, String> _thumbnailMemoryCache = {};
  
  static Future<void> saveDuration(String videoId, String duration) async {
    _durationMemoryCache[videoId] = duration;
    
    final prefs = await SharedPreferences.getInstance();
    final cache = _getDurationCache(prefs);
    cache[videoId] = duration;
    await prefs.setString(_durationCacheKey, json.encode(cache));
  }
  
  static Future<void> saveThumbnail(String videoId, String thumbnailPath) async {
    _thumbnailMemoryCache[videoId] = thumbnailPath;
    
    final prefs = await SharedPreferences.getInstance();
    final cache = _getThumbnailCache(prefs);
    cache[videoId] = thumbnailPath;
    await prefs.setString(_thumbnailCacheKey, json.encode(cache));
  }
  
  static Future<String?> getDuration(String videoId) async {
    if (_durationMemoryCache.containsKey(videoId)) {
      return _durationMemoryCache[videoId];
    }
    
    final prefs = await SharedPreferences.getInstance();
    final cache = _getDurationCache(prefs);
    final duration = cache[videoId];
    
    if (duration != null) {
      _durationMemoryCache[videoId] = duration;
    }
    
    return duration;
  }
  
  static Future<String?> getThumbnail(String videoId) async {
    if (_thumbnailMemoryCache.containsKey(videoId)) {
      final path = _thumbnailMemoryCache[videoId]!;
      if (await File(path).exists()) {
        return path;
      } else {
        _thumbnailMemoryCache.remove(videoId);
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final cache = _getThumbnailCache(prefs);
    final thumbnailPath = cache[videoId];
    
    if (thumbnailPath != null && await File(thumbnailPath).exists()) {
      _thumbnailMemoryCache[videoId] = thumbnailPath;
      return thumbnailPath;
    }
    
    return null;
  }
  
  static Future<void> clearCache() async {
    _durationMemoryCache.clear();
    _thumbnailMemoryCache.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_durationCacheKey);
    await prefs.remove(_thumbnailCacheKey);
  }
  
  static Map<String, String> _getDurationCache(SharedPreferences prefs) {
    final cacheString = prefs.getString(_durationCacheKey);
    if (cacheString == null) return {};
    
    try {
      final decoded = json.decode(cacheString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }
  
  static Map<String, String> _getThumbnailCache(SharedPreferences prefs) {
    final cacheString = prefs.getString(_thumbnailCacheKey);
    if (cacheString == null) return {};
    
    try {
      final decoded = json.decode(cacheString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }
}