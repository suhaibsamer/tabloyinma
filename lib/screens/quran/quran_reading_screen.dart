import 'package:flutter/material.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/models/quran_verse.dart';
import 'package:tabloy_iman/services/quran_metadata.dart';
import 'package:tabloy_iman/utils/kurdish_styles.dart';
import 'package:tabloy_iman/widgets/font_size_controls.dart';
import 'package:tabloy_iman/services/theme_manager.dart';
import 'dart:math' as math;

class QuranReadingScreen extends StatefulWidget {
  final int startGlobalIndex;
  final int endGlobalIndex;
  final String title;

  const QuranReadingScreen({
    Key? key,
    required this.startGlobalIndex,
    required this.endGlobalIndex,
    required this.title,
  }) : super(key: key);

  @override
  _QuranReadingScreenState createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen>
    with TickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  bool _isLoading = true;
  List<QuranVerse> _verses = [];
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _headerController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
    _loadVerses();
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

  Future<void> _loadVerses() async {
    try {
      await _quranService.loadQuranData();
      final all = _quranService.flattenedVerses;
      int start = widget.startGlobalIndex.clamp(0, all.length - 1);
      int end = widget.endGlobalIndex.clamp(0, all.length - 1);
      
      if (mounted) {
        setState(() {
          _verses = all.sublist(start, end + 1);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Positioned(
            top: -60, left: -60,
            child: _GlowBlob(color: _accentDim.withOpacity(0.18), size: 260),
          ),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const FontSizeControls(),
                    if (_isLoading) _buildLoadingState(),
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
                          (context, index) {
                            final verse = _verses[index];
                            final bool showHeader = index == 0 || verse.chapter != _verses[index - 1].chapter;
                            
                            return Column(
                              children: [
                                if (showHeader) _buildSurahHeader(verse.chapter),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildVerseCard(verse),
                                ),
                              ],
                            );
                          },
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _deepSpace,
      elevation: 0,
      centerTitle: true,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(widget.title, style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 18)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerFade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent.withOpacity(0.3)),
                  ),
                  child: const Text('📖', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: KurdishStyles.getTitleStyle(fontSize: 22, color: _starlight)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahHeader(int chapterNumber) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accent.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          QuranMetadata.getSurahName(chapterNumber),
          style: KurdishStyles.getArabicStyle(fontSize: 20, color: _accent),
        ),
      ),
    );
  }

  Widget _buildVerseCard(QuranVerse verse) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _midnight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ئایەتی ${verse.verse}',
                style: KurdishStyles.getKurdishStyle(color: _accent.withOpacity(0.7), fontSize: 12),
              ),
              Text(
                QuranMetadata.getSurahName(verse.chapter),
                style: KurdishStyles.getKurdishStyle(color: _moonGlow.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verse.text,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: KurdishStyles.getArabicStyle(fontSize: 20, color: _starlight),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: _accent)));
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
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
