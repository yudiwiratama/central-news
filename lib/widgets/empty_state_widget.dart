import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String category;
  final VoidCallback onRefresh;

  const EmptyStateWidget({
    super.key,
    required this.category,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Berita Pemerintah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada berita terkait pemerintah\ndi kategori $category saat ini.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Muat Ulang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Tidak Ada Berita?'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kemungkinan penyebab:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('1. Filter keywords aktif'),
                          Text('   → Berita tidak match keywords'),
                          SizedBox(height: 6),
                          Text('2. Sumber berita belum memiliki konten baru'),
                          SizedBox(height: 6),
                          Text('3. Error loading dari RSS feed'),
                          SizedBox(height: 16),
                          Text(
                            'Solusi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('• Non-aktifkan filter di Settings'),
                          Text('• Tambah/ubah filter keywords'),
                          Text('• Tambah sumber berita lain'),
                          Text('• Pull-to-refresh untuk reload'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Mengerti'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Mengapa tidak ada berita?'),
            ),
          ],
        ),
      ),
    );
  }
}
