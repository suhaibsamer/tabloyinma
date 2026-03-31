import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/services/quran_metadata.dart';
import 'package:tabloy_iman/models/quran_verse.dart';
import 'package:tabloy_iman/screens/quran/quran_reading_screen.dart';
import 'dart:math' as math;

import '../../services/quran_audio_service.dart';

class HafizQuranScreen extends StatefulWidget {
  const HafizQuranScreen({super.key});

  @override
  State<HafizQuranScreen> createState() => _HafizQuranScreenState();
}

class _HafizQuranScreenState extends State<HafizQuranScreen> with TickerProviderStateMixin {
  final TextEditingController _yearsController = TextEditingController();
  final QuranService _quranService = QuranService();
  
  int _planYears = 0;
  List<Map<String, dynamic>> _generatedPlan = [];
  List<bool> _completedDays = [];
  bool _isLoading = true;
  bool _isDataLoaded = false;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFF6366F1);
  static const _accentDim = Color(0xFF4F46E5);
  static const _green     = Color(0xFF34D399);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _quranService.loadQuranData();
    _isDataLoaded = true;
    await _loadSavedPlan();
  }

  Future<void> _loadSavedPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final int savedYears = prefs.getInt('hifz_plan_years') ?? 0;
    
    if (savedYears > 0) {
      _planYears = savedYears;
      _generatedPlan = _calculatePlanLogic(savedYears);
      
      List<String>? completedStr = prefs.getStringList('hifz_plan_completed');
      if (completedStr != null && completedStr.length == _generatedPlan.length) {
        _completedDays = completedStr.map((e) => e == 'true').toList();
      } else {
        _completedDays = List.generate(_generatedPlan.length, (_) => false);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _calculatePlanLogic(int years) {
    final List<QuranVerse> allVerses = _quranService.flattenedVerses;
    final int totalVerses = allVerses.length; 
    final int totalDays = years * 365;
    
    final int revisionDaysCount = (totalDays / 7).floor();
    final int memorizationDaysCount = totalDays - revisionDaysCount;
    final double versesPerMemoDay = totalVerses / memorizationDaysCount;
    
    final List<Map<String, dynamic>> plan = [];
    int currentVerseIndex = 0;
    int memoDayCounter = 0;
    DateTime startDate = DateTime.now();

    for (int day = 1; day <= totalDays; day++) {
      DateTime currentDate = startDate.add(Duration(days: day - 1));
      bool isRevisionDay = (day % 7 == 0);
      
      if (isRevisionDay) {
        plan.add({
          "day_number": day,
          "date": currentDate,
          "type": "Revision",
          "task": "پێداچوونەوەی هەفتانە (مراجعة)",
          "subtitle": "هەموو ئەو ئایەتانەی لەم هەفتەیەدا خوێندراون",
        });
      } else {
        memoDayCounter++;
        int startIdx = currentVerseIndex;
        int endIdx = (memoDayCounter * versesPerMemoDay).floor();
        if (endIdx <= startIdx && startIdx < totalVerses) endIdx = startIdx + 1;
        if (day == totalDays || endIdx > totalVerses || memoDayCounter >= memorizationDaysCount) endIdx = totalVerses;
        
        if (startIdx < totalVerses) {
          final startV = allVerses[startIdx];
          final endV = allVerses[endIdx - 1];
          String surahStart = QuranMetadata.getSurahName(startV.chapter);
          String surahEnd = QuranMetadata.getSurahName(endV.chapter);
          
          String task = startV.chapter == endV.chapter 
              ? "$surahStart: ${startV.verse} بۆ ${endV.verse}"
              : "$surahStart(${startV.verse}) بۆ $surahEnd(${endV.verse})";

          plan.add({
            "day_number": day,
            "date": currentDate,
            "type": "Memorization",
            "task": task,
            "subtitle": "لەبەرکردنی ئایەتە نوێیەکان",
            "start_idx": startIdx,
            "end_idx": endIdx - 1,
          });
          currentVerseIndex = endIdx;
        } else {
          plan.add({
            "day_number": day,
            "date": currentDate,
            "type": "Completed",
            "task": "تەواوبوو",
            "subtitle": "پیرۆزە!",
          });
        }
      }
    }
    return plan;
  }

  Future<void> _startPlan() async {
    final int? years = int.tryParse(_yearsController.text);
    if (years == null || years <= 0 || years > 50) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hifz_plan_years', years);
    
    final plan = _calculatePlanLogic(years);
    final completed = List.generate(plan.length, (_) => false);
    await prefs.setStringList('hifz_plan_completed', completed.map((e) => e.toString()).toList());

    setState(() {
      _planYears = years;
      _generatedPlan = plan;
      _completedDays = completed;
    });
  }

  Future<void> _updateCompletion(int index, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _completedDays[index] = val);
    await prefs.setStringList('hifz_plan_completed', _completedDays.map((e) => e.toString()).toList());
  }

  Future<void> _clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hifz_plan_years');
    await prefs.remove('hifz_plan_completed');
    setState(() {
      _planYears = 0;
      _generatedPlan = [];
      _completedDays = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('حافزی قورئان', style: TextStyle(color: _starlight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _moonGlow),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: _accent))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      if (_planYears == 0) _buildSetupSection() else _buildActivePlanSection(),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _accent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Text('🕋', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 16),
          const Text('پلانی لەبەرکردنی قورئان', style: TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'لێرە دەتوانیت پلانی درێژخایەن بۆ لەبەرکردنی قورئانی پیرۆز دابنێیت',
            textAlign: TextAlign.center,
            style: TextStyle(color: _moonGlow.withOpacity(0.5), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _midnight, borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              const Text('ماوەی لەبەرکردن (بە ساڵ)', style: TextStyle(color: _moonGlow, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: _yearsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'نموونە: ٢',
                  hintStyle: TextStyle(color: _starlight.withOpacity(0.1)),
                  filled: true,
                  fillColor: _nebula,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _startPlan,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_accentDim, _accent]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Text('دەستپێکردنی پلان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlanSection() {
    int completedCount = _completedDays.where((e) => e).length;
    double progress = _generatedPlan.isEmpty ? 0 : completedCount / _generatedPlan.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _clearPlan,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('سڕینەوە', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('پلانی $_planYears ساڵە', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('$completedCount لە ${_generatedPlan.length} ڕۆژ', style: TextStyle(color: _moonGlow.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.05),
          color: _green,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 30),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _generatedPlan.length,
          itemBuilder: (context, index) {
            final item = _generatedPlan[index];
            final bool isDone = _completedDays[index];
            final bool isRev = item['type'] == 'Revision';
            
            return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDone ? _green.withOpacity(0.1) : _midnight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDone ? _green.withOpacity(0.3) : _accent.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _updateCompletion(index, !isDone),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: isDone ? _green : Colors.transparent,
                          border: Border.all(color: isDone ? _green : _starlight.withOpacity(0.2)),
                        ),
                        child: isDone ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['task'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item['type'] == 'Memorization') ...[
                                GestureDetector(
                                  onTap: () {
                                    final audioService = Provider.of<QuranAudioService>(context, listen: false);
                                    audioService.setHifzMode(true);
                                    audioService.setRange(item['start_idx'], item['end_idx']);
                                    
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReadingScreen(
                                      startGlobalIndex: item['start_idx'],
                                      endGlobalIndex: item['end_idx'],
                                      title: 'ڕۆژی ${item['day_number']}',
                                      isHifzMode: true,
                                    )));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('گوێگرتن', style: TextStyle(color: _green, fontSize: 10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<QuranAudioService>(context, listen: false).setHifzMode(false);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReadingScreen(
                                      startGlobalIndex: item['start_idx'],
                                      endGlobalIndex: item['end_idx'],
                                      title: 'ڕۆژی ${item['day_number']}',
                                    )));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('خوێندنەوە', style: TextStyle(color: _accent, fontSize: 10)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(DateFormat('yyyy/MM/dd').format(item['date']), style: TextStyle(color: _moonGlow.withOpacity(0.3), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
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
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), radius, paint);
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
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
    );
  }
}
