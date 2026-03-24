import 'package:flutter/material.dart';
import 'dart:math' as math;

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen>
    with TickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0A0A12);
  static const _surface = Color(0xFF12121E);
  static const _surfaceHigh = Color(0xFF1A1A2E);
  static const _border = Color(0xFF252540);
  static const _gold = Color(0xFFD4A853);
  static const _goldLight = Color(0xFFF0C97A);
  static const _goldGlow = Color(0xFFFFE4A0);
  static const _text = Color(0xFFF5F0E8);
  static const _textMuted = Color(0xFF8A8599);
  static const _teal = Color(0xFF2DD4BF);

  late final AnimationController _fadeController;
  late final AnimationController _shimmerController;
  int? _hoveredIndex;

  final List<Map<String, dynamic>> names = const [
    {"arabic": "الله", "kurdish": "خوای گەورە", "number": 1},
    {"arabic": "الرحمن", "kurdish": "بەخشندە", "number": 2},
    {"arabic": "الرحيم", "kurdish": "میهرەبان", "number": 3},
    {"arabic": "الملك", "kurdish": "پاشا", "number": 4},
    {"arabic": "القدوس", "kurdish": "پاک و بێگەرد", "number": 5},
    {"arabic": "السلام", "kurdish": "ئاشتی خواز", "number": 6},
    {"arabic": "المؤمن", "kurdish": "دڵنیاکەرەوە", "number": 7},
    {"arabic": "المهيمن", "kurdish": "زۆر باڵادەست", "number": 8},
    {"arabic": "العزيز", "kurdish": "بەدەسەڵات", "number": 9},
    {"arabic": "الجبار", "kurdish": "زۆر خۆسەپێن", "number": 10},
    {"arabic": "المتكبر", "kurdish": "لێهاتوو - گەورە", "number": 11},
    {"arabic": "الخالق", "kurdish": "دروستکەر", "number": 12},
    {"arabic": "البارئ", "kurdish": "پەیداکەر", "number": 13},
    {"arabic": "المصور", "kurdish": "وێنەکێش", "number": 14},
    {"arabic": "الغفار", "kurdish": "زۆر لێخۆشبە", "number": 15},
    {"arabic": "القهار", "kurdish": "زۆر بە هێز", "number": 16},
    {"arabic": "الوهاب", "kurdish": "زۆر بەخشەر", "number": 17},
    {"arabic": "الرزاق", "kurdish": "ڕۆزیدەر", "number": 18},
    {"arabic": "الفتاح", "kurdish": "کەرەمکەر", "number": 19},
    {"arabic": "العليم", "kurdish": "زانا", "number": 20},
    {"arabic": "القابض", "kurdish": "گرتنی گیان", "number": 21},
    {"arabic": "الباسط", "kurdish": "فراوانکەر", "number": 22},
    {"arabic": "الخافض", "kurdish": "نزمکەرەوە", "number": 23},
    {"arabic": "الرافع", "kurdish": "بەرزکەرەوە", "number": 24},
    {"arabic": "المعز", "kurdish": "سەربەرزکەرەوە", "number": 25},
    {"arabic": "المذل", "kurdish": "سەرشۆڕکەرەوە", "number": 26},
    {"arabic": "السميع", "kurdish": "بیستەر", "number": 27},
    {"arabic": "البصير", "kurdish": "بینەر", "number": 28},
    {"arabic": "الحكم", "kurdish": "دادوەر", "number": 29},
    {"arabic": "العدل", "kurdish": "دادپەروەر", "number": 30},
    {"arabic": "اللطيف", "kurdish": "میهرەبان", "number": 31},
    {"arabic": "الخبير", "kurdish": "ئاگادار", "number": 32},
    {"arabic": "الحليم", "kurdish": "ئارامگر", "number": 33},
    {"arabic": "العظيم", "kurdish": "گەورە", "number": 34},
    {"arabic": "الغفور", "kurdish": "لێخۆشبە", "number": 35},
    {"arabic": "الشكور", "kurdish": "سوپاسگوزار", "number": 36},
    {"arabic": "العلي", "kurdish": "بەرز", "number": 37},
    {"arabic": "الكبير", "kurdish": "گەورەترین", "number": 38},
    {"arabic": "الحفيظ", "kurdish": "پارێزەر", "number": 39},
    {"arabic": "المقيت", "kurdish": "بەهێزکەر", "number": 40},
    {"arabic": "الحسيب", "kurdish": "بژارکەر", "number": 41},
    {"arabic": "الجليل", "kurdish": "خاوەن شکۆ", "number": 42},
    {"arabic": "الكريم", "kurdish": "بەخشندە", "number": 43},
    {"arabic": "الرقيب", "kurdish": "چاودێر", "number": 44},
    {"arabic": "المجيب", "kurdish": "وەڵامدەرەوە", "number": 45},
    {"arabic": "الواسع", "kurdish": "فراوان", "number": 46},
    {"arabic": "الحكيم", "kurdish": "دانایە", "number": 47},
    {"arabic": "الودود", "kurdish": "زۆر میهرەبان", "number": 48},
    {"arabic": "المجيد", "kurdish": "شکۆدار", "number": 49},
    {"arabic": "الباعث", "kurdish": "نێرەر", "number": 50},
    {"arabic": "الشهيد", "kurdish": "ئامادە", "number": 51},
    {"arabic": "الحق", "kurdish": "ڕاستی", "number": 52},
    {"arabic": "الوكيل", "kurdish": "جێ متمانە", "number": 53},
    {"arabic": "القوي", "kurdish": "بەهێز", "number": 54},
    {"arabic": "المتين", "kurdish": "زۆر بەهێز", "number": 55},
    {"arabic": "الولي", "kurdish": "پارێزەر", "number": 56},
    {"arabic": "الحميد", "kurdish": "جێی ستایش", "number": 57},
    {"arabic": "المحصي", "kurdish": "ژمارەکەر", "number": 58},
    {"arabic": "المبدئ", "kurdish": "دەستپێکەر", "number": 59},
    {"arabic": "المعيد", "kurdish": "گێڕەرەوە", "number": 60},
    {"arabic": "المحيي", "kurdish": "زیندۆکەر", "number": 61},
    {"arabic": "المميت", "kurdish": "مرێنەر", "number": 62},
    {"arabic": "الحي", "kurdish": "زیندۆ", "number": 63},
    {"arabic": "القيوم", "kurdish": "ڕاگەر", "number": 64},
    {"arabic": "الواجد", "kurdish": "دۆزەرەوە", "number": 65},
    {"arabic": "الماجد", "kurdish": "شکۆدار", "number": 66},
    {"arabic": "الواحد", "kurdish": "تاک", "number": 67},
    {"arabic": "الأحد", "kurdish": "تاکە", "number": 68},
    {"arabic": "الصمد", "kurdish": "پێویست پێی", "number": 69},
    {"arabic": "القادر", "kurdish": "بەدەسەڵات", "number": 70},
    {"arabic": "المقتدر", "kurdish": "خاوەن دەسەڵات", "number": 71},
    {"arabic": "المقدم", "kurdish": "پێشخەر", "number": 72},
    {"arabic": "المؤخر", "kurdish": "پاشخەر", "number": 73},
    {"arabic": "الأول", "kurdish": "یەکەم", "number": 74},
    {"arabic": "الآخر", "kurdish": "کۆتایی", "number": 75},
    {"arabic": "الظاهر", "kurdish": "دیار", "number": 76},
    {"arabic": "الباطن", "kurdish": "شاراوە", "number": 77},
    {"arabic": "الوالي", "kurdish": "فەرمانڕەوا", "number": 78},
    {"arabic": "المتعالي", "kurdish": "بەرز", "number": 79},
    {"arabic": "البر", "kurdish": "چاکەکار", "number": 80},
    {"arabic": "التواب", "kurdish": "تۆبەوەرگر", "number": 81},
    {"arabic": "المنتقم", "kurdish": "تۆڵەسێن", "number": 82},
    {"arabic": "العفو", "kurdish": "لێخۆشبە", "number": 83},
    {"arabic": "الرؤوف", "kurdish": "میهرەبان", "number": 84},
    {"arabic": "مالك الملك", "kurdish": "خاوەنی هەمووان", "number": 85},
    {"arabic": "ذو الجلال والإكرام", "kurdish": "خاوەنی شکۆ", "number": 86},
    {"arabic": "المقسط", "kurdish": "دادپەروەر", "number": 87},
    {"arabic": "الجامع", "kurdish": "کۆکەرەوە", "number": 88},
    {"arabic": "الغني", "kurdish": "دەوڵەمەند", "number": 89},
    {"arabic": "المغني", "kurdish": "دەوڵەمەندکەر", "number": 90},
    {"arabic": "المانع", "kurdish": "ڕێگر", "number": 91},
    {"arabic": "الضار", "kurdish": "زیانبەخش", "number": 92},
    {"arabic": "النافع", "kurdish": "سوودبەخش", "number": 93},
    {"arabic": "النور", "kurdish": "ڕووناکی", "number": 94},
    {"arabic": "الهادي", "kurdish": "ڕێنیشاندەر", "number": 95},
    {"arabic": "البديع", "kurdish": "داهێنەر", "number": 96},
    {"arabic": "الباقي", "kurdish": "هەمیشەیی", "number": 97},
    {"arabic": "الوارث", "kurdish": "جێگر", "number": 98},
    {"arabic": "الرشيد", "kurdish": "ڕێنیشاندەر", "number": 99},
    {"arabic": "الصبور", "kurdish": "ئارامگر", "number": 100},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Decorative radial glow at top
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gold.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Subtle geometric pattern overlay
          const Positioned.fill(child: _GeometricPatternOverlay()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSubtitle(),
                const SizedBox(height: 8),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: names.length,
                      itemBuilder: (context, index) {
                        return _AnimatedNameCard(
                          name: names[index],
                          index: index,
                          shimmerController: _shimmerController,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _text,
                size: 16,
              ),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_gold, _goldGlow, _gold],
            ).createShader(bounds),
            child: const Text(
              'ناوی خوای گەورە',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border, width: 1),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: _textMuted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withOpacity(0.18), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getStarIcon(), color: _gold, size: 14),
            const SizedBox(width: 8),
            const Text(
              '٩٩',
              style: TextStyle(
                fontSize: 15,
                color: _gold,
                fontWeight: FontWeight.w700,
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '· ناوی جوانەکانی خوا',
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            Icon(_getStarIcon(), color: _gold, size: 14),
          ],
        ),
      ),
    );
  }

  IconData _getStarIcon() => Icons.auto_awesome_rounded;
}

