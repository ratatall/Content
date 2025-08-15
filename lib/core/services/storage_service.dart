import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // API Key management
  static Future<void> saveApiKey(String apiKey) async {
    await _prefs?.setString(AppConstants.huggingfaceApiKeyKey, apiKey);
  }
  
  static String? getApiKey() {
    return _prefs?.getString(AppConstants.huggingfaceApiKeyKey);
  }
  
  static Future<void> removeApiKey() async {
    await _prefs?.remove(AppConstants.huggingfaceApiKeyKey);
  }
  
  // Cache management for offline access
  static Future<void> cacheResponse(String key, String response) async {
    final cachedResponses = getCachedResponses();
    cachedResponses[key] = {
      'response': response,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await _prefs?.setString(
      AppConstants.cachedResponsesKey,
      jsonEncode(cachedResponses),
    );
  }
  
  static Map<String, dynamic> getCachedResponses() {
    final cachedString = _prefs?.getString(AppConstants.cachedResponsesKey);
    if (cachedString == null) return {};
    
    try {
      return Map<String, dynamic>.from(jsonDecode(cachedString));
    } catch (e) {
      return {};
    }
  }
  
  static String? getCachedResponse(String key) {
    final cachedResponses = getCachedResponses();
    final cached = cachedResponses[key];
    
    if (cached == null) return null;
    
    // Check if cache is still valid (24 hours)
    final timestamp = cached['timestamp'] as int;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (now.difference(cacheTime).inHours > 24) {
      // Cache expired, remove it
      removeCachedResponse(key);
      return null;
    }
    
    return cached['response'] as String;
  }
  
  static Future<void> removeCachedResponse(String key) async {
    final cachedResponses = getCachedResponses();
    cachedResponses.remove(key);
    
    await _prefs?.setString(
      AppConstants.cachedResponsesKey,
      jsonEncode(cachedResponses),
    );
  }
  
  static Future<void> clearCache() async {
    await _prefs?.remove(AppConstants.cachedResponsesKey);
  }
  
  // Settings management
  static Future<void> saveBoolSetting(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }
  
  static bool getBoolSetting(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }
  
  static Future<void> saveStringSetting(String key, String value) async {
    await _prefs?.setString(key, value);
  }
  
  static String getStringSetting(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }
  
  static Future<void> saveIntSetting(String key, int value) async {
    await _prefs?.setInt(key, value);
  }
  
  static int getIntSetting(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }
  
  // Generate cache key for consistent caching
  static String generateCacheKey(String type, Map<String, String> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    final paramString = sortedParams.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    
    return '${type}_$paramString';
  }
}
