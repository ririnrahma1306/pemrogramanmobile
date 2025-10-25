// ============================================
// TUGAS UTS - PEMROGRAMAN MOBILE
// FILE: feedback_list_page.dart
// Deskripsi: Halaman daftar feedback mahasiswa
// ============================================

import 'package:flutter/material.dart';
import 'model/feedback_item.dart';
import 'feedback_detail_page.dart';

class FeedbackListPage extends StatelessWidget {
  final List<FeedbackItem> feedbackList;
  final Function(bool) onThemeChanged;

  const FeedbackListPage({
    super.key,
    required this.feedbackList,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: feedbackList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada feedback',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan isi formulir untuk menambah feedback',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Total Feedback: ${feedbackList.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // List feedback
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbackList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: feedback.getColor().withValues(alpha: 0.2),
                            child: Icon(
                              feedback.getIcon(),
                              color: feedback.getColor(),
                            ),
                          ),
                          title: Text(
                            feedback.namaMahasiswa,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                feedback.fakultas,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: feedback.getColor().withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: feedback.getColor().withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      feedback.jenisFeedback,
                                      style: TextStyle(
                                        color: feedback.getColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        feedback.nilaiKepuasan.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            // Navigasi ke detail page
                            final shouldDelete = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackDetailPage(
                                  feedback: feedback,
                                  index: index,
                                ),
                              ),
                            );
                            
                            // Jika user menghapus feedback, return index ke HomePage
                            if (shouldDelete == true) {
                              if (context.mounted) {
                                Navigator.pop(context, index);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}