import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabloy_iman/models/prayer_times.dart';
import 'package:tabloy_iman/services/prayer_times_service.dart';
import 'dart:async';
import 'dart:math' as math;

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage>
    with TickerProviderStateMixin {
  PrayerTimes? _prayerTimes;
  bool _isLoadingPrayerTimes = false;
  String _selectedCity = '';
  late AnimationController _shimmerController;
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);

  String _to12Hour(String time24) {
    try {
      final parts = time24.trim().split(':');
      if (parts.length < 2) return time24;
      int hour     = int.parse(parts[0]);
      final min    = parts[1].padLeft(2, '0');
      final isAm   = hour < 12;
      final period = isAm ? 'AM' : 'PM';
      if (hour == 0)      hour = 12;
      else if (hour > 12) hour -= 12;
      return '$hour:$min $period';
    } catch (_) {
      return time24;
    }
  }

  int _nextPrayerIndex(List<String> times) {
    final now = TimeOfDay.now();
    for (int i = 0; i < times.length; i++) {
      try {
        final parts = times[i].trim().split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        if (h > now.hour || (h == now.hour && m > now.minute)) return i;
      } catch (_) {}
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardAnimations = List.generate(6, (i) {
      final start = (i * 0.1).clamp(0.0, 0.5);
      final end   = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() => _isLoadingPrayerTimes = true);
    _staggerController.reset();
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedCity = prefs.getString('selectedCity') ?? 'erbil';
      final data = await PrayerTimesService.getTodayPrayerTimes();
      if (data != null && mounted) {
        setState(() => _prayerTimes = data);
        _staggerController.forward();
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar();
    } finally {
      if (mounted) setState(() => _isLoadingPrayerTimes = false);
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('هەڵەیەک ڕوویدا لە دابەزاندنی کاتەکانی بانگ',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF1E1033),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.red.shade700.withOpacity(0.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Positioned(
            top: -80, left: -60,
            child: _GlowBlob(color: _accentDim.withOpacity(0.15), size: 280),
          ),
          Positioned(
            top: 120, right: -40,
            child: _GlowBlob(
                color: const Color(0xFF1A6B8A).withOpacity(0.12), size: 200),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadPrayerTimes,
              color: _accent,
              backgroundColor: _nebula,
              displacement: 60,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4),
                    _buildLocationBadge(),
                    const SizedBox(height: 16),
                    // ── Countdown widget ──────────────────────────────────
                    if (_prayerTimes != null)
                      _NextPrayerCountdown(
                        prayerTimes: _prayerTimes!,
                        prayerData: _buildPrayerData(_prayerTimes!.times),
                        nextIndex: _nextPrayerIndex(_prayerTimes!.times),
                        to12Hour: _to12Hour,
                      ),
                    if (_prayerTimes != null) const SizedBox(height: 20),
                    // ─────────────────────────────────────────────────────
                    _buildSectionLabel('کاتەکانی بانگی ئەمڕۆ'),
                    const SizedBox(height: 12),
                    _buildBody(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildPrayerData(List<String> times) => [
    {'key': 'fajr',    'time': times[0], 'icon': '🌅', 'color': const Color(0xFFFF6B6B)},
    {'key': 'sunrise', 'time': times[1], 'icon': '🌄', 'color': const Color(0xFFFFA551)},
    {'key': 'dhuhr',   'time': times[2], 'icon': '☀️', 'color': const Color(0xFFFFD97D)},
    {'key': 'asr',     'time': times[3], 'icon': '🌤', 'color': const Color(0xFF56CCF2)},
    {'key': 'maghrib', 'time': times[4], 'icon': '🌇', 'color': const Color(0xFFFF6B9D)},
    {'key': 'isha',    'time': times[5], 'icon': '🌙', 'color': const Color(0xFFB08AFF)},
  ];

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'کاتەکانی بانگ',
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _starlight,
            letterSpacing: 0.3),
      ),
      iconTheme: const IconThemeData(color: _moonGlow),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _loadPrayerTimes,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _nebula,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withOpacity(0.22)),
              ),
              child: Icon(Icons.refresh_rounded, color: _accent, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBadge() {
    final cityName =
        PrayerNames.cityNames[_selectedCity.toLowerCase()] ?? _selectedCity;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.18)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _accentDim.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _accent.withOpacity(0.25)),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: _accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('شار',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: _moonGlow.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2)),
                const SizedBox(height: 3),
                Text(cityName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        color: _starlight,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2B1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                const Text('LIVE',
                    style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                color: _moonGlow.withOpacity(0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6)),
        const SizedBox(width: 8),
        Container(
          width: 4, height: 4,
          decoration: BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _accent, blurRadius: 5)]),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingPrayerTimes) return _buildSkeletonList();
    if (_prayerTimes != null)  return _buildPrayerList();
    return _buildEmptyState();
  }

  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) => Column(
        children: List.generate(6, (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 64,
          decoration: BoxDecoration(
            color: _midnight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              final v = (_shimmerController.value + i * 0.15) % 1.0;
              return LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.03),
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0.03),
                ],
                stops: [(v - 0.3).clamp(0.0, 1.0), v, (v + 0.3).clamp(0.0, 1.0)],
              ).createShader(bounds);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16))),
          ),
        )),
      ),
    );
  }

  Widget _buildPrayerList() {
    final prayerNames = PrayerNames.kurdish;
    final times       = _prayerTimes!.times;
    final nextIndex   = _nextPrayerIndex(times);
    final data        = _buildPrayerData(times);

    return Column(
      children: List.generate(data.length, (index) {
        final prayer     = data[index];
        final isNext     = index == nextIndex;
        final name       = prayerNames[prayer['key']]!;
        final time12     = _to12Hour(prayer['time'] as String);
        final timeParts  = time12.split(' ');
        final timePart   = timeParts[0];
        final periodPart = timeParts.length > 1 ? timeParts[1] : '';
        final color      = prayer['color'] as Color;

        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - _cardAnimations[index].value)),
            child: Opacity(
                opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                child: child),
          ),
          child: _buildPrayerRow(
            icon: prayer['icon'] as String,
            name: name,
            timePart: timePart,
            periodPart: periodPart,
            color: color,
            isNext: isNext,
          ),
        );
      }),
    );
  }

  Widget _buildPrayerRow({
    required String icon,
    required String name,
    required String timePart,
    required String periodPart,
    required Color color,
    required bool isNext,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isNext ? color.withOpacity(0.07) : _midnight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? color.withOpacity(0.45) : _accent.withOpacity(0.12),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isNext)
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(16)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isNext ? color.withOpacity(0.12) : _nebula,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNext
                          ? color.withOpacity(0.3)
                          : _accent.withOpacity(0.1),
                    ),
                  ),
                  child: Center(child: Text(icon,
                      style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Text(name,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: isNext
                            ? _starlight
                            : _moonGlow.withOpacity(0.65),
                        fontSize: 15,
                        fontWeight: isNext
                            ? FontWeight.w700
                            : FontWeight.w500)),
                const Spacer(),
                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isNext) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text('دواتر',
                            style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timePart,
                            style: TextStyle(
                                color: isNext ? _starlight : _moonGlow,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4)),
                        if (periodPart.isNotEmpty)
                          Text(periodPart,
                              style: TextStyle(
                                  color: isNext
                                      ? color.withOpacity(0.8)
                                      : _moonGlow.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nights_stay_rounded,
              color: _accent.withOpacity(0.25), size: 48),
          const SizedBox(height: 16),
          Text('هیچ زانیارییەک نییە',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: _moonGlow.withOpacity(0.35),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadPrayerTimes,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _nebula,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: Text('دووبارە هەوڵ بدەرەوە',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next Prayer Countdown Widget ─────────────────────────────────────────────

class _NextPrayerCountdown extends StatefulWidget {
  const _NextPrayerCountdown({
    required this.prayerTimes,
    required this.prayerData,
    required this.nextIndex,
    required this.to12Hour,
  });

  final PrayerTimes prayerTimes;
  final List<Map<String, dynamic>> prayerData;
  final int nextIndex;
  final String Function(String) to12Hour;

  @override
  State<_NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends State<_NextPrayerCountdown> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  double _progress = 0.0;

  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);

  @override
  void initState() {
    super.initState();
    _compute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _compute();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Parses "HH:mm" → total seconds from midnight
  int _toSec(String t) {
    try {
      final p = t.trim().split(':');
      return int.parse(p[0]) * 3600 + int.parse(p[1]) * 60;
    } catch (_) {
      return 0;
    }
  }

  void _compute() {
    final now = DateTime.now();
    final nowSec =
        now.hour * 3600 + now.minute * 60 + now.second;

    final ni = widget.nextIndex < 0 ? 0 : widget.nextIndex;
    final nextSec = _toSec(widget.prayerData[ni]['time'] as String);

    // seconds until next prayer (wrap to next day if needed)
    int diff = nextSec - nowSec;
    if (diff <= 0) diff += 86400;

    // previous prayer for progress bar
    final prevIdx = (ni - 1 + widget.prayerData.length) %
        widget.prayerData.length;
    int prevSec = _toSec(widget.prayerData[prevIdx]['time'] as String);
    int span = nextSec - prevSec;
    if (span <= 0) span += 86400;
    int elapsed = span - diff;

    setState(() {
      _remaining = Duration(seconds: diff);
      _progress = (elapsed / span).clamp(0.0, 1.0);
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final ni = widget.nextIndex < 0 ? 0 : widget.nextIndex;
    final prayer = widget.prayerData[ni];
    final color  = prayer['color'] as Color;
    final name   = PrayerNames.kurdish[prayer['key']] ?? '';
    final time12 = widget.to12Hour(prayer['time'] as String);

    final hh = _pad(_remaining.inHours);
    final mm = _pad(_remaining.inMinutes.remainder(60));
    final ss = _pad(_remaining.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Top row: icon + name + time ──────────────────────────────
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // Icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Center(
                    child: Text(prayer['icon'] as String,
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              // Name + label
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('بانگی داهاتوو',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          color: _moonGlow.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 3),
                  Text(name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                          color: _starlight,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const Spacer(),
              // Prayer time badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('کاتی بانگ',
                      style: TextStyle(
                          color: _moonGlow.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 3),
                  Text(time12,
                      style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Countdown segments ───────────────────────────────────────
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Segment(value: hh, label: 'کاتژمێر', color: color),
              _SegSep(color: color),
              _Segment(value: mm, label: 'خولەک',   color: color),
              _SegSep(color: color),
              _Segment(value: ss, label: 'چرکە',    color: color),
            ],
          ),

          const SizedBox(height: 16),

          // ── Progress bar ─────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: _nebula,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        color.withOpacity(0.7)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Segment box ───────────────────────────────────────────────────────────────

class _Segment extends StatelessWidget {
  const _Segment(
      {required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  static const _nebula   = Color(0xFF131829);
  static const _moonGlow = Color(0xFFE8E2FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _nebula,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: _moonGlow.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SegSep extends StatelessWidget {
  const _SegSep({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
      child: Text(':',
          style: TextStyle(
              color: color.withOpacity(0.5),
              fontSize: 22,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Starfield background ─────────────────────────────────────────────────────

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
      final rng    = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opac   = rng.nextDouble() * 0.45 + 0.08;
      paint.color  = Colors.white.withOpacity(opac);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Glow blob ────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}