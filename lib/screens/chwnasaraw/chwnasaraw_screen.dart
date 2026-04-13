import 'package:flutter/material.dart';

class ChwnaSarAwScreen extends StatefulWidget {
  const ChwnaSarAwScreen({super.key});

  @override
  State<ChwnaSarAwScreen> createState() => _ChwnaSarAwScreenState();
}

class _ChwnaSarAwScreenState extends State<ChwnaSarAwScreen>
    with TickerProviderStateMixin {
  // ── Palette ────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF050C0A);
  static const _surfaceHigh = Color(0xFF122018);
  static const _border = Color(0xFF1C3028);
  static const _emerald = Color(0xFF10C98A);
  static const _emeraldDim = Color(0xFF0A7A55);
  static const _emeraldGlow = Color(0xFF6EFFD4);
  static const _text = Color(0xFFE8F5F0);
  static const _textMuted = Color(0xFF5A8070);

  late final AnimationController _fadeController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background radial glow
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, _) => Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _emerald.withValues(alpha: 
                          0.06 + _pulseController.value * 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _emeraldDim.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle dot grid
          const Positioned.fill(child: _DotGridOverlay()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Column(
                        children: [
                          _DhikrCard(
                            index: 1,
                            title: 'ویردی چوونەسەرئاو',
                            instruction:
                            'بڵێ پاشان بە پێی چەپت بچۆرە ژوورەوە:',
                            dhikr:
                            'بِسْمِ اللهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبْثِ وَالْخَبَائِث',
                            dhikrKurdish:
                            'بە ناوی خوا، ئەی خوایە پەناتم پێ دەگرم لە نێرینە و مێینەی شەیتانەکانی جنۆکە',
                            proof:
                            'پەردەی نێوان چاوی جنۆکەکان و عەورەتی ئادەمیزاد ئەوەیە کەوا یەکێکیان چووە سەر ئاو بڵێت: بسم الله\n[ابن ماجة والترمذي · صحيح الجامع: ٣٦١١]',
                            entryDelay: 100,
                            pulseController: _pulseController,
                          ),
                          const SizedBox(height: 16),
                          _DhikrCard(
                            index: 2,
                            title: 'ویردی هاتنەدەر لە سەرئاو',
                            instruction:
                            'بە پێی ڕاستت بڕۆ دەرەوە و پاشان بڵێ:',
                            dhikr: 'غُفْرَانَكَ',
                            dhikrKurdish:
                            'ئەی خوایە داوای لێخۆشبوونت لێ دەکەم',
                            proof:
                            'فەرموودەی عائیشە -رضي الله عنها- کاتێک کە پێغەمبەر ﷺ لە سەرئاو دەهاتە دەرەوە دەیفەرموو: غفرانك\n[صحيح الجامع: ٤٧٠٧]',
                            entryDelay: 250,
                            pulseController: _pulseController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _surfaceHigh,
                borderRadius: BorderRadius.circular(13),
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
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_emerald, _emeraldGlow, _emerald],
                ).createShader(bounds),
                child: const Text(
                  'چوونەسەرئاو',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ئادابی سەرئاو',
                style: TextStyle(
                  fontSize: 11,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border, width: 1),
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: _emerald.withValues(alpha: 0.7),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dhikr Card ────────────────────────────────────────────────────────────────

class _DhikrCard extends StatefulWidget {
  final int index;
  final String title;
  final String instruction;
  final String dhikr;
  final String dhikrKurdish;
  final String proof;
  final int entryDelay;
  final AnimationController pulseController;

  const _DhikrCard({
    required this.index,
    required this.title,
    required this.instruction,
    required this.dhikr,
    required this.dhikrKurdish,
    required this.proof,
    required this.entryDelay,
    required this.pulseController,
  });

  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF050C0A);
  static const _surface = Color(0xFF0C1712);
  static const _surfaceHigh = Color(0xFF122018);
  static const _border = Color(0xFF1C3028);
  static const _emerald = Color(0xFF10C98A);
  static const _emeraldDim = Color(0xFF0A7A55);
  static const _text = Color(0xFFE8F5F0);
  static const _textMuted = Color(0xFF5A8070);
  static const _arabic = Color(0xFFB8FFE5);

  bool _proofExpanded = false;
  late AnimationController _entryController;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.entryDelay), () {
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
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              color: _emerald.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Card Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Index badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _emerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _emerald.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _emerald,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _text,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // ── Instruction ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      widget.instruction,
                      style: TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                        height: 1.6,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _emerald.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: _emerald.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Arabic Dhikr block ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: AnimatedBuilder(
                animation: widget.pulseController,
                builder: (_, child) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _emerald.withValues(alpha: 
                            0.07 + widget.pulseController.value * 0.025),
                        _emeraldDim.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _emerald.withValues(alpha: 
                          0.18 + widget.pulseController.value * 0.08),
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
                child: Column(
                  children: [
                    Text(
                      widget.dhikr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _arabic,
                        height: 1.9,
                        fontFamily: 'Amiri',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    if (widget.dhikrKurdish.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(
                          color: _emerald.withValues(alpha: 0.15),
                          height: 20,
                        ),
                      ),
                      Text(
                        widget.dhikrKurdish,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: _emerald.withValues(alpha: 0.65),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Proof section (expandable) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () =>
                        setState(() => _proofExpanded = !_proofExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedRotation(
                            turns: _proofExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.expand_more_rounded,
                              size: 16,
                              color: _emerald.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.menu_book_rounded,
                            size: 14,
                            color: _emerald.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'بەڵگە و سەرچاوە',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _proofExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border, width: 1),
                        ),
                        child: Text(
                          widget.proof,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _textMuted,
                            height: 1.8,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ),
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
}

// ── Dot Grid Overlay ──────────────────────────────────────────────────────────

class _DotGridOverlay extends StatelessWidget {
  const _DotGridOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DotGridPainter());
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10C98A).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
