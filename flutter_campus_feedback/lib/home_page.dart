// ============================================
// TUGAS UTS - PEMROGRAMAN MOBILE
// Nama: Ririn Rahmawati
// NIM: 701230036
// Kelas: Sistem Informasi
// Dosen: Ahmad Nasukha, S.Hum., M.S.I
// ============================================

import 'package:flutter/material.dart';
import 'model/feedback_item.dart';

// Import dengan show untuk menghindari konflik
import 'feedback_form_page.dart' show FeedbackFormPage;
import 'feedback_list_page.dart' show FeedbackListPage;
import 'about_page.dart' show AboutPage;

// ============================================
// HALAMAN 1 - BERANDA (HOME PAGE)
// Fungsi: Halaman utama aplikasi dengan navigasi ke halaman lain
// Widget: StatefulWidget untuk mengelola state feedback list
// ============================================

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const HomePage({super.key, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List untuk menyimpan semua feedback yang sudah dibuat
  // Menggunakan state management sederhana dengan setState()
  List<FeedbackItem> feedbackList = [];

  // ============================================
  // FUNGSI: Menambah feedback baru ke dalam list
  // Parameter: FeedbackItem yang dibuat dari form
  // ============================================
  void _addFeedback(FeedbackItem feedback) {
    setState(() {
      feedbackList.add(feedback);
    });
  }

  // ============================================
  // FUNGSI: Menghapus feedback berdasarkan index
  // Parameter: index dari feedback yang akan dihapus
  // ============================================
  void _deleteFeedback(int index) {
    setState(() {
      feedbackList.removeAt(index);
    });
  }

  // ============================================
  // NAVIGASI: Menuju halaman Form Feedback
  // Menggunakan Navigator.push dengan MaterialPageRoute
  // Return: FeedbackItem jika berhasil disimpan
  // ============================================
  void _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FeedbackFormPage(),
      ),
    );
    
    // Jika ada feedback baru, tambahkan ke list
    if (result != null && result is FeedbackItem) {
      _addFeedback(result);
      
      // Tampilkan SnackBar konfirmasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback berhasil disimpan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ============================================
  // NAVIGASI: Menuju halaman Daftar Feedback
  // Return: index jika ada feedback yang dihapus
  // ============================================
  void _navigateToList() async {
    final deletedIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackListPage(
          feedbackList: feedbackList,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
    
    // Jika ada feedback yang dihapus
    if (deletedIndex != null && deletedIndex is int) {
      _deleteFeedback(deletedIndex);
      
      // Tampilkan SnackBar konfirmasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback berhasil dihapus!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ============================================
  // NAVIGASI: Menuju halaman About/Profil
  // Pass callback onThemeChanged ke AboutPage
  // ============================================
  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Feedback App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        // Gradient background untuk estetika
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ============================================
                // LOGO FLUTTER
                // Menggunakan FlutterLogo (built-in widget)
                // Alternative: Image.asset jika ada file logo
                // ============================================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const FlutterLogo(size: 100),
                ),
                const SizedBox(height: 30),

                // Nama Aplikasi
                Text(
                  'Flutter Campus Feedback',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                
                // Subtitle
                Text(
                  'Kuesioner Kepuasan Mahasiswa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ============================================
                // TOMBOL 1: Isi Formulir Feedback
                // Navigasi ke FeedbackFormPage
                // ============================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToForm,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Isi Formulir Feedback'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ============================================
                // TOMBOL 2: Daftar Feedback
                // Disabled jika feedbackList kosong
                // Menampilkan jumlah feedback dalam label
                // ============================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: feedbackList.isEmpty ? null : _navigateToList,
                    icon: const Icon(Icons.list_alt),
                    label: Text(
                      feedbackList.isEmpty
                          ? 'Daftar Feedback (Kosong)'
                          : 'Daftar Feedback (${feedbackList.length})',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ============================================
                // TOMBOL 3: Tentang Aplikasi
                // Navigasi ke AboutPage
                // Menggunakan OutlinedButton untuk variasi
                // ============================================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToAbout,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Tentang Aplikasi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ============================================
                // TEKS MOTIVASI
                // Sesuai requirement tugas UTS
                // ============================================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Coding adalah seni memecahkan masalah dengan logika dan kreativitas.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// END OF HOME PAGE
// ============================================