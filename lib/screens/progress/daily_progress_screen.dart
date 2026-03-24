import 'package:flutter/material.dart';
import '../../services/progress_service.dart';

class DailyProgressScreen extends StatefulWidget {
  const DailyProgressScreen({super.key});

  @override
  State<DailyProgressScreen> createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  final ProgressService _progressService = ProgressService();
  Map<String, int> _prayers = {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0};
  int _zikrCount = 0;
  bool _isLoading = true;

  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _gold = Color(0xFFFFD97D);

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prayers = await _progressService.getDailyPrayers();
    final zikr = await _progressService.getZikrCount('daily_zikr');
    setState(() {
      _prayers = prayers;
      _zikrCount = zikr;
      _isLoading = false;
    });
  }

  Future<void> _togglePrayer(String prayer, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    await _progressService.togglePrayer(prayer, newStatus == 1);
    _loadProgress();
  }

  Future<void> _incrementZikr() async {
    final newCount = _zikrCount + 1;
    await _progressService.updateZikrCount('daily_zikr', newCount);
    _loadProgress();
  }

  Future<void> _resetZikr() async {
    await _progressService.updateZikrCount('daily_zikr', 0);
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'بەرەوپێشچوونی ڕۆژانە',
          style: TextStyle(color: _starlight, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _starlight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_deepSpace, _midnight],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgressSummary(),
                    const SizedBox(height: 30),
                    _buildSectionTitle('نوێژەکان'),
                    const SizedBox(height: 16),
                    _buildPrayerCard('بەیانی', 'fajr'),
                    _buildPrayerCard('نێوەڕۆ', 'dhuhr'),
                    _buildPrayerCard('عەسر', 'asr'),
                    _buildPrayerCard('شێوان', 'maghrib'),
                    _buildPrayerCard('خەوتنان', 'isha'),
                    const SizedBox(height: 30),
                    _buildSectionTitle('زیکرەکان'),
                    const SizedBox(height: 16),
                    _buildZikrCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    int completedPrayers = _prayers.values.where((v) => v == 1).length;
    double percentage = (completedPrayers / 5);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ئاستی ئەنجامدان',
                style: TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(color: _accent, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: _midnight,
              color: _accent,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completedPrayers لە ٥ نوێژ ئەنجامدراوە',
            style: TextStyle(color: _moonGlow.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: _starlight, fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildPrayerCard(String label, String key) {
    bool isCompleted = _prayers[key] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? _accent.withOpacity(0.4) : Colors.transparent),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          label,
          style: TextStyle(
            color: isCompleted ? _starlight : _starlight.withOpacity(0.6),
            fontSize: 18,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.right,
        ),
        leading: Icon(
          isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isCompleted ? _accent : _starlight.withOpacity(0.3),
          size: 28,
        ),
        onTap: () => _togglePrayer(key, _prayers[key]!),
      ),
    );
  }

  Widget _buildZikrCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'زیکری گشتی',
            style: TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _incrementZikr,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _gold, width: 4),
                boxShadow: [
                  BoxShadow(color: _gold.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Center(
                child: Text(
                  _zikrCount.toString(),
                  style: const TextStyle(color: _gold, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _resetZikr,
                icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20),
                label: const Text('سفرکردنەوە', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'بۆ زیادکردن پەنجە بنێ بە بازنەکەدا',
            style: TextStyle(color: _moonGlow.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
