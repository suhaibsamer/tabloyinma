import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class TazbihScreen extends StatefulWidget {
  const TazbihScreen({super.key});

  @override
  State<TazbihScreen> createState() => _TazbihScreenState();
}

class _TazbihScreenState extends State<TazbihScreen>
    with TickerProviderStateMixin {
  int _counter = 0;
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Dhikr list with translations
  List<Map<String, String>> _dhikrs = [
    {'arabic': 'سُبْحَانَ اللهِ', 'kurdish': 'پاکی بۆ خودا'},
    {'arabic': 'الْحَمْدُ لِلَّهِ', 'kurdish': 'سوپاس بۆ خودا'},
    {'arabic': 'لَا إِلَهَ إِلَّا اللهُ', 'kurdish': 'هیچ خودایەک نییە جگە لە الله'},
    {'arabic': 'اللهُ أَكْبَرُ', 'kurdish': 'خودا گەورەتره'},
    {'arabic': 'أَسْتَغْفِرُ اللهَ', 'kurdish': 'داوای بەخشینەوە لە خودا دەکەم'},
    {'arabic': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ', 'kurdish': 'پاکی و ستایش بۆ خودا'},
  ];

  // Target counts (33 or 100 traditionally)
  final int _target = 33;

  late AnimationController _rippleController;
  late AnimationController _rotateController;
  late AnimationController _countController;
  late Animation<double> _rippleAnim;
  late Animation<double> _countScaleAnim;

  @override
  void initState() {
    super.initState();
    _loadDhikrs();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _countScaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _countController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadDhikrs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dhikrsJson = prefs.getString('custom_dhikrs');
    if (dhikrsJson != null) {
      final List<dynamic> decoded = json.decode(dhikrsJson);
      setState(() {
        _dhikrs = decoded.map((item) => Map<String, String>.from(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDhikrs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_dhikrs', json.encode(_dhikrs));
  }

  void _addDhikr(String arabic, String kurdish) {
    setState(() {
      _dhikrs.add({'arabic': arabic, 'kurdish': kurdish});
    });
    _saveDhikrs();
  }

  void _deleteDhikr(int index) {
    if (_dhikrs.length <= 1) return;
    setState(() {
      _dhikrs.removeAt(index);
      if (_selectedIndex >= _dhikrs.length) {
        _selectedIndex = _dhikrs.length - 1;
      }
      _reset();
    });
    _saveDhikrs();
  }

  void _showAddDhikrDialog() {
    final TextEditingController arabicController = TextEditingController();
    final TextEditingController kurdishController = TextEditingController();

    const Color gold = Color(0xFFD4A853);
    const Color surface = Color(0xFF0F0F1E);
    const Color textPrimary = Color(0xFFF0E6CC);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gold.withOpacity(0.3)),
        ),
        title: const Text(
          'زیادکردنی زیکر',
          textAlign: TextAlign.right,
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: arabicController,
              textAlign: TextAlign.right,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'زیکرەکە بە عەرەبی',
                hintStyle: TextStyle(color: textPrimary.withOpacity(0.3)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: gold.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: gold)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: kurdishController,
              textAlign: TextAlign.right,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'ماناکەی بە کوردی',
                hintStyle: TextStyle(color: textPrimary.withOpacity(0.3)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: gold.withOpacity(0.3))),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: gold)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پاشگەزبونەوە', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (arabicController.text.isNotEmpty &&
                  kurdishController.text.isNotEmpty) {
                _addDhikr(arabicController.text, kurdishController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('زیادکردن', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _rotateController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _rippleController.forward(from: 0.0);
    _countController.forward(from: 0.0).then((_) => _countController.reverse());
    setState(() {
      _counter++;
      if (_counter >= _target) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _counter = 0);
  }

  double get _progress => (_counter % _target) / _target;
  bool get _targetReached => _counter > 0 && _counter % _target == 0;

  @override
  Widget build(BuildContext context) {
    // Color palette
    const Color bg = Color(0xFF080810);
    const Color surface = Color(0xFF0F0F1E);
    const Color gold = Color(0xFFD4A853);
    const Color goldLight = Color(0xFFEDD07B);
    const Color goldDim = Color(0xFF8B6A2A);
    const Color textPrimary = Color(0xFFF0E6CC);
    const Color textSecondary = Color(0xFF7A6E5C);
    const Color divider = Color(0xFF1E1E30);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Rotating geometric background ──────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (_, __) => CustomPaint(
                  painter: _GeometricBgPainter(
                    rotation: _rotateController.value * 2 * math.pi,
                  ),
                ),
              ),
            ),

            // ── Radial gold glow behind button ─────────────────────────
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        gold.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── App Bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: textSecondary, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                'تەزبیح',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'TAZBIH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: goldDim,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: gold, size: 22),
                          onPressed: _reset,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Dhikr Selector ───────────────────────────────────
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _dhikrs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _dhikrs.length) {
                          return GestureDetector(
                            onTap: _showAddDhikrDialog,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: gold.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_rounded, color: gold, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'زیادکردن',
                                    style: TextStyle(
                                      color: gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final isSelected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedIndex = index;
                            _reset();
                          }),
                          onLongPress: () {
                            // Show delete option
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: surface,
                                title: const Text('سڕینەوە', textAlign: TextAlign.right, style: TextStyle(color: textPrimary)),
                                content: const Text('دڵنیایت دەتەوێت ئەم زیکرە بسڕیتەوە؟', textAlign: TextAlign.right, style: TextStyle(color: textSecondary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('نەخێر')),
                                  TextButton(onPressed: () {
                                    _deleteDhikr(index);
                                    Navigator.pop(context);
                                  }, child: const Text('بەڵێ', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? gold.withOpacity(0.15)
                                  : surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? gold : divider,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              _dhikrs[index]['arabic']!,
                              style: TextStyle(
                                color: isSelected ? goldLight : textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Arabic Text ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          _dhikrs[_selectedIndex]['arabic']!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dhikrs[_selectedIndex]['kurdish']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Arc Progress + Counter ───────────────────────────
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arc progress ring
                        CustomPaint(
                          size: const Size(160, 160),
                          painter: _ArcProgressPainter(
                            progress: _progress,
                            gold: gold,
                            goldDim: goldDim,
                            reached: _targetReached,
                          ),
                        ),
                        // Counter number
                        ScaleTransition(
                          scale: _countScaleAnim,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _counter.toString(),
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: _targetReached ? goldLight : textPrimary,
                                  fontFamily: 'monospace',
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                '/ $_target',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Main Tap Button ──────────────────────────────────
                  GestureDetector(
                    onTap: _increment,
                    child: AnimatedBuilder(
                      animation: _rippleAnim,
                      builder: (_, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple ring
                            if (_rippleController.isAnimating)
                              Transform.scale(
                                scale: 1.0 + _rippleAnim.value * 0.45,
                                child: Opacity(
                                  opacity: (1 - _rippleAnim.value) * 0.4,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: gold, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            child!,
                          ],
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surface,
                          border: Border.all(
                            color: gold.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _OrnamentPainter(gold: goldDim),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'زیکر بکە',
                                  style: TextStyle(
                                    color: goldLight,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ZIKR',
                                  style: TextStyle(
                                    color: goldDim,
                                    fontSize: 10,
                                    letterSpacing: 5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Session / streak info bar ────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoPill(
                          label: 'کۆی گشتی',
                          value: _counter.toString(),
                          gold: gold,
                          goldDim: goldDim,
                          textSecondary: textSecondary,
                          surface: surface,
                        ),
                        _GoldDivider(gold: goldDim),
                        _InfoPill(
                          label: 'چەندەم',
                          value: (_counter ~/ _target + 1).toString(),
                          gold: gold,
                          goldDim: goldDim,
                          textSecondary: textSecondary,
                          surface: surface,
                        ),
                        _GoldDivider(gold: goldDim),
                        _InfoPill(
                          label: 'ئامانج',
                          value: _target.toString(),
                          gold: gold,
                          goldDim: goldDim,
                          textSecondary: textSecondary,
                          surface: surface,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Painters ──────────────────────────────────────────────────────────────

class _GeometricBgPainter extends CustomPainter {
  final double rotation;
  _GeometricBgPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i < 4; i++) {
      final r = 160.0 + i * 70;
      paint.color = const Color(0xFFD4A853).withOpacity(0.035 - i * 0.006);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation + i * (math.pi / 8));
      _drawPolygon(canvas, paint, r, 8);
      canvas.restore();
    }
  }

  void _drawPolygon(Canvas canvas, Paint paint, double r, int sides) {
    final path = Path();
    for (int i = 0; i <= sides; i++) {
      final angle = (2 * math.pi * i / sides) - math.pi / 2;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GeometricBgPainter old) => old.rotation != rotation;
}

class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color gold;
  final Color goldDim;
  final bool reached;

  _ArcProgressPainter({
    required this.progress,
    required this.gold,
    required this.goldDim,
    required this.reached,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 10;
    const strokeW = 4.0;

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(cx, cy), r, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..color = reached ? gold : goldDim;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );

    // Dot at start
    final dotPaint = Paint()..color = goldDim;
    canvas.drawCircle(Offset(cx, cy - r), 3, dotPaint);
  }

  @override
  bool shouldRepaint(_ArcProgressPainter old) =>
      old.progress != progress || old.reached != reached;
}

class _OrnamentPainter extends CustomPainter {
  final Color gold;
  _OrnamentPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = gold.withOpacity(0.5);

    // Inner decorative circle
    canvas.drawCircle(Offset(cx, cy), size.width / 2 - 20, paint);
    canvas.drawCircle(Offset(cx, cy), size.width / 2 - 28, paint..strokeWidth = 0.4);

    // Small corner diamonds
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i / 8);
      final r = size.width / 2 - 24;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5,
          Paint()..color = gold.withOpacity(0.6));
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) => false;
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color gold, goldDim, textSecondary, surface;
  const _InfoPill({
    required this.label,
    required this.value,
    required this.gold,
    required this.goldDim,
    required this.textSecondary,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: gold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _GoldDivider extends StatelessWidget {
  final Color gold;
  const _GoldDivider({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: gold.withOpacity(0.3),
    );
  }
}