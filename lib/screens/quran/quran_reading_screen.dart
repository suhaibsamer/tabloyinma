import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'package:tabloy_iman/models/quran_verse.dart';
import 'package:tabloy_iman/services/quran_metadata.dart';
import 'package:tabloy_iman/services/quran_audio_service.dart';
import 'package:tabloy_iman/utils/kurdish_styles.dart';
import 'package:tabloy_iman/widgets/font_size_controls.dart';
import 'package:tabloy_iman/services/theme_manager.dart';
import 'package:tabloy_iman/screens/quran/reciter_selection_screen.dart';
import 'dart:math' as math;
import 'dart:async';

class QuranReadingScreen extends StatefulWidget {
  final int startGlobalIndex;
  final int endGlobalIndex;
  final String title;
  final bool isHifzMode;

  const QuranReadingScreen({
    Key? key,
    required this.startGlobalIndex,
    required this.endGlobalIndex,
    required this.title,
    this.isHifzMode = false,
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
  
  final Map<int, GlobalKey> _verseKeys = {};
  bool _isAutoScrollEnabled = true;
  int? _lastPlayedVerseIdx;

  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _accent    = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);
  static const _gold      = Color(0xFFFFD700);
  static const _teal      = Color(0xFF22D3EE);
  static const _green     = Color(0xFF34D399);

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
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      if (_isAutoScrollEnabled) setState(() => _isAutoScrollEnabled = false);
    }
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
          for (int i = 0; i < _verses.length; i++) {
            _verseKeys[start + i] = GlobalKey();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToVerse(int globalIdx) {
    if (!mounted) return;
    final key = _verseKeys[globalIdx];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranAudioService>(
      builder: (context, audioService, child) {
        final currentVerse = audioService.currentVerse;
        final currentGlobalIdx = audioService.currentIndex;

        if (_isAutoScrollEnabled && currentVerse != null) {
          if (_lastPlayedVerseIdx != currentGlobalIdx) {
            _lastPlayedVerseIdx = currentGlobalIdx;
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToVerse(currentGlobalIdx));
          }
        }

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
                  _buildSliverAppBar(audioService),
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
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                      sliver: ValueListenableBuilder<double>(
                        valueListenable: ThemeManager().fontSizeDelta,
                        builder: (context, _, __) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final globalIdx = widget.startGlobalIndex + index;
                                final verse = _verses[index];
                                final bool showHeader = index == 0 || verse.chapter != _verses[index - 1].chapter;
                                final isPlaying = currentGlobalIdx == globalIdx;

                                return Column(
                                  key: _verseKeys[globalIdx],
                                  children: [
                                    if (showHeader) _buildSurahHeader(verse.chapter),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: _buildVerseCard(verse, isPlaying, audioService, globalIdx),
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
              if (widget.isHifzMode || audioService.player.playing)
                _buildAudioControls(audioService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(QuranAudioService audioService) {
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
      actions: [
        IconButton(
          icon: const Icon(Icons.person_search_rounded, color: _moonGlow),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReciterSelectionScreen())),
        ),
      ],
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

  Widget _buildVerseCard(QuranVerse verse, bool isPlaying, QuranAudioService audioService, int globalIdx) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isPlaying ? _accent.withOpacity(0.08) : _midnight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isPlaying ? _accent.withOpacity(0.6) : _accent.withOpacity(0.1), width: isPlaying ? 2 : 1),
          boxShadow: isPlaying ? [BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 20)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'ئایەتی ${verse.verse}',
                      style: KurdishStyles.getKurdishStyle(color: isPlaying ? _accent : _accent.withOpacity(0.7), fontSize: 12, fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
                    ),
                    if (isPlaying) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.volume_up_rounded, color: _accent, size: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    audioService.playPlaylist(_verses, globalIdx - widget.startGlobalIndex);
                  },
                  child: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, color: isPlaying ? _accent : _moonGlow.withOpacity(0.3), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              verse.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: KurdishStyles.getArabicStyle(fontSize: 22, color: isPlaying ? _gold : _starlight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls(QuranAudioService audioService) {
    return Positioned(
      left: 20, right: 20, bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _midnight.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: _accent),
                  onPressed: () => _showHifzSettings(audioService),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (audioService.currentVerse != null)
                        Text(
                          '${QuranMetadata.getSurahName(audioService.currentVerse!.chapter)} - ئایەتی ${audioService.currentVerse!.verse}',
                          style: KurdishStyles.getKurdishStyle(color: _starlight, fontSize: 13, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (audioService.isHifzMode)
                        Text(
                          'دۆخی لەبەرکردن (دووبارەبوونەوە: ${audioService.repeatCount == -1 ? "∞" : audioService.repeatCount}x)',
                          style: TextStyle(color: _teal, fontSize: 10),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isAutoScrollEnabled ? Icons.sync : Icons.sync_disabled, color: _isAutoScrollEnabled ? _green : _moonGlow.withOpacity(0.4)),
                  onPressed: () => setState(() => _isAutoScrollEnabled = !_isAutoScrollEnabled),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous_rounded, color: _starlight, size: 32), onPressed: () => audioService.skipToPrevious()),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => audioService.player.playing ? audioService.pause() : audioService.play(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 12)]),
                    child: Icon(audioService.player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.skip_next_rounded, color: _starlight, size: 32), onPressed: () => audioService.skipToNext()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHifzSettings(QuranAudioService audioService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _midnight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _starlight.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 24),
                  const Text('ڕێکخستنەکانی لەبەرکردن', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildSettingRow(
                    'ژمارەی دووبارەبوونەوە',
                    DropdownButton<int>(
                      dropdownColor: _midnight,
                      value: audioService.repeatCount,
                      items: [1, 3, 5, 10, -1].map((e) => DropdownMenuItem(value: e, child: Text(e == -1 ? '∞' : '${e}x', style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          audioService.setRepeatCount(val);
                          setModalState(() {});
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  _buildSettingRow(
                    'ماوەی وەستان لە نێوان ئایەتەکان',
                    DropdownButton<int>(
                      dropdownColor: _midnight,
                      value: audioService.gapDuration.inSeconds,
                      items: [0, 2, 5, 8, 10].map((e) => DropdownMenuItem(value: e, child: Text('${e}s', style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          audioService.setGapDuration(Duration(seconds: val));
                          setModalState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: _accent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('پاشکەوتکردن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          trailing,
          Text(label, style: const TextStyle(color: _moonGlow, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: _accent)));
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) => Offset(math.Random(i * 137).nextDouble(), math.Random(i * 137).nextDouble()));
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      paint.color = Colors.white.withOpacity(rng.nextDouble() * 0.45 + 0.1);
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), rng.nextDouble() * 1.2 + 0.3, paint);
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
