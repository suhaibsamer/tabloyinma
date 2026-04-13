import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../widgets/font_size_controls.dart';
import '../../services/theme_manager.dart';

class SunnahPrayersScreen extends StatefulWidget {
  const SunnahPrayersScreen({super.key});

  @override
  State<SunnahPrayersScreen> createState() => _SunnahPrayersScreenState();
}

class _SunnahPrayersScreenState extends State<SunnahPrayersScreen> {
  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _gold = Color(0xFFFFD97D);

  final List<SunnahPrayer> _prayers = [
    SunnahPrayer(
      title: 'نوێژی ئیستیخارە',
      subtitle: 'بۆ داواکردنی خێر لە خودا لە کارەکاندا',
      description: 'نوێژی ئیستیخارە سوننەتە کاتێک کەسێک دوودڵ بێت لە هەڵبژاردنی کارێک کە ڕێگەپێدراو بێت.',
      steps: [
        'دەستنوێژێکی تەواو و چاک بگرە.',
        'نیەتی دوو ڕکات نوێژی ئیستیخارە بکە.',
        'دوو ڕکات نوێژی ئاسایی بکە.',
        'دوای سەلامدانەوە، دوعای ئیستیخارە بخوێنە.',
      ],
      duaArabic: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ. اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ (ناوى کاره‌که‌ ده‌هێنیت) خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي ثُمَّ بَارِكْ لِي فِيهِ.',
      duaKurdish: 'خودایە من داوای خێرت لێدەکەم بە زانیاری خۆت، و داوای توانای لێدەکەم بە دەسەڵاتی خۆت، چونکە تۆ دەسەڵاتت هەیە و من نیمە، و تۆ دەزانیت و من نازانم. خودایە ئەگەر دەزانیت ئەم کارە خێرە بۆم لە ئایینم و ژیانم و کۆتایی کارم، ئەوا بۆم بڕیار بدە و ئاسانی بکە و بەرەکەتی تێ بخە.',
    ),
    SunnahPrayer(
      title: 'نوێژی چێشتەنگاو (الضحی)',
      subtitle: 'نوێژی پاکان و تۆبەکاران',
      description: 'کاتەکەی لە دوای هەڵاتنی خۆر دەست پێ دەکات تاوەکو پێش بانگی نیوەڕۆ.',
      steps: [
        'کەمترینەکەی دوو ڕکاتە و دەتوانیت زیاتریش بکەیت.',
        'وەک نوێژی ئاسایی ئەنجام دەدرێت.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'نوێژە سوننەتەکان',
          style: KurdishStyles.getTitleStyle(color: _starlight),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _starlight),
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
                builder: (context, _, _) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _prayers.length,
                    itemBuilder: (context, index) {
                      return _buildPrayerCard(_prayers[index]);
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

  Widget _buildPrayerCard(SunnahPrayer prayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            prayer.title,
            style: KurdishStyles.getKurdishStyle(fontSize: 16, color: _starlight, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          subtitle: Text(
            prayer.subtitle,
            style: KurdishStyles.getKurdishStyle(fontSize: 12, color: _moonGlow.withValues(alpha: 0.5)),
            textAlign: TextAlign.right,
          ),
          iconColor: _accent,
          collapsedIconColor: _accent,
          childrenPadding: const EdgeInsets.all(20),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              prayer.description,
              style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _moonGlow.withValues(alpha: 0.8)),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('هەنگاوەکان:'),
            ...prayer.steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key + 1}. ', style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _accent, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _starlight),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (prayer.duaArabic != null) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('دوعاکە:'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _midnight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  prayer.duaArabic!,
                  textAlign: TextAlign.center,
                  style: KurdishStyles.getArabicStyle(fontSize: 18, color: _starlight),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                prayer.duaKurdish!,
                style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _moonGlow.withValues(alpha: 0.7)),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: KurdishStyles.getKurdishStyle(fontSize: 15, color: _accent, fontWeight: FontWeight.bold),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class SunnahPrayer {
  final String title;
  final String subtitle;
  final String description;
  final List<String> steps;
  final String? duaArabic;
  final String? duaKurdish;

  SunnahPrayer({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.steps,
    this.duaArabic,
    this.duaKurdish,
  });
}

