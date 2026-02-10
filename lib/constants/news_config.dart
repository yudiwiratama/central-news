import 'package:flutter/material.dart';
import '../models/news_category.dart';

class NewsConfig {
  /// Keywords for filtering government-related news (case-insensitive)
  static const List<String> governmentKeywords = [
    'pemerintah',
    'kementerian',
    'menteri',
    'presiden',
    'wapres',
    'dinas',
    'pemda',
    'bumn',
    'pejabat',
    'anggaran',
    'kebijakan',
  ];

  /// All news categories with their respective RSS feeds
  static final List<NewsCategory> categories = [
    const NewsCategory(
      id: 'hukum_politik',
      name: 'Hukum & Politik',
      icon: Icons.gavel,
      feeds: [
        RssFeedSource(
          url: 'https://www.antaranews.com/rss/politik.xml',
          sourceName: 'Antara News Politik',
        ),
        RssFeedSource(
          url: 'https://www.antaranews.com/rss/hukum.xml',
          sourceName: 'Antara News Hukum',
        ),
      ],
    ),
    const NewsCategory(
      id: 'ekonomi',
      name: 'Ekonomi',
      icon: Icons.attach_money,
      feeds: [
        RssFeedSource(
          url: 'https://djpb.kemenkeu.go.id/portal/id/berita.feed?type=rss',
          sourceName: 'DJPB Kemenkeu',
        ),
        RssFeedSource(
          url: 'https://www.antaranews.com/rss/ekonomi.xml',
          sourceName: 'Antara News Ekonomi',
        ),
        RssFeedSource(
          url: 'https://www.cnbcindonesia.com/market/rss',
          sourceName: 'CNBC Indonesia Market',
        ),
      ],
    ),
    const NewsCategory(
      id: 'pendidikan',
      name: 'Pendidikan',
      icon: Icons.school,
      feeds: [
        RssFeedSource(
          url: 'https://www.detik.com/edu/rss',
          sourceName: 'Detik Edu',
        ),
        RssFeedSource(
          url: 'https://edukasi.sindonews.com/rss',
          sourceName: 'Sindonews Edukasi',
        ),
      ],
    ),
    const NewsCategory(
      id: 'kesehatan',
      name: 'Kesehatan',
      icon: Icons.local_hospital,
      feeds: [
        RssFeedSource(
          url: 'https://kemkes.go.id/id/rss/article/kegiatan-kemenkes',
          sourceName: 'Kementerian Kesehatan',
        ),
        RssFeedSource(
          url: 'https://health.detik.com/rss',
          sourceName: 'Detik Health',
        ),
      ],
    ),
    const NewsCategory(
      id: 'teknologi',
      name: 'Teknologi',
      icon: Icons.computer,
      feeds: [
        RssFeedSource(
          url: 'https://www.cnbcindonesia.com/tech/rss',
          sourceName: 'CNBC Indonesia Tech',
        ),
        RssFeedSource(
          url: 'https://www.antaranews.com/rss/tekno.xml',
          sourceName: 'Antara News Tekno',
        ),
      ],
    ),
    const NewsCategory(
      id: 'nasional',
      name: 'Nasional',
      icon: Icons.flag,
      feeds: [
        RssFeedSource(
          url: 'https://rss.tempo.co/nasional',
          sourceName: 'Tempo Nasional',
        ),
        RssFeedSource(
          url: 'https://www.cnnindonesia.com/nasional/rss',
          sourceName: 'CNN Indonesia Nasional',
        ),
      ],
    ),
  ];

  /// Get category by ID
  static NewsCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

