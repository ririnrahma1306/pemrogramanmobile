import 'package:flutter/material.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer & Stopwatch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ? const StopwatchWidget()
                : const TimerWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      color: _selectedTab == 0 ? Colors.white : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stopwatch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedTab == 0 ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      color: _selectedTab == 1 ? Colors.white : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Timer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedTab == 1 ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stopwatch Widget
class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  final List<String> _laps = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() => _milliseconds += 10);
      });
      setState(() => _isRunning = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _milliseconds = 0;
      _isRunning = false;
      _laps.clear();
    });
  }

  void _lap() {
    setState(() {
      _laps.insert(0, _formatTime(_milliseconds));
    });
  }

  String _formatTime(int ms) {
    int hundreds = (ms / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main timer display - dibungkus dengan Flexible
        Flexible(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isRunning)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 200 + (_pulseController.value * 20),
                              height: 200 + (_pulseController.value * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1 - (_pulseController.value * 0.1)),
                              ),
                            );
                          },
                        ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_milliseconds),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (_milliseconds > 0 && !_isRunning)
                        FloatingActionButton(
                          onPressed: _reset,
                          heroTag: 'reset',
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.refresh),
                        ),
                      FloatingActionButton.extended(
                        onPressed: _startStop,
                        heroTag: 'startstop',
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                      ),
                      if (_isRunning)
                        FloatingActionButton(
                          onPressed: _lap,
                          heroTag: 'lap',
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.flag),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Laps list - dibungkus dengan Flexible
        if (_laps.isNotEmpty)
          Flexible(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Laps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_laps.length} laps',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _laps.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${_laps.length - index}'),
                          ),
                          title: Text(
                            _laps[index],
                            style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          trailing: index == 0
                              ? const Icon(Icons.flag, color: Colors.orange)
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Timer Widget
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 300; // Default 5 minutes
  int _remainingSeconds = 300;
  bool _isRunning = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
      _rotationController.stop();
      setState(() => _isRunning = false);
    } else {
      if (_remainingSeconds <= 0) {
        setState(() {
          _remainingSeconds = _seconds;
        });
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _rotationController.stop();
            _showTimerComplete();
          }
        });
      });

      _rotationController.repeat();
      setState(() => _isRunning = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    _rotationController.stop();
    _rotationController.reset();
    setState(() {
      _remainingSeconds = _seconds;
      _isRunning = false;
    });
  }

  void _showTimerComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.green),
            SizedBox(width: 12),
            Text('Time\'s Up!'),
          ],
        ),
        content: const Text('Your timer has completed.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / _seconds;

    return Column(
      children: [
        // Main timer display - dibungkus dengan Flexible
        Flexible(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _remainingSeconds <= 10 ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _rotationController,
                        child: Icon(
                          Icons.access_time,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (_remainingSeconds != _seconds && !_isRunning)
                        FloatingActionButton(
                          onPressed: _reset,
                          heroTag: 'timer_reset',
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.refresh),
                        ),
                      FloatingActionButton.extended(
                        onPressed: _startStop,
                        heroTag: 'timer_startstop',
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick Set buttons - dibungkus dengan Flexible
        if (!_isRunning)
          Flexible(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Quick Set',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickButton('1 min', 60),
                        _buildQuickButton('3 min', 180),
                        _buildQuickButton('5 min', 300),
                        _buildQuickButton('10 min', 600),
                        _buildQuickButton('15 min', 900),
                        _buildQuickButton('30 min', 1800),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickButton(String label, int seconds) {
    final isSelected = _seconds == seconds && _remainingSeconds == seconds;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _seconds = seconds;
          _remainingSeconds = seconds;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }
}