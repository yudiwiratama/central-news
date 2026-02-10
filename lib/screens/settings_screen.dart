import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/news_config.dart';
import '../providers/settings_provider.dart';
import '../models/news_category.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';
import 'filter_keywords_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (!settings.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Responsive.isDesktop(context) ? 900 : double.infinity,
              ),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  // Header with Gradient (BBC-style: clean & simple)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage sources and filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              
              // Filter Keywords Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: Icon(
                    Icons.tune,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Filter Keywords',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    settings.filterEnabled
                        ? settings.customKeywords.isNotEmpty
                            ? '✓ ${settings.customKeywords.length} custom keywords aktif'
                            : '✓ ${settings.getEnabledDefaultKeywordsCount(NewsConfig.governmentKeywords)}/${NewsConfig.governmentKeywords.length} default keywords'
                        : '✗ Nonaktif - Semua berita ditampilkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: settings.filterEnabled ? Colors.green[700] : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FilterKeywordsScreen(),
                      ),
                    );
                  },
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sumber Berita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Categories with sources
              ...NewsConfig.categories.map((category) {
                return _buildCategorySection(context, settings, category);
              }),
              
                  // Reset button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetDialog(context, settings),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset ke Pengaturan Default'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    SettingsProvider settings,
    NewsCategory category,
  ) {
    final customFeeds = settings.getCustomFeedsForCategory(category.id);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F9FA),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddFeedDialog(context, settings, category),
                  icon: const Icon(Icons.add, size: 22),
                  tooltip: 'Tambah RSS Feed',
                  color: AppTheme.primaryPurple,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Default sources
          ...category.feeds.map((feed) {
            final isEnabled = settings.isSourceEnabled(category.id, feed.url);
            return _buildSourceTile(
              context,
              settings,
              category.id,
              feed.url,
              feed.sourceName,
              isEnabled,
              isCustom: false,
            );
          }),
          
          // Custom sources
          if (customFeeds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'RSS Feed Kustom',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ...customFeeds.map((feed) {
              return _buildSourceTile(
                context,
                settings,
                category.id,
                feed.url,
                feed.name,
                true,
                isCustom: true,
                onDelete: () => _confirmDeleteFeed(context, settings, feed.url, feed.name),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceTile(
    BuildContext context,
    SettingsProvider settings,
    String categoryId,
    String url,
    String name,
    bool isEnabled, {
    bool isCustom = false,
    VoidCallback? onDelete,
  }) {
    return ListTile(
      leading: Icon(
        isCustom ? Icons.rss_feed : Icons.source,
        color: isEnabled 
            ? Theme.of(context).primaryColor 
            : Colors.grey[400],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isEnabled ? Colors.black87 : Colors.grey[600],
        ),
      ),
      subtitle: Text(
        url,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCustom && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red[400],
              onPressed: onDelete,
              tooltip: 'Hapus',
            ),
          if (!isCustom)
            Switch(
              value: isEnabled,
              onChanged: (value) {
                settings.toggleSource(categoryId, url, value);
              },
              activeTrackColor: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }

  void _showAddFeedDialog(
    BuildContext context,
    SettingsProvider settings,
    NewsCategory category,
  ) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah RSS Feed ke ${category.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Sumber',
                  hintText: 'Contoh: CNN Indonesia',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama sumber tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL RSS Feed',
                  hintText: 'https://example.com/rss',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'URL tidak boleh kosong';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL harus dimulai dengan http:// atau https://';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final feed = CustomRssFeed(
                  url: urlController.text.trim(),
                  name: nameController.text.trim(),
                  categoryId: category.id,
                );
                
                final success = await settings.addCustomFeed(feed);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('RSS Feed berhasil ditambahkan'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL sudah ada'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFeed(
    BuildContext context,
    SettingsProvider settings,
    String url,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus RSS Feed?'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.removeCustomFeed(url);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('RSS Feed dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan?'),
        content: const Text(
          'Semua pengaturan akan dikembalikan ke default dan RSS feed kustom akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan telah direset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

