import 'package:flutter/material.dart';

class NewsCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<RssFeedSource> feeds;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.feeds,
  });
}

class RssFeedSource {
  final String url;
  final String sourceName;

  const RssFeedSource({
    required this.url,
    required this.sourceName,
  });
}