// ── Animated Name Card ────────────────────────────────────────────────────────

class _AnimatedNameCard extends StatefulWidget {
  final Map<String, dynamic> name;
  final int index;
  final AnimationController shimmerController;

  const _AnimatedNameCard({
    required this.name,
    required this.index,
    required this.shimmerController,
  });

  @override
  State<_AnimatedNameCard> createState() => _AnimatedNameCardState();
}

class _AnimatedNameCardState extends State<_AnimatedNameCard>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0A0A12);
  static const _surface = Color(0xFF12121E);
  static const _surfaceHigh = Color(0xFF1A1A2E);
  static const _border = Color(0xFF252540);
  static const _gold = Color(0xFFD4A853);
  static const _goldLight = Color(0xFFF0C97A);
  static const _text = Color(0xFFF5F0E8);
  static const _textMuted = Color(0xFF8A8599);
  static const _teal = Color(0xFF2DD4BF);

  bool _pressed = false;
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // Staggered entry
    Future.delayed(Duration(milliseconds: 40 * (widget.index % 20)), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final number = widget.name['number'] as int;
    // First card (Allah) gets a special treatment
    final bool isFirst = number == 1;

    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: _buildCard(isFirst, number),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(bool isFirst, int number) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isFirst
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1608), Color(0xFF0E0C18)],
        )
            : null,
        color: isFirst ? null : _surface,
        border: Border.all(
          color: isFirst
              ? _gold.withOpacity(0.45)
              : _border,
          width: isFirst ? 1.5 : 1.0,
        ),
        boxShadow: isFirst
            ? [
          BoxShadow(
            color: _gold.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Number badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isFirst
                    ? _gold.withOpacity(0.15)
                    : _surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFirst
                      ? _gold.withOpacity(0.3)
                      : _border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isFirst ? _gold : _textMuted,
                  ),
                ),
              ),
            ),
          ),
          // Decorative corner ornament for first card
          if (isFirst)
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.auto_awesome,
                color: _gold,
                size: 14,
              ),
            ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arabic name with shimmer for first card
                  isFirst
                      ? AnimatedBuilder(
                    animation: widget.shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          final t = widget.shimmerController.value;
                          return LinearGradient(
                            begin: Alignment(-2 + t * 4, 0),
                            end: Alignment(-1 + t * 4, 0),
                            colors: const [
                              _gold,
                              _goldLight,
                              _gold,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          widget.name['arabic']!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  )
                      : Text(
                    widget.name['arabic']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _gold,
                      fontFamily: 'Amiri',
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  // Divider line
                  Container(
                    width: 32,
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          isFirst ? _gold.withOpacity(0.6) : _border,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Kurdish translation
                  Text(
                    widget.name['kurdish']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isFirst ? _goldLight.withOpacity(0.85) : _textMuted,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Geometric Pattern Overlay ─────────────────────────────────────────────────

class _GeometricPatternOverlay extends StatelessWidget {
  const _GeometricPatternOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GeometricPainter());
}

class _GeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A853).withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw subtle Islamic geometric star pattern in top region
    _drawStarPattern(canvas, paint, Offset(size.width * 0.85, size.height * 0.06), 60);
    _drawStarPattern(canvas, paint, Offset(size.width * 0.12, size.height * 0.12), 40);
    _drawStarPattern(canvas, paint, Offset(size.width * 0.5, size.height * 0.04), 30);
  }

  void _drawStarPattern(Canvas canvas, Paint paint, Offset center, double r) {
    const points = 8;
    const inner = 0.45;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * inner;
      final angle = (i * math.pi) / points - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Outer circle
    canvas.drawCircle(center, r * 1.25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
