import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabloy_iman/screens/quran/quran_reading_screen.dart';
import 'package:provider/provider.dart';
import 'package:tabloy_iman/services/quran_audio_service.dart';
import 'package:tabloy_iman/services/quran_metadata.dart';
import 'dart:math' as math;

class QuranCompletionScreen extends StatefulWidget {
  const QuranCompletionScreen({super.key});

  @override
  State<QuranCompletionScreen> createState() => _QuranCompletionScreenState();
}

class _QuranCompletionScreenState extends State<QuranCompletionScreen> {
  final TextEditingController _daysController = TextEditingController();
  final int _totalVerses = 6236;
  final int _totalPages = 604;
  
  double _versesPerDay = 0;
  double _pagesPerDay = 0;
  bool _calculated = false;

  int _planDays = 0;
  List<bool> _completedDays = [];
  bool _isLoading = true;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);
  static const _green     = Color(0xFF34D399);

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _planDays = prefs.getInt('quran_plan_days') ?? 0;
        List<String>? completedStr = prefs.getStringList('quran_plan_completed');
        if (completedStr != null && completedStr.length == _planDays) {
          _completedDays = completedStr.map((e) => e == 'true').toList();
        } else {
          _completedDays = List.generate(_planDays, (_) => false);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _savePlan(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_plan_days', days);
    
    final newCompletedDays = List.generate(days, (_) => false);
    await prefs.setStringList('quran_plan_completed', newCompletedDays.map((e) => e.toString()).toList());
    
    if (mounted) {
      setState(() {
        _planDays = days;
        _completedDays = newCompletedDays;
      });
    }
  }

  Future<void> _updateDayCompletion(int index, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _completedDays[index] = isCompleted;
      });
    }
    await prefs.setStringList('quran_plan_completed', _completedDays.map((e) => e.toString()).toList());
  }
  
  Future<void> _clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_plan_days');
    await prefs.remove('quran_plan_completed');
    if (mounted) {
      setState(() {
        _planDays = 0;
        _completedDays = [];
        _daysController.clear();
        _calculated = false;
      });
    }
  }

  void _calculate() {
    final days = int.tryParse(_daysController.text);
    if (days != null && days > 0) {
      setState(() {
        _versesPerDay = _totalVerses / days;
        _pagesPerDay = _totalPages / days;
        _calculated = true;
      });
    } else {
      setState(() {
        _calculated = false;
      });
    }
  }

  // --- Page Logic ---
  int _getStartPage(int dayIndex) {
    int basePages = _totalPages ~/ _planDays;
    int remainder = _totalPages % _planDays;
    int start = 1;
    for (int i = 0; i < dayIndex; i++) {
      start += basePages + (i < remainder ? 1 : 0);
    }
    return start;
  }

  int _getEndPage(int dayIndex) {
    int basePages = _totalPages ~/ _planDays;
    int remainder = _totalPages % _planDays;
    int start = _getStartPage(dayIndex);
    int pagesForThisDay = basePages + (dayIndex < remainder ? 1 : 0);
    return start + pagesForThisDay - 1;
  }

  // --- Verse Logic (Global Indices) ---
  int _getStartVerse(int dayIndex) {
    int baseVerses = _totalVerses ~/ _planDays;
    int remainder = _totalVerses % _planDays;
    int start = 0;
    for (int i = 0; i < dayIndex; i++) {
      start += baseVerses + (i < remainder ? 1 : 0);
    }
    return start;
  }

  int _getEndVerse(int dayIndex) {
    int baseVerses = _totalVerses ~/ _planDays;
    int remainder = _totalVerses % _planDays;
    int start = _getStartVerse(dayIndex);
    int versesForThisDay = baseVerses + (dayIndex < remainder ? 1 : 0);
    return start + versesForThisDay - 1;
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _midnight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _accent.withOpacity(0.3))),
        title: const Text('سڕینەوەی پلان',
            textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'دڵنیایت دەتەوێت ئەم پلانە بسڕیتەوە و سەرلەنوێ دەست پێ بکەیتەوە؟',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white70)),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('نەخێر', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearPlan();
            },
            child: const Text('بەڵێ، بسڕەوە',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'خەتمەکردنی قورئان',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _starlight,
          ),
        ),
        iconTheme: const IconThemeData(color: _moonGlow),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Positioned(
            top: -60,
            right: -80,
            child: _GlowBlob(color: _accentDim.withOpacity(0.16), size: 260),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        if (_planDays > 0)
                          _buildActivePlanSection()
                        else
                          _buildSetupSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final audioService = Provider.of<QuranAudioService>(context);
    final isPlayingKhatm = audioService.player.playing && !audioService.isHifzMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withOpacity(0.18), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent.withOpacity(0.3), width: 1),
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 16),
              // Play/Resume Button
              GestureDetector(
                onTap: () {
                  if (isPlayingKhatm) {
                    audioService.stop();
                  } else {
                    audioService.resumeKhatm();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPlayingKhatm ? Colors.red.withOpacity(0.1) : _green.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: isPlayingKhatm ? Colors.red.withOpacity(0.3) : _green.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isPlayingKhatm ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: isPlayingKhatm ? Colors.red : _green,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'پلانی خەتمەکردنی قورئان',
            style: TextStyle(
              color: _starlight,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (audioService.currentVerse != null && !audioService.isHifzMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'خوێندنەوەی ئێستا: ${QuranMetadata.getSurahName(audioService.currentVerse!.chapter)} (${audioService.currentVerse!.verse})',
                style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          Text(
            'لێرە دەتوانیت پلانی خەتمکردنی قورئانی پیرۆز دابنێیت و چاودێری بەرەوپێشچوونەکانت بکەیت',
            style: TextStyle(
              color: _moonGlow.withOpacity(0.5),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupSection() {
    return Column(
      children: [
        _buildInputSection(),
        const SizedBox(height: 30),
        if (_calculated) ...[
          _buildResultSection(),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              int days = int.tryParse(_daysController.text) ?? 0;
              if (days > 0) _savePlan(days);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_accentDim, _accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text(
                  'دەستپێکردنی پلان',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withOpacity(0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'ماوەی خەتمکردن (بە ڕۆژ)',
            style: TextStyle(
              color: _moonGlow,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.bold),
            onChanged: (value) => _calculate(),
            decoration: InputDecoration(
              hintText: 'نموونە: ٣٠',
              hintStyle: TextStyle(color: _moonGlow.withOpacity(0.2)),
              filled: true,
              fillColor: _nebula,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: _accent.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: _accent.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        _buildResultCard(
          title: 'ئایەت لە ڕۆژێکدا',
          value: _versesPerDay.toStringAsFixed(1),
          icon: '🔢',
          color: const Color(0xFF34D399),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          title: 'لاپەڕە لە ڕۆژێکدا',
          value: _pagesPerDay.toStringAsFixed(1),
          icon: '📄',
          color: const Color(0xFF60A5FA),
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          title: 'خوێندنەوەی هەر پێنج نوێژەکە',
          value: (_pagesPerDay / 5).toStringAsFixed(1),
          subtitle: 'لاپەڕە دوای هەر نوێژێک',
          icon: '🕌',
          color: const Color(0xFFFBBF24),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _moonGlow.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: _starlight,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _moonGlow.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanSection() {
    int completedCount = _completedDays.where((e) => e).length;
    double progress = _planDays > 0 ? completedCount / _planDays : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showClearDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: const Text('سڕینەوەی پلان', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'پلانی $_planDays ڕۆژە',
                  style: const TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.w800),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  'تەواوبووە: $completedCount لە $_planDays',
                  style: TextStyle(color: _moonGlow.withOpacity(0.6), fontSize: 13),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Progress Bar
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _midnight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: _green.withOpacity(0.5), blurRadius: 6)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        
        const Text(
          'خشتەی ڕۆژانە',
          style: TextStyle(color: _starlight, fontSize: 16, fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _planDays,
          itemBuilder: (context, index) {
            return _buildDayCard(index);
          },
        ),
      ],
    );
  }

  Widget _buildDayCard(int index) {
    bool isCompleted = _completedDays[index];
    int startPage = _getStartPage(index);
    int endPage = _getEndPage(index);
    int startVerse = _getStartVerse(index);
    int endVerse = _getEndVerse(index);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? _green.withOpacity(0.12) : _midnight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? _green.withOpacity(0.5) : _accent.withOpacity(0.2), 
          width: 1
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _updateDayCompletion(index, !isCompleted),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? _green : Colors.transparent,
                border: Border.all(color: isCompleted ? _green : _moonGlow.withOpacity(0.3), width: 2),
              ),
              child: isCompleted 
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Info & Read Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        'ڕۆژی ${index + 1}',
                        style: TextStyle(
                          color: isCompleted ? _green : _starlight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Read Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranReadingScreen(
                              startGlobalIndex: startVerse,
                              endGlobalIndex: endVerse,
                              title: 'ڕۆژی ${index + 1}',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _accent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('خوێندنەوە', style: TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.menu_book_rounded, color: _accent, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'لاپەڕە $startPage بۆ $endPage',
                  style: TextStyle(
                    color: _moonGlow.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
