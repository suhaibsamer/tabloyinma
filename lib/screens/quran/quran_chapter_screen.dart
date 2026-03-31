import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/models/quran_verse.dart';
import 'package:tabloy_iman/services/bookmark_service.dart';
import 'package:tabloy_iman/services/quran_audio_service.dart';
import 'package:tabloy_iman/utils/kurdish_styles.dart';
import 'package:tabloy_iman/widgets/font_size_controls.dart';
import 'package:tabloy_iman/services/theme_manager.dart';
import 'package:tabloy_iman/screens/quran/reciter_selection_screen.dart';
import 'dart:math' as math;
import 'dart:async';

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
  
  // Highlighting & Auto-scroll
  final Map<int, GlobalKey> _verseKeys = {};
  bool _isAutoScrollEnabled = true;
  Timer? _autoScrollTimer;
  int? _lastPlayedVerse;

  // ── Palette ──────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _teal      = Color(0xFF22D3EE);
  static const _tealDim   = Color(0xFF0E7490);
  static const _gold      = Color(0xFFFFD700);

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
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 140;
    if (show != _showAppBarTitle) setState(() => _showAppBarTitle = show);

    // Detect manual scroll
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      if (_isAutoScrollEnabled) {
        setState(() => _isAutoScrollEnabled = false);
      }
    }
  }

  void _scrollToVerse(int verseNumber) {
    if (!mounted) return;
    final key = _verseKeys[verseNumber];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  Future<void> _loadChapterVerses() async {
    try {
      await _quranService.loadQuranData();
      final verses = _quranService.getVersesForChapter(widget.chapterNumber);
      if (mounted) {
        setState(() { 
          _verses = verses; 
          _isLoading = false; 
          for (var v in verses) {
            _verseKeys[v.verse] = GlobalKey();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('هەڵەیەک ڕوویدا لە بارکردنی ئایەتەکان', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        ]),
        backgroundColor: const Color(0xFF1E1033),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isError ? Colors.red.shade700.withOpacity(0.5) : _teal.withOpacity(0.5)),
        ),
      ),
    );
  }

  Future<void> _playVerse(int index) async {
    try {
      setState(() => _isAutoScrollEnabled = true);
      await Provider.of<QuranAudioService>(context, listen: false).playPlaylist(_verses, index);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranAudioService>(
      builder: (context, audioService, child) {
        final currentVerse = audioService.currentVerse;
        
        // Auto-scroll logic if enabled
        if (_isAutoScrollEnabled && currentVerse != null && currentVerse.chapter == widget.chapterNumber) {
          if (_lastPlayedVerse != currentVerse.verse) {
            _lastPlayedVerse = currentVerse.verse;
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToVerse(currentVerse.verse));
          }
        }

        return Scaffold(
          backgroundColor: _deepSpace,
          floatingActionButton: currentVerse != null && !_isAutoScrollEnabled
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() => _isAutoScrollEnabled = true);
                    _scrollToVerse(currentVerse.verse);
                  },
                  backgroundColor: _teal,
                  icon: const Icon(Icons.center_focus_strong_rounded, color: _deepSpace),
                  label: Text('شوێنکەوتنی خوێندنەوە', style: KurdishStyles.getKurdishStyle(color: _deepSpace, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              : null,
          body: Stack(
            children: [
              const Positioned.fill(child: _StarfieldBackground()),
              Positioned(top: -60, left: -60, child: _GlowBlob(color: _tealDim.withOpacity(0.18), size: 260)),
              Positioned(top: 160, right: -40, child: _GlowBlob(color: const Color(0xFF7B5CF0).withOpacity(0.12), size: 200)),
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSliverAppBar(audioService),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const FontSizeControls(),
                        if (_isLoading) _buildLoadingState()
                        else if (_verses.isEmpty) _buildEmptyState(),
                      ],
                    ),
                  ),
                  if (!_isLoading && _verses.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
                      sliver: ValueListenableBuilder<double>(
                        valueListenable: ThemeManager().fontSizeDelta,
                        builder: (context, _, __) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final verse = _verses[index];
                                final isPlaying = currentVerse?.chapter == verse.chapter && currentVerse?.verse == verse.verse;
                                
                                // PERFORMANCE: Use RepaintBoundary for each verse card
                                return RepaintBoundary(
                                  key: _verseKeys[verse.verse],
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildVerseCard(verse, index, isPlaying, audioService),
                                  ),
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
      },
    );
  }

  Widget _buildSliverAppBar(QuranAudioService audioService) {
    return SliverAppBar(
      expandedHeight: 230,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _deepSpace,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: _moonGlow),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_search_rounded, color: _moonGlow),
          tooltip: 'هەڵبژاردنی قورئانخوێن',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReciterSelectionScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.download_for_offline_rounded, color: _moonGlow),
          onPressed: () {
            _showSnackBar('دابەزاندنی هەموو سوورەتەکە دەستی پێکرد...');
            audioService.downloadChapter(widget.chapterNumber, _verses).then((_) {
              _showSnackBar('سوورەتەکە بە سەرکەوتوویی دابەزێنرا');
            });
          },
        ),
      ],
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(widget.chapterName, style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 18)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: FadeTransition(opacity: _headerFade, child: _buildExpandedHeader()),
      ),
    );
  }

  Widget _buildExpandedHeader() {
    return Container(
      decoration: const BoxDecoration(color: _deepSpace),
      child: Stack(
        children: [
          Positioned(
            top: -40, left: -40, right: -40,
            child: Container(
              height: 300,
              decoration: BoxDecoration(gradient: RadialGradient(colors: [_teal.withOpacity(0.12), Colors.transparent], radius: 0.8)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 45),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: _teal.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: _teal.withOpacity(0.2), width: 1.5)),
                  child: const Center(child: Text('🕌', style: TextStyle(fontSize: 34))),
                ),
                const SizedBox(height: 18),
                Text(widget.chapterName, style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 24)),
                const SizedBox(height: 6),
                Text('سوورەتی ژمارە ${widget.chapterNumber}', style: KurdishStyles.getKurdishStyle(color: _teal.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(QuranVerse verse, int index, bool isPlaying, QuranAudioService audioService) {
    return FutureBuilder<bool>(
      future: _bookmarkService.isBookmarked(widget.chapterNumber, verse.verse),
      builder: (context, snapshot) {
        final isBookmarked = snapshot.data ?? false;
        
        return FutureBuilder<bool>(
          future: audioService.isDownloaded(widget.chapterNumber, verse.verse),
          builder: (context, downloadSnapshot) {
            final isDownloaded = downloadSnapshot.data ?? false;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: isPlaying ? _teal.withOpacity(0.08) : _midnight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isPlaying ? _teal.withOpacity(0.6) : _teal.withOpacity(0.15), width: isPlaying ? 2 : 1),
                boxShadow: [BoxShadow(color: isPlaying ? _teal.withOpacity(0.15) : _teal.withOpacity(0.06), blurRadius: isPlaying ? 20 : 16, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    if (isPlaying)
                      Positioned(
                        top: 10, left: 10,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) => Transform.scale(scale: 0.8 + (value * 0.2), child: Icon(Icons.graphic_eq_rounded, color: _teal, size: 22)),
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
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: _nebula, borderRadius: BorderRadius.circular(9), border: Border.all(color: isPlaying ? _teal.withOpacity(0.4) : Colors.white.withOpacity(0.06))),
                                    child: Center(child: Text('${index + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPlaying ? _teal : _moonGlow))),
                                  ),
                                  if (isDownloaded) const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.offline_pin_rounded, color: _teal, size: 16)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(color: isPlaying ? _teal.withOpacity(0.2) : _teal.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: isPlaying ? _teal.withOpacity(0.5) : _teal.withOpacity(0.28))),
                                child: Text('ئایەتی ${verse.verse}', style: KurdishStyles.getKurdishStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, isPlaying ? _teal.withOpacity(0.4) : _teal.withOpacity(0.18), Colors.transparent]))),
                          ),
                          Text(verse.text, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: KurdishStyles.getArabicStyle(color: isPlaying ? _gold : _starlight, fontSize: isPlaying ? 22 : 20)),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                label: 'پاشکەوت',
                                color: isBookmarked ? _teal : null,
                                onTap: () async {
                                  await _bookmarkService.toggleBookmark(widget.chapterNumber, verse.verse, widget.chapterName);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 10),
                              _buildActionButton(
                                icon: Icons.download_rounded,
                                label: isDownloaded ? 'دابەزێنراوە' : 'دابەزاندن',
                                color: isDownloaded ? _teal : null,
                                onTap: () => audioService.downloadVerse(widget.chapterNumber, verse.verse),
                              ),
                              const SizedBox(width: 10),
                              _buildActionButton(
                                icon: isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                                label: isPlaying ? 'ڕاگرتن' : 'گوێگرتن',
                                onTap: () => isPlaying ? audioService.stop() : _playVerse(index),
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
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, bool isPrimary = false, Color? color}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: isPrimary ? _teal.withOpacity(0.12) : _nebula, borderRadius: BorderRadius.circular(12), border: Border.all(color: isPrimary ? _teal.withOpacity(0.35) : Colors.white.withOpacity(0.06))),
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

  Widget _buildLoadingState() => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: _teal)));
  Widget _buildEmptyState() => const SizedBox(height: 300, child: Center(child: Text('هیچ ئایەتێک نییە', style: TextStyle(color: Colors.white))));
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(60, (i) => Offset(math.Random(i * 137).nextDouble(), math.Random(i * 137).nextDouble()));
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      paint.color = Colors.white.withOpacity(math.Random(i * 137).nextDouble() * 0.4 + 0.1);
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), math.Random(i * 137).nextDouble() * 1.2 + 0.3, paint);
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
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])));
}
