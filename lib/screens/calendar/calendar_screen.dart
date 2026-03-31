import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

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
  static const _card = Color(0xFF0F172A);
  static const _border = Color(0xFF25324A);

  static const _text = Color(0xFFF8FAFC);
  static const _muted = Color(0xFF94A3B8);
  static const _faint = Color(0xFF64748B);

  static const _primary = Color(0xFF8B5CF6);
  static const _primary2 = Color(0xFF6D28D9);
  static const _gold = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF38BDF8);

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

  @override
  Widget build(BuildContext context) {
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
                        _buildQuickInfoCards(),
                        const SizedBox(height: 18),
                        _buildCalendarCard(),
                        const SizedBox(height: 22),
                        _buildOccasionsSection(),
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
              color: _primary.withOpacity(0.18),
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
              color: _blue.withOpacity(0.10),
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
                'کۆچی و زایینی',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          const _GlassIconButton(
            icon: Icons.calendar_month_rounded,
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
            color: _primary.withOpacity(0.28),
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
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
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
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
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

  Widget _buildQuickInfoCards() {
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
            title: 'مانگ',
            value: _getKurdishGregorianMonthName(_selectedDate.month),
            icon: Icons.date_range_rounded,
            color: _gold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            title: 'کۆچی',
            value: '${_hijriDate.hDay}',
            icon: Icons.nightlight_round,
            color: _green,
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

              final isWhiteDay =
                  hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15;
              final isOccasion = _getOccasion(hijri) != null;

              Color bgColor = Colors.transparent;
              Color borderColor = Colors.transparent;
              Color textColor = _text;

              if (isSelected) {
                bgColor = _primary;
                borderColor = _primary;
                textColor = Colors.white;
              } else if (isToday) {
                bgColor = _blue.withOpacity(0.16);
                borderColor = _blue.withOpacity(0.45);
              } else if (isOccasion) {
                bgColor = _gold.withOpacity(0.12);
                borderColor = _gold.withOpacity(0.35);
              } else if (isWhiteDay) {
                bgColor = _green.withOpacity(0.10);
                borderColor = _green.withOpacity(0.35);
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${hijri.hDay}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : _muted.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isOccasion || isWhiteDay) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isOccasion ? _gold : _green,
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

  Widget _buildOccasionsSection() {
    final currentHijri = HijriCalendar.fromDate(_selectedDate);
    final monthOccasions =
    _getMonthOccasions(currentHijri.hMonth, currentHijri.hYear);

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
          'ڕۆژە تایبەتەکانی ئەم مانگە',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (monthOccasions.isEmpty)
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
                'هیچ بۆنەیەک نییە لەم مانگەدا',
                style: TextStyle(
                  color: _muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          ...monthOccasions.map((occ) => _buildOccasionItem(occ)),
      ],
    );
  }

  Widget _buildOccasionItem(Occasion occ) {
    final accent = occ.isWhiteDay ? _green : _gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
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
                  '${occ.hijriDay} ${occ.hijriMonth}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (occ.isWhiteDay)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _green.withOpacity(0.30)),
              ),
              child: const Text(
                'ڕۆژوو',
                style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _getOccasion(HijriCalendar hijri) {
    if (hijri.hMonth == 9 && hijri.hDay == 1) return 'سەرەتای مانگی ڕەمەزان';
    if (hijri.hMonth == 10 && hijri.hDay == 1) return 'جەژنی ڕەمەزان';
    if (hijri.hMonth == 12 && hijri.hDay == 10) return 'جەژنی قوربان';
    if (hijri.hMonth == 1 && hijri.hDay == 10) return 'عاشوورا';
    if (hijri.hMonth == 3 && hijri.hDay == 12) {
      return 'مەولوودی پێغەمبەر (د.خ)';
    }
    return null;
  }

  List<Occasion> _getMonthOccasions(int month, int year) {
    List<Occasion> occasions = [];

    occasions.add(
      Occasion(
        title: 'ڕۆژانی سپی (بۆ ڕۆژوو)',
        hijriDay: 13,
        hijriMonth: _getKurdishHijriMonthName(month),
        icon: '⚪',
        isWhiteDay: true,
      ),
    );
    occasions.add(
      Occasion(
        title: 'ڕۆژانی سپی (بۆ ڕۆژوو)',
        hijriDay: 14,
        hijriMonth: _getKurdishHijriMonthName(month),
        icon: '⚪',
        isWhiteDay: true,
      ),
    );
    occasions.add(
      Occasion(
        title: 'ڕۆژانی سپی (بۆ ڕۆژوو)',
        hijriDay: 15,
        hijriMonth: _getKurdishHijriMonthName(month),
        icon: '⚪',
        isWhiteDay: true,
      ),
    );

    if (month == 9) {
      occasions.insert(
        0,
        Occasion(
          title: 'سەرەتای مانگی ڕەمەزان',
          hijriDay: 1,
          hijriMonth: _getKurdishHijriMonthName(9),
          icon: '🌙',
        ),
      );
    } else if (month == 10) {
      occasions.insert(
        0,
        Occasion(
          title: 'جەژنی ڕەمەزان',
          hijriDay: 1,
          hijriMonth: _getKurdishHijriMonthName(10),
          icon: '🎉',
        ),
      );
    } else if (month == 12) {
      occasions.insert(
        0,
        Occasion(
          title: 'جەژنی قوربان',
          hijriDay: 10,
          hijriMonth: _getKurdishHijriMonthName(12),
          icon: '🐑',
        ),
      );
      occasions.insert(
        0,
        Occasion(
          title: 'ڕۆژی عەرەفە',
          hijriDay: 9,
          hijriMonth: _getKurdishHijriMonthName(12),
          icon: '🤲',
        ),
      );
    } else if (month == 1) {
      occasions.insert(
        0,
        Occasion(
          title: 'سەری ساڵی کۆچی',
          hijriDay: 1,
          hijriMonth: _getKurdishHijriMonthName(1),
          icon: '🗓️',
        ),
      );
      occasions.insert(
        1,
        Occasion(
          title: 'عاشوورا',
          hijriDay: 10,
          hijriMonth: _getKurdishHijriMonthName(1),
          icon: '🕌',
        ),
      );
    } else if (month == 3) {
      occasions.insert(
        0,
        Occasion(
          title: 'مەولوودی پێغەمبەر (د.خ)',
          hijriDay: 12,
          hijriMonth: _getKurdishHijriMonthName(3),
          icon: '✨',
        ),
      );
    }

    return occasions;
  }
}

class Occasion {
  final String title;
  final int hijriDay;
  final String hijriMonth;
  final String icon;
  final bool isWhiteDay;

  Occasion({
    required this.title,
    required this.hijriDay,
    required this.hijriMonth,
    required this.icon,
    this.isWhiteDay = false,
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
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              color: color.withOpacity(0.12),
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
            maxLines: 1,
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