import 'package:flutter/material.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _isAnswered = false;
  bool _quizCompleted = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'Apa yang dimaksud dengan Navigator.push() di Flutter?',
      options: [
        'Menghapus halaman',
        'Menambah halaman baru ke stack',
        'Menutup aplikasi',
        'Refresh halaman'
      ],
      correctAnswer: 1,
      explanation:
          'Navigator.push() digunakan untuk menambahkan halaman baru ke navigation stack.',
    ),
    QuizQuestion(
      question: 'Widget apa yang digunakan untuk membuat list scrollable?',
      options: ['Container', 'Column', 'ListView', 'Stack'],
      correctAnswer: 2,
      explanation:
          'ListView adalah widget yang digunakan untuk membuat daftar item yang dapat di-scroll.',
    ),
    QuizQuestion(
      question: 'Apa fungsi dari setState() di Flutter?',
      options: [
        'Membuat widget baru',
        'Menghapus state',
        'Memperbarui UI ketika state berubah',
        'Menutup aplikasi'
      ],
      correctAnswer: 2,
      explanation:
          'setState() digunakan untuk memberitahu framework bahwa ada perubahan state yang perlu di-render ulang.',
    ),
    QuizQuestion(
      question: 'Material Design adalah sistem desain yang dikembangkan oleh?',
      options: ['Apple', 'Microsoft', 'Google', 'Facebook'],
      correctAnswer: 2,
      explanation:
          'Material Design adalah sistem desain yang dikembangkan oleh Google.',
    ),
    QuizQuestion(
      question:
          'Widget apa yang digunakan untuk menampilkan gambar di Flutter?',
      options: ['Picture', 'Image', 'Photo', 'Graphics'],
      correctAnswer: 1,
      explanation:
          'Image widget digunakan untuk menampilkan gambar dari berbagai sumber.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;

      if (index == _questions[_currentQuestion].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _isAnswered = false;
        _progressController.reset();
        _progressController.forward();
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _quizCompleted = false;
      _progressController.reset();
      _progressController.forward();
    });
  }

  Color _getScoreColor() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) return 'Excellent! 🎉';
    if (percentage >= 60) return 'Good Job! 👍';
    if (percentage >= 40) return 'Not Bad! 😊';
    return 'Keep Learning! 💪';
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(),
                  const SizedBox(height: 24),
                  _buildOptionsSection(),
                  if (_isAnswered) ...[
                    const SizedBox(height: 24),
                    _buildExplanation(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(_currentQuestion < _questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.check),
                        label: Text(_currentQuestion < _questions.length - 1
                            ? 'Next Question'
                            : 'Finish Quiz'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestion + 1}/${_questions.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Score: $_score',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: ((_currentQuestion + _progressAnimation.value) /
                    _questions.length),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${_currentQuestion + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _questions[_currentQuestion].question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: List.generate(
        _questions[_currentQuestion].options.length,
        (index) => _buildOptionCard(index),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = _selectedAnswer == index;
    final isCorrect =
        index == _questions[_currentQuestion].correctAnswer;
    
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (_isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor ?? Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor?.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor ?? Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: borderColor ?? Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _questions[_currentQuestion].options[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (icon != null)
              Icon(icon, color: borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Card(
      elevation: 2,
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _questions[_currentQuestion].explanation,
                    style: TextStyle(
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: _getScoreColor().withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_score/${_questions.length}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(),
                        ),
                      ),
                      Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _getScoreMessage(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'You answered $_score out of ${_questions.length} questions correctly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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