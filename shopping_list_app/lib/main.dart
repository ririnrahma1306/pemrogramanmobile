import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const ShoppingListApp());
}

class ShoppingListApp extends StatefulWidget {
  const ShoppingListApp({super.key});

  @override
  State<ShoppingListApp> createState() => _ShoppingListAppState();
}

class _ShoppingListAppState extends State<ShoppingListApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List Sultan',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        fontFamily: 'Poppins',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
      ),
      home: ShoppingListScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// ---------------------------------------------------------
// 1. MODEL DATA
// ---------------------------------------------------------
class ShoppingItem {
  String id;
  String name;
  String amount;
  String category;
  int price;
  bool isBought;
  bool isUrgent;
  DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.price = 0,
    this.isBought = false,
    this.isUrgent = false,
    required this.createdAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      category: json['category'],
      price: json['price'] ?? 0,
      isBought: json['isBought'] ?? false,
      isUrgent: json['isUrgent'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'price': price,
      'isBought': isBought,
      'isUrgent': isUrgent,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// ---------------------------------------------------------
// 2. UI SCREEN & LOGIC
// ---------------------------------------------------------
class ShoppingListScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ShoppingListScreen({
    super.key, 
    required this.toggleTheme, 
    required this.isDarkMode
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _items = [];
  final List<String> _categories = ['Makanan', 'Minuman', 'Elektronik', 'Kebersihan', 'Lainnya'];
  
  String _selectedCategoryFilter = 'Semua';
  String _searchQuery = '';
  String _sortBy = 'Terbaru';
  bool _isShoppingMode = false;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> itemsJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('shopping_list_sultan', jsonEncode(itemsJson));
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? itemsString = prefs.getString('shopping_list_sultan');
    if (itemsString != null) {
      List<dynamic> jsonList = jsonDecode(itemsString);
      setState(() {
        _items = jsonList.map((json) => ShoppingItem.fromJson(json)).toList();
      });
    }
  }

  void _addItem(String name, String amount, String category, int price, bool isUrgent) {
    setState(() {
      _items.insert(0, ShoppingItem(
        id: DateTime.now().toString(),
        name: name,
        amount: amount,
        category: category,
        price: price,
        isUrgent: isUrgent,
        createdAt: DateTime.now(),
      ));
    });
    _saveItems();
  }

  void _editItem(int index, String name, String amount, String category, int price, bool isUrgent) {
    setState(() {
      _items[index].name = name;
      _items[index].amount = amount;
      _items[index].category = category;
      _items[index].price = price;
      _items[index].isUrgent = isUrgent;
    });
    _saveItems();
  }

  void _deleteItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final deletedItem = _items[index];
    
    setState(() {
      _items.removeAt(index);
    });
    _saveItems();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedItem.name} dihapus'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Batal',
          onPressed: () {
            setState(() {
              _items.insert(index, deletedItem);
            });
            _saveItems();
          },
        ),
      ),
    );
  }

  void _clearCompleted() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bersihkan Selesai?"),
        content: const Text("Semua item yang sudah dibeli akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _items.removeWhere((item) => item.isBought);
              });
              _saveItems();
              Navigator.pop(ctx);
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  void _toggleStatus(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _items[index].isBought = !_items[index].isBought;
      });
      _saveItems();
      
      if (_items.isNotEmpty && _items.every((item) => item.isBought)) {
        _showSuccessDialog();
      }
    }
  }
  
  void _toggleUrgent(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _items[index].isUrgent = !_items[index].isUrgent;
      });
      _saveItems();
    }
  }

  void _shareList() {
    String text = "🛒 Daftar Belanja Sultan:\n\n";
    for (var item in _items) {
      String status = item.isBought ? "✅" : "⬜";
      String urgent = item.isUrgent ? "⭐ PENTING" : "";
      text += "$status ${item.name} (${item.amount}) $urgent\n";
    }
    text += "\nTotal Budget: ${_formatCurrency(_totalCostPending + _totalCostBought)}";
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Teks disalin! Siap dikirim ke WA."), behavior: SnackBarBehavior.floating),
    );
  }

  void _showStatistics() {
    Map<String, int> catStats = {};
    for (var cat in _categories) {
      catStats[cat] = _items.where((i) => i.category == cat).fold(0, (sum, i) => sum + i.price);
    }
    int total = _totalCostPending + _totalCostBought;

    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📊 Statistik Pengeluaran", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ..._categories.map((cat) {
                int amount = catStats[cat] ?? 0;
                if (amount == 0) return const SizedBox.shrink();
                double pct = total == 0 ? 0 : amount / total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // FIX: Menggunakan ikon kategori di sini
                          Row(children: [
                            Icon(_getCategoryIcon(cat), size: 16, color: _getCategoryColor(cat)),
                            const SizedBox(width: 8),
                            Text(cat, style: TextStyle(color: _getCategoryColor(cat), fontWeight: FontWeight.bold)),
                          ]),
                          Text(_formatCurrency(amount)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey[300],
                          color: _getCategoryColor(cat),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (total == 0) const Center(child: Text("Belum ada data harga.")),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Belanja Beres!"),
        content: const Text("Semua barang sudah dibeli. Waktunya pulang!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))
        ],
      ),
    );
  }

  List<ShoppingItem> get _filteredItems {
    var list = _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'Semua' || item.category == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    list.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;

      switch (_sortBy) {
        case 'Abjad': return a.name.compareTo(b.name);
        case 'Termurah': return a.price.compareTo(b.price);
        case 'Termahal': return b.price.compareTo(a.price);
        case 'Terbaru': default: return b.createdAt.compareTo(a.createdAt);
      }
    });

    return list;
  }

  int get _totalCostPending => _items.where((item) => !item.isBought).fold(0, (sum, item) => sum + item.price);
  int get _totalCostBought => _items.where((item) => item.isBought).fold(0, (sum, item) => sum + item.price);
  int get _totalPending => _items.where((item) => !item.isBought).length;
  int get _totalBought => _items.where((item) => item.isBought).length;

  // FIX: Fungsi ini sekarang dipakai di _showStatistics dan _buildNormalTile
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan': return Icons.lunch_dining;
      case 'Minuman': return Icons.local_cafe;
      case 'Elektronik': return Icons.devices;
      case 'Kebersihan': return Icons.cleaning_services;
      default: return Icons.shopping_basket;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan': return Colors.orange;
      case 'Minuman': return Colors.blue;
      case 'Elektronik': return Colors.purple;
      case 'Kebersihan': return Colors.teal;
      default: return Colors.grey;
    }
  }

  void _showItemDialog({ShoppingItem? itemToEdit}) {
    final isEdit = itemToEdit != null;
    final nameController = TextEditingController(text: isEdit ? itemToEdit.name : '');
    final amountController = TextEditingController(text: isEdit ? itemToEdit.amount : '');
    final priceController = TextEditingController(text: isEdit ? itemToEdit.price.toString() : '');
    String selectedCategory = isEdit ? itemToEdit.category : _categories[0];
    bool isUrgent = isEdit ? itemToEdit.isUrgent : false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? 'Edit Belanjaan' : 'Tambah Belanjaan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: 'Nama Barang', prefixIcon: const Icon(Icons.shopping_bag_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: amountController, decoration: InputDecoration(labelText: 'Jumlah', prefixIcon: const Icon(Icons.numbers), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Harga (Rp)', prefixIcon: const Icon(Icons.monetization_on_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // FIX: Gunakan InputDecorator + DropdownButton (menghindari error 'value deprecated')
                    InputDecorator(
                      decoration: InputDecoration(labelText: 'Kategori', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setDialogState(() => selectedCategory = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Tandai Penting (Urgent)"),
                      secondary: const Icon(Icons.star, color: Colors.amber),
                      value: isUrgent,
                      onChanged: (val) => setDialogState(() => isUrgent = val),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final price = int.tryParse(priceController.text) ?? 0;
                      if (isEdit) {
                        final index = _items.indexWhere((i) => i.id == itemToEdit.id);
                        if (index != -1) _editItem(index, nameController.text, amountController.text, selectedCategory, price, isUrgent);
                      } else {
                        _addItem(nameController.text, amountController.text, selectedCategory, price, isUrgent);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEdit ? 'Simpan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredItems;
    final isDark = widget.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // --- WAVE BACKGROUND HEADER ---
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF004D40), const Color(0xFF00695C)] 
                    : [const Color(0xFF009688), const Color(0xFF80CBC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- TOP BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Belanja Sultan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_isShoppingMode ? "Mode Fokus Belanja Aktif" : "Atur belanjaanmu", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(_isShoppingMode ? Icons.check_circle : Icons.shopping_cart_checkout, color: Colors.white),
                            tooltip: 'Mode Belanja',
                            onPressed: () => setState(() => _isShoppingMode = !_isShoppingMode),
                            style: IconButton.styleFrom(backgroundColor: Colors.white24),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                            onPressed: widget.toggleTheme,
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // --- DASHBOARD ---
                if (!_isShoppingMode) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             _buildSummaryColumn("Harus Dibeli", _totalPending, _totalCostPending, Colors.orange),
                             Container(width: 1, height: 40, color: Colors.grey[300]),
                             _buildSummaryColumn("Selesai", _totalBought, _totalCostBought, Colors.green),
                             // Small Tools
                             Column(
                               children: [
                                 IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: _shareList, tooltip: 'Share', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                 const SizedBox(height: 10),
                                 IconButton(icon: const Icon(Icons.bar_chart, color: Colors.purple), onPressed: _showStatistics, tooltip: 'Stats', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                 const SizedBox(height: 10),
                                 // FIX: Tombol Clear Completed ditambahkan kembali
                                 if (_totalBought > 0)
                                   IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.red), onPressed: _clearCompleted, tooltip: 'Hapus Selesai', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                               ],
                             )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Cari barang...',
                              prefixIcon: const Icon(Icons.search, color: Colors.teal),
                              filled: true,
                              fillColor: isDark ? Colors.black26 : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.sort, color: Colors.teal),
                            onSelected: (val) => setState(() => _sortBy = val),
                            itemBuilder: (ctx) => ['Terbaru', 'Abjad', 'Termurah', 'Termahal'].map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Filter Chips
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                      // FIX: Menghapus .toList() yang tidak perlu
                      children: [
                        _buildFilterChip('Semua'),
                        ..._categories.map((cat) => _buildFilterChip(cat)),
                      ],
                    ),
                  ),
                ] else 
                  const SizedBox(height: 20), // Spacer in Shopping Mode

                // --- LIST VIEW ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: displayList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                                const SizedBox(height: 10),
                                const Text("List Kosong", style: TextStyle(fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final item = displayList[index];
                              return TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 500),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - value)),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: _isShoppingMode 
                                  ? _buildShoppingModeTile(item) 
                                  : _buildNormalTile(item),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isShoppingMode 
          ? null // Sembunyikan tombol tambah saat mode belanja
          : FloatingActionButton.extended(
              onPressed: () => _showItemDialog(),
              backgroundColor: Colors.teal,
              elevation: 4,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }

  // Tampilan Normal (Bisa Edit/Hapus)
  Widget _buildNormalTile(ShoppingItem item) {
    final isDark = widget.isDarkMode;
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Card(
        elevation: item.isUrgent ? 4 : 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: item.isUrgent && !item.isBought ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
        ),
        color: item.isBought ? (isDark ? Colors.black26 : Colors.grey[100]) : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
        child: ListTile(
          onTap: () => _showItemDialog(itemToEdit: item),
          leading: GestureDetector(
            onTap: () => _toggleUrgent(item.id),
            child: Icon(item.isUrgent ? Icons.star : Icons.star_border, color: item.isUrgent ? Colors.amber : Colors.grey),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: item.isBought ? TextDecoration.lineThrough : null,
              color: item.isBought ? Colors.grey : null
            ),
          ),
          // FIX: Menambahkan Ikon Kategori di Subtitle
          subtitle: Row(
            children: [
              Icon(_getCategoryIcon(item.category), size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("${item.amount} • ${_formatCurrency(item.price)}"),
            ],
          ),
          trailing: Checkbox(
            value: item.isBought,
            activeColor: Colors.teal,
            shape: const CircleBorder(),
            onChanged: (val) => _toggleStatus(item.id),
          ),
        ),
      ),
    );
  }

  // Tampilan Mode Belanja (Fokus, Teks Besar, Tanpa Edit)
  Widget _buildShoppingModeTile(ShoppingItem item) {
    final isDark = widget.isDarkMode;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: item.isBought ? (isDark ? Colors.black26 : Colors.grey[200]) : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _toggleStatus(item.id), // Klik di mana saja untuk centang
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.5, // Checkbox lebih besar
                child: Checkbox(
                  value: item.isBought,
                  activeColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (val) => _toggleStatus(item.id),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 20, // Font lebih besar
                        fontWeight: FontWeight.bold,
                        decoration: item.isBought ? TextDecoration.lineThrough : null,
                        color: item.isBought ? Colors.grey : null
                      ),
                    ),
                    Row(
                      children: [
                        Icon(_getCategoryIcon(item.category), size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "${item.amount} • ${item.category}",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isUrgent) const Icon(Icons.star, color: Colors.amber, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String title, int count, int totalCost, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(_formatCurrency(totalCost), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategoryFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.teal,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        onSelected: (val) => setState(() => _selectedCategoryFilter = label),
      ),
    );
  }
}

// --- CUSTOM CLIPPER UNTUK HEADER BERGELOMBANG ---
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}