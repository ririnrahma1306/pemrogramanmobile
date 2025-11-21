// ==================== TODO LIST PRO - FLUTTER APP ====================
//
// INSTALASI PACKAGE:
// Tambahkan di pubspec.yaml:
//
// dependencies:
//   flutter:
//     sdk: flutter
//   shared_preferences: ^2.2.2
//
// Jalankan: flutter pub get
//
// ======================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ==================== MODEL ====================
class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  String priority; // High, Medium, Low
  String category; // Work, Personal, Shopping, Health, Other
  DateTime createdAt;
  DateTime? dueDate;
  List<String> tags;
  Color? customColor;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = 'Medium',
    this.category = 'Personal',
    required this.createdAt,
    this.dueDate,
    this.tags = const [],
    this.customColor,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'],
      priority: json['priority'] ?? 'Medium',
      category: json['category'] ?? 'Personal',
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      customColor: json['customColor'] != null
          ? Color(json['customColor'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'customColor': customColor?.value,
    };
  }

  Color getPriorityColor() {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getCategoryIcon() {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Health':
        return Icons.favorite;
      case 'Study':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}

// ==================== MAIN ====================
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: TodoListScreen(),
    );
  }
}

// ==================== TODO LIST SCREEN ====================
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with TickerProviderStateMixin {
  List<Todo> todos = [];
  String currentFilter = 'Semua';
  String sortBy = 'Date';
  String searchQuery = '';
  bool isLoading = true;
  bool showCompleted = true;
  bool isGridView = false;
  late AnimationController _fabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ==================== LOAD & SAVE DATA ====================
  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? todosString = prefs.getString('todos');

      if (todosString != null && todosString.isNotEmpty) {
        List<dynamic> todosJson = jsonDecode(todosString);
        setState(() {
          todos = todosJson.map((json) => Todo.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Gagal memuat data: $e', isError: true);
    }
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> todosJson =
          todos.map((todo) => todo.toJson()).toList();
      String todosString = jsonEncode(todosJson);
      await prefs.setString('todos', todosString);
    } catch (e) {
      _showSnackBar('Gagal menyimpan data: $e', isError: true);
    }
  }

  // ==================== CRUD OPERATIONS ====================
  void _addTodo(Todo todo) {
    setState(() {
      todos.insert(0, todo);
    });
    _saveTodos();
    _showSnackBar('✅ Todo berhasil ditambahkan!');
  }

  void _updateTodo(int index, Todo updatedTodo) {
    setState(() {
      todos[index] = updatedTodo;
    });
    _saveTodos();
    _showSnackBar('✏️ Todo berhasil diperbarui!');
  }

  void _toggleComplete(int index) {
    setState(() {
      todos[index].isCompleted = !todos[index].isCompleted;
    });
    _saveTodos();

    if (todos[index].isCompleted) {
      _showSnackBar('🎉 Todo selesai!');
    }
  }

  void _deleteTodo(int index) {
    final deletedTodo = todos[index];
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ Todo dihapus'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              todos.insert(index, deletedTodo);
            });
            _saveTodos();
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _deleteAllCompleted() {
    setState(() {
      todos.removeWhere((todo) => todo.isCompleted);
    });
    _saveTodos();
    _showSnackBar('🧹 Semua todo selesai telah dihapus');
  }

  // ==================== FILTER & SORT ====================
  List<Todo> _getFilteredTodos() {
    List<Todo> filtered = todos;

    if (currentFilter == 'Selesai') {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    } else if (currentFilter == 'Belum Selesai') {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    } else if (currentFilter != 'Semua') {
      filtered =
          filtered.where((todo) => todo.category == currentFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            todo.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
            todo.tags
                .any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }

    if (!showCompleted) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    if (sortBy == 'Priority') {
      filtered.sort((a, b) {
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        return (priorityOrder[a.priority] ?? 3)
            .compareTo(priorityOrder[b.priority] ?? 3);
      });
    } else if (sortBy == 'Category') {
      filtered.sort((a, b) => a.category.compareTo(b.category));
    } else if (sortBy == 'Due Date') {
      filtered.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (sortBy == 'Title') {
      filtered
          .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    return filtered;
  }

  Map<String, int> _getStatistics() {
    int total = todos.length;
    int completed = todos.where((todo) => todo.isCompleted).length;
    int pending = total - completed;
    int highPriority =
        todos.where((todo) => todo.priority == 'High' && !todo.isCompleted).length;
    int overdue = todos.where((todo) {
      if (todo.dueDate == null || todo.isCompleted) return false;
      return todo.dueDate!.isBefore(DateTime.now());
    }).length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'highPriority': highPriority,
      'overdue': overdue,
    };
  }

  double _getCompletionPercentage() {
    if (todos.isEmpty) return 0;
    return (todos.where((t) => t.isCompleted).length / todos.length) * 100;
  }

  // ==================== UI HELPERS ====================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTodoDialog({int? index}) {
    final isEdit = index != null;
    final todo = isEdit ? todos[index] : null;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoFormScreen(
          todo: todo,
          onSave: (newTodo) {
            if (isEdit) {
              _updateTodo(index, newTodo); // ✅ Hapus tanda '!' di sini (Perbaikan Peringatan Kuning)
            } else {
              _addTodo(newTodo);
            }
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Hapus Todo?'),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus "${todos[index].title}"?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTodo(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.tune, color: Colors.deepPurple, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Divider(height: 24, thickness: 1.5),
              Text(
                'Filter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('Semua', Icons.list),
                  _buildChip('Selesai', Icons.check_circle),
                  _buildChip('Belum Selesai', Icons.pending),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('Work', Icons.work),
                  _buildChip('Personal', Icons.person),
                  _buildChip('Shopping', Icons.shopping_cart),
                  _buildChip('Health', Icons.favorite),
                  _buildChip('Study', Icons.school),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Sort by',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('Date', Icons.calendar_today),
                  _buildSortChip('Priority', Icons.flag),
                  _buildSortChip('Category', Icons.category),
                  _buildSortChip('Due Date', Icons.alarm),
                  _buildSortChip('Title', Icons.sort_by_alpha),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple[100]!),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Tampilkan Todo Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Sembunyikan untuk fokus pada todo aktif',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  value: showCompleted,
                  onChanged: (value) {
                    setState(() {
                      showCompleted = value;
                    });
                    Navigator.pop(context);
                  },
                  activeColor: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    final isSelected = currentFilter == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.deepPurple,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          currentFilter = selected ? label : 'Semua';
        });
        Navigator.pop(context);
      },
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: isSelected ? 3 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildSortChip(String label, IconData icon) {
    final isSelected = sortBy == label;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.blue[700],
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          sortBy = label;
        });
        Navigator.pop(context);
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.blue[50],
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: isSelected ? 3 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();
    final filteredTodos = _getFilteredTodos();
    final completionPercentage = _getCompletionPercentage();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📝 Todo List Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (searchQuery.isEmpty) {
                  // Show search
                } else {
                  searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_completed') {
                if (stats['completed']! > 0) {
                  _deleteAllCompleted();
                } else {
                  _showSnackBar('Tidak ada todo selesai untuk dihapus');
                }
              } else if (value == 'stats') {
                _showStatsDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Statistik'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_completed',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Hapus Semua Selesai'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari todo...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),

                // Statistics Card
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(103, 58, 183, 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total', stats['total']!, Icons.list_alt),
                          Container(height: 40, width: 1, color: Colors.white30),
                          _buildStatItem(
                              'Selesai', stats['completed']!, Icons.check_circle),
                          Container(height: 40, width: 1, color: Colors.white30),
                          _buildStatItem(
                              'Pending', stats['pending']!, Icons.pending),
                        ],
                      ),
                      if (todos.isNotEmpty) ...[
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completionPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white30,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${completionPercentage.toStringAsFixed(0)}% Selesai',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Filter Indicator
                if (currentFilter != 'Semua')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt, size: 16, color: Colors.deepPurple),
                        SizedBox(width: 4),
                        Text(
                          'Filter: $currentFilter',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentFilter = 'Semua';
                            });
                          },
                          child: Icon(Icons.close,
                              size: 16, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 8),

                // Todo List
                Expanded(
                  child: filteredTodos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.inbox,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                searchQuery.isNotEmpty
                                    ? 'Tidak ada hasil'
                                    : 'Belum ada todo',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (searchQuery.isEmpty)
                                Text(
                                  'Tekan tombol + untuk menambah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        )
                      : isGridView
                          ? _buildGridView(filteredTodos)
                          : _buildListView(filteredTodos),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoDialog(),
        icon: Icon(Icons.add),
        label: Text('Tambah Todo'),
      ),
    );
  }

  Widget _buildListView(List<Todo> filteredTodos) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        final originalIndex = todos.indexOf(todo);
        return _buildTodoCard(todo, originalIndex);
      },
    );
  }

  Widget _buildGridView(List<Todo> filteredTodos) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        final originalIndex = todos.indexOf(todo);
        return _buildTodoGridCard(todo, originalIndex);
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTodoCard(Todo todo, int originalIndex) {
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _toggleComplete(originalIndex);
          return false;
        }
        return true;
      },
      onDismissed: (direction) {
        _deleteTodo(originalIndex);
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOverdue
              ? BorderSide(color: Colors.red, width: 2)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => _toggleComplete(originalIndex),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Row(
            children: [
              Icon(
                todo.getCategoryIcon(),
                size: 16,
                color: todo.getPriorityColor(),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: todo.isCompleted
                        ? Colors.grey
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    todo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              // ==========================================================
              // ===== BAGIAN WRAP (SOLUSI OVERFLOW) ======================
              // ==========================================================
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Wrap( 
                  spacing: 8.0, 
                  runSpacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: todo.getPriorityColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.priority,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(todo.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (todo.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alarm, size: 12, color: isOverdue ? Colors.red : Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            _formatDueDate(todo.dueDate!),
                            style: TextStyle(
                              fontSize: 11,
                              color: isOverdue ? Colors.red : Colors.blue,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () => _showTodoDialog(index: originalIndex),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _showDeleteDialog(originalIndex),
              ),
            ],
          ),
          onTap: () => _toggleComplete(originalIndex),
        ),
      ),
    );
  }

  Widget _buildTodoGridCard(Todo todo, int originalIndex) {
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOverdue
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showTodoDialog(index: originalIndex),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) => _toggleComplete(originalIndex),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: todo.getPriorityColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todo.priority,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                todo.getCategoryIcon(),
                size: 32,
                color: todo.getPriorityColor(),
              ),
              SizedBox(height: 8),
              Text(
                todo.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration:
                      todo.isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              if (todo.dueDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 12,
                      color: isOverdue ? Colors.red : Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDueDate(todo.dueDate!),
                        style: TextStyle(
                          fontSize: 10,
                          color: isOverdue ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog() {
    final stats = _getStatistics();
    final completionRate = _getCompletionPercentage();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Statistik Todo'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                  'Total Todo', stats['total']!, Icons.list_alt, Colors.blue),
              _buildStatRow('Selesai', stats['completed']!, Icons.check_circle,
                  Colors.green),
              _buildStatRow('Belum Selesai', stats['pending']!, Icons.pending,
                  Colors.orange),
              _buildStatRow('Prioritas Tinggi', stats['highPriority']!,
                  Icons.flag, Colors.red),
              _buildStatRow('Terlambat', stats['overdue']!, Icons.alarm,
                  Colors.red[900]!),
              Divider(height: 24),
              Text(
                'Tingkat Penyelesaian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRate / 100,
                  minHeight: 20,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  '${completionRate.toStringAsFixed(1)}% Selesai',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Terlambat';
    } else if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Besok';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lagi';
    } else {
      // ✅ PERBAIKAN DI SINI: Menggunakan 'dueDate.year' bukan 'date.year'
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }
}

// ==================== TODO FORM SCREEN ====================
class TodoFormScreen extends StatefulWidget {
  final Todo? todo;
  final Function(Todo) onSave;

  const TodoFormScreen({
    super.key,
    this.todo,
    required this.onSave,
  });

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late String _priority;
  late String _category;
  DateTime? _dueDate;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _tagController = TextEditingController();
    _priority = widget.todo?.priority ?? 'Medium';
    _category = widget.todo?.category ?? 'Personal';
    _dueDate = widget.todo?.dueDate;
    _tags = List.from(widget.todo?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (time != null && mounted) { 
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        category: _category,
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
        isCompleted: widget.todo?.isCompleted ?? false,
        tags: _tags,
      );

      widget.onSave(todo);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? '✏️ Edit Todo' : '➕ Tambah Todo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'SIMPAN',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Todo *',
                hintText: 'Masukkan judul todo...',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                hintText: 'Tambahkan detail todo...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 16),
            Text('Tags',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Tambah tag...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onFieldSubmitted: (value) => _addTag(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  child: Icon(Icons.add),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.asMap().entries.map((entry) {
                  return Chip(
                    label: Text('#${entry.value}'),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(entry.key),
                    backgroundColor: Colors.blue[100],
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 20),
            Text('Prioritas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip('High', Colors.red),
                SizedBox(width: 8),
                _buildPriorityChip('Medium', Colors.orange),
                SizedBox(width: 8),
                _buildPriorityChip('Low', Colors.green),
              ],
            ),
            SizedBox(height: 20),
            Text('Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('Work', Icons.work),
                _buildCategoryChip('Personal', Icons.person),
                _buildCategoryChip('Shopping', Icons.shopping_cart),
                _buildCategoryChip('Health', Icons.favorite),
                _buildCategoryChip('Study', Icons.school),
              ],
            ),
            SizedBox(height: 20),
            Text('Deadline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InkWell(
              onTap: _selectDueDate,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                            : 'Pilih tanggal & waktu deadline',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEdit ? '✅ UPDATE TODO' : '✅ TAMBAH TODO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'BATAL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority, Color color) {
    final isSelected = _priority == priority;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 18, color: isSelected ? Colors.white : color),
            SizedBox(width: 6),
            Text(priority),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _priority = priority;
          });
        },
        selectedColor: color,
        backgroundColor: Color.fromRGBO(
          color.red,
          color.green,
          color.blue,
          0.2,
        ),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black), 
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _category == category;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.black), 
          SizedBox(width: 6),
          Text(category),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _category = category;
        });
      },
      selectedColor: Colors.deepPurple,
      backgroundColor: Color.fromRGBO(103, 58, 183, 0.2),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black), 
    );
  }
}