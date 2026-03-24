import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tabloy_iman/widgets/pray_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:async';

// ── Import your screens ───────────────────────────────────────────────────────
import 'package:tabloy_iman/screens/prayer_times/prayer_times_page.dart';
import 'package:tabloy_iman/screens/quran/quran_home_screen.dart';
import 'package:tabloy_iman/screens/zikr/zikr_screen.dart';
import 'package:tabloy_iman/screens/tazbih/tazbih_screen.dart';
import 'package:tabloy_iman/screens/qibla/qibla_screen.dart';
import 'package:tabloy_iman/screens/allah_names/allah_names_screen.dart';
import 'package:tabloy_iman/screens/prayer_wall/prayer_wall_screen.dart';
import 'package:tabloy_iman/screens/calendar/calendar_screen.dart';
import 'package:tabloy_iman/screens/library/library_screen.dart';
import 'package:tabloy_iman/screens/quiz/quiz_screen.dart';
import 'package:tabloy_iman/screens/zakat/zakat_screen.dart';
import 'package:tabloy_iman/screens/atahyat/atahyat_screen.dart';
import 'package:tabloy_iman/screens/obligatory_prayers/obligatory_prayers_screen.dart';
import 'package:tabloy_iman/screens/sunnah_prayers/sunnah_prayers_screen.dart';
import 'package:tabloy_iman/screens/call_times/call_times_page.dart';
import 'package:tabloy_iman/screens/settings/settings_screen.dart';
import 'package:tabloy_iman/screens/name_dictionary/name_dictionary_screen.dart';
import '../../chwnasaraw/chwnasaraw_screen.dart';
import '../../mosque_map_screen.dart';
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

  // ── Palette ───────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);

  // ── Current zikr period ───────────────────────────────────────────────────
  _ZikrPeriod get _currentZikrPeriod {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 12)  return _ZikrPeriod.morning;
    if (h >= 12 && h < 18) return _ZikrPeriod.afternoon;
    return _ZikrPeriod.night;
  }

  // ── Social media items ────────────────────────────────────────────────────
  static const _socialItems = [
    _SocialItem(
      platform: 'Instagram',
      handle: '@teestudio87',
      description: 'وێنە و ستۆری نوێ ببینن',
      emoji: '📸',
      color: Color(0xFFE1306C),
      gradB: Color(0xFFF77737),
      url: 'https://www.instagram.com/tee_studio87?igsh=YWR6bGhxNzRqYXFp&utm_source=qr',
    ),
    _SocialItem(
      platform: 'Telegram',
      handle: '@teestudio87',
      description: 'کەناڵی تەلێگرامی ئێمە بەشداری بکە',
      emoji: '✈️',
      color: Color(0xFF229ED9),
      gradB: Color(0xFF1AAFED),
      url: 'https://t.me/teestudio87',
    ),
    _SocialItem(
      platform: 'YouTube',
      handle: '@tabloy_iman',
      description: 'ڤیدیۆی ئیسلامی تەماشا بکە',
      emoji: '▶️',
      color: Color(0xFFFF4444),
      gradB: Color(0xFFFF0000),
      url: 'https://youtube.com/@tabloy_iman',
    ),
    _SocialItem(
      platform: 'TikTok',
      handle: '@tabloy_iman',
      description: 'ڤیدیۆی کورت و بەسوود',
      emoji: '🎵',
      color: Color(0xFF69C9D0),
      gradB: Color(0xFFEE1D52),
      url: 'https://tiktok.com/@tabloy_iman',
    ),
  ];

  // ── Screen definitions ────────────────────────────────────────────────────
  final List<_ScreenItem> _featured = [];
  final List<_ScreenItem> _all      = [];

  late final List<_ScreenItem> _screens = [
    _ScreenItem(title: 'کاتەکانی بانگ',        icon: Icons.access_time,    color: const Color(0xFF60A5FA), gradB: const Color(0xFF3B82F6), screen: const PrayerTimesPage(),         isFeatured: true),
    _ScreenItem(title: 'قورئانی پیرۆز',         icon: Icons.menu_book,      color: const Color(0xFF34D399), gradB: const Color(0xFF10B981), screen: const QuranHomeScreen(),         isFeatured: true),
    _ScreenItem(title: 'خەتمی قورئان',          icon: Icons.menu_book_rounded,       color: const Color(0xFF94A3B8), gradB: const Color(0xFF475569), screen: const QuranCompletionScreen(), isFeatured: true),
    _ScreenItem(title: 'تەسبیح',                icon: Icons.fingerprint,    color: const Color(0xFF2DD4BF), gradB: const Color(0xFF0D9488), screen: const TazbihScreen(),           isFeatured: true),
    _ScreenItem(title: 'قیبلە',                 icon: Icons.explore,        color: const Color(0xFFF87171), gradB: const Color(0xFFEF4444), screen: const QiblaScreen()),
    _ScreenItem(title: 'ناوە پیرۆزەکانی خودا',  icon: Icons.favorite,       color: const Color(0xFFF472B6), gradB: const Color(0xFFEC4899), screen: const AllahNamesScreen()),
 //   _ScreenItem(title: 'دیواری نزا',            icon: Icons.chat_bubble,    color: const Color(0xFFA78BFA), gradB: const Color(0xFF7C3AED), screen: const PrayerWallScreen()),
    _ScreenItem(title: 'بەرەوپێشچوونی ڕۆژانە', icon: Icons.trending_up,    color: const Color(0xFF818CF8), gradB: const Color(0xFF6366F1), screen: const DailyProgressScreen()),
    _ScreenItem(title: 'ڕۆژژمێر',              icon: Icons.calendar_month, color: const Color(0xFFFB923C), gradB: const Color(0xFFF97316), screen: const CalendarScreen()), //   _ScreenItem(title: 'کتێبخانە',             icon: Icons.library_books,  color: const Color(0xFFD97706), gradB: const Color(0xFFB45309), screen: const LibraryScreen()),
  //  _ScreenItem(title: 'پێشبڕکێ',              icon: Icons.quiz,           color: const Color(0xFF22D3EE), gradB: const Color(0xFF06B6D4), screen: const QuizScreen()),
    _ScreenItem(title: 'زەکات',                 icon: Icons.calculate,      color: const Color(0xFF4ADE80), gradB: const Color(0xFF16A34A), screen: const ZakatScreen()),
  //  _ScreenItem(title: 'نەخشەی مزگەوتەکان',    icon: Icons.map,            color: const Color(0xFF38BDF8), gradB: const Color(0xFF0284C7), screen: const MosqueMapScreen()),
    _ScreenItem(title: 'تەحیات',                icon: Icons.description,    color: const Color(0xFF94A3B8), gradB: const Color(0xFF64748B), screen: const AtahyatScreen()),
    _ScreenItem(title: 'نوێژە فەرزەکان',        icon: Icons.check_circle,   color: const Color(0xFF60A5FA), gradB: const Color(0xFF2563EB), screen: const ObligatoryPrayersScreen()),
    _ScreenItem(title: 'نوێژە سوننەتەکان',      icon: Icons.star,           color: const Color(0xFFFDE047), gradB: const Color(0xFFCA8A04), screen: const SunnahPrayersScreen()),
    _ScreenItem(title: 'ئادابەکان',             icon: Icons.clean_hands,    color: const Color(0xFF86EFAC), gradB: const Color(0xFF15803D), screen: const ChwnaSarAwScreen()),
 //   _ScreenItem(title: 'کاتەکانی پەیوەندی',     icon: Icons.phone_in_talk,  color: const Color(0xFFC084FC), gradB: const Color(0xFF7E22CE), screen: const CallTimesPage()),
    _ScreenItem(title: 'فەرهەنگی ناوەکان',    icon: Icons.book,           color: const Color(0xFFC084FC), gradB: const Color(0xFF7E22CE), screen: const NameDictionaryScreen()),
    _ScreenItem(title: 'حیفزی قورئان',          icon: Icons.menu_book_rounded,       color: const Color(0xFF94A3B8), gradB: const Color(0xFF475569), screen: const HafizQuranScreen()),
  ];

  @override
  void initState() {
    super.initState();
    for (final s in _screens) {
      if (s.isFeatured) _featured.add(s); else _all.add(s);
    }

    final total = _screens.length;
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900 + total * 60),
    )..forward();

    _itemAnimations = List.generate(total, (i) {
      final start = (i * 0.06).clamp(0.0, 0.7);
      final end   = (start + 0.40).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _bannerPageController = PageController(viewportFraction: 0.92);
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentBannerPage + 1) % _socialItems.length;
      _bannerPageController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => _currentBannerPage = next);
    });

    // Show random prayer overlay on app start
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

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Positioned(top: -60, right: -80,
              child: _GlowBlob(color: _accentDim.withOpacity(0.16), size: 260)),
          Positioned(top: 200, left: -50,
              child: _GlowBlob(color: const Color(0xFF0E4D6A).withOpacity(0.18), size: 200)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 4),

                  // ── Greeting ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGreetingBanner(),
                  ),
                  const SizedBox(height: 14),

                  // ── Social follow carousel ─────────────────────────────
                  _buildSocialCarousel(),
                  const SizedBox(height: 14),

                  // ── Zikr time card ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildZikrTimeCard(),
                  ),
                  const SizedBox(height: 26),

                  // ── Featured grid ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionLabel('بەرنامە گرنگەکان'),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFeaturedGrid(),
                  ),
                  const SizedBox(height: 26),

                  // ── All programs list ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionLabel('هەموو بەرنامەکان'),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildAllList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          const Text('تابلۆی ئیمان',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: _starlight, letterSpacing: 0.4)),
          const SizedBox(height: 3),
          Container(
            width: 32, height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _accent.withOpacity(0.0), _accent, _accent.withOpacity(0.0)]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: _moonGlow),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PrayerWallScreen())),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _nebula,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.35), width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.chat_bubble_rounded,
                    color: Color(0xFFA78BFA), size: 18),
                Positioned(
                  top: 7, right: 7,
                  child: Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: const Color(0xFFFBBF24).withOpacity(0.7),
                          blurRadius: 5)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _nebula,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withOpacity(0.25), width: 1),
              ),
              child: const Icon(Icons.settings_rounded, color: _accent, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Greeting banner ───────────────────────────────────────────────────────
  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _accent.withOpacity(0.18), width: 1),
        boxShadow: [BoxShadow(color: _accentDim.withOpacity(0.1),
            blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_accentDim.withOpacity(0.35),
                  const Color(0xFF1A6B8A).withOpacity(0.2)],
              ),
              border: Border.all(color: _accent.withOpacity(0.3), width: 1),
            ),
            child: const Center(child: Text('☪️', style: TextStyle(fontSize: 26))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('بەخێربێیت',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: _moonGlow.withOpacity(0.5),
                        fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.8)),
                const SizedBox(height: 4),
                const Text('تابلۆی ئیمان',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: _starlight, fontSize: 20,
                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Social follow carousel ────────────────────────────────────────────────
  Widget _buildSocialCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 88,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: _socialItems.length,
            onPageChanged: (i) => setState(() => _currentBannerPage = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _SocialBannerCard(item: _socialItems[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Page dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_socialItems.length, (i) {
            final active = i == _currentBannerPage;
            final dotColor = _socialItems[i].color;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? dotColor : _moonGlow.withOpacity(0.18),
                borderRadius: BorderRadius.circular(3),
                boxShadow: active
                    ? [BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 6)]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Zikr time card ────────────────────────────────────────────────────────
  Widget _buildZikrTimeCard() {
    final period = _currentZikrPeriod;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ZikrScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _midnight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: period.color.withOpacity(0.4), width: 1),
          boxShadow: [BoxShadow(color: period.color.withOpacity(0.14),
              blurRadius: 20, offset: const Offset(0, 5))],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Period icon
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [period.color.withOpacity(0.28),
                    period.color.withOpacity(0.08)],
                ),
                border: Border.all(color: period.color.withOpacity(0.45), width: 1),
              ),
              child: Center(child: Text(period.emoji,
                  style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('زیکری ئێستا',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: period.color.withOpacity(0.6),
                          fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(period.kurdishName,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: period.color, fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(period.timeRange,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: _moonGlow.withOpacity(0.3),
                          fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Time badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: period.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: period.color.withOpacity(0.3)),
                  ),
                  child: Text('بچۆ',
                      style: TextStyle(color: period.color, fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label,
            textDirection: TextDirection.rtl,
            style: TextStyle(color: _moonGlow.withOpacity(0.65), fontSize: 13,
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(width: 8),
        Container(
          width: 4, height: 4,
          decoration: BoxDecoration(color: _accent, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _accent, blurRadius: 6)]),
        ),
      ],
    );
  }

  // ── Featured 2-column grid ────────────────────────────────────────────────
  Widget _buildFeaturedGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 14,
        mainAxisSpacing: 14, childAspectRatio: 0.92,
      ),
      itemCount: _featured.length,
      itemBuilder: (_, i) {
        final anim = _itemAnimations[i];
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 28 * (1 - anim.value)),
            child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
          ),
          child: _FeaturedCard(
            item: _featured[i],
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _featured[i].screen)),
          ),
        );
      },
    );
  }

  // ── All programs list ─────────────────────────────────────────────────────
  Widget _buildAllList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final globalIndex = _featured.length + i;
        final anim = globalIndex < _itemAnimations.length
            ? _itemAnimations[globalIndex]
            : const AlwaysStoppedAnimation<double>(1.0);
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, 24 * (1 - (anim as Animation<double>).value)),
            child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
          ),
          child: _ListCard(
            item: _all[i],
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _all[i].screen)),
          ),
        );
      },
    );
  }
}

