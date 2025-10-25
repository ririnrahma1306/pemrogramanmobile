import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/feedback_item.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk TextField
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _pesanController = TextEditingController();
  
  // State variables
  String? _selectedFakultas;
  final Map<String, bool> _fasilitasChecked = {
    'Perpustakaan': false,
    'Laboratorium': false,
    'Ruang Kelas': false,
    'Kantin': false,
    'Masjid': false,
    'Area Parkir': false,
  };
  double _nilaiKepuasan = 3.0;
  String _jenisFeedback = 'Saran';
  bool _setujuSyarat = false;

  final List<String> _fakultasList = [
    'Fakultas Ekonomi dan Bisnis Islam',
    'Fakultas Syariah',
    'Fakultas Ushuluddin dan Studi Agama',
    'Fakultas Tarbiyah dan Keguruan',
    'Fakultas Adab dan Humaniora',
    'Fakultas Sains dan Teknologi',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _simpanFeedback() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi setuju syarat & ketentuan
    if (!_setujuSyarat) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perhatian'),
          content: const Text(
            'Anda harus menyetujui syarat dan ketentuan sebelum menyimpan feedback.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Ambil fasilitas yang dipilih
    List<String> fasilitasDipilih = _fasilitasChecked.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (fasilitasDipilih.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu fasilitas yang dinilai!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Buat objek FeedbackItem
    final feedbackItem = FeedbackItem(
      namaMahasiswa: _namaController.text,
      nim: _nimController.text,
      fakultas: _selectedFakultas!,
      fasilitasDinilai: fasilitasDipilih,
      nilaiKepuasan: _nilaiKepuasan,
      jenisFeedback: _jenisFeedback,
      setujuSyarat: _setujuSyarat,
      pesanTambahan: _pesanController.text.isEmpty ? null : _pesanController.text,
    );

    // Kembali ke halaman sebelumnya dengan membawa data
    Navigator.pop(context, feedbackItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Feedback Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.feedback,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan isi formulir di bawah ini',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama Mahasiswa
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Mahasiswa',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NIM
            TextFormField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
                hintText: 'Masukkan NIM',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIM wajib diisi';
                }
                if (value.length < 8) {
                  return 'NIM minimal 8 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fakultas Dropdown
            DropdownButtonFormField<String>(
              value: _selectedFakultas,
              decoration: const InputDecoration(
                labelText: 'Fakultas',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
              items: _fakultasList.map((fakultas) {
                return DropdownMenuItem(
                  value: fakultas,
                  child: Text(fakultas),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFakultas = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih fakultas';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Fasilitas yang Dinilai
            Text(
              'Fasilitas yang Dinilai:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _fasilitasChecked.keys.map((fasilitas) {
                  return CheckboxListTile(
                    title: Text(fasilitas),
                    value: _fasilitasChecked[fasilitas],
                    onChanged: (value) {
                      setState(() {
                        _fasilitasChecked[fasilitas] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Nilai Kepuasan Slider
            Text(
              'Nilai Kepuasan: ${_nilaiKepuasan.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Slider(
                      value: _nilaiKepuasan,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      label: _nilaiKepuasan.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _nilaiKepuasan = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1.0\n(Sangat Tidak Puas)',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center),
                        Text('5.0\n(Sangat Puas)',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jenis Feedback Radio
            Text(
              'Jenis Feedback:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Saran'),
                    subtitle: const Text('Memberikan masukan untuk perbaikan'),
                    value: 'Saran',
                    groupValue: _jenisFeedback,
                    onChanged: (value) {
                      setState(() {
                        _jenisFeedback = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Keluhan'),
                    subtitle: const Text('Menyampaikan ketidakpuasan'),
                    value: 'Keluhan',
                    groupValue: _jenisFeedback,
                    onChanged: (value) {
                      setState(() {
                        _jenisFeedback = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Apresiasi'),
                    subtitle: const Text('Memberikan pujian atau terima kasih'),
                    value: 'Apresiasi',
                    groupValue: _jenisFeedback,
                    onChanged: (value) {
                      setState(() {
                        _jenisFeedback = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pesan Tambahan (Opsional)
            TextFormField(
              controller: _pesanController,
              decoration: const InputDecoration(
                labelText: 'Pesan Tambahan (Opsional)',
                hintText: 'Tulis detail feedback Anda...',
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Switch Setuju Syarat
            Card(
              color: _setujuSyarat
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: SwitchListTile(
                title: const Text('Setuju Syarat & Ketentuan'),
                subtitle: const Text(
                  'Data yang Anda berikan akan digunakan untuk evaluasi kampus',
                ),
                value: _setujuSyarat,
                onChanged: (value) {
                  setState(() {
                    _setujuSyarat = value;
                  });
                },
                secondary: Icon(
                  _setujuSyarat ? Icons.check_circle : Icons.info_outline,
                  color: _setujuSyarat ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            ElevatedButton.icon(
              onPressed: _simpanFeedback,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Batal
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Batal'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}