// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note_form_page.dart';
import 'note.dart';
import 'storage_service.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Note> _notes = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Semua',
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.loadNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveNotes() async {
    await StorageService.saveNotes(_notes);
  }

  List<Note> get _filteredNotes {
    return _notes.where((note) {
      final matchesCategory = _selectedCategory == 'Semua' || note.category == _selectedCategory;
      final matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Kuliah': return '📚';
      case 'Organisasi': return '🤝';
      case 'Pribadi': return '🏠';
      case 'Lain-lain': return '✨';
      default: return '📝';
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Kuliah': return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case 'Organisasi': return [const Color(0xFF43e97b), const Color(0xFF38f9d7)];
      case 'Pribadi': return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      case 'Lain-lain': return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      default: return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  Future<void> _addNote() async {
    final result = await Navigator.push<Note>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NoteFormPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (result != null) {
      setState(() {
        _notes.insert(0, result);
      });
      await _saveNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('🎉 ', style: TextStyle(fontSize: 20)),
                Text('Yey! Catatan baru berhasil disimpan!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _editNote(int index) async {
    final current = _notes[index];
    final result = await Navigator.push<Note>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NoteFormPage(existingNote: current),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (result != null) {
      setState(() {
        _notes[index] = result;
      });
      await _saveNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('✏️ ', style: TextStyle(fontSize: 20)),
                Text('Sip! Catatan berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _deleteNote(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, anim1, anim2) => Container(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🗑️', style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 12),
                const Text('Hapus Catatan?', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Yakin nih mau hapus? Catatan ini bakal hilang selamanya lho... 🥺',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Gak Jadi Deh', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _notes.removeAt(index);
                  });
                  Navigator.pop(ctx);
                  await _saveNotes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Text('👋 ', style: TextStyle(fontSize: 20)),
                            Text('Daaah... Catatan berhasil dihapus!'),
                          ],
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Hapus Aja', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String emoji = '📝';
    String message = 'Belum ada catatan nih!';
    String subtitle = 'Yuk mulai tulis ide cemerlangmu di sini!';

    if (_selectedCategory != 'Semua') {
      emoji = _getCategoryEmoji(_selectedCategory);
      message = 'Kategori $_selectedCategory kosong melompong';
      subtitle = 'Coba tambah catatan baru atau intip kategori lain ya';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * 0.2,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _addNote,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'Tambah Catatan Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar Keren
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Student Notes 🚀',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
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
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode
                        ? [const Color(0xFF2d3436), const Color(0xFF000000)]
                        : [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: Transform.rotate(
                              angle: value * 0.2,
                              child: const Text(
                                '✍️',
                                style: TextStyle(fontSize: 80),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        widget.isDarkMode ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch(
                      value: widget.isDarkMode,
                      onChanged: widget.onThemeChanged,
                      activeThumbColor: Colors.amber,
                      activeTrackColor: Colors.white.withValues(alpha: 0.5),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari catatan...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Kategori (Horizontal List)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category == 'Semua' ? '🌈' : _getCategoryEmoji(category),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Daftar Catatan
          filteredNotes.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = filteredNotes[index];
                        final actualIndex = _notes.indexOf(note);
                        final formattedDate = DateFormat('dd MMM • HH:mm').format(note.createdDate);

                        return Dismissible(
                          key: Key(note.createdDate.toString()),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white, size: 30),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            _deleteNote(actualIndex);
                            return false;
                          },
                          child: GestureDetector(
                            onTap: () => _editNote(actualIndex),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCategoryGradient(note.category)[0].withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Strip Warna Kategori
                                  Container(
                                    width: 12,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _getCategoryGradient(note.category),
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header Kartu
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                note.category.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade600,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  InkWell(
                                                    onTap: () => _deleteNote(actualIndex),
                                                    borderRadius: BorderRadius.circular(20),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Icon(
                                                        Icons.delete_outline_rounded,
                                                        size: 20,
                                                        color: Colors.red.withValues(alpha: 0.6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            note.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            note.content,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                      },
                      childCount: filteredNotes.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _addNote,
          label: const Text('Catat Sesuatu', style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.edit),
          backgroundColor: widget.isDarkMode ? const Color(0xFF6c5ce7) : const Color(0xFF0984e3),
        ),
      ),
    );
  }
}