import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabloy_iman/models/prayer_times.dart';
import 'package:tabloy_iman/services/prayer_times_service.dart';
import 'package:tabloy_iman/utils/info_utils.dart';

import 'package:tabloy_iman/screens/prayer_guide/prayer_guide_screen.dart';
import 'package:tabloy_iman/screens/prayer_guide/prayer_detail_screen.dart';
import 'package:tabloy_iman/services/prayer_guide_service.dart';

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

  static const _bg = Color(0xFF070B14);
  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);
  static const _accent = Color(0xFF7C5CFF);
  static const _accent2 = Color(0xFF46C2FF);
  static const _success = Color(0xFF22C55E);

  String _to12Hour(String time24) {
    try {
      final parts = time24.trim().split(':');
      if (parts.length < 2) return time24;
      int hour = int.parse(parts[0]);
      final min = parts[1].padLeft(2, '0');
      final isAm = hour < 12;
      final period = isAm ? 'AM' : 'PM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
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
      final end = (start + 0.5).clamp(0.0, 1.0);
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
    } catch (_) {
      if (mounted) _showErrorSnackBar();
    } finally {
      if (mounted) setState(() => _isLoadingPrayerTimes = false);
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'هەڵەیەک ڕوویدا لە وەرگرتنی کاتەکانی بانگ',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF23172E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildPrayerData(List<String> times) => [
        {
          'key': 'fajr',
          'time': times[0],
          'icon': '🌅',
          'color': const Color(0xFFFF7A7A),
        },
        {
          'key': 'sunrise',
          'time': times[1],
          'icon': '🌄',
          'color': const Color(0xFFFFB35C),
        },
        {
          'key': 'dhuhr',
          'time': times[2],
          'icon': '☀️',
          'color': const Color(0xFFFFD76A),
        },
        {
          'key': 'asr',
          'time': times[3],
          'icon': '🌤',
          'color': const Color(0xFF5BC0FF),
        },
        {
          'key': 'maghrib',
          'time': times[4],
          'icon': '🌇',
          'color': const Color(0xFFFF6CA8),
        },
        {
          'key': 'isha',
          'time': times[5],
          'icon': '🌙',
          'color': const Color(0xFF9D7CFF),
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          const Positioned.fill(child: _ModernBackground()),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadPrayerTimes,
              color: _accent,
              backgroundColor: _surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 14),
                  _buildLocationCard(),
                  const SizedBox(height: 18),
                  if (_prayerTimes != null)
                    _NextPrayerCountdownModern(
                      prayerTimes: _prayerTimes!,
                      prayerData: _buildPrayerData(_prayerTimes!.times),
                      nextIndex: _nextPrayerIndex(_prayerTimes!.times),
                      to12Hour: _to12Hour,
                    ),
                  if (_prayerTimes != null) const SizedBox(height: 18),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  _buildBody(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        'کاتەکانی بانگ',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: const IconThemeData(color: _textPrimary),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => InfoUtils.showInfo(
              context,
              title: 'کاتەکانی بانگ',
              description: 'ئەم بەشە کاتەکانی پێنج فەرزی نوێژ نیشان دەدات بەپێی شوێنی جوگرافی تۆ.',
              howToUse: 'دەتوانیت کاتەکانی نوێژی ئەمڕۆ ببینی، هەروەها ئاگادارکەرەوە (بانگ) چالاک بکەیت بۆ هەر نوێژێک.',
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: _textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _loadPrayerTimes,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: _textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                _accent.withValues(alpha: 0.30),
                _accent2.withValues(alpha: 0.18),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'زانکۆی ڕۆژانەی بانگ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'کاتەکانت بە شێوازێکی نوێ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'کاتی بانگ، بانگی داهاتوو، و هەموو زانیارییە پێویستەکان لە دیزاینێکی مۆدێرن',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final cityName =
        PrayerNames.cityNames[_selectedCity.toLowerCase()] ?? _selectedCity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  _accent.withValues(alpha: 0.95),
                  _accent2.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شوێنی هەڵبژێردراو',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cityName,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _success.withValues(alpha: 0.30)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: _success, size: 8),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: _success,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: _accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'کاتەکانی ئەمڕۆ',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingPrayerTimes) return _buildSkeletonList();
    if (_prayerTimes != null) return _buildPrayerList();
    return _buildEmptyState();
  }

  Widget _buildSkeletonList() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, _) {
        return Column(
          children: List.generate(
            6,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 82,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  final v = (_shimmerController.value + i * 0.15) % 1.0;
                  return LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.03),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                    stops: [
                      (v - 0.3).clamp(0.0, 1.0),
                      v,
                      (v + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerList() {
    final prayerNames = PrayerNames.kurdish;
    final times = _prayerTimes!.times;
    final nextIndex = _nextPrayerIndex(times);
    final data = _buildPrayerData(times);

    return Column(
      children: List.generate(data.length, (index) {
        final prayer = data[index];
        final isNext = index == nextIndex;
        final name = prayerNames[prayer['key']]!;
        final time12 = _to12Hour(prayer['time'] as String);
        final timeParts = time12.split(' ');
        final timePart = timeParts[0];
        final periodPart = timeParts.length > 1 ? timeParts[1] : '';
        final color = prayer['color'] as Color;

        return AnimatedBuilder(
          animation: _cardAnimations[index],
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 22 * (1 - _cardAnimations[index].value)),
            child: Opacity(
              opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: _buildPrayerTile(
            context: context,
            prayerKey: prayer['key'] as String,
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

  Widget _buildPrayerTile({
    required BuildContext context,
    required String prayerKey,
    required String icon,
    required String name,
    required String timePart,
    required String periodPart,
    required Color color,
    required bool isNext,
  }) {
    final isFriday = DateTime.now().weekday == DateTime.friday;
    final isDhuhr = prayerKey == 'dhuhr';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isNext
              ? [
                  color.withValues(alpha: 0.14),
                  _surface2.withValues(alpha: 0.94),
                ]
              : [
                  _surface.withValues(alpha: 0.94),
                  _surface2.withValues(alpha: 0.88),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: isNext
              ? color.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: isNext ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isNext
                      ? color.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isNext
                        ? color.withValues(alpha: 0.30)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: isNext ? _textPrimary : _textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (isNext)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: color.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              'داهاتوو',
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isNext ? 'ئەو بانگەی دواتر دەبێت' : 'کاتی تۆمارکراو',
                      style: TextStyle(
                        color: _textSecondary.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timePart,
                    style: TextStyle(
                      color: isNext
                          ? _textPrimary
                          : _textPrimary.withValues(alpha: 0.92),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (periodPart.isNotEmpty)
                    Text(
                      periodPart,
                      style: TextStyle(
                        color:
                            isNext ? color : _textSecondary.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (isFriday && isDhuhr) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                await PrayerGuideService().init();
                final jumuah = PrayerGuideService().getPrayerById('jumuah');
                if (jumuah != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrayerDetailScreen(prayer: jumuah),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.auto_stories_rounded, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'چۆنێتی ئەنجامدانی نوێژی هەینی',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_left_rounded, color: color, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: _textSecondary.withValues(alpha: 0.4),
            size: 46,
          ),
          const SizedBox(height: 14),
          Text(
            'هیچ زانیارییەک بەردەست نییە',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadPrayerTimes,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [_accent, _accent2],
                ),
              ),
              child: const Text(
                'دووبارە هەوڵ بدەرەوە',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerCountdownModern extends StatefulWidget {
  const _NextPrayerCountdownModern({
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
  State<_NextPrayerCountdownModern> createState() =>
      _NextPrayerCountdownModernState();
}

class _NextPrayerCountdownModernState
    extends State<_NextPrayerCountdownModern> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  double _progress = 0.0;

  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);

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
    final nowSec = now.hour * 3600 + now.minute * 60 + now.second;

    final ni = widget.nextIndex < 0 ? 0 : widget.nextIndex;
    final nextSec = _toSec(widget.prayerData[ni]['time'] as String);

    int diff = nextSec - nowSec;
    if (diff <= 0) diff += 86400;

    final prevIdx =
        (ni - 1 + widget.prayerData.length) % widget.prayerData.length;
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
    final color = prayer['color'] as Color;
    final name = PrayerNames.kurdish[prayer['key']] ?? '';
    final time12 = widget.to12Hour(prayer['time'] as String);

    final hh = _pad(_remaining.inHours);
    final mm = _pad(_remaining.inMinutes.remainder(60));
    final ss = _pad(_remaining.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            _surface2.withValues(alpha: 0.92),
            _surface.withValues(alpha: 0.92),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Center(
                  child: Text(
                    prayer['icon'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بانگی داهاتوو',
                      style: TextStyle(
                        color: _textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'کاتی بانگ',
                    style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time12,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeBox(value: hh, label: 'کاتژمێر', color: color),
              _TimeSep(color: color),
              _TimeBox(value: mm, label: 'خولەک', color: color),
              _TimeSep(color: color),
              _TimeBox(value: ss, label: 'چرکە', color: color),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor:
                  AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimeSep extends StatelessWidget {
  const _TimeSep({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
      child: Text(
        ':',
        style: TextStyle(
          color: color.withValues(alpha: 0.65),
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ModernBackground extends StatelessWidget {
  const _ModernBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF070B14),
                Color(0xFF0D1324),
              ],
            ),
          ),
        ),
        const Positioned.fill(child: _StarfieldBackground()),
        Positioned(
          top: -80,
          right: -40,
          child: _GlowBlob(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.18),
            size: 220,
          ),
        ),
        Positioned(
          top: 120,
          left: -50,
          child: _GlowBlob(
            color: const Color(0xFF46C2FF).withValues(alpha: 0.14),
            size: 200,
          ),
        ),
      ],
    );
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(85, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.3 + 0.3;
      final opacity = rng.nextDouble() * 0.45 + 0.08;
      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
