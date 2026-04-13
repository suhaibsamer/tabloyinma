import 'package:flutter/material.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/utils/kurdish_styles.dart';
import 'package:tabloy_iman/utils/info_utils.dart';
import 'quran_chapter_screen.dart';
import 'quran_bookmarks_screen.dart';
import 'dart:math' as math;

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  _QuranHomeScreenState createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen>
    with TickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  bool _isLoading = true;
  List<dynamic> _filteredChapters = [];
  late List<dynamic> _allChapters;
  final TextEditingController _searchController = TextEditingController();
  bool _showAppBarTitle = false;
  late ScrollController _scrollController;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late AnimationController _listController;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _green     = Color(0xFF34D399);
  static const _greenDim  = Color(0xFF065F46);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadQuranData();
    _searchController.addListener(_filterChapters);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 140;
    if (show != _showAppBarTitle) setState(() => _showAppBarTitle = show);
  }

  Future<void> _loadQuranData() async {
    try {
      await _quranService.loadQuranData();
      if (mounted) {
        setState(() {
          _allChapters = _quranService.chapters;
          _filteredChapters = _allChapters;
          _isLoading = false;
        });
        _listController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('خرابی لە بارکردنی قورئان',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
            backgroundColor: const Color(0xFF1E1033),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade700.withValues(alpha: 0.5)),
            ),
          ),
        );
      }
    }
  }

  void _filterChapters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChapters = _allChapters.where((chapter) {
        final name = _getChapterName(chapter.number).toLowerCase();
        final number = chapter.number.toString();
        return name.contains(query) || number.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Positioned(
            top: -60,
            right: -60,
            child: _GlowBlob(color: _greenDim.withValues(alpha: 0.2), size: 260),
          ),
          Positioned(
            top: 220,
            left: -50,
            child: _GlowBlob(
                color: const Color(0xFF7B5CF0).withValues(alpha: 0.1), size: 200),
          ),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: _buildSearchBar(),
                ),
              ),
              if (_isLoading)
                SliverToBoxAdapter(child: _buildLoadingState()),
              if (!_isLoading && _filteredChapters.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState()),
              if (!_isLoading && _filteredChapters.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildChapterCard(
                            _filteredChapters[index], index),
                      ),
                      childCount: _filteredChapters.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sliver AppBar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _deepSpace,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _moonGlow),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => InfoUtils.showInfo(
              context,
              title: 'قورئانی پیرۆز',
              description: 'خوێندنەوەی قورئانی پیرۆز بە نوسین و دەنگی قورئانخوێنە جیاوازەکان.',
              howToUse: 'دەتوانیت سورەتەکان هەڵبژێریت، گوێ لە دەنگی قورئان بگریت و نیشانە دابنێیت (Bookmark) بۆ ئەو شوێنەی پێی گەیشتوویت.',
            ),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _nebula,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _green.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.info_outline_rounded,
                  color: _green, size: 18),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuranBookmarksScreen(),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _nebula,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF059669).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.bookmarks_rounded,
                  color: Color(0xFF059669), size: 18),
            ),
          ),
        ),
      ],
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text(
          'قورئانی پیرۆز',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _starlight,
            letterSpacing: 0.3,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: FadeTransition(
          opacity: _headerFade,
          child: _buildExpandedHeader(),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return Container(
      decoration: const BoxDecoration(color: _deepSpace),
      child: Stack(
        children: [
          // Green glow bloom
          Positioned(
            top: -40,
            left: -40,
            right: -40,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    _greenDim.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom shimmer line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _green.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon ring
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _greenDim.withValues(alpha: 0.45),
                        _greenDim.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                        color: _green.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('☪️', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'قورئانی پیرۆز',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _starlight,
                    letterSpacing: 0.3,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBadge('١١٤', 'سورەت'),
                    Container(
                      width: 1,
                      height: 16,
                      color: _green.withValues(alpha: 0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    _buildStatBadge('٦٢٣٦', 'ئایەت'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _green,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _moonGlow.withValues(alpha: 0.5),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: _starlight, fontSize: 15),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: TextStyle(
            color: _moonGlow.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14),
            child:
                Icon(Icons.search_rounded, color: _green.withValues(alpha: 0.6), size: 22),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: _searchController.clear,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _nebula,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded,
                        color: _moonGlow.withValues(alpha: 0.45), size: 16),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ── Loading / Empty ───────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _midnight,
                border: Border.all(color: _green.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: _green.withValues(alpha: 0.1), blurRadius: 24),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_green),
                  strokeWidth: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل القرآن الكريم...',
              style: TextStyle(
                fontSize: 14,
                color: _moonGlow.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _midnight,
                border: Border.all(color: _green.withValues(alpha: 0.2), width: 1),
              ),
              child:
                  const Center(child: Text('🔍', style: TextStyle(fontSize: 34))),
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(
                fontSize: 15,
                color: _moonGlow.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _searchController.clear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _nebula,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: _green.withValues(alpha: 0.25), width: 1),
                ),
                child: const Text(
                  'پاکردنەوەی گەڕان',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chapter Card ──────────────────────────────────────────────────────────

  Widget _buildChapterCard(dynamic chapter, int index) {
    final chapterName = _getChapterName(chapter.number);
    final versesCount = chapter.verses?.length ?? 0;

    // Cycle through subtle accent tints for visual variety
    final tints = [
      _green,
      const Color(0xFF60A5FA),
      const Color(0xFFA78BFA),
      const Color(0xFFFBBF24),
      const Color(0xFFF472B6),
      const Color(0xFF22D3EE),
    ];
    final tint = tints[index % tints.length];

    return AnimatedBuilder(
      animation: _listController,
      builder: (_, child) {
        final delay = (index * 0.015).clamp(0.0, 0.6);
        final end = (delay + 0.4).clamp(0.0, 1.0);
        final anim = CurvedAnimation(
          parent: _listController,
          curve: Interval(delay, end, curve: Curves.easeOutCubic),
        );
        return Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranChapterScreen(
              chapterNumber: chapter.number,
              chapterName: chapterName,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _midnight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tint.withValues(alpha: 0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: tint.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Chapter number circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        tint.withValues(alpha: 0.3),
                        tint.withValues(alpha: 0.08),
                      ],
                    ),
                    border:
                        Border.all(color: tint.withValues(alpha: 0.35), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      chapter.number.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: tint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chapterName,
                        style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 15),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: tint.withValues(alpha: 0.22), width: 1),
                        ),
                        child: Text(
                          'آيات: $versesCount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tint.withValues(alpha: 0.85),
                            letterSpacing: 0.3,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Arrow
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: tint.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: tint.withValues(alpha: 0.7),
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Chapter Names ─────────────────────────────────────────────────────────

  String _getChapterName(int chapterNumber) {
    const chapterNames = {
      1: 'سُورَةُ الْفَاتِحَةِ', 2: 'سُورَةُ البَقَرَةِ',
      3: 'سُورَةُ آلِ عِمْرَانَ', 4: 'سُورَةُ النِّسَاءِ',
      5: 'سُورَةُ المَائـِدَةِ', 6: 'سُورَةُ الأَنْعَامِ',
      7: 'سُورَةُ الأَعْرَافِ', 8: 'سُورَةُ الأَنفَالِ',
      9: 'سُورَةُ التَّوْبَةِ', 10: 'سُورَةُ يُونُسَ',
      11: 'سُورَةُ هُودٍ', 12: 'سُورَةُ يُوسُفَ',
      13: 'سُورَةُ الرَّعْدِ', 14: 'سُورَةُ إِبْرَاهِيمَ',
      15: 'سُورَةُ الحِجْرِ', 16: 'سُورَةُ النَّحْلِ',
      17: 'سُورَةُ الإِسْرَاءِ', 18: 'سُورَةُ الكَهْفِ',
      19: 'سُورَةُ مَرْيَمَ', 20: 'سُورَةُ طه',
      21: 'سُورَةُ الأَنبِيَاءِ', 22: 'سُورَةُ الحَجِّ',
      23: 'سُورَةُ المُؤْمِنُونَ', 24: 'سُورَةُ النُّورِ',
      25: 'سُورَةُ الفُرْقانِ', 26: 'سُورَةُ الشُّعَرَاءِ',
      27: 'سُورَةُ النَّمْلِ', 28: 'سُورَةُ القَصَصِ',
      29: 'سُورَةُ العَنكَبُوتِ', 30: 'سُورَةُ الرُّومِ',
      31: 'سُورَةُ لُقْمانَ', 32: 'سُورَةُ السَّجْدَةِ',
      33: 'سُورَةُ الأَحْزابِ', 34: 'سُورَةُ سَبَإٍ',
      35: 'سُورَةُ فَاطِرٍ', 36: 'سُورَةُ يس',
      37: 'سُورَةُ الصَّافَّاتِ', 38: 'سُورَةُ ص',
      39: 'سُورَةُ الزُّمَرِ', 40: 'سُورَةُ غَافِرٍ',
      41: 'سُورَةُ فُصِّلَتْ', 42: 'سُورَةُ الشُّورَىٰ',
      43: 'سُورَةُ الزُّخْرُفِ', 44: 'سُورَةُ الدُّخانِ',
      45: 'سُورَةُ الجَاثِيَةِ', 46: 'سُورَةُ الأَحْقافِ',
      47: 'سُورَةُ مُحَمَّدٍ', 48: 'سُورَةُ الفَتْحِ',
      49: 'سُورَةُ الحُجُرَاتِ', 50: 'سُورَةُ ق',
      51: 'سُورَةُ الذَّارِيَاتِ', 52: 'سُورَةُ الطُّورِ',
      53: 'سُورَةُ النَّجْمِ', 54: 'سُورَةُ القَمَرِ',
      55: 'سُورَةُ الرَّحْمَٰنِ', 56: 'سُورَةُ الوَاقِعَةِ',
      57: 'سُورَةُ الحَدِيدِ', 58: 'سُورَةُ المُجَادلَةِ',
      59: 'سُورَةُ الحَشْرِ', 60: 'سُورَةُ المُمْتَحنَةِ',
      61: 'سُورَةُ الصَّفِّ', 62: 'سُورَةُ الجُمُعَةِ',
      63: 'سُورَةُ المُنَافِقُونَ', 64: 'سُورَةُ التَّغَابُنِ',
      65: 'سُورَةُ الطَّلَاقِ', 66: 'سُورَةُ التَّحْرِيمِ',
      67: 'سُورَةُ المُلْكِ', 68: 'سُورَةُ القَلَمِ',
      69: 'سُورَةُ الحَاقَّةِ', 70: 'سُورَةُ المَعَارِجِ',
      71: 'سُورَةُ نُوحٍ', 72: 'سُورَةُ الجِنِّ',
      73: 'سُورَةُ المُزَّمِّلِ', 74: 'سُورَةُ المُدَّثِّرِ',
      75: 'سُورَةُ القِيَامَةِ', 76: 'سُورَةُ الإِنسانِ',
      77: 'سُورَةُ المُرْسَلاتِ', 78: 'سُورَةُ النَّبَإِ',
      79: 'سُورَةُ النَّازِعاتِ', 80: 'سُورَةُ عَبَسَ',
      81: 'سُورَةُ التَّكْوِيرِ', 82: 'سُورَةُ الانفِطارِ',
      83: 'سُورَةُ المُطَفِّفِينَ', 84: 'سُورَةُ الانشِقاقِ',
      85: 'سُورَةُ البُرُوجِ', 86: 'سُورَةُ الطَّارِقِ',
      87: 'سُورَةُ الأَعْلىٰ', 88: 'سُورَةُ الغَاشِيَةِ',
      89: 'سُورَةُ الفَجْرِ', 90: 'سُورَةُ البَلَدِ',
      91: 'سُورَةُ الشَّمْسِ', 92: 'سُورَةُ اللَّيْلِ',
      93: 'سُورَةُ الضُّحىٰ', 94: 'سُورَةُ الشَّرحِ',
      95: 'سُورَةُ التِّينِ', 96: 'سُورَةُ العَلَقِ',
      97: 'سُورَةُ القَدْرِ', 98: 'سُورَةُ البَيِّنَةِ',
      99: 'سُورَةُ الزَّلزَلَةِ', 100: 'سُورَةُ العَادِياتِ',
      101: 'سُورَةُ القَارِعةِ', 102: 'سُورَةُ التَّكاثُرِ',
      103: 'سُورَةُ العَصْرِ', 104: 'سُورَةُ الهُمَزةِ',
      105: 'سُورَةُ الفِيلِ', 106: 'سُورَةُ قُرَيْشٍ',
      107: 'سُورَةُ المَاعونِ', 108: 'سُورَةُ الكَوْثَرِ',
      109: 'سُورَةُ الكَافِرونَ', 110: 'سُورَةُ النَّصرِ',
      111: 'سُورَةُ المَسَدِ', 112: 'سُورَةُ الإخلاصِ',
      113: 'سُورَةُ الفَلَقِ', 114: 'سُورَةُ النَّاسِ',
    };
    return chapterNames[chapterNumber] ?? 'سُورَةُ مجهولة';
  }
}

// ── Background Starfield ──────────────────────────────────────────────────────

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
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.45 + 0.1;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Glow Blob ─────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
