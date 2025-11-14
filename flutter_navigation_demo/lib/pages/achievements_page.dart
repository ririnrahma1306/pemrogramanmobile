import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Achievement> achievements = [
    Achievement(
      title: 'First Steps',
      description: 'Membuka aplikasi untuk pertama kali',
      icon: Icons.star,
      isUnlocked: true,
      color: Colors.amber,
    ),
    Achievement(
      title: 'Explorer',
      description: 'Mengunjungi semua halaman',
      icon: Icons.explore,
      isUnlocked: true,
      color: Colors.blue,
    ),
    Achievement(
      title: 'Feedback Master',
      description: 'Mengirim 5 feedback',
      icon: Icons.feedback,
      isUnlocked: false,
      color: Colors.green,
    ),
    Achievement(
      title: 'Night Owl',
      description: 'Menggunakan dark mode',
      icon: Icons.nightlight,
      isUnlocked: true,
      color: Colors.indigo,
    ),
    Achievement(
      title: 'Customizer',
      description: 'Membuka halaman settings',
      icon: Icons.settings,
      isUnlocked: true,
      color: Colors.orange,
    ),
    Achievement(
      title: 'Social Butterfly',
      description: 'Share aplikasi ke 3 teman',
      icon: Icons.share,
      isUnlocked: false,
      color: Colors.pink,
    ),
    Achievement(
      title: 'Power User',
      description: 'Menggunakan aplikasi 7 hari berturut-turut',
      icon: Icons.bolt,
      isUnlocked: false,
      color: Colors.purple,
    ),
    Achievement(
      title: 'Perfect Score',
      description: 'Memberikan rating 5.0',
      icon: Icons.grade,
      isUnlocked: false,
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get unlockedCount =>
      achievements.where((a) => a.isUnlocked).length;

  double get progress => unlockedCount / achievements.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 48,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '$unlockedCount / ${achievements.length} Unlocked',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return FadeTransition(
                  opacity: _animation,
                  child: _buildAchievementCard(achievement, index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Card(
      elevation: achievement.isUnlocked ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: achievement.isUnlocked
          ? null
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? achievement.color.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            achievement.icon,
            size: 32,
            color: achievement.isUnlocked
                ? achievement.color
                : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: achievement.isUnlocked
                      ? null
                      : Colors.grey,
                ),
              ),
            ),
            if (achievement.isUnlocked)
              Icon(
                Icons.check_circle,
                color: achievement.color,
                size: 20,
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            achievement.description,
            style: TextStyle(
              color: achievement.isUnlocked
                  ? Colors.grey[600]
                  : Colors.grey,
            ),
          ),
        ),
        onTap: achievement.isUnlocked
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(achievement.icon, color: achievement.color),
                        const SizedBox(width: 12),
                        Text(achievement.title),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievement.description),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: achievement.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: achievement.color,
                              ),
                              const SizedBox(width: 8),
                              const Text('Achievement Unlocked!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            : null,
      ),
    );
  }
}