// ── Social Banner Card ────────────────────────────────────────────────────────

class _SocialBannerCard extends StatelessWidget {
  final _SocialItem item;
  const _SocialBannerCard({required this.item});

  static const _midnight = Color(0xFF0B0F1E);
  static const _moonGlow = Color(0xFFE8E2FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _midnight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: item.color.withOpacity(0.28), width: 1),
          boxShadow: [BoxShadow(color: item.color.withOpacity(0.1),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Left glow blob
              Positioned(left: -20, top: -20,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        item.color.withOpacity(0.2), Colors.transparent])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    // Icon box
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [item.color.withOpacity(0.3),
                            item.gradB.withOpacity(0.15)],
                        ),
                        border: Border.all(color: item.color.withOpacity(0.4), width: 1),
                      ),
                      child: Center(child: Text(item.emoji,
                          style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(item.platform,
                                  style: TextStyle(color: item.color,
                                      fontSize: 15, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                      color: item.color.withOpacity(0.25), width: 1),
                                ),
                                child: Text('فۆڵۆمان بکە',
                                    style: TextStyle(color: item.color,
                                        fontSize: 9, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(item.description,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: _moonGlow.withOpacity(0.45),
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(item.handle,
                              style: TextStyle(color: _moonGlow.withOpacity(0.25),
                                  fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 13, color: item.color.withOpacity(0.5)),
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

// ── Featured Card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final _ScreenItem item;
  final VoidCallback onTap;
  const _FeaturedCard({required this.item, required this.onTap});

  static const _midnight  = Color(0xFF0B0F1E);
  static const _starlight = Color(0xFFF0EEF8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _midnight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: item.color.withOpacity(0.22), width: 1),
          boxShadow: [BoxShadow(color: item.color.withOpacity(0.1),
              blurRadius: 18, offset: const Offset(0, 5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(top: -24, right: -24,
                  child: Container(width: 90, height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            item.color.withOpacity(0.22), Colors.transparent])))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [item.color.withOpacity(0.25),
                              item.gradB.withOpacity(0.12)],
                          ),
                          border: Border.all(
                              color: item.color.withOpacity(0.35), width: 1),
                        ),
                        child: Icon(item.icon, color: item.color, size: 26),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item.title,
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: _starlight, fontSize: 13,
                                fontWeight: FontWeight.w700, height: 1.35)),
                        const SizedBox(height: 10),
                        Container(
                          width: 36, height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(colors: [
                              item.color.withOpacity(0.0), item.color,
                              item.color.withOpacity(0.0)]),
                          ),
                        ),
                      ],
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

// ── List Card ─────────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final _ScreenItem item;
  final VoidCallback onTap;
  const _ListCard({required this.item, required this.onTap});

  static const _midnight  = Color(0xFF0B0F1E);
  static const _starlight = Color(0xFFF0EEF8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _midnight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: item.color.withOpacity(0.18), width: 1),
          boxShadow: [BoxShadow(color: item.color.withOpacity(0.07),
              blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [item.color.withOpacity(0.22),
                    item.gradB.withOpacity(0.1)],
                ),
                border: Border.all(color: item.color.withOpacity(0.3), width: 1),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: _starlight, fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: item.color.withOpacity(0.2), width: 1),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 13, color: item.color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _ScreenItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color gradB;
  final Widget screen;
  final bool isFeatured;
  const _ScreenItem({
    required this.title, required this.icon,
    required this.color, required this.gradB,
    required this.screen, this.isFeatured = false,
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
    required this.platform, required this.handle,
    required this.description, required this.emoji,
    required this.color, required this.gradB, required this.url,
  });
}

