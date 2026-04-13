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
import 'dart:ui';

// ── Palette ──────────────────────────────────────────────────────────────
const _bg = Color(0xFF070B14);
const _bg2 = Color(0xFF0E1423);
const _surface = Color(0xFF111827);
const _surface2 = Color(0xFF182133);
const _card = Color(0xFF121A2B);
const _text = Color(0xFFF8FAFC);
const _subText = Color(0xFFB8C1D1);
const _accent = Color(0xFF8B5CF6);
const _accent2 = Color(0xFF6366F1);
const _gold = Color(0xFFFBBF24);
const _teal = Color(0xFF22D3EE);
const _green = Color(0xFF34D399);
const _danger = Color(0xFFF43F5E);

class QuranReadingScreen extends StatefulWidget {
  final int startGlobalIndex;
  final int endGlobalIndex;
  final String title;
  final bool isHifzMode;

  const QuranReadingScreen({
    super.key,
    required this.startGlobalIndex,
    required this.endGlobalIndex,
    required this.title,
    this.isHifzMode = false,
  });

  @override
  State<QuranReadingScreen> createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen>
    with TickerProviderStateMixin {
  final QuranService _quranService = QuranService();

  bool _isLoading = true;
  List<QuranVerse> _verses = [];
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;
  bool _isAutoScrollEnabled = true;
  int? _lastPlayedVerseIdx;

  final Map<int, GlobalKey> _verseKeys = {};

  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<double> _headerScale;

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
      curve: Curves.easeOutCubic,
    );

