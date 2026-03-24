import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../widgets/font_size_controls.dart';
import '../../services/theme_manager.dart';

class AtahyatScreen extends StatelessWidget {
  const AtahyatScreen({super.key});

  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _accentDim = Color(0xFF7B5CF0);
  static const _gold = Color(0xFFFFD97D);
  static const _divider = Color(0xFF252A45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تەحیات',
          style: KurdishStyles.getTitleStyle(color: _starlight),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _starlight, size: 20),
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
        child: Column(
          children: [
            const FontSizeControls(),
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: ThemeManager().fontSizeDelta,
                builder: (context, _, __) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionCard(
                          title: 'التَّحِيَّاتُ (تەحیات)',
                          arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَواتُ وَالطَّيِّباتُ، السَّلامُ عَلَيْكَ أيُّها النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَکاتُهُ، السَّلامُ عَلَيْنا وَعَلَى عِبادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لا إلَهَ إلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.',
                          kurdish: 'سڵاو و نزا و پاكی و بێگەردی بۆ خودایە، سڵاو لەسەر تۆ بێت ئەی پێغەمبەر و ڕەحمەت و بەرەکەتەکانی خودات لێبێت، سڵاو لەسەر ئێمە و لەسەر هەموو بەندە چاکەکانی خودا بێت، شایەتی دەدەم کە هیچ خودایەک نییە شایستەی پەرستن بێت جگە لە (الله) و شایەتی دەدەم کە محمد بەندە و نێردراوی خودایە.',
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          title: 'الصَّلَواتُ (سەڵاوات)',
                          arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، کَمَا صَلَّيْتَ عَلَى إبْرَاهِيمَ وَعَلَى آلِ إبْرَاهِيمَ، إنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، کَمَا بَارَکتَ عَلَى إبْرَاهِيمَ وَعَلَى آلِ إبْرَاهِيمَ، إنَّكَ حَمِيدٌ مَجِيدٌ.',
                          kurdish: 'خودایە سەڵاوات و دروود بنێرە بۆ سەر محمد و ئال و بەیتی محمد، هەروەک چۆن سەڵاواتت نارد بۆ سەر ئیبراهیم و ئال و بەیتی ئیبراهیم، بەڕاستی تۆ سوپاسکراو و خاوەن شکۆیت. خودایە بەرەکەت بڕژێنە بەسەر محمد و ئال و بەیتی محمد، هەروەک چۆن بەرەکەتت ڕشت بەسەر ئیبراهیم و ئال و بەیتی ئیبراهیم، بەڕاستی تۆ سوپاسکراو و خاوەن شکۆیت.',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String arabic, required String kurdish}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: KurdishStyles.getTitleStyle(color: _accent, fontSize: 16),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          const Divider(color: _divider, thickness: 1),
          const SizedBox(height: 16),
          Text(
            arabic,
            textAlign: TextAlign.right,
            style: KurdishStyles.getArabicStyle(color: _starlight),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _midnight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accent.withOpacity(0.08)),
            ),
            child: Text(
              kurdish,
              textAlign: TextAlign.right,
              style: KurdishStyles.getKurdishStyle(color: _moonGlow.withOpacity(0.85)),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