enum _ZikrPeriod {
  morning, afternoon, night;

  String get kurdishName {
    switch (this) {
      case _ZikrPeriod.morning:   return 'زیکری بەیانی';
      case _ZikrPeriod.afternoon: return 'زیکری ئێوارە';
      case _ZikrPeriod.night:     return 'زیکری شەو';
    }
  }

  String get timeRange {
    switch (this) {
      case _ZikrPeriod.morning:   return '٤:٠٠ - ١٢:٠٠';
      case _ZikrPeriod.afternoon: return '١٢:٠٠ - ١٨:٠٠';
      case _ZikrPeriod.night:     return '١٨:٠٠ - ٤:٠٠';
    }
  }

  String get emoji {
    switch (this) {
      case _ZikrPeriod.morning:   return '🌅';
      case _ZikrPeriod.afternoon: return '🌤';
      case _ZikrPeriod.night:     return '🌙';
    }
  }

  Color get color {
    switch (this) {
      case _ZikrPeriod.morning:   return const Color(0xFFFBBF24);
      case _ZikrPeriod.afternoon: return const Color(0xFF60A5FA);
      case _ZikrPeriod.night:     return const Color(0xFFA78BFA);
    }
  }
}

// ── Starfield ─────────────────────────────────────────────────────────────────

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
      final rng     = math.Random(i * 137);
      final radius  = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.45 + 0.1;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
          Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
          radius, paint);
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
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}