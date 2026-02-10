import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/news_category.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  // Enabled/disabled sources per category
  Map<String, Map<String, bool>> _sourcePreferences = {};
  
  // Custom RSS feeds added by user
  List<CustomRssFeed> _customFeeds = [];
  
  // Custom filter keywords
  List<String> _customKeywords = [];
  
  // Enabled/disabled default keywords (Map<keyword, bool>)
  Map<String, bool> _defaultKeywordStates = {};
  
  // Enable/disable filtering - DEFAULT: FALSE (user sees all news)
  bool _filterEnabled = false;
  
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  // Get custom keywords
  List<String> get customKeywords => List.unmodifiable(_customKeywords);
  
  // Get filter enabled status
  bool get filterEnabled => _filterEnabled;
  
  // Get default keyword states
  Map<String, bool> get defaultKeywordStates => Map.unmodifiable(_defaultKeywordStates);
  
  // Get source preferences for a category
  Map<String, bool> getSourcePreferences(String categoryId) {
    return _sourcePreferences[categoryId] ?? {};
  }
  
  // Check if a source is enabled
  bool isSourceEnabled(String categoryId, String sourceUrl) {
    return _sourcePreferences[categoryId]?[sourceUrl] ?? true;
  }
  
  // Get custom feeds
  List<CustomRssFeed> get customFeeds => List.unmodifiable(_customFeeds);
  
  // Get custom feeds for a category
  List<CustomRssFeed> getCustomFeedsForCategory(String categoryId) {
    return _customFeeds
        .where((feed) => feed.categoryId == categoryId)
        .toList();
  }
  
  // Initialize settings
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadSourcePreferences();
    await _loadCustomFeeds();
    await _loadCustomKeywords();
    await _loadDefaultKeywordStates();
    await _loadFilterEnabled();
    
    _isInitialized = true;
    notifyListeners();
  }
  
  // Load source preferences from storage
  Future<void> _loadSourcePreferences() async {
    final json = _prefs?.getString('source_preferences');
    if (json != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        _sourcePreferences = data.map(
          (key, value) => MapEntry(
            key,
            (value as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v as bool),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error loading source preferences: $e');
        _sourcePreferences = {};
      }
    }
  }
  
  // Load custom feeds from storage
  Future<void> _loadCustomFeeds() async {
    final json = _prefs?.getString('custom_feeds');
    if (json != null) {
      try {
        final List<dynamic> data = jsonDecode(json);
        _customFeeds = data
            .map((item) => CustomRssFeed.fromJson(item))
            .toList();
      } catch (e) {
        debugPrint('Error loading custom feeds: $e');
        _customFeeds = [];
      }
    }
  }
  
  // Load custom keywords from storage
  Future<void> _loadCustomKeywords() async {
    final json = _prefs?.getString('custom_keywords');
    if (json != null) {
      try {
        final List<dynamic> data = jsonDecode(json);
        _customKeywords = data.map((item) => item.toString()).toList();
      } catch (e) {
        debugPrint('Error loading custom keywords: $e');
        _customKeywords = [];
      }
    }
  }
  
  // Load default keyword states
  Future<void> _loadDefaultKeywordStates() async {
    final json = _prefs?.getString('default_keyword_states');
    if (json != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(json);
        _defaultKeywordStates = data.map((key, value) => MapEntry(key, value as bool));
      } catch (e) {
        debugPrint('Error loading default keyword states: $e');
        _defaultKeywordStates = {};
      }
    }
  }
  
  // Load filter enabled status
  Future<void> _loadFilterEnabled() async {
    _filterEnabled = _prefs?.getBool('filter_enabled') ?? false; // Default: OFF
  }
  
  // Toggle source enabled/disabled
  Future<void> toggleSource(String categoryId, String sourceUrl, bool enabled) async {
    if (_sourcePreferences[categoryId] == null) {
      _sourcePreferences[categoryId] = {};
    }
    
    _sourcePreferences[categoryId]![sourceUrl] = enabled;
    await _saveSourcePreferences();
    notifyListeners();
  }
  
  // Save source preferences to storage
  Future<void> _saveSourcePreferences() async {
    final json = jsonEncode(_sourcePreferences);
    await _prefs?.setString('source_preferences', json);
  }
  
  // Add custom RSS feed
  Future<bool> addCustomFeed(CustomRssFeed feed) async {
    // Check if URL already exists
    if (_customFeeds.any((f) => f.url == feed.url)) {
      return false;
    }
    
    _customFeeds.add(feed);
    await _saveCustomFeeds();
    notifyListeners();
    return true;
  }
  
  // Remove custom RSS feed
  Future<void> removeCustomFeed(String url) async {
    _customFeeds.removeWhere((feed) => feed.url == url);
    await _saveCustomFeeds();
    notifyListeners();
  }
  
  // Update custom feed
  Future<void> updateCustomFeed(String oldUrl, CustomRssFeed newFeed) async {
    final index = _customFeeds.indexWhere((f) => f.url == oldUrl);
    if (index != -1) {
      _customFeeds[index] = newFeed;
      await _saveCustomFeeds();
      notifyListeners();
    }
  }
  
  // Save custom feeds to storage
  Future<void> _saveCustomFeeds() async {
    final json = jsonEncode(_customFeeds.map((f) => f.toJson()).toList());
    await _prefs?.setString('custom_feeds', json);
  }
  
  // Save custom keywords to storage
  Future<void> _saveCustomKeywords() async {
    final json = jsonEncode(_customKeywords);
    await _prefs?.setString('custom_keywords', json);
  }
  
  // Save default keyword states
  Future<void> _saveDefaultKeywordStates() async {
    final json = jsonEncode(_defaultKeywordStates);
    await _prefs?.setString('default_keyword_states', json);
  }
  
  // Save filter enabled status
  Future<void> _saveFilterEnabled() async {
    await _prefs?.setBool('filter_enabled', _filterEnabled);
  }
  
  // Add custom keyword
  Future<bool> addKeyword(String keyword) async {
    final trimmed = keyword.trim().toLowerCase();
    if (trimmed.isEmpty) return false;
    
    // Check if already exists
    if (_customKeywords.contains(trimmed)) {
      return false;
    }
    
    _customKeywords.add(trimmed);
    await _saveCustomKeywords();
    notifyListeners();
    return true;
  }
  
  // Remove custom keyword
  Future<void> removeKeyword(String keyword) async {
    _customKeywords.remove(keyword.toLowerCase());
    await _saveCustomKeywords();
    notifyListeners();
  }
  
  // Toggle filter enabled/disabled
  Future<void> toggleFilter(bool enabled) async {
    _filterEnabled = enabled;
    await _saveFilterEnabled();
    notifyListeners();
  }
  
  // Toggle default keyword on/off
  Future<void> toggleDefaultKeyword(String keyword, bool enabled) async {
    _defaultKeywordStates[keyword] = enabled;
    await _saveDefaultKeywordStates();
    notifyListeners();
  }
  
  // Check if default keyword is enabled
  bool isDefaultKeywordEnabled(String keyword) {
    return _defaultKeywordStates[keyword] ?? true; // Default to true (enabled)
  }
  
  // Get all active keywords (default + custom)
  List<String> getActiveKeywords(List<String> defaultKeywords) {
    if (!_filterEnabled) return [];
    
    // If user has custom keywords, use only custom
    if (_customKeywords.isNotEmpty) {
      return _customKeywords;
    }
    
    // Otherwise, use enabled default keywords
    return defaultKeywords.where((keyword) => isDefaultKeywordEnabled(keyword)).toList();
  }
  
  // Get count of enabled default keywords
  int getEnabledDefaultKeywordsCount(List<String> defaultKeywords) {
    return defaultKeywords.where((k) => isDefaultKeywordEnabled(k)).length;
  }
  
  // Reset custom keywords to default
  Future<void> resetKeywords() async {
    _customKeywords = [];
    _defaultKeywordStates = {};
    await _prefs?.remove('custom_keywords');
    await _prefs?.remove('default_keyword_states');
    notifyListeners();
  }
  
  // Reset all settings
  Future<void> resetSettings() async {
    _sourcePreferences = {};
    _customFeeds = [];
    _customKeywords = [];
    _defaultKeywordStates = {};
    _filterEnabled = false; // Default: OFF
    await _prefs?.remove('source_preferences');
    await _prefs?.remove('custom_feeds');
    await _prefs?.remove('custom_keywords');
    await _prefs?.remove('default_keyword_states');
    await _prefs?.remove('filter_enabled');
    notifyListeners();
  }
  
  // Get enabled sources for a category (including custom)
  List<RssFeedSource> getEnabledSources(
    String categoryId,
    List<RssFeedSource> defaultSources,
  ) {
    final enabled = <RssFeedSource>[];
    
    // Add enabled default sources
    for (final source in defaultSources) {
      if (isSourceEnabled(categoryId, source.url)) {
        enabled.add(source);
      }
    }
    
    // Add custom sources
    for (final custom in getCustomFeedsForCategory(categoryId)) {
      enabled.add(RssFeedSource(
        url: custom.url,
        sourceName: custom.name,
      ));
    }
    
    return enabled;
  }
}

class CustomRssFeed {
  final String url;
  final String name;
  final String categoryId;
  final DateTime addedDate;
  
  CustomRssFeed({
    required this.url,
    required this.name,
    required this.categoryId,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'categoryId': categoryId,
    'addedDate': addedDate.toIso8601String(),
  };
  
  factory CustomRssFeed.fromJson(Map<String, dynamic> json) => CustomRssFeed(
    url: json['url'],
    name: json['name'],
    categoryId: json['categoryId'],
    addedDate: DateTime.parse(json['addedDate']),
  );
}

