import 'package:flutter/material.dart';

class ActivityLog {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  ActivityLog({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<ActivityLog> activities = [
    ActivityLog(
      title: 'Membuka Aplikasi',
      description: 'Memulai sesi baru',
      icon: Icons.launch,
      color: Colors.blue,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ActivityLog(
      title: 'Statistik yang Dilihat',
      description: 'Memeriksa statistik penggunaan aplikasi',
      icon: Icons.analytics,
      color: Colors.green,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ActivityLog(
      title: 'Kirim Umpan Balik',
      description: 'Rating: 4.5 - Pengalaman aplikasi yang luar biasa!',
      icon: Icons.feedback,
      color: Colors.orange,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityLog(
      title: 'Tema Berubah',
      description: 'Beralih ke mode gelap',
      icon: Icons.dark_mode,
      color: Colors.indigo,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ActivityLog(
      title: 'Profil Diperbarui',
      description: 'Informasi profil diperbarui',
      icon: Icons.person,
      color: Colors.purple,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ActivityLog(
      title: 'Melihat Halaman Tentang',
      description: 'Belajar lebih banyak tentang aplikasi',
      icon: Icons.info,
      color: Colors.teal,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ActivityLog(
      title: 'Prestasi yang Diterima',
      description: 'Mendapatkan lencana "Penjelusuran Aplikasi"',
      icon: Icons.emoji_events,
      color: Colors.amber,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kegiatan Terbaru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${activities.length} activities recorded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return _buildActivityItem(activities[index], index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportHistory,
        icon: const Icon(Icons.download),
        label: const Text('Ekspor'),
      ),
    );
  }

  Widget _buildActivityItem(ActivityLog activity, int index) {
    return Dismissible(
      key: Key(activity.timestamp.toString()),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          activities.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.title} removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  activities.insert(index, activity);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
            ),
          ),
          title: Text(
            activity.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(activity.description),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(activity.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Semua Aktivitas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Hari ini'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Minggu ini'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Bulan ini '),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat aktivitas? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                activities.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat dibersihkan'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Bersih'),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    final buffer = StringBuffer();
    buffer.writeln('Ekspor Riwayat Aktivitas');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Activities: ${activities.length}');
    buffer.writeln('\n${'=' * 50}\n');

    for (final activity in activities) {
      buffer.writeln('Title: ${activity.title}');
      buffer.writeln('Description: ${activity.description}');
      buffer.writeln('Time: ${activity.timestamp}');
      buffer.writeln('-' * 50);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Text('Siap Diekspor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RIwayat aktivitas Anda telah siap untuk diekspor.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: ${activities.length} activities',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat berhasil diekspor!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan ke File'),
          ),
        ],
      ),
    );
  }
}