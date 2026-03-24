import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../widgets/font_size_controls.dart';
import '../../services/theme_manager.dart';

class ObligatoryPrayersScreen extends StatelessWidget {
  const ObligatoryPrayersScreen({super.key});

  // Celestial deep-space color palette
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _gold = Color(0xFFFFD97D);
  static const _divider = Color(0xFF252A45);

  final List<FardPrayer> _prayers = const [
    FardPrayer(
      title: 'نوێژی بەیانی (الفجر)',
      rakats: '٢ ڕکات',
      time: 'لە کاتی سپێدەی بەیانییەوە تا پێش هەڵاتنی خۆر.',
      description: 'نوێژی بەیانی یەکەم نوێژی فەرزە لە ڕۆژدا و فەزڵ و پاداشتێکی زۆری هەیە.',
    ),
    FardPrayer(
      title: 'نوێژی نیوەڕۆ (الظهر)',
      rakats: '٤ ڕکات',
      time: 'لە کاتی لادانی خۆر لە ناوەڕاستی ئاسمانەوە تاوەکو کاتی عەسر.',
      description: 'نوێژی نیوەڕۆ یەکەم نوێژ بوو کە پێغەمبەر (د.خ) ئەنجامی دا دوای فەرزبوونی.',
    ),
    FardPrayer(
      title: 'نوێژی عەسر (العصر)',
      rakats: '٤ ڕکات',
      time: 'لە کاتی تەواوبوونی کاتی نیوەڕۆوە تاوەکو پێش ئاوابوونی خۆر.',
      description: 'ئەم نوێژە لە قورئاندا وەک (الصلوة الوسطی) ناوی براوە و جەختی لێکراوەتەوە.',
    ),
    FardPrayer(
      title: 'نوێژی شێوان (المغرب)',
      rakats: '٣ ڕکات',
      time: 'لە کاتی ئاوابوونی تەواوی خۆرەوە تا نەمانی سوورایی ئاسمان.',
      description: 'نوێژی شێوان تاکە نوێژێکی فەرزە کە سێ ڕکات بێت.',
    ),
    FardPrayer(
      title: 'نوێژی خەوتنان (العشاء)',
      rakats: '٤ ڕکات',
      time: 'لە کاتی نەمانی سوورایی ئاسمانەوە تا نیوەی شەو.',
      description: 'نوێژی خەوتنان کۆتا نوێژی فەرزە لە شەو و ڕۆژدا.',
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
          'نوێژە فەرزەکان',
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
                builder: (context, _, __) {
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

  Widget _buildPrayerCard(FardPrayer prayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                prayer.title,
                style: KurdishStyles.getKurdishStyle(fontSize: 16, color: _accent, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prayer.rakats,
                  style: KurdishStyles.getKurdishStyle(fontSize: 12, color: _starlight, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _divider, thickness: 1),
          const SizedBox(height: 12),
          _buildInfoRow('کاتەکەی:', prayer.time),
          const SizedBox(height: 12),
          _buildInfoRow('دەربارەی:', prayer.description),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _gold.withOpacity(0.8), fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: KurdishStyles.getKurdishStyle(fontSize: 14, color: _moonGlow.withOpacity(0.7)),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class FardPrayer {
  final String title;
  final String rakats;
  final String time;
  final String description;

  const FardPrayer({
    required this.title,
    required this.rakats,
    required this.time,
    required this.description,
  });
}
