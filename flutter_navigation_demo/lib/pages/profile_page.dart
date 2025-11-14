import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit profile segera hadir!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Mahasiswa Flutter',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'flutter.student@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    Icons.school,
                    'Universitas',
                    'Universitas Islam Negeri Sulthan Thaha Saifuddin Jambi',
                  ),
                  const Divider(height: 1),
                  _buildProfileItem(
                    context,
                    Icons.book,
                    'Program Studi',
                    'Sisitem Informasi',
                  ),
                  const Divider(height: 1),
                  _buildProfileItem(
                    context,
                    Icons.numbers,
                    'NIM',
                    '701230036',
                  ),
                  const Divider(height: 1),
                  _buildProfileItem(
                    context,
                    Icons.calendar_today,
                    'Semester',
                    '5 (Lima)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    Icons.phone,
                    'Telepon',
                    '+62 831-2185-3615',
                  ),
                  const Divider(height: 1),
                  _buildProfileItem(
                    context,
                    Icons.location_on,
                    'Alamat',
                    'Jambi City, Jambi, Indonesia',
                  ),
                  const Divider(height: 1),
                  _buildProfileItem(
                    context,
                    Icons.cake,
                    'Tanggal Lahir',
                    '13 Juni 2005',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logout berhasil!'),
                      ),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}