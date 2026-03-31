import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tabloy_iman/widgets/pray_dialog.dart';

// screens
import 'package:tabloy_iman/screens/prayer_times/prayer_times_page.dart';
import 'package:tabloy_iman/screens/quran/quran_home_screen.dart';
import 'package:tabloy_iman/screens/zikr/zikr_screen.dart';
import 'package:tabloy_iman/screens/tazbih/tazbih_screen.dart';
import 'package:tabloy_iman/screens/qibla/qibla_screen.dart';
import 'package:tabloy_iman/screens/allah_names/allah_names_screen.dart';
import 'package:tabloy_iman/screens/prayer_wall/prayer_wall_screen.dart';
import 'package:tabloy_iman/screens/calendar/calendar_screen.dart';
import 'package:tabloy_iman/screens/zakat/zakat_screen.dart';
import 'package:tabloy_iman/screens/atahyat/atahyat_screen.dart';
import 'package:tabloy_iman/screens/obligatory_prayers/obligatory_prayers_screen.dart';
import 'package:tabloy_iman/screens/sunnah_prayers/sunnah_prayers_screen.dart';
import 'package:tabloy_iman/screens/settings/settings_screen.dart';
import 'package:tabloy_iman/screens/name_dictionary/name_dictionary_screen.dart';
import '../../chwnasaraw/chwnasaraw_screen.dart';
import '../../progress/daily_progress_screen.dart';
import '../../quran/hafiz_quran_screen.dart';
import '../../quran/quran_completion_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _itemAnimations;
  late PageController _bannerPageController;
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  static const _bg = Color(0xFF070B14);
  static const _surface = Color(0xFF111827);
  static const _border = Color(0xFF273449);

  static const _text = Color(0xFFF8FAFC);
  static const _muted = Color(0xFF94A3B8);
  static const _faint = Color(0xFF64748B);

  static const _primary = Color(0xFF8B5CF6);
  static const _primary2 = Color(0xFF6D28D9);
  static const _blue = Color(0xFF38BDF8);

  _ZikrPeriod get _currentZikrPeriod {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 12) return _ZikrPeriod.morning;
    if (h >= 12 && h < 18) return _ZikrPeriod.afternoon;
    return _ZikrPeriod.night;
  }

  static const _socialItems = [
    _SocialItem(
      platform: 'Instagram',
      handle: '@teestudio87',
      description: 'وێنە و ستۆری نوێ ببینن',
      emoji: '📸',
      color: Color(0xFFE1306C),
      gradB: Color(0xFFF77737),
      url: 'https://instagram.com/teestudio87',
    ),
    _SocialItem(
      platform: 'Telegram',
      handle: '@teestudio78',
      description: 'کەناڵی تەلێگرامی ئێمە',
      emoji: '✈️',
      color: Color(0xFF229ED9),
      gradB: Color(0xFF1AAFED),
      url: 'https://t.me/teestudio78',
    ),
    _SocialItem(
      platform: 'YouTube',
      handle: '@TeeStudio87',
      description: 'زانیاری تەکنەلۆژیا و ژمێریاری',
      emoji: '▶️',
      color: Color(0xFFFF4444),
      gradB: Color(0xFFFF0000),
      url: 'https://www.youtube.com/@TeeStudio87',
    ),
    _SocialItem(
      platform: 'TikTok',
      handle: '@teestudio87',
      description: 'ڤیدیۆی کورت و بەسوود',
      emoji: '🎵',
      color: Color(0xFF69C9D0),
      gradB: Color(0xFFEE1D52),
      url: 'https://www.tiktok.com/@teestudio87',
    ),
  ];

  final List<_ScreenItem> _featured = [];
  final List<_ScreenItem> _all = [];

  late final List<_ScreenItem> _screens = [
    _ScreenItem(
      title: 'کاتەکانی بانگ',
      icon: Icons.access_time_rounded,
      color: const Color(0xFF60A5FA),
      gradB: const Color(0xFF2563EB),
      screen: const PrayerTimesPage(),
      isFeatured: true,
    ),
    _ScreenItem(
      title: 'قورئانی پیرۆز',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF34D399),
      gradB: const Color(0xFF059669),
      screen: const QuranHomeScreen(),
      isFeatured: true,
    ),
    _ScreenItem(
      title: 'خەتمی قورئان',
      icon: Icons.auto_stories_rounded,
      color: const Color(0xFFA78BFA),
      gradB: const Color(0xFF7C3AED),
      screen: const QuranCompletionScreen(),
      isFeatured: true,
    ),
    _ScreenItem(
      title: 'تەسبیح',
      icon: Icons.fingerprint_rounded,
      color: const Color(0xFF2DD4BF),
      gradB: const Color(0xFF0F766E),
      screen: const TazbihScreen(),
      isFeatured: true,
    ),
    _ScreenItem(
      title: 'قیبلە',
      icon: Icons.explore_rounded,
      color: const Color(0xFFF87171),
      gradB: const Color(0xFFDC2626),
      screen: const QiblaScreen(),
    ),
    _ScreenItem(
      title: 'ناوە پیرۆزەکانی خودا',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFF472B6),
      gradB: const Color(0xFFDB2777),
      screen: const AllahNamesScreen(),
    ),
    _ScreenItem(
      title: 'بەرەوپێشچوونی ڕۆژانە',
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF818CF8),
      gradB: const Color(0xFF4F46E5),
      screen: const DailyProgressScreen(),
    ),
    _ScreenItem(
      title: 'ڕۆژژمێر',
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFFB923C),
      gradB: const Color(0xFFEA580C),
      screen: const CalendarScreen(),
    ),
    _ScreenItem(
      title: 'زەکات',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF4ADE80),
      gradB: const Color(0xFF16A34A),
      screen: const ZakatScreen(),
    ),
    _ScreenItem(
      title: 'تەحیات',
      icon: Icons.description_rounded,
      color: const Color(0xFF94A3B8),
      gradB: const Color(0xFF475569),
      screen: const AtahyatScreen(),
    ),
    _ScreenItem(
      title: 'نوێژە فەرزەکان',
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF60A5FA),
      gradB: const Color(0xFF2563EB),
      screen: const ObligatoryPrayersScreen(),
    ),
    _ScreenItem(
      title: 'نوێژە سوننەتەکان',
      icon: Icons.star_rounded,
      color: const Color(0xFFFDE047),
      gradB: const Color(0xFFCA8A04),
      screen: const SunnahPrayersScreen(),
    ),
    _ScreenItem(
      title: 'ئادابەکان',
      icon: Icons.clean_hands_rounded,
      color: const Color(0xFF86EFAC),
      gradB: const Color(0xFF15803D),
      screen: const ChwnaSarAwScreen(),
    ),
    _ScreenItem(
      title: 'فەرهەنگی ناوەکان',
      icon: Icons.book_rounded,
      color: const Color(0xFFC084FC),
      gradB: const Color(0xFF7E22CE),
      screen: const NameDictionaryScreen(),
    ),
    _ScreenItem(
      title: 'حیفزی قورئان',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF94A3B8),
      gradB: const Color(0xFF475569),
      screen: const HafizQuranScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();

    for (final s in _screens) {
      if (s.isFeatured) {
        _featured.add(s);
      } else {
        _all.add(s);
      }
    }

    final total = _screens.length;
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900 + total * 60),
    )..forward();

    _itemAnimations = List.generate(total, (i) {
      final start = (i * 0.06).clamp(0.0, 0.7);
      final end = (start + 0.40).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _bannerPageController = PageController(viewportFraction: 0.90);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBannerPage + 1) % _socialItems.length;
      _bannerPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentBannerPage = next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrayDialog.show(context);
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            _buildBackgroundGlow(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 18),
                    _buildSocialCarousel(),
                    const SizedBox(height: 18),
                    _buildZikrTimeCard(),
                    const SizedBox(height: 12),
                    _buildSectionTitle('بەرنامە گرنگەکان'),
                    const SizedBox(height: 12),
                    _buildFeaturedGrid(),
                    const SizedBox(height: 26),
                    _buildSectionTitle('هەموو بەرنامەکان'),
                    const SizedBox(height: 12),
                    _buildAllList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'تابلۆی ئیمان',
        style: TextStyle(
          color: _text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _SquareIconButton(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFFA78BFA),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrayerWallScreen()),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _SquareIconButton(
            icon: Icons.settings_rounded,
            color: _primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withOpacity(0.18),
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: -50,
          child: Container(
            width: 180,
            height: 180,
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

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        gradient: const LinearGradient(
          colors: [_primary, _primary2],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بەخێربێیت',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'بۆ تابلۆی ئیمان',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'هەموو بەشە ئیسلامییەکانی پێویست لە یەک شوێن',
                    textAlign: TextAlign.right,
                     textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Center(
              child: Text('☪️', style: TextStyle(fontSize: 30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final items = [
      (
      'بانگ',
      Icons.access_time_rounded,
      const PrayerTimesPage(),
      const Color(0xFF60A5FA)
      ),
      (
      'قیبلە',
      Icons.explore_rounded,
      const QiblaScreen(),
      const Color(0xFFF87171)
      ),
      (
      'زیکر',
      Icons.auto_awesome_rounded,
      const ZikrScreen(),
      const Color(0xFF10B981)
      ),
      (
      'قورئان',
      Icons.menu_book_rounded,
      const QuranHomeScreen(),
      const Color(0xFFA78BFA)
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.$3),
                ),
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      Icon(item.$2, color: item.$4, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        item.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 104,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: _socialItems.length,
            onPageChanged: (i) => setState(() => _currentBannerPage = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _SocialBannerCard(item: _socialItems[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_socialItems.length, (i) {
            final active = i == _currentBannerPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? _socialItems[i].color
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildZikrTimeCard() {
    final period = _currentZikrPeriod;
    return Container(
      height: 85, // Slightly taller to accommodate 3 lines of text
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: period.color.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () =>  () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZikrScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: period.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(period.emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'زیکری ئێستا',
                      style: TextStyle(
                        color: period.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      period.kurdishName,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Minimal Circle Indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: period.color.withOpacity(0.1),
                ),
                child: Icon(Icons.chevron_right_rounded, color: period.color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 5,
          height: 18,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedGrid() {
    return GridView.builder(
      itemCount: _featured.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (_, i) {
        final anim = _itemAnimations[i];
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 24 * (1 - anim.value)),
            child: Opacity(opacity: anim.value, child: child),
          ),
          child: _FeaturedCard(
            item: _featured[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _featured[i].screen),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllList() {
    return ListView.separated(
      itemCount: _all.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final globalIndex = _featured.length + i;
        final anim = globalIndex < _itemAnimations.length
            ? _itemAnimations[globalIndex]
            : const AlwaysStoppedAnimation<double>(1);
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)),
            child: Opacity(opacity: anim.value, child: child),
          ),
          child: _ListCard(
            item: _all[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _all[i].screen),
            ),
          ),
        );
      },
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _HomePageState._surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _SocialBannerCard extends StatelessWidget {
  final _SocialItem item;

  const _SocialBannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Same fixed height as ListCard
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _HomePageState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.color.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async { /* URL Launch Logic */ },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Solid Emoji Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.platform,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.handle,
                      style: const TextStyle(
                        color: _HomePageState._muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  color: item.color.withOpacity(0.4), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final _ScreenItem item;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        // Keeping original sizing constraints implicit
        decoration: BoxDecoration(
          color: _HomePageState._surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: item.color.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Modern Background Pattern (Replacing the simple circle)
              Positioned(
                top: -15,
                right: -15,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          item.color.withOpacity(0.12),
                          item.color.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Content Layout
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon & Mini Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(item.icon, color: item.color, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.arrow_forward_ios, size: 10, color: item.color),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Bottom Section: Text & Dynamic Indicator
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _HomePageState._text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Modern "Capsule" Indicator
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [item.color, item.gradB],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final _ScreenItem item;
  final VoidCallback onTap;

  const _ListCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Subtle outer glow instead of a harsh shadow
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            splashColor: item.color.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _HomePageState._surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                // Single, crisp border
                border: Border.all(color: item.color.withOpacity(0.12), width: 1.5),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Icon Container with Gradient
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.color.withOpacity(0.15),
                          item.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  // Title Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: _HomePageState._text.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sleek Arrow (No box, just the icon)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.chevron_right_rounded, // Left arrow for RTL
                      size: 20,
                      color: item.color.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color gradB;
  final Widget screen;
  final bool isFeatured;

  const _ScreenItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.gradB,
    required this.screen,
    this.isFeatured = false,
  });
}

class _SocialItem {
  final String platform;
  final String handle;
  final String description;
  final String emoji;
  final Color color;
  final Color gradB;
  final String url;

  const _SocialItem({
    required this.platform,
    required this.handle,
    required this.description,
    required this.emoji,
    required this.color,
    required this.gradB,
    required this.url,
  });
}

enum _ZikrPeriod {
  morning,
  afternoon,
  night,
}

extension _ZikrPeriodX on _ZikrPeriod {
  String get kurdishName {
    switch (this) {
      case _ZikrPeriod.morning:
        return 'زیکری بەیانی';
      case _ZikrPeriod.afternoon:
        return 'زیکری ئێواران';
      case _ZikrPeriod.night:
        return 'زیکری شەوان';
    }
  }

  String get emoji {
    switch (this) {
      case _ZikrPeriod.morning:
        return '🌅';
      case _ZikrPeriod.afternoon:
        return '☀️';
      case _ZikrPeriod.night:
        return '🌙';
    }
  }

  String get timeRange {
    switch (this) {
      case _ZikrPeriod.morning:
        return '٤:٠٠ - ١٢:٠٠';
      case _ZikrPeriod.afternoon:
        return '١٢:٠٠ - ٦:٠٠';
      case _ZikrPeriod.night:
        return '٦:٠٠ - ٤:٠٠';
    }
  }

  Color get color {
    switch (this) {
      case _ZikrPeriod.morning:
        return const Color(0xFFF59E0B);
      case _ZikrPeriod.afternoon:
        return const Color(0xFF38BDF8);
      case _ZikrPeriod.night:
        return const Color(0xFF8B5CF6);
    }
  }
}