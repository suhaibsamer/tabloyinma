import 'package:flutter/material.dart';
import '../../services/progress_service.dart';

class DailyProgressScreen extends StatefulWidget {
  const DailyProgressScreen({super.key});

  @override
  State<DailyProgressScreen> createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  final ProgressService _progressService = ProgressService();

  final Map<String, int> _fardPrayers = {
    'fajr': 0,
    'dhuhr': 0,
    'asr': 0,
    'maghrib': 0,
    'isha': 0,
  };

  final Map<String, int> _sunnahPrayers = {
    'sunnah_fajr': 0,
    'sunnah_dhuhr_before': 0,
    'sunnah_dhuhr_after': 0,
    'sunnah_maghrib': 0,
    'sunnah_isha': 0,
    'witr': 0,
    'duha': 0,
  };

  int _zikrCount = 0;
  bool _isLoading = true;

  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _gold = Color(0xFFFFD97D);
  static const _green = Color(0xFF34D399);
  static const _blue = Color(0xFF60A5FA);

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prayers = await _progressService.getDailyPrayers();
    final zikr = await _progressService.getZikrCount('daily_zikr');

    setState(() {
      for (final key in _fardPrayers.keys) {
        _fardPrayers[key] = prayers[key] ?? 0;
      }

      for (final key in _sunnahPrayers.keys) {
        _sunnahPrayers[key] = prayers[key] ?? 0;
      }

      _zikrCount = zikr;
      _isLoading = false;
    });
  }

  Future<void> _togglePrayer(String prayerKey, int currentStatus) async {
    final newStatus = currentStatus == 1 ? 0 : 1;
    await _progressService.togglePrayer(prayerKey, newStatus == 1);
    await _loadProgress();
  }

  Future<void> _incrementZikr() async {
    final newCount = _zikrCount + 1;
    await _progressService.updateZikrCount('daily_zikr', newCount);
    await _loadProgress();
  }

  Future<void> _resetZikr() async {
    await _progressService.updateZikrCount('daily_zikr', 0);
    await _loadProgress();
  }

  int get _completedFard => _fardPrayers.values.where((v) => v == 1).length;
  int get _completedSunnah => _sunnahPrayers.values.where((v) => v == 1).length;
  int get _totalCompleted => _completedFard + _completedSunnah;
  int get _totalPrayers => _fardPrayers.length + _sunnahPrayers.length;
  double get _percentage => _totalCompleted / _totalPrayers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'بەرەوپێشچوونی ڕۆژانە',
          style: TextStyle(
            color: _starlight,
            fontWeight: FontWeight.bold,
          ),
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
            ? const Center(
          child: CircularProgressIndicator(color: _accent),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressSummary(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 30),

              _buildSectionTitle('نوێژە فەرزەکان'),
              const SizedBox(height: 16),
              _buildPrayerCard('نوێژی بەیانی', 'fajr', _fardPrayers['fajr']!, icon: Icons.wb_twilight_outlined),
              _buildPrayerCard('نوێژی نێوەڕۆ', 'dhuhr', _fardPrayers['dhuhr']!, icon: Icons.light_mode_outlined),
              _buildPrayerCard('نوێژی عەسر', 'asr', _fardPrayers['asr']!, icon: Icons.wb_sunny_outlined),
              _buildPrayerCard('نوێژی شێوان', 'maghrib', _fardPrayers['maghrib']!, icon: Icons.nightlight_round),
              _buildPrayerCard('نوێژی خەوتنان', 'isha', _fardPrayers['isha']!, icon: Icons.dark_mode_outlined),

              const SizedBox(height: 30),
              _buildSectionTitle('نوێژە سوننەتەکان'),
              const SizedBox(height: 16),
              _buildPrayerCard('سوننەتی بەیانی', 'sunnah_fajr', _sunnahPrayers['sunnah_fajr']!, icon: Icons.star_border_rounded, accentColor: _gold),
              _buildPrayerCard('سوننەتی پێش نێوەڕۆ', 'sunnah_dhuhr_before', _sunnahPrayers['sunnah_dhuhr_before']!, icon: Icons.star_border_rounded, accentColor: _gold),
              _buildPrayerCard('سوننەتی دوای نێوەڕۆ', 'sunnah_dhuhr_after', _sunnahPrayers['sunnah_dhuhr_after']!, icon: Icons.star_border_rounded, accentColor: _gold),
              _buildPrayerCard('سوننەتی دوای شێوان', 'sunnah_maghrib', _sunnahPrayers['sunnah_maghrib']!, icon: Icons.star_border_rounded, accentColor: _gold),
              _buildPrayerCard('سوننەتی دوای خەوتنان', 'sunnah_isha', _sunnahPrayers['sunnah_isha']!, icon: Icons.star_border_rounded, accentColor: _gold),
              _buildPrayerCard('ویتر', 'witr', _sunnahPrayers['witr']!, icon: Icons.auto_awesome_outlined, accentColor: _green),
              _buildPrayerCard('دوحا', 'duha', _sunnahPrayers['duha']!, icon: Icons.wb_sunny_rounded, accentColor: _blue),

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ئاستی ئەنجامدان',
                  style: TextStyle(
                    color: _starlight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${(_percentage * 100).toInt()}%',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _percentage,
              backgroundColor: _midnight,
              color: _accent,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_totalCompleted لە $_totalPrayers نوێژ ئەنجامدراوە',
            style: TextStyle(
              color: _moonGlow.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            title: 'فەرز',
            value: '$_completedFard / ${_fardPrayers.length}',
            color: _accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStatCard(
            title: 'سوننەت',
            value: '$_completedSunnah / ${_sunnahPrayers.length}',
            color: _gold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStatCard(
            title: 'زیکر',
            value: '$_zikrCount',
            color: _green,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _starlight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: _starlight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPrayerCard(
      String label,
      String key,
      int currentStatus, {
        IconData? icon,
        Color accentColor = _accent,
      }) {
    final isCompleted = currentStatus == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? accentColor.withOpacity(0.45)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Icon(
          isCompleted
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isCompleted ? accentColor : _starlight.withOpacity(0.28),
          size: 28,
        ),
        title: Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isCompleted ? _starlight : _starlight.withOpacity(0.68),
            fontSize: 17,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: accentColor.withOpacity(0.9), size: 22)
            : null,
        onTap: () => _togglePrayer(key, currentStatus),
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
            style: TextStyle(
              color: _starlight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                  BoxShadow(
                    color: _gold.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _zikrCount.toString(),
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _resetZikr,
            icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20),
            label: const Text(
              'سفرکردنەوە',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'بۆ زیادکردن پەنجە بنێ بە بازنەکەدا',
            style: TextStyle(
              color: _moonGlow.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}