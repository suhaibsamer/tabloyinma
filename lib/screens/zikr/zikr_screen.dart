import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../widgets/font_size_controls.dart';
import '../../services/theme_manager.dart';
import '../../utils/info_utils.dart';

class ZikrScreen extends StatefulWidget {
  final String initialCategory; // 'morning', 'evening', 'sleep'
  const ZikrScreen({super.key, this.initialCategory = 'morning'});

  @override
  State<ZikrScreen> createState() => _ZikrScreenState();
}

class _ZikrScreenState extends State<ZikrScreen> {
  late String _selectedCategory;

  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);

  final Map<String, List<ZikrItem>> _zikrData = {
    'morning': [
      ZikrItem(
        arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        kurdish: 'گەیشتینە بەیانی و پاشایەتی بۆ خودایە، سوپاس بۆ خودا، هیچ پەرستراوێک نییە تەنها (الله) نەبێت کە تاک و تەنهایە و هاوبەشی نییە، هەموو دەسەڵات و سوپاسێک بۆ ئەوە و ئەویش بەسەر هەموو شتێکدا بەدەسەڵاتە.',
        count: 1,
      ),
      ZikrItem(
        arabic: 'بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
        kurdish: 'بە ناوی ئەو خودایەی کە بە ناوی ئەو هیچ شتێک لە زەوی و لە ئاسماندا زیان ناگەیەنێت و ئەو بیسەر و زانایە.',
        count: 3,
      ),
      ZikrItem(
        arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
        kurdish: 'ئەی ئەو خودایەی کە هەمیشە زیندوویت، بە ڕەحمەتی تۆ داوای یارمەتی دەکەم، هەموو کارەکانم بۆ چاک بکە و بۆ چاوتروکانێکیش نەمخەیتە ئەستۆی خۆم.',
        count: 1,
      ),
    ],
    'evening': [
      ZikrItem(
        arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        kurdish: 'گەیشتینە ئێوارە و پاشایەتی بۆ خودایە، سوپاس بۆ خودا، هیچ پەرستراوێک نییە تەنها (الله) نەبێت کە تاک و تەنهایە.',
        count: 1,
      ),
      ZikrItem(
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        kurdish: 'پەنا دەگرم بە وشە تەواوەکانی خودا لە شەڕ و خراپەی دروستکراوەکانی.',
        count: 3,
      ),
      ZikrItem(
        arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
        kurdish: 'خودایە بە یارمەتی تۆ گەیشتینە ئێوارە و بە تۆش دەگەینە بەیانی، و بە ویستی تۆ دەژین و دەمرین و گەڕانەوەمان هەر بۆ لای تۆیە.',
        count: 1,
      ),
    ],
    'sleep': [
      ZikrItem(
        arabic: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا، بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
        kurdish: 'پەروەردگارم بە ناوی تۆوە پاڵکەوتم و بە ناوی تۆشەوە هەڵدەستم، ئەگەر گیانمت کێشا ڕەحمەتت لێی بێت و ئەگەر نەتکێشا بیپارێزە وەک چۆن بەندە چاکەکانت دەپارێزیت.',
        count: 1,
      ),
      ZikrItem(
        arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        kurdish: 'خودایە بمپارێزە لە سزاکەت لەو ڕۆژەی کە بەندەکانت زیندوو دەکەیتەوە.',
        count: 3,
      ),
      ZikrItem(
        arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        kurdish: 'خودایە بە ناوی تۆوە دەمرم و دەژیم.',
        count: 1,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'زیکرەکان',
          style: KurdishStyles.getTitleStyle(color: _starlight),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _starlight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: _starlight),
            onPressed: () => InfoUtils.showInfo(
              context,
              title: 'زیکرەکان',
              description: 'زیکرەکانی بەیانیان و ئێواران و دوای نوێژەکان.',
              howToUse: 'زیکرەکان بە دوای یەکدا بخوێنەوە، هەر زیکرێک تەواو بوو کلیکی لێ بکە بۆ ئەوەی بڕواتە سەر زیکری دواتر.',
            ),
          ),
        ],
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
            _buildCategoryTabs(),
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: ThemeManager().fontSizeDelta,
                builder: (context, _, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _zikrData[_selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      return _buildZikrCard(_zikrData[_selectedCategory]![index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildTab('بەیانیان', 'morning'),
          _buildTab('ئێواران', 'evening'),
          _buildTab('پێش خەوتن', 'sleep'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String category) {
    bool isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: KurdishStyles.getKurdishStyle(
              fontSize: 14,
              color: isSelected ? _deepSpace : _starlight.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZikrCard(ZikrItem zikr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            zikr.arabic,
            textAlign: TextAlign.center,
            style: KurdishStyles.getArabicStyle(color: _starlight),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          Text(
            zikr.kurdish,
            textAlign: TextAlign.right,
            style: KurdishStyles.getKurdishStyle(color: _moonGlow.withValues(alpha: 0.7)),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'دووبارەکردنەوە: ${zikr.count}',
                  style: KurdishStyles.getKurdishStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: _accent),
                onPressed: () {}, // Share logic
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ZikrItem {
  final String arabic;
  final String kurdish;
  final int count;

  ZikrItem({required this.arabic, required this.kurdish, required this.count});
}

