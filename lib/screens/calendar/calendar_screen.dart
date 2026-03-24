import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late HijriCalendar _hijriDate;
  late AnimationController _fadeController;

  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);
  static const _gold = Color(0xFFFFD97D);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _hijriDate = HijriCalendar.fromDate(_selectedDate);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'کۆچی و زایینی',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateHeader(),
              const SizedBox(height: 30),
              _buildCalendarCard(),
              const SizedBox(height: 30),
              _buildOccasionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ئەمڕۆ',
            style: TextStyle(
              color: _accent.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_hijriDate.hDay} ${_getKurdishHijriMonthName(_hijriDate.hMonth)} ${_hijriDate.hYear} کۆچی',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _starlight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedDate.day} ${_getKurdishGregorianMonthName(_selectedDate.month)} ${_selectedDate.year} زایینی',
            style: TextStyle(
              color: _moonGlow.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    // Current month view
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: _starlight),
                onPressed: () => _onDateChanged(DateTime(_selectedDate.year, _selectedDate.month - 1)),
              ),
              Text(
                '${_getKurdishGregorianMonthName(_selectedDate.month)} ${_selectedDate.year}',
                style: const TextStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: _starlight),
                onPressed: () => _onDateChanged(DateTime(_selectedDate.year, _selectedDate.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ی', 'د', 'س', 'چ', 'پ', 'ھ', 'ش'].map((day) => Text(
              day,
              style: TextStyle(color: _accent.withOpacity(0.6), fontWeight: FontWeight.bold),
            )).toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + weekdayOfFirstDay,
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay) return const SizedBox();
              
              final dayNumber = index - weekdayOfFirstDay + 1;
              final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              final hijri = HijriCalendar.fromDate(date);
              final isToday = date.day == DateTime.now().day && 
                            date.month == DateTime.now().month && 
                            date.year == DateTime.now().year;
              
              final isWhiteDay = hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15;
              final isOccasion = _getOccasion(hijri) != null;

              return Container(
                decoration: BoxDecoration(
                  color: isToday ? _accent : (isWhiteDay ? _accentDim.withOpacity(0.3) : (isOccasion ? _gold.withOpacity(0.2) : Colors.transparent)),
                  borderRadius: BorderRadius.circular(12),
                  border: isWhiteDay || isOccasion 
                    ? Border.all(color: isWhiteDay ? _accent : _gold, width: 1)
                    : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isToday ? _deepSpace : _starlight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        hijri.hDay.toString(),
                        style: TextStyle(
                          color: isToday ? _deepSpace.withOpacity(0.7) : _accent.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
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
    final monthOccasions = _getMonthOccasions(currentHijri.hMonth, currentHijri.hYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بۆنە ئایینییەکان',
          style: TextStyle(color: _starlight, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...monthOccasions.map((occ) => _buildOccasionItem(occ)).toList(),
        if (monthOccasions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'هیچ بۆنەیەک نییە لەم مانگەدا',
              style: TextStyle(color: _moonGlow, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildOccasionItem(Occasion occ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: occ.isWhiteDay ? _accent.withOpacity(0.3) : _gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: occ.isWhiteDay ? _accent.withOpacity(0.1) : _gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              occ.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occ.title,
                  style: const TextStyle(color: _starlight, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${occ.hijriDay} ${occ.hijriMonth}',
                  style: TextStyle(color: _moonGlow.withOpacity(0.6), fontSize: 14),
                ),
              ],
            ),
          ),
          if (occ.isWhiteDay)
            const Chip(
              label: Text('ڕۆژوو', style: TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: _accentDim,
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
    if (hijri.hMonth == 3 && hijri.hDay == 12) return 'مەولوودی پێغەمبەر (د.خ)';
    return null;
  }

  List<Occasion> _getMonthOccasions(int month, int year) {
    List<Occasion> occasions = [];
    
    // Add white days
    occasions.add(Occasion(title: 'ڕۆژانی سپی (بۆ ڕۆژوو)', hijriDay: 13, hijriMonth: _getKurdishHijriMonthName(month), icon: '⚪', isWhiteDay: true));
    occasions.add(Occasion(title: 'ڕۆژانی سپی (بۆ ڕۆژوو)', hijriDay: 14, hijriMonth: _getKurdishHijriMonthName(month), icon: '⚪', isWhiteDay: true));
    occasions.add(Occasion(title: 'ڕۆژانی سپی (بۆ ڕۆژوو)', hijriDay: 15, hijriMonth: _getKurdishHijriMonthName(month), icon: '⚪', isWhiteDay: true));

    // Special occasions
    if (month == 9) {
      occasions.insert(0, Occasion(title: 'سەرەتای مانگی ڕەمەزان', hijriDay: 1, hijriMonth: _getKurdishHijriMonthName(9), icon: '🌙'));
    } else if (month == 10) {
      occasions.insert(0, Occasion(title: 'جەژنی ڕەمەزان', hijriDay: 1, hijriMonth: _getKurdishHijriMonthName(10), icon: '🎉'));
    } else if (month == 12) {
      occasions.insert(0, Occasion(title: 'جەژنی قوربان', hijriDay: 10, hijriMonth: _getKurdishHijriMonthName(12), icon: '🐑'));
      occasions.insert(0, Occasion(title: 'ڕۆژی عەرەفە', hijriDay: 9, hijriMonth: _getKurdishHijriMonthName(12), icon: '🤲'));
    } else if (month == 1) {
      occasions.insert(0, Occasion(title: 'سەری ساڵی کۆچی', hijriDay: 1, hijriMonth: _getKurdishHijriMonthName(1), icon: '🗓️'));
      occasions.insert(1, Occasion(title: 'عاشوورا', hijriDay: 10, hijriMonth: _getKurdishHijriMonthName(1), icon: '🕌'));
    } else if (month == 3) {
      occasions.insert(0, Occasion(title: 'مەولوودی پێغەمبەر (د.خ)', hijriDay: 12, hijriMonth: _getKurdishHijriMonthName(3), icon: '✨'));
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
