import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_category.dart';
import '../providers/news_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import '../utils/responsive.dart';
import 'news_card.dart';
import 'summary_card.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';

class CategoryNewsList extends StatefulWidget {
  final NewsCategory category;

  const CategoryNewsList({
    super.key,
    required this.category,
  });

  @override
  State<CategoryNewsList> createState() => _CategoryNewsListState();
}

class _CategoryNewsListState extends State<CategoryNewsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch news and summary when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final summaryProvider = Provider.of<SummaryProvider>(context, listen: false);
      
      // Fetch news
      if (settings.isInitialized &&
          newsProvider.getLoadingState(widget.category.id) ==
              NewsLoadingState.initial) {
        newsProvider.fetchNewsForCategory(widget.category);
      }
      
      // Fetch AI summary
      if (!summaryProvider.hasSummary(widget.category.id)) {
        summaryProvider.fetchSummary(widget.category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer3<NewsProvider, SettingsProvider, SummaryProvider>(
      builder: (context, newsProvider, settingsProvider, summaryProvider, child) {
        // Wait for settings to initialize
        if (!settingsProvider.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final isLoading = newsProvider.isLoading(widget.category.id);
        final hasError = newsProvider.hasError(widget.category.id);
        final isEmpty = newsProvider.isEmpty(widget.category.id);
        final news = newsProvider.getNewsForCategory(widget.category.id);

        // Loading state (initial load)
        if (isLoading && news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memuat berita...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Error state (with no cached data)
        if (hasError && news.isEmpty) {
          return ErrorStateWidget(
            message: newsProvider.getErrorMessage(widget.category.id) ??
                'Terjadi kesalahan',
            onRetry: () => newsProvider.fetchNewsForCategory(widget.category),
          );
        }

        // Empty state (no news found after filtering)
        if (isEmpty) {
          return EmptyStateWidget(
            category: widget.category.name,
            onRefresh: () => newsProvider.refreshCategory(widget.category),
          );
        }

        // Success state with data
        final isDesktop = Responsive.isDesktop(context);
        final isTablet = Responsive.isTablet(context);
        final gridColumns = Responsive.getGridColumns(context);
        
        return RefreshIndicator(
          onRefresh: () => newsProvider.refreshCategory(widget.category),
          color: Theme.of(context).primaryColor,
          child: news.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: EmptyStateWidget(
                        category: widget.category.name,
                        onRefresh: () =>
                            newsProvider.refreshCategory(widget.category),
                      ),
                    ),
                  ],
                )
              : (isDesktop || isTablet)
                  ? Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.getMaxWidth(context),
                        ),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // AI Summary Card (if available)
                            if (summaryProvider.hasSummary(widget.category.id))
                              SliverPadding(
                                padding: Responsive.getScreenPadding(context),
                                sliver: SliverToBoxAdapter(
                                  child: SummaryCard(
                                    summary: summaryProvider.getSummary(widget.category.id)!,
                                  ),
                                ),
                              )
                            else if (summaryProvider.isLoading(widget.category.id))
                              SliverPadding(
                                padding: Responsive.getScreenPadding(context),
                                sliver: const SliverToBoxAdapter(
                                  child: SummaryLoadingCard(),
                                ),
                              ),
                            
                            // News Grid
                            SliverPadding(
                              padding: Responsive.getScreenPadding(context),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridColumns,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return NewsCard(newsItem: news[index]);
                                  },
                                  childCount: news.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // AI Summary Card (if available)
                        if (summaryProvider.hasSummary(widget.category.id))
                          SliverToBoxAdapter(
                            child: SummaryCard(
                              summary: summaryProvider.getSummary(widget.category.id)!,
                            ),
                          )
                        else if (summaryProvider.isLoading(widget.category.id))
                          const SliverToBoxAdapter(
                            child: SummaryLoadingCard(),
                          ),
                        
                        // News List
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return NewsCard(newsItem: news[index]);
                              },
                              childCount: news.length,
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
