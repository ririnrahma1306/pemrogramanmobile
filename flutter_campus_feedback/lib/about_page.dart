import 'package:flutter/material.dart';
import 'dart:math';

class AboutPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const AboutPage({super.key, required this.onThemeChanged});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  int _logoTapCount = 0;
  bool _easterEggFound = false;
  bool _secretAchievement = false;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // State untuk mengelola saklar (Switch)
  bool _isDark = false;


  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Cek tema saat ini saat halaman dibuka
    // Gunakan addPostFrameCallback agar context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Cek brightness dari tema yang sedang aktif
        final brightness = Theme.of(context).brightness;
        setState(() {
          // Atur saklar ke posisi ON (true) jika tema adalah dark
          _isDark = brightness == Brightness.dark;
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    setState(() {
      _logoTapCount++;
    });

    if (_logoTapCount == 7 && !_easterEggFound) {
      setState(() {
        _easterEggFound = true;
      });
      _scaleController.forward().then((_) => _scaleController.reverse());
      _rotateController.forward().then((_) => _rotateController.reset());
      
      _showEasterEggDialog();
    }
  }

  void _showEasterEggDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('🎉 '),
            Expanded(
              child: Text(
                'Easter Egg Ditemukan!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🐣 Selamat! Kamu menemukan rahasia tersembunyi!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // PERBAIKAN: Menggunakan .withOpacity()
                color: Colors.amber.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Column(
                children: [
                  Text(
                    '💡 Fun Fact:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Flutter digunakan oleh Google, Alibaba, BMW, dan banyak perusahaan besar lainnya! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '✨ Achievement Unlocked: "Curious Explorer"',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantap! 😎'),
          ),
        ],
      ),
    );
  }

  void _showSecretAchievement() {
    // Pastikan _secretAchievement belum true untuk menghindari spam snackbar
    if (_secretAchievement) return;
    
    setState(() {
      _secretAchievement = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '🏆 Secret Achievement: "Developer Respect"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_easterEggFound)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.emoji_events, color: Colors.amber),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    // PERBAIKAN: Menggunakan .withOpacity()
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Logo UIN STS Jambi dengan Easter Egg
                  GestureDetector(
                    onTap: _onLogoTap,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_scaleController, _rotateController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    // PERBAIKAN: Menggunakan .withOpacity()
                                    color: _easterEggFound
                                        ? Colors.amber.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: _easterEggFound ? 30 : 20,
                                    spreadRadius: _easterEggFound ? 8 : 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo_uin.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  // PERBAIKAN: Menggunakan .withOpacity()
                                  color: _easterEggFound ? Colors.amber.withOpacity(0.7) : null,
                                  colorBlendMode: _easterEggFound ? BlendMode.modulate : null,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback ke ikon jika logo tidak ditemukan
                                    return Icon(
                                      Icons.account_balance,
                                      size: 80,
                                      color: _easterEggFound
                                          ? Colors.amber
                                          : Theme.of(context).colorScheme.primary,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_logoTapCount > 0 && _logoTapCount < 7)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${7 - _logoTapCount} lagi... 👀',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'UIN Sulthan Thaha Saifuddin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 19),
                  Text(
                    'Jambi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                           fontWeight: FontWeight.bold,
                          // Warna sedikit disesuaikan agar lebih terlihat di dark mode
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),

            // Informasi Aplikasi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    context,
                    Icons.app_settings_alt,
                    'Aplikasi',
                    'Flutter Campus Feedback',
                    'Aplikasi kuesioner kepuasan mahasiswa',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.book,
                    'Mata Kuliah',
                    'Pemrograman Mobile',
                    'Mobile Programming',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.person,
                    'Dosen Pengampu',
                    'Ahmad Nasukha, S.Hum., M.S.I',
                    'Program Studi Sistem Informasi',
                  ),
                  const SizedBox(height: 12),
                  // Easter Egg: Long press pada developer name
                  GestureDetector(
                    onLongPress: _showSecretAchievement,
                    child: _buildInfoCard(
                      context,
                      _secretAchievement ? Icons.code_sharp : Icons.code,
                      'Dikembangkan Oleh',
                      'Ririn Rahmawati',
                      _secretAchievement ? '701230036 ⭐ Master Developer' : '701230036',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.calendar_today,
                    'Tahun Akademik',
                    '2025/2026',
                    'Tugas UTS - Semester Ganjil',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    Icons.flutter_dash,
                    'Teknologi',
                    'Flutter 3.22+',
                    'Material Design 3',
                  ),
                  const SizedBox(height: 12),

                  // Fitur Aplikasi
                  Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.stars,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Fitur Aplikasi',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(Icons.edit, 'Form feedback interaktif'),
                          _buildFeatureItem(Icons.list, 'Daftar feedback mahasiswa'),
                          _buildFeatureItem(Icons.info, 'Detail feedback lengkap'),
                          _buildFeatureItem(Icons.navigation, 'Navigasi antar halaman'),
                          _buildFeatureItem(Icons.check_circle, 'Validasi input data'),
                          _buildFeatureItem(Icons.palette, 'Material Design 3'),
                          if (_easterEggFound)
                            _buildFeatureItem(Icons.egg, 'Easter eggs tersembunyi 🐣'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================================================
                  // PENAMBAHAN: Kartu Pengaturan untuk Dark Mode
                  // ==================================================
                  Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: SwitchListTile(
                        title: Text('Mode Gelap'),
                        value: _isDark,
                        secondary: Icon(
                            _isDark ? Icons.dark_mode : Icons.light_mode),
                        onChanged: (bool newValue) {
                          // 1. Update state lokal (untuk saklarnya)
                          setState(() {
                            _isDark = newValue;
                          });
                          // 2. Panggil fungsi di main.dart (untuk ganti tema)
                          widget.onThemeChanged(newValue);
                        },
                      ),
                    ),
                  ),
                  // ==================================================
                  // AKHIR PENAMBAHAN
                  // ==================================================

                  const SizedBox(height: 24),

                  // Tombol Kembali
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.home),
                      label: const Text('Kembali ke Beranda'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    '© 2025 UIN STS Jambi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (_easterEggFound && _secretAchievement)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '✨ Master Explorer Unlocked! ✨',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // Beri sedikit padding di bawah agar tidak terlalu mepet
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Card(
      elevation: 1,
      // PERBAIKAN: Menggunakan .withOpacity()
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // PERBAIKAN: Menggunakan .withOpacity()
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                       // Warna disesuaikan agar lebih terlihat di dark mode
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

