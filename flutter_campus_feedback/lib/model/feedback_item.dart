// ============================================
// TUGAS UTS - PEMROGRAMAN MOBILE
// FILE: feedback_item.dart
// Deskripsi: Model class untuk data feedback mahasiswa
// ============================================
// Nama: Ririn Rahmawati
// NIM: 701230036
// Kelas: Sistem Informasi
// Dosen: Ahmad Nasukha, S.Hum., M.S.I
// ============================================

import 'package:flutter/material.dart';

// ============================================
// MODEL CLASS: FeedbackItem
// 
// Fungsi: Menyimpan data feedback mahasiswa
// Digunakan untuk transfer data antar halaman
// 
// Properties:
// - namaMahasiswa: String (nama lengkap mahasiswa)
// - nim: String (nomor induk mahasiswa)
// - fakultas: String (nama fakultas)
// - fasilitasDinilai: List<String> (daftar fasilitas yang dinilai)
// - nilaiKepuasan: double (skala 1-5)
// - jenisFeedback: String (Saran/Keluhan/Apresiasi)
// - setujuSyarat: bool (persetujuan syarat & ketentuan)
// - pesanTambahan: String? (pesan opsional)
// ============================================

class FeedbackItem {
  final String namaMahasiswa;
  final String nim;
  final String fakultas;
  final List<String> fasilitasDinilai;
  final double nilaiKepuasan;
  final String jenisFeedback; // Saran, Keluhan, Apresiasi
  final bool setujuSyarat;
  final String? pesanTambahan;

  // ============================================
  // CONSTRUCTOR
  // Semua field required kecuali pesanTambahan (optional)
  // ============================================
  FeedbackItem({
    required this.namaMahasiswa,
    required this.nim,
    required this.fakultas,
    required this.fasilitasDinilai,
    required this.nilaiKepuasan,
    required this.jenisFeedback,
    required this.setujuSyarat,
    this.pesanTambahan,
  });

  // ============================================
  // GETTER: getColor()
  // 
  // Fungsi: Menentukan warna ikon berdasarkan jenis feedback
  // Return: Color (Material Design colors)
  // 
  // Apresiasi = Hijau (positif)
  // Saran = Biru (netral/informatif)
  // Keluhan = Merah (negatif/perhatian)
  // ============================================
  Color getColor() {
    switch (jenisFeedback) {
      case 'Apresiasi':
        return Colors.green;
      case 'Saran':
        return Colors.blue;
      case 'Keluhan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ============================================
  // GETTER: getIcon()
  // 
  // Fungsi: Menentukan ikon yang sesuai dengan jenis feedback
  // Return: IconData (Material Icons)
  // 
  // Apresiasi = thumb_up (like/pujian)
  // Saran = lightbulb (ide/masukan)
  // Keluhan = report_problem (warning/keluhan)
  // ============================================
  IconData getIcon() {
    switch (jenisFeedback) {
      case 'Apresiasi':
        return Icons.thumb_up;
      case 'Saran':
        return Icons.lightbulb;
      case 'Keluhan':
        return Icons.report_problem;
      default:
        return Icons.feedback;
    }
  }
}

// ============================================
// END OF FEEDBACK ITEM MODEL
// ============================================