import 'package:flutter/foundation.dart';
import '../services/summary_service.dart';

class SummaryProvider extends ChangeNotifier {
  final SummaryService _summaryService = SummaryService();
  
  // Summaries by category
  final Map<String, CategorySummary?> _summaries = {};
  
  // Loading states
  final Map<String, bool> _isLoading = {};
  
  // API health status
  bool _apiAvailable = false;
  bool _isCheckingHealth = false;
  
  bool get apiAvailable => _apiAvailable;
  bool get isCheckingHealth => _isCheckingHealth;
  
  /// Get summary for a category
  CategorySummary? getSummary(String categoryId) {
    return _summaries[categoryId];
  }
  
  /// Check if summary is loading
  bool isLoading(String categoryId) {
    return _isLoading[categoryId] ?? false;
  }
  
  /// Check if summary exists
  bool hasSummary(String categoryId) {
    return _summaries[categoryId] != null;
  }
  
  /// Check API health
  Future<void> checkHealth() async {
    _isCheckingHealth = true;
    notifyListeners();
    
    try {
      _apiAvailable = await _summaryService.checkHealth();
      print('API Health check: ${_apiAvailable ? "OK" : "Down"}');
    } catch (e) {
      _apiAvailable = false;
      print('API Health check error: $e');
    } finally {
      _isCheckingHealth = false;
      notifyListeners();
    }
  }
  
  /// Fetch summary for a category
  Future<void> fetchSummary(String categoryId) async {
    // If already loading, skip
    if (_isLoading[categoryId] == true) {
      return;
    }
    
    _isLoading[categoryId] = true;
    notifyListeners();
    
    try {
      final summary = await _summaryService.fetchCategorySummary(categoryId);
      
      if (summary != null) {
        _summaries[categoryId] = summary;
        print('✓ Summary loaded for $categoryId');
      } else {
        print('✗ No summary available for $categoryId');
      }
    } catch (e) {
      print('Error fetching summary for $categoryId: $e');
    } finally {
      _isLoading[categoryId] = false;
      notifyListeners();
    }
  }
  
  /// Fetch all summaries
  Future<void> fetchAllSummaries() async {
    try {
      final summaries = await _summaryService.fetchAllSummaries();
      
      _summaries.clear();
      _summaries.addAll(summaries);
      
      print('✓ All summaries loaded: ${summaries.length} categories');
      notifyListeners();
    } catch (e) {
      print('Error fetching all summaries: $e');
    }
  }
  
  /// Clear summary for a category
  void clearSummary(String categoryId) {
    _summaries.remove(categoryId);
    notifyListeners();
  }
  
  /// Clear all summaries
  void clearAll() {
    _summaries.clear();
    notifyListeners();
  }
}

