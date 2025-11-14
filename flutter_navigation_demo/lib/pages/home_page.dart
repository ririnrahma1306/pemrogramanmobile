import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const HomePage({required this.onThemeChanged, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    // Controller untuk animasi FAB (Floating Action Button)
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  // List halaman yang ditampilkan di Bottom Navigation
  final List<Widget> _pages = [
    const HomeContent(),
    const FeedbackContent(),
    const ProfileContent(),
  ];

  /// Handler ketika item di Bottom Navigation di-tap
  /// Reset dan forward animasi FAB untuk smooth transition
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _fabController.reset();
      _fabController.forward();
    });
  }

  /// Fungsi untuk pull-to-refresh
  /// Simulasi loading data dengan delay 2 detik
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil di-refresh!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Navigation Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Search button - membuka search delegate
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          // Settings button - navigasi ke settings page
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      
      // Drawer Navigation - Menu samping kiri
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header dengan gradient
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Menu Navigasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Navigation Items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback Form'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 2);
              },
            ),
            
            const Divider(),
            
            // Additional Features
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Achievements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/achievements');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/statistics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/history');
              },
            ),
            
            const Divider(),
            
            // Extra Tools - SEMUA AKTIF
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/quiz');
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Timer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/timer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/calculator');
              },
            ),
            
            const Divider(),
            
            // Settings & Tutorial
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Tutorial'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/onboarding');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      
      // Body dengan pull-to-refresh
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _pages[_selectedIndex],
      ),
      
      // Bottom Navigation Bar untuk navigasi utama
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      
      // FAB dengan animasi untuk quick access ke feedback form
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/feedback-form');
          },
          icon: const Icon(Icons.add),
          label: const Text('Feedback'),
          tooltip: 'Tambah Feedback Baru',
        ),
      ),
    );
  }
}

/// Custom Search Delegate untuk search functionality
class CustomSearchDelegate extends SearchDelegate<String> {
  final List<String> searchItems = [
    'Home',
    'About',
    'Feedback',
    'Profile',
    'Settings',
    'Navigation',
    'Flutter',
    'Material Design',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = searchItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(results[index]),
          onTap: () {
            close(context, results[index]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mencari: ${results[index]}')),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

/// Content untuk tab Home di Bottom Navigation
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Hero animation untuk app icon
            Hero(
              tag: 'app-icon',
              child: Icon(
                Icons.home_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selamat Datang!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi Demo Navigasi Flutter',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            // Card dengan daftar fitur aplikasi
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Fitur Aplikasi:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.navigation, 'Navigasi Multi-Page'),
                    _buildFeatureItem(Icons.send, 'Pengiriman Data'),
                    _buildFeatureItem(Icons.dashboard, 'Bottom Navigation'),
                    _buildFeatureItem(Icons.menu, 'Drawer Menu'),
                    _buildFeatureItem(Icons.animation, 'Animasi & Transisi'),
                    _buildFeatureItem(Icons.dark_mode, 'Dark Mode'),
                    _buildFeatureItem(Icons.search, 'Search Function'),
                    _buildFeatureItem(Icons.refresh, 'Pull to Refresh'),
                    _buildFeatureItem(Icons.emoji_events, 'Achievements'),
                    _buildFeatureItem(Icons.analytics, 'Statistics'),
                    _buildFeatureItem(Icons.history, 'Activity History'),
                    _buildFeatureItem(Icons.quiz, 'Quiz Game'),
                    _buildFeatureItem(Icons.note, 'Notes Manager'),
                    _buildFeatureItem(Icons.timer, 'Timer & Stopwatch'),
                    _buildFeatureItem(Icons.calculate, 'Calculator'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Quick access buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Tentang'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

/// Content untuk tab Feedback di Bottom Navigation
class FeedbackContent extends StatelessWidget {
  const FeedbackContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Animasi scale untuk icon feedback
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.feedback_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Feedback',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Berikan feedback Anda tentang aplikasi ini',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/feedback-form');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Isi Feedback Form'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content untuk tab Profile di Bottom Navigation
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lihat Profile Lengkap'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}