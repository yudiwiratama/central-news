import 'package:flutter/material.dart';
import '../constants/news_config.dart';
import '../widgets/category_news_list.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return DefaultTabController(
      length: NewsConfig.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Central News',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'Centralized News Aggregator',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Pengaturan',
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontSize: isDesktop ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: isDesktop ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                tabAlignment: TabAlignment.start,
                tabs: NewsConfig.categories.map((category) {
                  return Tab(
                    height: 48,
                    child: Text(
                      category.name.toUpperCase(),
                      style: const TextStyle(
                        letterSpacing: 0.8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.subtleGradient,
          ),
          child: TabBarView(
            children: NewsConfig.categories.map((category) {
              return CategoryNewsList(category: category);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