    _headerScale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );

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
    final show = _scrollController.offset > 120;
    if (show != _showAppBarTitle) {
      setState(() => _showAppBarTitle = show);
    }

    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      if (_isAutoScrollEnabled) {
        setState(() => _isAutoScrollEnabled = false);
      }
    }
  }

  Future<void> _loadVerses() async {
    try {
      await _quranService.loadQuranData();
      final all = _quranService.flattenedVerses;

      final start = widget.startGlobalIndex.clamp(0, all.length - 1);
      final end = widget.endGlobalIndex.clamp(0, all.length - 1);

      if (!mounted) return;

      setState(() {
        _verses = all.sublist(start, end + 1);
        for (int i = 0; i < _verses.length; i++) {
          _verseKeys[start + i] = GlobalKey();
        }
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToVerse(int globalIdx) {
    if (!mounted) return;
    final key = _verseKeys[globalIdx];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: 0.35,
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToVerse(currentGlobalIdx);
            });
          }
        }

        return Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              const Positioned.fill(child: _ModernBackground()),

              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(audioService),

                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const FontSizeControls(),
                        if (_isLoading) _buildLoadingState(),
                      ],
                    ),
                  ),

                  if (!_isLoading && _verses.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                      sliver: ValueListenableBuilder<double>(
                        valueListenable: ThemeManager().fontSizeDelta,
                        builder: (context, _, __) {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final globalIdx = widget.startGlobalIndex + index;
                                final verse = _verses[index];
                                final bool showHeader = index == 0 ||
                                    verse.chapter != _verses[index - 1].chapter;
                                final bool isPlaying =
                                    currentGlobalIdx == globalIdx;

                                return Column(
                                  key: _verseKeys[globalIdx],
                                  children: [
                                    if (showHeader)
                                      _buildSurahHeader(verse.chapter),

                                    Padding(
                                      padding:
                                      const EdgeInsets.only(bottom: 14),
                                      child: _buildVerseCard(
                                        verse,
                                        isPlaying,
                                        audioService,
                                        globalIdx,
                                      ),
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
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: _bg.withValues(alpha: 0.9),
      centerTitle: true,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: _showAppBarTitle ? 1 : 0,
        child: Text(
          widget.title,
          style: KurdishStyles.getTitleStyle(
            color: _text,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _text),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (widget.isHifzMode)
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: _accent),
            onPressed: () => _showHifzSettings(audioService),
          ),
        IconButton(
          icon: const Icon(Icons.person_search_rounded, color: _text),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReciterSelectionScreen(),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: FadeTransition(
          opacity: _headerFade,
          child: ScaleTransition(
            scale: _headerScale,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 92, 18, 20),
              child: _buildHeroHeader(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [_surface2, _surface],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_accent, _accent2],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '📖',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'خوێندنەوەی قورئان',
                        textAlign: TextAlign.right,
                        style: KurdishStyles.getKurdishStyle(
                          color: _subText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        textAlign: TextAlign.right,
                        style: KurdishStyles.getTitleStyle(
                          fontSize: 22,
                          color: _text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          '${_verses.length} ئایەت',
                          style: KurdishStyles.getKurdishStyle(
                            color: _text,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(int chapterNumber) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accent.withValues(alpha: 0.16),
            _accent2.withValues(alpha: 0.08),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _accent.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              QuranMetadata.getSurahName(chapterNumber),
              textAlign: TextAlign.right,
              style: KurdishStyles.getArabicStyle(
                fontSize: 21,
                color: _text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(
      QuranVerse verse,
      bool isPlaying,
      QuranAudioService audioService,
      int globalIdx,
      ) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPlaying
                ? [
              _accent.withValues(alpha: 0.16),
              _card.withValues(alpha: 0.98),
            ]
                : [
              _card.withValues(alpha: 0.98),
              _surface.withValues(alpha: 0.92),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPlaying
                ? _accent.withValues(alpha: 0.60)
                : Colors.white.withValues(alpha: 0.08),
            width: isPlaying ? 1.6 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPlaying
                  ? _accent.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.16),
              blurRadius: isPlaying ? 24 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? _accent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPlaying
                          ? _accent.withValues(alpha: 0.32)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    isPlaying
                        ? '${audioService.currentRepeat + 1}/${audioService.repeatCount == -1 ? "∞" : audioService.repeatCount}'
                        : '#${verse.verse}',
                    style: TextStyle(
                      color: isPlaying ? _text : _subText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                if (isPlaying)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: _accent,
                      size: 18,
                    ),
                  ),
                Text(
                  'ئایەتی ${verse.verse}',
                  style: KurdishStyles.getKurdishStyle(
                    color: isPlaying ? _accent : _subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verse.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: KurdishStyles.getArabicStyle(
                fontSize: 23,
                color: isPlaying ? _gold : _text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls(QuranAudioService audioService) {
    return Positioned(
      left: 14,
      right: 14,
      bottom: 14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.26),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _smallActionButton(
                      icon: Icons.tune_rounded,
                      color: _accent,
                      onTap: () => _showHifzSettings(audioService),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          if (audioService.currentVerse != null)
                            Text(
                              '${QuranMetadata.getSurahName(audioService.currentVerse!.chapter)} - ئایەتی ${audioService.currentVerse!.verse}',
                              textAlign: TextAlign.center,
                              style: KurdishStyles.getKurdishStyle(
                                color: _text,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 3),
                          if (audioService.isHifzMode)
                            Text(
                              'دۆخی فێربوون • ${audioService.currentRepeat + 1}/${audioService.repeatCount == -1 ? "∞" : audioService.repeatCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _teal,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _smallActionButton(
                      icon: _isAutoScrollEnabled
                          ? Icons.sync_rounded
                          : Icons.sync_disabled_rounded,
                      color: _isAutoScrollEnabled ? _green : _danger,
                      onTap: () {
                        setState(() {
                          _isAutoScrollEnabled = !_isAutoScrollEnabled;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => audioService.skipToPrevious(),
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: _text,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () {
                        audioService.player.playing
                            ? audioService.pause()
                            : audioService.play();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_accent, _accent2],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.40),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          audioService.player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    IconButton(
                      onPressed: () => audioService.skipToNext(),
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: _text,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showHifzSettings(QuranAudioService audioService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 80),
              decoration: const BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ڕێکخستنەکانی فێربوون و لەبەرکردن',
                        style: TextStyle(
                          color: _text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 18),

                      _modernSettingTile(
                        title: 'ژمارەی دووبارەبوونەوە',
                        child: DropdownButton<int>(
                          dropdownColor: _surface2,
                          value: audioService.repeatCount,
                          underline: const SizedBox(),
                          style: const TextStyle(color: _text),
                          items: [1, 3, 5, 10, -1]
                              .map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e == -1 ? '∞' : '${e}x',
                                style: const TextStyle(color: _text),
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              audioService.setRepeatCount(val);
                              setModalState(() {});
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      _modernSettingTile(
                        title: 'ماوەی بێدەنگی',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'سمارت',
                              style: TextStyle(
                                color: _subText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch(
                              value: audioService.isSmartGap,
                              activeColor: _accent,
                              onChanged: (val) {
                                audioService.setSmartGap(val);
                                setModalState(() {});
                              },
                            ),
                            if (!audioService.isSmartGap)
                              DropdownButton<int>(
                                dropdownColor: _surface2,
                                value: audioService.gapDuration.inSeconds,
                                underline: const SizedBox(),
                                style: const TextStyle(color: _text),
                                items: [0, 2, 5, 8, 10]
                                    .map(
                                      (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      '${e}s',
                                      style:
                                      const TextStyle(color: _text),
                                    ),
                                  ),
                                )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    audioService.setGapDuration(
                                      Duration(seconds: val),
                                    );
                                    setModalState(() {});
                                  }
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _modernSettingTile(
                        title: 'خێرایی خوێندنەوە',
                        child: DropdownButton<double>(
                          dropdownColor: _surface2,
                          value: audioService.playbackSpeed,
                          underline: const SizedBox(),
                          style: const TextStyle(color: _text),
                          items: [0.5, 0.75, 1.0, 1.25, 1.5]
                              .map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                '${e}x',
                                style: const TextStyle(color: _text),
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              audioService.setPlaybackSpeed(val);
                              setModalState(() {});
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'پێشنیاری دەنگی مامۆستا',
                        style: TextStyle(
                          color: _subText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          _buildReciterChip(
                            audioService,
                            'Husary_64kbps',
                            'حسەری',
                            setModalState,
                          ),
                          _buildReciterChip(
                            audioService,
                            'Minshawi_Mujawwad_128kbps',
                            'مەنشاوی',
                            setModalState,
                          ),
                          _buildReciterChip(
                            audioService,
                            'Alafasy_128kbps',
                            'عەفاسی',
                            setModalState,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'پاشکەوتکردن',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _modernSettingTile({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _surface2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          child,
          const Spacer(),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterChip(
      QuranAudioService audioService,
      String id,
      String name,
      StateSetter setModalState,
      ) {
    final isSelected = audioService.reciterId == id;

    return GestureDetector(
      onTap: () {
        audioService.setReciter(id);
        setModalState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accent : _surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _accent
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _accent.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : _subText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 280,
      child: Center(
        child: CircularProgressIndicator(color: _accent),
      ),
    );
  }
}

class _ModernBackground extends StatelessWidget {
  const _ModernBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bg, _bg2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -50,
          child: _GlowCircle(
            color: _accent.withValues(alpha: 0.16),
            size: 220,
          ),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _GlowCircle(
            color: _teal.withValues(alpha: 0.10),
            size: 180,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _StarfieldPainter(),
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(
    85,
        (i) => Offset(
      math.Random(i * 131).nextDouble(),
      math.Random(i * 173).nextDouble(),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 97);
      paint.color = Colors.white.withValues(alpha: 
        rng.nextDouble() * 0.28 + 0.05,
      );

      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        rng.nextDouble() * 1.4 + 0.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
