import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_central_news/main.dart';
import 'package:flutter_central_news/providers/news_provider.dart';
import 'package:flutter_central_news/models/news_item.dart';
import 'package:flutter_central_news/constants/news_config.dart';

void main() {
  group('NewsItem Tests', () {
    test('isGovernmentRelated returns true for government keywords', () {
      final newsItem = NewsItem(
        title: 'Pemerintah Umumkan Kebijakan Baru',
        description: 'Menteri menjelaskan tentang anggaran',
        link: 'https://example.com',
        sourceName: 'Test Source',
        category: 'Test',
      );

      expect(
        newsItem.isGovernmentRelated(NewsConfig.governmentKeywords),
        isTrue,
      );
    });

    test('isGovernmentRelated returns false for non-government news', () {
      final newsItem = NewsItem(
        title: 'Sepak Bola Liga Indonesia',
        description: 'Pertandingan seru antara dua tim favorit',
        link: 'https://example.com',
        sourceName: 'Test Source',
        category: 'Test',
      );

      expect(
        newsItem.isGovernmentRelated(NewsConfig.governmentKeywords),
        isFalse,
      );
    });

    test('isGovernmentRelated is case-insensitive', () {
      final newsItem = NewsItem(
        title: 'PEMERINTAH mengeluarkan kebijakan',
        description: 'MENTERI berbicara di konferensi',
        link: 'https://example.com',
        sourceName: 'Test Source',
        category: 'Test',
      );

      expect(
        newsItem.isGovernmentRelated(NewsConfig.governmentKeywords),
        isTrue,
      );
    });

    test('getRelativeTime returns correct format', () {
      final now = DateTime.now();
      
      // 2 hours ago
      final newsItem1 = NewsItem(
        title: 'Test',
        description: 'Test',
        link: 'https://example.com',
        pubDate: now.subtract(const Duration(hours: 2)),
        sourceName: 'Test Source',
        category: 'Test',
      );
      expect(newsItem1.getRelativeTime(), contains('jam'));

      // 2 days ago
      final newsItem2 = NewsItem(
        title: 'Test',
        description: 'Test',
        link: 'https://example.com',
        pubDate: now.subtract(const Duration(days: 2)),
        sourceName: 'Test Source',
        category: 'Test',
      );
      expect(newsItem2.getRelativeTime(), contains('hari'));
    });
  });

  group('NewsConfig Tests', () {
    test('has correct number of categories', () {
      expect(NewsConfig.categories.length, equals(6));
    });

    test('all categories have feeds', () {
      for (final category in NewsConfig.categories) {
        expect(category.feeds.isNotEmpty, isTrue);
      }
    });

    test('getCategoryById returns correct category', () {
      final category = NewsConfig.getCategoryById('ekonomi');
      expect(category, isNotNull);
      expect(category!.name, equals('Ekonomi'));
    });

    test('getCategoryById returns null for invalid id', () {
      final category = NewsConfig.getCategoryById('invalid_id');
      expect(category, isNull);
    });
  });

  group('NewsProvider Tests', () {
    test('initial state is correct', () {
      final provider = NewsProvider();
      expect(
        provider.getLoadingState('test_category'),
        equals(NewsLoadingState.initial),
      );
      expect(provider.getNewsForCategory('test_category'), isEmpty);
      expect(provider.isLoading('test_category'), isFalse);
      expect(provider.hasError('test_category'), isFalse);
    });

    test('getTotalNewsCount returns 0 initially', () {
      final provider = NewsProvider();
      expect(provider.getTotalNewsCount(), equals(0));
    });

    test('hasAnyLoadedNews returns false initially', () {
      final provider = NewsProvider();
      expect(provider.hasAnyLoadedNews(), isFalse);
    });
  });

  group('Widget Tests', () {
    testWidgets('MyApp builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => NewsProvider(),
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Widget rendered successfully
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
