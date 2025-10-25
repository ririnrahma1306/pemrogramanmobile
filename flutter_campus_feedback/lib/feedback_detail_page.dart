import 'package:flutter/material.dart';
import 'model/feedback_item.dart';

class FeedbackDetailPage extends StatelessWidget {
  final FeedbackItem feedback;
  final int index;

  const FeedbackDetailPage({
    super.key,
    required this.feedback,
    required this.index,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus feedback ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Tutup dialog
              Navigator.pop(context);
              // Kembali ke list page dengan signal untuk hapus
              Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Hapus Feedback',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan ikon dan jenis feedback
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: feedback.getColor().withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: feedback.getColor().withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: feedback.getColor().withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feedback.getIcon(),
                      size: 48,
                      color: feedback.getColor(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feedback.jenisFeedback,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: feedback.getColor(),
                        ),
                  ),
                ],
              ),
            ),

            // Detail informasi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Mahasiswa
                  _buildSectionTitle(context, 'Informasi Mahasiswa'),
                  _buildInfoCard(
                    context,
                    [
                      _buildInfoRow(Icons.person, 'Nama', feedback.namaMahasiswa),
                      const Divider(),
                      _buildInfoRow(Icons.badge, 'NIM', feedback.nim),
                      const Divider(),
                      _buildInfoRow(Icons.school, 'Fakultas', feedback.fakultas),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fasilitas yang Dinilai
                  _buildSectionTitle(context, 'Fasilitas yang Dinilai'),
                  _buildInfoCard(
                    context,
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: feedback.fasilitasDinilai.map((fasilitas) {
                          return Chip(
                            avatar: const Icon(Icons.check_circle, size: 16),
                            label: Text(fasilitas),
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            side: BorderSide(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Nilai Kepuasan
                  _buildSectionTitle(context, 'Nilai Kepuasan'),
                  _buildInfoCard(
                    context,
                    [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[700],
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            feedback.nilaiKepuasan.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[700],
                                ),
                          ),
                          Text(
                            ' / 5.0',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getKepuasanColor(feedback.nilaiKepuasan).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getKepuasanLabel(feedback.nilaiKepuasan),
                              style: TextStyle(
                                color: _getKepuasanColor(feedback.nilaiKepuasan),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: feedback.nilaiKepuasan / 5.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getKepuasanColor(feedback.nilaiKepuasan),
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pesan Tambahan
                  if (feedback.pesanTambahan != null && feedback.pesanTambahan!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Pesan Tambahan'),
                    _buildInfoCard(
                      context,
                      [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.message,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feedback.pesanTambahan!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Status Persetujuan
                  _buildSectionTitle(context, 'Status'),
                  _buildInfoCard(
                    context,
                    [
                      Row(
                        children: [
                          Icon(
                            feedback.setujuSyarat
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: feedback.setujuSyarat
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feedback.setujuSyarat
                                  ? 'Menyetujui syarat dan ketentuan'
                                  : 'Tidak menyetujui syarat dan ketentuan',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tombol Aksi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Kembali'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(context),
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getKepuasanColor(double nilai) {
    if (nilai >= 4.0) return Colors.green;
    if (nilai >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _getKepuasanLabel(double nilai) {
    if (nilai >= 4.5) return 'Sangat Puas';
    if (nilai >= 4.0) return 'Puas';
    if (nilai >= 3.0) return 'Cukup';
    if (nilai >= 2.0) return 'Kurang Puas';
    return 'Tidak Puas';
  }
}