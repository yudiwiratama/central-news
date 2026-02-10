import 'package:flutter/foundation.dart';
import '../models/news_item.dart';
import '../models/news_category.dart';
import '../services/news_service.dart';
import '../constants/news_config.dart';
import 'settings_provider.dart';

enum NewsLoadingState { initial, loading, success, error }

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  SettingsProvider? _settingsProvider;

  // State for each category
  final Map<String, List<NewsItem>> _newsByCategory = {};
  final Map<String, NewsLoadingState> _loadingStates = {};
  final Map<String, String> _errorMessages = {};

  // Getters
  List<NewsItem> getNewsForCategory(String categoryId) {
    return _newsByCategory[categoryId] ?? [];
  }

  NewsLoadingState getLoadingState(String categoryId) {
    return _loadingStates[categoryId] ?? NewsLoadingState.initial;
  }

  String? getErrorMessage(String categoryId) {
    return _errorMessages[categoryId];
  }

  bool isLoading(String categoryId) {
    return _loadingStates[categoryId] == NewsLoadingState.loading;
  }

  bool hasError(String categoryId) {
    return _loadingStates[categoryId] == NewsLoadingState.error;
  }

  bool isEmpty(String categoryId) {
    final state = _loadingStates[categoryId];
    final news = _newsByCategory[categoryId] ?? [];
    return state == NewsLoadingState.success && news.isEmpty;
  }

  /// Set settings provider reference
  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  /// Fetch news for a specific category
  Future<void> fetchNewsForCategory(
    NewsCategory category, {
    bool refresh = false,
  }) async {
    // If already loading, don't trigger another request
    if (_loadingStates[category.id] == NewsLoadingState.loading && !refresh) {
      return;
    }

    // Set loading state
    _loadingStates[category.id] = NewsLoadingState.loading;
    _errorMessages.remove(category.id);
    notifyListeners();

    try {
      // Get enabled sources from settings
      final enabledSources = _settingsProvider?.getEnabledSources(
        category.id,
        category.feeds,
      ) ?? category.feeds;
      
      // Get active keywords from settings
      final keywords = _settingsProvider?.getActiveKeywords(
        NewsConfig.governmentKeywords,
      );

      // Fetch news from service with enabled sources and keywords
      final news = await _newsService.fetchCategoryNews(
        category,
        enabledSources,
        filterKeywords: keywords,
      );

      // Update state
      _newsByCategory[category.id] = news;
      _loadingStates[category.id] = NewsLoadingState.success;
      _errorMessages.remove(category.id);
    } catch (e) {
      // Handle error
      _loadingStates[category.id] = NewsLoadingState.error;
      _errorMessages[category.id] = _getErrorMessage(e);
      
      // Keep existing data if available (for refresh scenarios)
      if (_newsByCategory[category.id] == null) {
        _newsByCategory[category.id] = [];
      }
    } finally {
      notifyListeners();
    }
  }

  /// Fetch all categories at once (initial load)
  Future<void> fetchAllCategories(List<NewsCategory> categories) async {
    // Set all to loading
    for (final category in categories) {
      _loadingStates[category.id] = NewsLoadingState.loading;
    }
    notifyListeners();

    // Fetch all in parallel
    await Future.wait(
      categories.map((category) => fetchNewsForCategory(category)),
    );
  }

  /// Refresh news for a specific category (pull-to-refresh)
  Future<void> refreshCategory(NewsCategory category) async {
    return fetchNewsForCategory(category, refresh: true);
  }

  /// Clear all data (useful for logout or reset)
  void clearAll() {
    _newsByCategory.clear();
    _loadingStates.clear();
    _errorMessages.clear();
    notifyListeners();
  }

  /// Clear data for specific category
  void clearCategory(String categoryId) {
    _newsByCategory.remove(categoryId);
    _loadingStates.remove(categoryId);
    _errorMessages.remove(categoryId);
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Koneksi timeout. Silakan coba lagi.';
    } else if (errorStr.contains('socket') || 
               errorStr.contains('network') ||
               errorStr.contains('connection')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    } else if (errorStr.contains('404')) {
      return 'Sumber berita tidak ditemukan.';
    } else if (errorStr.contains('500') || 
               errorStr.contains('502') || 
               errorStr.contains('503')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Get total news count across all categories
  int getTotalNewsCount() {
    return _newsByCategory.values
        .fold(0, (sum, list) => sum + list.length);
  }

  /// Check if any category has loaded successfully
  bool hasAnyLoadedNews() {
    return _newsByCategory.values.any((list) => list.isNotEmpty);
  }
}

