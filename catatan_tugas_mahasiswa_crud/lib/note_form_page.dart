// lib/note_form_page.dart
import 'package:flutter/material.dart';
import 'note.dart';

class NoteFormPage extends StatefulWidget {
  final Note? existingNote;

  const NoteFormPage({super.key, this.existingNote});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];

  bool get isEditMode => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingNote?.content ?? '');
    _selectedCategory = widget.existingNote?.category ?? 'Kuliah';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Kuliah':
        return '📚';
      case 'Organisasi':
        return '🤝';
      case 'Pribadi':
        return '🏠';
      case 'Lain-lain':
        return '✨';
      default:
        return '📝';
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Kuliah':
        return [Colors.blue.shade400, Colors.blue.shade700];
      case 'Organisasi':
        return [Colors.green.shade400, Colors.green.shade700];
      case 'Pribadi':
        return [Colors.orange.shade400, Colors.orange.shade700];
      case 'Lain-lain':
        return [Colors.purple.shade400, Colors.purple.shade700];
      default:
        return [Colors.grey.shade400, Colors.grey.shade700];
    }
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('⚠️ '),
              const Text('Isi semua field dulu ya!'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final newNote = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdDate: widget.existingNote?.createdDate ?? DateTime.now(),
      category: _selectedCategory,
    );

    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isEditMode ? 'Edit Catatan ✏️' : 'Catatan Baru 🆕',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getCategoryGradient(_selectedCategory),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (value * 0.4),
                            child: Text(
                              _getCategoryEmoji(_selectedCategory),
                              style: const TextStyle(fontSize: 80),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Judul Catatan 📌',
                              hintText: 'Tulis judul yang menarik...',
                              prefixIcon: const Icon(
                                Icons.title_rounded,
                                size: 28,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (value) => value == null ||
                                    value.trim().isEmpty
                                ? 'Judul wajib diisi ya! 😊'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Kategori 🏷️',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getCategoryGradient(
                                          _selectedCategory),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getCategoryEmoji(_selectedCategory),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              _getCategoryGradient(category),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getCategoryEmoji(category),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              labelText: 'Isi Catatan 📝',
                              hintText: 'Tulis apa yang ada di pikiran...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            maxLines: 10,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            validator: (value) => value == null ||
                                    value.trim().isEmpty
                                ? 'Isi catatan tidak boleh kosong! 📌'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getCategoryGradient(_selectedCategory),
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryGradient(
                                        _selectedCategory)[0]
                                    .withValues(),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _saveNote,
                              borderRadius: BorderRadius.circular(30),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isEditMode
                                          ? 'Simpan Perubahan 💾'
                                          : 'Simpan Catatan 💾',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}