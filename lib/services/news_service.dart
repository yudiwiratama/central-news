import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/news_item.dart';
import '../models/news_category.dart';
import '../constants/news_config.dart';

class NewsService {
  /// Fetch news for a specific category with government filtering
  Future<List<NewsItem>> fetchCategoryNews(
    NewsCategory category,
    List<RssFeedSource> enabledFeeds, {
    List<String>? filterKeywords,
  }) async {
    final List<NewsItem> allNews = [];
    final List<Future<void>> fetchTasks = [];

    // Fetch all enabled feeds in parallel for better performance
    for (final feed in enabledFeeds) {
      fetchTasks.add(
        _fetchSingleFeed(feed, category.name, filterKeywords: filterKeywords)
            .then((items) {
          allNews.addAll(items);
        }).catchError((error) {
          // Log error but don't stop other feeds from loading
          print('Error fetching ${feed.sourceName}: $error');
        }),
      );
    }

    // Wait for all feeds to complete (with individual error handling)
    await Future.wait(fetchTasks);

    // Sort by date (newest first)
    allNews.sort((a, b) {
      if (a.pubDate == null && b.pubDate == null) return 0;
      if (a.pubDate == null) return 1;
      if (b.pubDate == null) return -1;
      return b.pubDate!.compareTo(a.pubDate!);
    });

    return allNews;
  }

  /// Fetch and filter a single RSS feed
  Future<List<NewsItem>> _fetchSingleFeed(
    RssFeedSource feedConfig,
    String categoryName, {
    List<String>? filterKeywords,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(feedConfig.url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load feed: ${response.statusCode} from ${feedConfig.sourceName}');
      }

      // Parse RSS feed
      final feed = RssFeed.parse(response.body);
      final List<NewsItem> filteredNews = [];

      // Process each item
      for (final item in feed.items ?? []) {
        // Create NewsItem
        final newsItem = NewsItem(
          title: item.title?.trim() ?? 'No Title',
          description: _cleanDescription(item.description ?? ''),
          link: item.link ?? '',
          pubDate: item.pubDate,
          imageUrl: _extractImageUrl(item),
          sourceName: feedConfig.sourceName,
          category: categoryName,
        );

        // Apply filter if keywords provided
        if (filterKeywords == null || filterKeywords.isEmpty) {
          // No filter, add all news
          filteredNews.add(newsItem);
        } else if (newsItem.isGovernmentRelated(filterKeywords)) {
          // Filter enabled, check keywords
          filteredNews.add(newsItem);
        }
      }

      return filteredNews;
    } catch (e) {
      print('Error in _fetchSingleFeed for ${feedConfig.sourceName}: $e');
      rethrow;
    }
  }

  /// Extract image URL from RSS item
  String? _extractImageUrl(RssItem item) {
    // Try media:content or enclosure
    if (item.enclosure?.url != null &&
        item.enclosure!.url!.contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)',
            caseSensitive: false))) {
      return item.enclosure!.url;
    }

    // Try to extract from content
    final images = item.content?.images;
    if (images != null && images.isNotEmpty) {
      return images.first;
    }

    // Try to extract from description
    final description = item.description ?? '';
    final imgRegex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = imgRegex.firstMatch(description);
    if (match != null) {
      return match.group(1);
    }

    return null;
  }

  /// Clean HTML tags and extra whitespace from description
  String _cleanDescription(String description) {
    // Remove HTML tags
    String cleaned = description.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode common HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    
    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  /// Fetch news for all categories (useful for initial load)
  Future<Map<String, List<NewsItem>>> fetchAllCategories(
    List<RssFeedSource> Function(NewsCategory) getEnabledSources,
  ) async {
    final Map<String, List<NewsItem>> result = {};

    await Future.wait(
      NewsConfig.categories.map((category) async {
        try {
          final enabledSources = getEnabledSources(category);
          result[category.id] = await fetchCategoryNews(category, enabledSources);
        } catch (e) {
          print('Error fetching category ${category.name}: $e');
          result[category.id] = [];
        }
      }),
    );

    return result;
  }
}

