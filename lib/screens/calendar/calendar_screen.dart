import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../utils/info_utils.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late HijriCalendar _hijriDate;

  static const _bg = Color(0xFF070B14);
  static const _surface = Color(0xFF111827);
  static const _surface2 = Color(0xFF172033);
  static const _border = Color(0xFF25324A);

  static const _text = Color(0xFFF8FAFC);
  static const _muted = Color(0xFF94A3B8);
  static const _faint = Color(0xFF64748B);

  static const _primary = Color(0xFF8B5CF6);
  static const _primary2 = Color(0xFF6D28D9);
  static const _gold = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF38BDF8);
  static const _red = Color(0xFFFB7185);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _hijriDate = HijriCalendar.fromDate(_selectedDate);
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _hijriDate = HijriCalendar.fromDate(date);
    });
  }

  String _getKurdishHijriMonthName(int month) {
    const months = {
      1: 'مۆحەڕەم',
      2: 'سەفەر',
      3: 'ڕەبیعولئەووەڵ',
      4: 'ڕەبیعولسانی',
      5: 'جومادەلئەووەڵ',
      6: 'جومادەلسانی',
      7: 'ڕەجەب',
      8: 'شەعبان',
      9: 'ڕەمەزان',
      10: 'شەووال',
      11: 'زیلقەعدە',
      12: 'زیلحەججە',
    };
    return months[month] ?? '';
  }

  String _getKurdishGregorianMonthName(int month) {
    const months = {
      1: 'کانوونی دووەم',
      2: 'شوبات',
      3: 'ئازار',
      4: 'نیسان',
      5: 'ئایار',
      6: 'حوزەیران',
      7: 'تەممووز',
      8: 'ئاب',
      9: 'ئەیلوول',
      10: 'تشرینی یەکەم',
      11: 'تشرینی دووەم',
      12: 'کانوونی یەکەم',
    };
    return months[month] ?? '';
  }

  List<_OccasionDefinition> _occasionDefinitions() {
    return [
      _OccasionDefinition(
        title: 'سەری ساڵی کۆچی',
        hijriMonth: 1,
        hijriDay: 1,
        icon: '🗓️',
        color: _blue,
      ),
      _OccasionDefinition(
        title: 'عاشوورا',
        hijriMonth: 1,
        hijriDay: 10,
        icon: '🕌',
        color: _gold,
      ),
      _OccasionDefinition(
        title: 'مەولوودی پێغەمبەر (د.خ)',
        hijriMonth: 3,
        hijriDay: 12,
        icon: '✨',
        color: _gold,
      ),
      _OccasionDefinition(
        title: 'شەوی میعراج',
        hijriMonth: 7,
        hijriDay: 27,
        icon: '🌌',
        color: _primary,
      ),
      _OccasionDefinition(
        title: 'نیوەی شەعبان',
        hijriMonth: 8,
        hijriDay: 15,
        icon: '🌕',
        color: _green,
      ),
      _OccasionDefinition(
        title: 'سەرەتای مانگی ڕەمەزان',
        hijriMonth: 9,
        hijriDay: 1,
        icon: '🌙',
        color: _primary,
      ),
      _OccasionDefinition(
        title: 'شەوی قەدر',
        hijriMonth: 9,
        hijriDay: 27,
        icon: '🤲',
        color: _gold,
      ),
      _OccasionDefinition(
        title: 'جەژنی ڕەمەزان',
        hijriMonth: 10,
        hijriDay: 1,
        icon: '🎉',
        color: _green,
      ),
      _OccasionDefinition(
        title: 'ڕۆژی عەرەفە',
        hijriMonth: 12,
        hijriDay: 9,
        icon: '🤍',
        color: _blue,
      ),
      _OccasionDefinition(
        title: 'جەژنی قوربان',
        hijriMonth: 12,
        hijriDay: 10,
        icon: '🐑',
        color: _red,
      ),
    ];
  }

  List<_UpcomingOccasion> _buildUpcomingOccasions() {
    final now = DateTime.now();
    final List<_UpcomingOccasion> items = [];

    for (final def in _occasionDefinitions()) {
      final nextDate = _findNextGregorianForHijri(
        hijriMonth: def.hijriMonth,
        hijriDay: def.hijriDay,
        from: now,
      );

      if (nextDate != null) {
        items.add(
          _UpcomingOccasion(
            title: def.title,
            icon: def.icon,
            color: def.color,
            date: nextDate,
            hijriMonth: def.hijriMonth,
            hijriDay: def.hijriDay,
            hijriMonthName: _getKurdishHijriMonthName(def.hijriMonth),
          ),
        );
      }
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  DateTime? _findNextGregorianForHijri({
    required int hijriMonth,
    required int hijriDay,
    required DateTime from,
  }) {
    for (int i = 0; i <= 500; i++) {
      final date = from.add(Duration(days: i));
      final hijri = HijriCalendar.fromDate(date);
      if (hijri.hMonth == hijriMonth && hijri.hDay == hijriDay) {
        return DateTime(date.year, date.month, date.day);
      }
    }
    return null;
  }

  String _formatCountdown(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative) {
      return 'تێپەڕیووە';
    }

    if (diff.inHours < 24) {
      final hours = diff.inHours == 0 ? 1 : diff.inHours;
      return '$hours کاتژمێر ماوە';
    }

    final days = diff.inDays + ((diff.inHours % 24) > 0 ? 1 : 0);
    return '$days ڕۆژ ماوە';
  }

  String _formatGregorianDate(DateTime date) {
    return '${date.day} ${_getKurdishGregorianMonthName(date.month)} ${date.year}';
  }

  String? _getOccasion(HijriCalendar hijri) {
    for (final def in _occasionDefinitions()) {
      if (hijri.hMonth == def.hijriMonth && hijri.hDay == def.hijriDay) {
        return def.title;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final upcomingOccasions = _buildUpcomingOccasions();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      children: [
                        _buildTopDateCard(),
                        const SizedBox(height: 18),
                        _buildQuickInfoCards(upcomingOccasions),
                        const SizedBox(height: 18),
                        _buildCalendarCard(),
                        const SizedBox(height: 22),
                        _buildOccasionsSection(upcomingOccasions),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.18),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -40,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: const [
              Text(
                'ڕۆژنامەی ئایینی',
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'هەموو بۆنە ئایینییەکان',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _GlassIconButton(
            icon: Icons.info_outline_rounded,
            onTap: () => InfoUtils.showInfo(
              context,
              title: 'ڕۆژژمێر',
              description: 'ڕۆژژمێری کۆچی و زاینی و بۆنە ئایینییەکان.',
              howToUse: 'دەتوانیت بەروارەکان ببینی و بزانیت چەند ڕۆژ ماوە بۆ بۆنە ئایینییەکانی وەک ڕەمەزان و جەژنەکان.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [_primary, _primary2],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Text(
              'بەرواری هەڵبژێردراو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_hijriDate.hDay} ${_getKurdishHijriMonthName(_hijriDate.hMonth)} ${_hijriDate.hYear}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'کۆچی',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                Text(
                  '${_selectedDate.day} ${_getKurdishGregorianMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'زایینی',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards(List<_UpcomingOccasion> occasions) {
    final nextOccasion = occasions.isNotEmpty ? occasions.first : null;

    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            title: 'ڕۆژ',
            value: '${_selectedDate.day}',
            icon: Icons.today_rounded,
            color: _blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            title: 'مانگی کۆچی',
            value: _getKurdishHijriMonthName(_hijriDate.hMonth),
            icon: Icons.nightlight_round,
            color: _green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            title: 'نزیکترین بۆنە',
            value:
            nextOccasion == null ? '-' : _formatCountdown(nextOccasion.date),
            icon: Icons.alarm_rounded,
            color: _gold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final firstDayOfMonth =
    DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MonthNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _onDateChanged(
                  DateTime(_selectedDate.year, _selectedDate.month - 1, 1),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getKurdishGregorianMonthName(_selectedDate.month),
                      style: const TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedDate.year}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _MonthNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _onDateChanged(
                  DateTime(_selectedDate.year, _selectedDate.month + 1, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ی', 'د', 'س', 'چ', 'پ', 'هـ', 'ش']
                .map(
                  (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + weekdayOfFirstDay,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay) return const SizedBox();

              final dayNumber = index - weekdayOfFirstDay + 1;
              final date =
              DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              final hijri = HijriCalendar.fromDate(date);

              final now = DateTime.now();
              final isToday = date.day == now.day &&
                  date.month == now.month &&
                  date.year == now.year;

              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              final isOccasion = _getOccasion(hijri) != null;

              Color bgColor = Colors.transparent;
              Color borderColor = Colors.transparent;
              Color textColor = _text;

              if (isSelected) {
                bgColor = _primary;
                borderColor = _primary;
                textColor = Colors.white;
              } else if (isToday) {
                bgColor = _blue.withValues(alpha: 0.16);
                borderColor = _blue.withValues(alpha: 0.45);
              } else if (isOccasion) {
                bgColor = _gold.withValues(alpha: 0.12);
                borderColor = _gold.withValues(alpha: 0.35);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _onDateChanged(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${hijri.hDay}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : _muted.withValues(alpha: 0.9),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      if (isOccasion) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionsSection(List<_UpcomingOccasion> occasions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بۆنە ئایینییەکان',
          style: TextStyle(
            color: _text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'هەموو بۆنە داهاتووەکان بە کاتی ماوە',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (occasions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: const Center(
              child: Text(
                'هیچ بۆنەیەک نەدۆزرایەوە',
                style: TextStyle(
                  color: _muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          ...occasions.map(_buildOccasionItem),
      ],
    );
  }

  Widget _buildOccasionItem(_UpcomingOccasion occ) {
    final countdown = _formatCountdown(occ.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: occ.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: occ.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                occ.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occ.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${occ.hijriDay} ${occ.hijriMonthName}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatGregorianDate(occ.date),
                  style: const TextStyle(
                    color: _faint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: occ.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: occ.color.withValues(alpha: 0.28)),
            ),
            child: Text(
              countdown,
              style: TextStyle(
                color: occ.color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionDefinition {
  final String title;
  final int hijriMonth;
  final int hijriDay;
  final String icon;
  final Color color;

  _OccasionDefinition({
    required this.title,
    required this.hijriMonth,
    required this.hijriDay,
    required this.icon,
    required this.color,
  });
}

class _UpcomingOccasion {
  final String title;
  final String icon;
  final Color color;
  final DateTime date;
  final int hijriMonth;
  final int hijriDay;
  final String hijriMonthName;

  _UpcomingOccasion({
    required this.title,
    required this.icon,
    required this.color,
    required this.date,
    required this.hijriMonth,
    required this.hijriDay,
    required this.hijriMonthName,
  });
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: _CalendarScreenState._text, size: 18),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _CalendarScreenState._surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _CalendarScreenState._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: _CalendarScreenState._muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _CalendarScreenState._text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _CalendarScreenState._surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _CalendarScreenState._border),
        ),
        child: Icon(
          icon,
          color: _CalendarScreenState._text,
        ),
      ),
    );
  }
}
