import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // PERBAIKAN 1: Menggunakan super.key (Gaya Modern)
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Validasi Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const FormMahasiswaPage(),
    );
  }
}

class FormMahasiswaPage extends StatefulWidget {
  // PERBAIKAN 1: Menggunakan super.key
  const FormMahasiswaPage({super.key});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _bounceController;
  late AnimationController _rotateController;

  // Form keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Controllers
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();

  // State
  String? selectedJurusan;
  double semester = 1;

  // Data Hobi
  Map<String, bool> hobi = {
    '📚 Membaca Buku': false,
    '⚽ Olahraga': false,
    '🎵 Mendengarkan Musik': false,
    '✈️ Traveling': false,
    '🎮 Bermain Game': false,
  };

  bool persetujuan = false;

  List<Map<String, dynamic>> jurusanList = [
    {'icon': '💻', 'name': 'Teknik Informatika'},
    {'icon': '📊', 'name': 'Sistem Informasi'},
    {'icon': '⚡', 'name': 'Teknik Elektro'},
    {'icon': '⚙️', 'name': 'Teknik Mesin'},
    {'icon': '📈', 'name': 'Manajemen'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Validasi Data Pribadi
        return _formKey1.currentState?.validate() ?? false;
      case 1: // Validasi Akademik
        bool formValid = _formKey2.currentState?.validate() ?? false;
        bool jurusanValid = selectedJurusan != null;
        if (!jurusanValid) {
          _showSnackBar(
              'Harap pilih jurusan terlebih dahulu.', Colors.orange);
        }
        return formValid && jurusanValid;
      case 2: // Validasi Hobi & Persetujuan
        bool hobiValid = hobi.values.any((selected) => selected);
        if (!hobiValid) {
          _showSnackBar(
              'Harap pilih minimal satu hobi.', Colors.orange);
          return false;
        }
        if (!persetujuan) {
          _showSnackBar(
              'Anda harus menyetujui syarat & ketentuan untuk melanjutkan.',
              Colors.red);
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitForm() {
    List<String> hobiTerpilih =
        hobi.entries.where((e) => e.value).map((e) => e.key).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFFf093fb),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          // PERBAIKAN 5: Tambahkan SingleChildScrollView agar tidak Overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                          0, -10 * math.sin(_bounceController.value * math.pi)),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF667eea),
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pendaftaran Berhasil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Data registrasi Anda telah kami terima.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        // PERBAIKAN 2: Ganti withOpacity -> withValues
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Data:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      const Divider(height: 16),
                      _buildInfoRow('👤', 'Nama', namaController.text),
                      _buildInfoRow('📧', 'Email', emailController.text),
                      _buildInfoRow('📱', 'No. HP', noHpController.text),
                      _buildInfoRow('🎓', 'Jurusan', selectedJurusan ?? ''),
                      _buildInfoRow(
                          '📖', 'Semester', 'Semester ${semester.toInt()}'),
                      _buildInfoRow('💫', 'Hobi', hobiTerpilih.join(", ")),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk TextField agar kode lebih rapi
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          floatingLabelStyle: const TextStyle(color: Color(0xFF667eea)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFF4facfe),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Formal
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Rotating Icon
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateController.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 40,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'FORM PENDAFTARAN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'DATA MAHASISWA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timeline,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'LANGKAH ${_currentStep + 1} DARI 3',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Form Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Stepper(
                    currentStep: _currentStep,
                    elevation: 0,
                    onStepContinue: () {
                      if (_validateCurrentStep()) {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _submitForm();
                        }
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    const BoxShadow(
                                      // PERBAIKAN 2: Ganti withOpacity -> withValues
                                      color: Color(0x66667eea),
                                      // Kode Hex di atas sudah ada alpha 0x66, jadi aman
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: details.onStepContinue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep == 2
                                            ? 'KIRIM DATA'
                                            : 'LANJUT',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF667eea),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF667eea),
                                      width: 2,
                                    ),
                                  ),
                                  onPressed: details.onStepCancel,
                                  child: const Text(
                                    'KEMBALI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      // STEP 1
                      Step(
                        title: const Text(
                          'DATA PRIBADI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          'Lengkapi identitas diri Anda',
                          style: TextStyle(fontSize: 12),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _formKey1,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: namaController,
                                label: 'Nama Lengkap',
                                hint: 'Masukkan nama lengkap',
                                icon: Icons.person_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama wajib diisi';
                                  }
                                  if (value.length < 3) {
                                    return 'Nama minimal 3 karakter';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: emailController,
                                label: 'Alamat Email',
                                hint: 'contoh@email.com',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: noHpController,
                                label: 'Nomor Telepon',
                                hint: '08123456789',
                                icon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nomor telepon wajib diisi';
                                  }
                                  if (value.length < 10) {
                                    return 'Nomor telepon minimal 10 digit';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return 'Nomor telepon harus berupa angka';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // STEP 2
                      Step(
                        title: const Text(
                          'DATA AKADEMIK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          'Informasi perkuliahan',
                          style: TextStyle(fontSize: 12),
                        ),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _formKey2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x1A667eea),
                                      Color(0x1A764ba2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Pilih Jurusan',
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.school_rounded,
                                      color: Color(0xFF667eea),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  initialValue: selectedJurusan,
                                  items: jurusanList
                                      .map<DropdownMenuItem<String>>((jurusan) {
                                    return DropdownMenuItem<String>(
                                      value: jurusan['name'] as String,
                                      child: Text(
                                        '${jurusan['icon']} ${jurusan['name']}',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => selectedJurusan = value);
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Jurusan wajib dipilih';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x1A667eea),
                                      Color(0x1A764ba2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'SEMESTER',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF667eea),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667eea),
                                                Color(0xFF764ba2),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x66667eea),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            'SEMESTER ${semester.toInt()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor:
                                            const Color(0xFF667eea),
                                        inactiveTrackColor:
                                            const Color(0x33667eea),
                                        thumbColor: const Color(0xFF764ba2),
                                        overlayColor: const Color(0x4D764ba2),
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                          overlayRadius: 24,
                                        ),
                                      ),
                                      child: Slider(
                                        min: 1,
                                        max: 8,
                                        divisions: 7,
                                        value: semester,
                                        onChanged: (value) {
                                          setState(() => semester = value);
                                        },
                                      ),
                                    ),
                                    const Text(
                                      'Geser untuk memilih semester',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF667eea),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // STEP 3
                      Step(
                        title: const Text(
                          'HOBI & PERSETUJUAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          'Lengkapi data tambahan',
                          style: TextStyle(fontSize: 12),
                        ),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2
                            ? StepState.complete
                            : StepState.indexed,
                        content: Form(
                          key: _formKey3,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x1A667eea),
                                      Color(0x1A764ba2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_rounded,
                                          color: Color(0xFF667eea),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'PILIH HOBI',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF667eea),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '(Pilih minimal satu opsi)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // PERBAIKAN 3: Hapus .toList() yang tidak perlu
                                    ...hobi.keys.map((hobiName) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: hobi[hobiName]!
                                              // PERBAIKAN 2: Ganti withOpacity -> withValues
                                              ? const Color(0xFF667eea)
                                                  .withValues(alpha: 0.1)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: hobi[hobiName]!
                                                ? const Color(0xFF667eea)
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          activeColor: const Color(0xFF667eea),
                                          title: Text(
                                            hobiName,
                                            style: TextStyle(
                                              fontWeight: hobi[hobiName]!
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: hobi[hobiName]!
                                                  ? const Color(0xFF667eea)
                                                  : Colors.black87,
                                            ),
                                          ),
                                          value: hobi[hobiName],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              hobi[hobiName] = value!;
                                            });
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Container(
                                decoration: BoxDecoration(
                                  // PERBAIKAN 2: Ganti withOpacity -> withValues
                                  color: persetujuan
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: persetujuan
                                        ? Colors.green
                                        // PERBAIKAN 2: Ganti withOpacity -> withValues
                                        : Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: SwitchListTile(
                                  title: const Text(
                                    'Persetujuan Syarat & Ketentuan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    persetujuan
                                        ? 'Anda telah menyetujui syarat & ketentuan'
                                        : 'Wajib disetujui untuk melanjutkan',
                                    style: TextStyle(
                                      color: persetujuan
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // PERBAIKAN 4: activeColor Deprecated -> gunakan activeTrackColor
                                  activeTrackColor: Colors.green,
                                  value: persetujuan,
                                  onChanged: (bool value) {
                                    setState(() {
                                      persetujuan = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}