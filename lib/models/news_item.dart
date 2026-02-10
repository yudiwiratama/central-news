class NewsItem {
  final String title;
  final String description;
  final String link;
  final DateTime? pubDate;
  final String? imageUrl;
  final String sourceName;
  final String category;

  NewsItem({
    required this.title,
    required this.description,
    required this.link,
    this.pubDate,
    this.imageUrl,
    required this.sourceName,
    required this.category,
  });

  /// Check if this news item contains government-related keywords
  bool isGovernmentRelated(List<String> keywords) {
    final titleLower = title.toLowerCase();
    final descriptionLower = description.toLowerCase();

    return keywords.any((keyword) =>
        titleLower.contains(keyword.toLowerCase()) ||
        descriptionLower.contains(keyword.toLowerCase()));
  }

  /// Get relative time string (e.g., "2 hours ago")
  String getRelativeTime() {
    if (pubDate == null) return '';

    final now = DateTime.now();
    final difference = now.difference(pubDate!);

    if (difference.inDays > 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  String toString() {
    return 'NewsItem(title: $title, source: $sourceName, pubDate: $pubDate)';
  }
}

