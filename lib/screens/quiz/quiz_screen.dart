import 'package:flutter/material.dart';
import 'dart:math' as math;

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  bool _quizCompleted = false;
  late List<Question> _shuffledQuestions;

  // ── Palette ────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _correct = Color(0xFF10B981);
  static const _wrong = Color(0xFFEF4444);

  final List<Question> _questions = [
    Question(
      question: "پێغەمبەر ﷺ لە چ ساڵێکدا لەدایکبووە؟",
      options: ["٥٧٠ زایینی", "٥٧١ زایینی", "٥٧٢ زایینی", "٥٧٣ زایینی"],
      correctAnswerIndex: 1,
    ),
    Question(
      question: "سوورەتەکانی قورئانی پیرۆز چەند سوورەتن؟",
      options: ["١١٠ سوورەت", "١١٢ سوورەت", "١١٤ سوورەت", "١١٦ سوورەت"],
      correctAnswerIndex: 2,
    ),
    Question(
      question: "یەکەم کۆچکردنی موسڵمانان بۆ کوێ بوو؟",
      options: ["مەدینە", "حەبەشە", "یەمەن", "شام"],
      correctAnswerIndex: 1,
    ),
    Question(
      question: "درێژترین سوورەتی قورئانی پیرۆز کامەیە؟",
      options: ["ئال عیمران", "ئەلنییساء", "ئەلبەقەرە", "ئەلئەنعام"],
      correctAnswerIndex: 2,
    ),
    Question(
      question: "کێ بوو بە یەکەم خەلیفەی موسڵمانان؟",
      options: ["عومەری کوڕی خەتاب", "عوسمانی کوڕی عەفان", "عەلی کوڕی ئەبو تالیب", "ئەبوبەکری صدیق"],
      correctAnswerIndex: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupQuiz();
  }

  void _setupQuiz() {
    // Clone and shuffle questions
    _shuffledQuestions = List.from(_questions)..shuffle();
    
    // Shuffle options for each question
    for (var i = 0; i < _shuffledQuestions.length; i++) {
      final q = _shuffledQuestions[i];
      final correctOption = q.options[q.correctAnswerIndex];
      
      final shuffledOptions = List<String>.from(q.options)..shuffle();
      final newCorrectIndex = shuffledOptions.indexOf(correctOption);
      
      _shuffledQuestions[i] = Question(
        question: q.question,
        options: shuffledOptions,
        correctAnswerIndex: newCorrectIndex,
      );
    }
  }

  void _handleAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = index;
      if (index == _shuffledQuestions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      } else {
        _quizCompleted = true;
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _setupQuiz();
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? _deepSpace : Colors.white;
    final textColor = isDarkMode ? _starlight : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تاقیکردنەوەی زانیاری',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (isDarkMode) const Positioned.fill(child: _StarfieldBackground()),
          SafeArea(
            child: _quizCompleted
                ? _buildResultView(textColor, isDarkMode)
                : _buildQuizView(textColor, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(Color textColor, bool isDarkMode) {
    final question = _shuffledQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _shuffledQuestions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode ? _midnight : Colors.grey.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(_accent),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'امتیاز: $_score',
                style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
              ),
              Text(
                'پرسیار ${_currentQuestionIndex + 1} لە ${_shuffledQuestions.length}',
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? _midnight : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _accent.withOpacity(0.2), width: 1.5),
            ),
            child: Text(
              question.question,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 40),
          // Options
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildOptionButton(index, question, isDarkMode, textColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, Question question, bool isDarkMode, Color textColor) {
    bool isCorrect = index == question.correctAnswerIndex;
    bool isSelected = index == _selectedAnswerIndex;
    
    Color buttonColor = isDarkMode ? _midnight : const Color(0xFFF8FAFC);
    Color borderColor = isDarkMode ? _accent.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
    
    if (_isAnswered) {
      if (isCorrect) {
        buttonColor = _correct.withOpacity(0.15);
        borderColor = _correct;
      } else if (isSelected) {
        buttonColor = _wrong.withOpacity(0.15);
        borderColor = _wrong;
      }
    } else if (isSelected) {
      borderColor = _accent;
    }

    return GestureDetector(
      onTap: () => _handleAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                color: isSelected ? borderColor : Colors.transparent,
              ),
              child: Center(
                child: isSelected 
                  ? Icon(
                      isCorrect ? Icons.check : Icons.close, 
                      color: Colors.white, 
                      size: 18
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(Color textColor, bool isDarkMode) {
    double percentage = (_score / _shuffledQuestions.length) * 100;
    String message = percentage >= 80 ? "نایاب بوو! 🌟" : percentage >= 50 ? "باش بوو! 👍" : "هەوڵ بدەرەوە 📚";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDarkMode ? _midnight : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withOpacity(0.3), width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    message,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_score / ${_shuffledQuestions.length}',
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'نمرەکانت',
                    style: TextStyle(color: textColor.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _restartQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('دووبارە دەستپێکردنەوە', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'گەڕانەوە بۆ سەرەتا',
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Background Starfield ──────────────────────────────────────────────────────

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.45 + 0.1;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
