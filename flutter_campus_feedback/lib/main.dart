// ============================================
// TUGAS UTS - PEMROGRAMAN MOBILE
// Nama: Ririn Rahmawati
// NIM: 701230036
// Kelas: Sistem Informasi
// Dosen: Ahmad Nasukha, S.Hum., M.S.I
// ============================================

import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

// ============================================
// MAIN APP dengan Dark Mode Support
// Menggunakan StatefulWidget untuk mengelola theme mode
// ============================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State untuk menyimpan mode tema (light/dark)
  ThemeMode _themeMode = ThemeMode.light;

  // ============================================
  // FUNGSI: Toggle Dark Mode
  // Dipanggil dari AboutPage melalui callback
  // ============================================
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Feedback',
      debugShowCheckedModeBanner: false,
      
      // ============================================
      // LIGHT THEME - Material Design 3
      // ============================================
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      
      // ============================================
      // DARK THEME - Material Design 3
      // Warna disesuaikan untuk pengalaman dark mode yang nyaman
      // ============================================
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      // Mode tema saat ini (light/dark)
      themeMode: _themeMode,
      
      // Home page dengan callback untuk toggle theme
      home: HomePage(onThemeChanged: _toggleTheme),
    );
  }
}

// ============================================
// END OF MAIN APP
// ============================================