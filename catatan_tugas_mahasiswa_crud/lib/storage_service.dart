// lib/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'note.dart';

class StorageService {
  static const String _notesKey = 'notes_list';
  static const String _darkModeKey = 'dark_mode';

  // Simpan daftar catatan
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => note.toMap()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesJson));
  }

  // Load daftar catatan
  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(_notesKey);
    
    if (notesString == null || notesString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> notesJson = jsonDecode(notesString);
      return notesJson.map((json) => Note.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Simpan preferensi dark mode
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  // Load preferensi dark mode
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}