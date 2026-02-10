import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  // API Base URL - Change this to your VPS URL when deployed
  // 
  // Development (local):
  // static const String baseUrl = 'http://localhost:5000';
  //
  // Production (VPS):
  // static const String baseUrl = 'https://your-vps-domain.com';
  // atau
  // static const String baseUrl = 'http://your-vps-ip:5000';
  //
  // ⚠️ IMPORTANT: Ganti URL di bawah ini dengan URL VPS Anda!
  static const String baseUrl = 'http://43.129.55.32:5000'; // Fixed: removed extra slash
  
  /// Fetch summary for a specific category
  Future<CategorySummary?> fetchCategorySummary(String categoryId) async {
    final url = '$baseUrl/api/summary/$categoryId';
    print('🔍 Fetching summary from: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 60)); // Increased for AI generation time
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('✅ Summary fetched successfully for $categoryId');
          return CategorySummary.fromJson(data['data']);
        } else {
          print('⚠️ API returned success=false: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.body}');
      }
      
      return null;
    } catch (e, stackTrace) {
      print('❌ Error fetching summary for $categoryId:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
      return null;
    }
  }
  
  /// Fetch all summaries
  Future<Map<String, CategorySummary>> fetchAllSummaries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/summaries'),
      ).timeout(const Duration(seconds: 180)); // 3 minutes for all categories
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final Map<String, CategorySummary> summaries = {};
          
          final dataMap = data['data'] as Map<String, dynamic>;
          dataMap.forEach((key, value) {
            summaries[key] = CategorySummary.fromJson(value);
          });
          
          return summaries;
        }
      }
      
      return {};
    } catch (e) {
      print('Error fetching all summaries: $e');
      return {};
    }
  }
  
  /// Check if API server is healthy
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

class CategorySummary {
  final String category;
  final String summary;
  final List<String> highlights;
  final int newsCount;
  final DateTime generatedAt;
  final String? model;
  
  CategorySummary({
    required this.category,
    required this.summary,
    required this.highlights,
    required this.newsCount,
    required this.generatedAt,
    this.model,
  });
  
  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'] ?? '',
      summary: json['summary'] ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      newsCount: json['news_count'] ?? 0,
      generatedAt: DateTime.parse(json['generated_at']),
      model: json['model'],
    );
  }
  
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);
    
    if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}

