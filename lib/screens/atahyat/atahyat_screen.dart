import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../widgets/font_size_controls.dart';
import '../../services/theme_manager.dart';
import '../../utils/info_utils.dart';

class AtahyatScreen extends StatelessWidget {
  const AtahyatScreen({super.key});

  static const _bg = Color(0xFF070B14);
  static const _bg2 = Color(0xFF0D1324);
  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);
  static const _accent = Color(0xFF7C5CFF);
  static const _accent2 = Color(0xFF46C2FF);
  static const _gold = Color(0xFFFFD36E);
  static const _line = Color(0x26FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تەحیات',
          style: KurdishStyles.getTitleStyle(
            color: _textPrimary,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: _textPrimary),
            onPressed: () => InfoUtils.showInfo(
              context,
              title: 'تەحیات',
              description: 'فێربوونی تەحیات و سەڵاوات و دوعاکانی نێو نوێژ.',
              howToUse: 'دەتوانیت دەقەکان بخوێنیتەوە و گوێ لە دەربڕینی ڕاستیان بگریت.',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg, _bg2],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTopHero(),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: FontSizeControls(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: ThemeManager().fontSizeDelta,
                      builder: (context, _, _) {
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            _buildSectionCard(
                              icon: Icons.auto_awesome_rounded,
                              badge: 'ذکر',
                              title: 'التَّحِيَّاتُ',
                              subtitle: 'دەقی عەرەبی و وەرگێڕانی کوردی',
                              arabic:
                                  'التَّحِيَّاتُ لِلَّهِ وَالصَّلَواتُ وَالطَّيِّباتُ، السَّلامُ عَلَيْكَ أيُّها النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَکاتُهُ، السَّلامُ عَلَيْنا وَعَلَى عِبادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لا إلَهَ إلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.',
                              kurdish:
                                  'سڵاو و نزا و پاکی و بێگەردی بۆ خودایە، سڵاو لەسەر تۆ بێت ئەی پێغەمبەر و ڕەحمەت و بەرەکەتەکانی خودات لێبێت، سڵاو لەسەر ئێمە و لەسەر هەموو بەندە چاکەکانی خودا بێت، شایەتی دەدەم کە هیچ خودایەک نییە شایستەی پەرستن بێت جگە لە الله، و شایەتی دەدەم کە محمد بەندە و نێردراوی خودایە.',
                            ),
                            const SizedBox(height: 18),
                            _buildSectionCard(
                              icon: Icons.favorite_rounded,
                              badge: 'دروود',
                              title: 'الصَّلَواتُ',
                              subtitle: 'سەڵاوات لەسەر پێغەمبەر ﷺ',
                              arabic:
                                  'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، کَمَا صَلَّيْتَ عَلَى إبْرَاهِيمَ وَعَلَى آلِ إبْرَاهِيمَ، إنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، کَمَا بَارَکتَ عَلَى إبْرَاهِيمَ وَعَلَى آلِ إبْرَاهِيمَ، إنَّكَ حَمِيدٌ مَجِيدٌ.',
                              kurdish:
                                  'خودایە سەڵاوات و دروود بنێرە بۆ سەر محمد و ئال و بەیتی محمد، هەروەک چۆن سەڵاواتت نارد بۆ سەر ئیبراهیم و ئال و بەیتی ئیبراهیم، بەڕاستی تۆ سوپاسکراو و خاوەن شکۆیت. خودایە بەرەکەت بڕژێنە بەسەر محمد و ئال و بەیتی محمد، هەروەک چۆن بەرەکەتت ڕشت بەسەر ئیبراهیم و ئال و بەیتی ئیبراهیم، بەڕاستی تۆ سوپاسکراو و خاوەن شکۆیت.',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.18),
                  blurRadius: 90,
                  spreadRadius: 25,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -40,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent2.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: _accent2.withValues(alpha: 0.12),
                  blurRadius: 90,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [_accent, _accent2],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'بە شێوازێکی نوێ بخوێنەوە',
                        textAlign: TextAlign.right,
                        style: KurdishStyles.getKurdishStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'تەحیات و سەڵاوات',
                        textAlign: TextAlign.right,
                        style: KurdishStyles.getTitleStyle(
                          color: _textPrimary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'دەقی عەرەبی لەگەڵ وەرگێڕانی کوردی بە دیزاینێکی سادە و مۆدێرن',
                        textAlign: TextAlign.right,
                        style: KurdishStyles.getKurdishStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String badge,
    required String title,
    required String subtitle,
    required String arabic,
    required String kurdish,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                _surface.withValues(alpha: 0.92),
                _surface2.withValues(alpha: 0.88),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 16),
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
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _gold.withValues(alpha: 0.20)),
                    ),
                    child: Text(
                      badge,
                      style: KurdishStyles.getKurdishStyle(
                        color: _gold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          _accent.withValues(alpha: 0.95),
                          _accent2.withValues(alpha: 0.95),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.right,
                style: KurdishStyles.getTitleStyle(
                  color: _textPrimary,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: KurdishStyles.getKurdishStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _line),
                ),
                child: Text(
                  arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: KurdishStyles.getArabicStyle(
                    color: _textPrimary,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Text(
                  kurdish,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: KurdishStyles.getKurdishStyle(
                    color: _textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
