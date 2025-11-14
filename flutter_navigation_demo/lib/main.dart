import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/feedback_form_page.dart';
import 'pages/feedback_detail_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/achievements_page.dart';
import 'pages/statistics_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/history_page.dart';
import 'pages/quiz_page.dart';
import 'pages/notes_page.dart';
import 'pages/timer_page.dart';
import 'pages/calculator_page.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
/// Mengelola tema (light/dark mode) dan routing aplikasi
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State untuk mengatur tema aplikasi
  ThemeMode _themeMode = ThemeMode.light;

  /// Fungsi untuk toggle tema antara light dan dark mode
  /// Parameter [isDark] menentukan apakah dark mode aktif
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration untuk light mode
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      
      // Theme configuration untuk dark mode
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      themeMode: _themeMode,
      
      // Splash screen sebagai halaman awal
      initialRoute: '/splash',
      
      // Named routes untuk semua halaman
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/': (context) => HomePage(onThemeChanged: _toggleTheme),
        '/about': (context) => const AboutPage(),
        '/feedback-form': (context) => const FeedbackFormPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => SettingsPage(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeChanged: _toggleTheme,
            ),
        '/achievements': (context) => const AchievementsPage(),
        '/statistics': (context) => const StatisticsPage(),
        '/history': (context) => const HistoryPage(),
        '/quiz': (context) => const QuizPage(),
        '/notes': (context) => const NotesPage(),
        '/timer': (context) => const TimerPage(),
        '/calculator': (context) => const CalculatorPage(),
      },
      
      /// Generate route untuk halaman yang memerlukan arguments
      /// Digunakan untuk FeedbackDetailPage yang menerima data dari form
      onGenerateRoute: (settings) {
        if (settings.name == '/feedback-detail') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => FeedbackDetailPage(
              name: args['name']!,
              feedback: args['feedback']!,
              rating: args['rating']!,
            ),
          );
        }
        return null;
      },
    );
  }
}