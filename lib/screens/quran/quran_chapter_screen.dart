import 'package:flutter/material.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/models/quran_verse.dart';
import 'package:tabloy_iman/services/bookmark_service.dart';
import 'package:tabloy_iman/utils/kurdish_styles.dart';
import 'package:tabloy_iman/widgets/font_size_controls.dart';
import 'package:tabloy_iman/services/theme_manager.dart';
import 'dart:math' as math;

class QuranChapterScreen extends StatefulWidget {
  final int chapterNumber;
  final String chapterName;

  const QuranChapterScreen({
    Key? key,
    required this.chapterNumber,
    required this.chapterName,
  }) : super(key: key);

  @override
  _QuranChapterScreenState createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen>
    with TickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  final BookmarkService _bookmarkService = BookmarkService();
  bool _isLoading = true;
  List<QuranVerse> _verses = [];
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _teal      = Color(0xFF22D3EE);
  static const _tealDim   = Color(0xFF0E7490);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerController.forward();

    _loadChapterVerses();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 140;
    if (show != _showAppBarTitle) setState(() => _showAppBarTitle = show);
  }

  Future<void> _loadChapterVerses() async {
    try {
      await _quranService.loadQuranData();
      final verses = _quranService.getVersesForChapter(widget.chapterNumber);
      if (mounted) setState(() { _verses = verses; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('هەڵەیەک ڕوویدا لە بارکردنی ئایەتەکان',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
            backgroundColor: const Color(0xFF1E1033),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade700.withOpacity(0.5)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          // Ambient glows
          Positioned(
            top: -60,
            left: -60,
            child: _GlowBlob(color: _tealDim.withOpacity(0.18), size: 260),
          ),
          Positioned(
            top: 160,
            right: -40,
            child: _GlowBlob(
                color: const Color(0xFF7B5CF0).withOpacity(0.12), size: 200),
          ),
          // Main scroll
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const FontSizeControls(),
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_verses.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
              if (!_isLoading && _verses.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                  sliver: ValueListenableBuilder<double>(
                    valueListenable: ThemeManager().fontSizeDelta,
                    builder: (context, _, __) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildVerseCard(_verses[index], index),
                          ),
                          childCount: _verses.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 230,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _deepSpace,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _moonGlow),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.chapterName,
          style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 18),
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
          // Teal glow backdrop
          Positioned(
            top: -40,
            left: -40,
            right: -40,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [_teal.withOpacity(0.12), Colors.transparent],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 45),
                // Decorative icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _teal.withOpacity(0.2), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('🕌', style: TextStyle(fontSize: 34)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.chapterName,
                  style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'سوورەتی ژمارە ${widget.chapterNumber}',
                  style: KurdishStyles.getKurdishStyle(color: _teal.withOpacity(0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(QuranVerse verse, int index) {
    return FutureBuilder<bool>(
      future: _bookmarkService.isBookmarked(widget.chapterNumber, verse.verse),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        return Container(
          decoration: BoxDecoration(
            color: _midnight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _teal.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: _teal.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _teal.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _nebula,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _moonGlow,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _teal.withOpacity(0.28),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'ئایەتی ${verse.verse}',
                              style: KurdishStyles.getKurdishStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _teal.withOpacity(0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Verse text
                      Text(
                        verse.text,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: KurdishStyles.getArabicStyle(color: _starlight, fontSize: 20),
                      ),
                      const SizedBox(height: 18),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(
                            icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            label: 'پاشکەوت',
                            color: isBookmarked ? _teal : null,
                            onTap: () async {
                              await _bookmarkService.toggleBookmark(
                                  widget.chapterNumber, verse.verse, widget.chapterName);
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            label: 'ناردن',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _buildActionButton(
                            icon: Icons.volume_up_rounded,
                            label: 'گوێگرتن',
                            onTap: () {},
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary ? _teal.withOpacity(0.12) : _nebula,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? _teal.withOpacity(0.35) : Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color ?? (isPrimary ? _teal : _moonGlow.withOpacity(0.45)), size: 18),
              const SizedBox(height: 4),
              Text(label, style: KurdishStyles.getKurdishStyle(fontSize: 10, color: color ?? (isPrimary ? _teal : _moonGlow.withOpacity(0.45)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: _teal)));
  }

  Widget _buildEmptyState() {
    return const SizedBox(height: 300, child: Center(child: Text('هیچ ئایەتێک نییە', style: TextStyle(color: Colors.white))));
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(60, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.4 + 0.1;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), radius, paint);
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
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
    );
  }
}
