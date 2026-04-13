import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabloy_iman/utils/info_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE — Modern Minimalist OLED & Emerald Accent
// ─────────────────────────────────────────────────────────────────────────────
const _bg          = Color(0xFF090A0C);   // OLED-friendly deep background
const _card        = Color(0xFF141518);   // Elevated card surface
const _rim         = Color(0xFF26282D);   // Subtle borders
const _accent      = Color(0xFF00E676);   // Vibrant mint/emerald accent
const _accentGlow  = Color(0x2600E676);   // Soft emerald glow (15% opacity)
const _textMain    = Color(0xFFF3F4F6);   // Primary stark white/grey text
const _textSub     = Color(0xFF9CA3AF);   // Muted secondary text
const _tickBright  = Color(0xFFD1D5DB);   // Major dial ticks
const _tickDim     = Color(0xFF374151);   // Minor dial ticks

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late Future<_LocStatus> _locFuture;
  late AnimationController _entryCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _locFuture = _requestLocation();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<_LocStatus> _requestLocation() async {
    final perm = await Permission.locationWhenInUse.request();
    final enabled = await Geolocator.isLocationServiceEnabled();
    return _LocStatus(perm, enabled);
  }

  void _retry() => setState(() => _locFuture = _requestLocation());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _ModernAppBar(),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: FutureBuilder<_LocStatus>(
            future: _locFuture,
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const _LoadingView();
              }
              if (snap.hasError || !snap.hasData) {
                return _ErrorView(
                  loc: const _LocStatus(PermissionStatus.denied, false),
                  onRetry: _retry,
                );
              }
              final loc = snap.data!;
              if (loc.granted && loc.enabled) return const _CompassView();
              return _ErrorView(loc: loc, onRetry: _retry);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: _BackButton(),
      title: const Text(
        'ئاڕاستەی قیبلە',
        style: TextStyle(
          color: _textMain,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: _textMain, size: 20),
          onPressed: () => InfoUtils.showInfo(
            context,
            title: 'قیبلە',
            description: 'دۆزینەوەی ئاراستەی قیبلە بەپێی شوێنی تۆ.',
            howToUse: 'مۆبایلەکەت بە ڕێکی ڕابگرە، ئامێرەکە ئاراستەی قیبلەت بۆ دیاری دەکات.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: _PulseDot(),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rim),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: _textMain,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Pulsing live-indicator dot
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) => Transform.scale(
      scale: _scale.value,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: _accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _accentGlow, blurRadius: 10, spreadRadius: 4),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      color: _accent,
      strokeWidth: 2.0,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPASS VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _CompassView extends StatelessWidget {
  const _CompassView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (ctx, snap) {
        if (!snap.hasData) return const _LoadingView();

        final q = snap.data!;
        final compassRad = -(q.direction * math.pi / 180);
        final qiblaRad   = -(q.qiblah   * math.pi / 180);

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Stat cards ──────────────────────────────────────────
                Row(
                  children: [
                    _StatCard(
                      label: 'ئافسەت',
                      sublabel: 'Offset',
                      value: '${q.offset.toStringAsFixed(1)}°',
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      label: 'ئاڕاستە',
                      sublabel: 'Direction',
                      value: '${q.qiblah.toStringAsFixed(1)}°',
                      highlight: true,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // ── Compass ────────────────────────────────────────────
                _CompassDial(
                  compassRad: compassRad,
                  qiblaRad: qiblaRad,
                ),

                const SizedBox(height: 40),

                // ── Cardinal pill ──────────────────────────────────────
                _CardinalBar(heading: q.direction),

                const SizedBox(height: 24),

                // ── Hint card ──────────────────────────────────────────
                const _HintCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD — Minimalist, flat, modern
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String sublabel;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: highlight ? _accent.withValues(alpha: 0.3) : _rim),
          boxShadow: highlight
              ? [const BoxShadow(color: _accentGlow, blurRadius: 20, spreadRadius: -5)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (highlight)
                  const Icon(Icons.explore_rounded, color: _accent, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: highlight ? _accent : _textMain,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: const TextStyle(
                color: _textSub,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPASS DIAL — Layered RepaintBoundaries, minimalist tech style
// ─────────────────────────────────────────────────────────────────────────────
class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.compassRad,
    required this.qiblaRad,
  });

  final double compassRad;
  final double qiblaRad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer minimal track
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _rim, width: 1.5),
            ),
          ),

          // Dial (rotates with device heading)
          RepaintBoundary(
            child: Transform.rotate(
              angle: compassRad,
              filterQuality: FilterQuality.medium,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: _DialPainter(),
              ),
            ),
          ),

          // Needle (points to Qibla)
          RepaintBoundary(
            child: Transform.rotate(
              angle: qiblaRad,
              filterQuality: FilterQuality.medium,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: _NeedlePainter(),
              ),
            ),
          ),

          // Centre hub
          const _CentreHub(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARDINAL BAR — Tech Pill shape
// ─────────────────────────────────────────────────────────────────────────────
class _CardinalBar extends StatelessWidget {
  const _CardinalBar({required this.heading});
  final double heading;

  static String _cardinal(double h) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((h + 22.5) % 360 ~/ 45)];
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: _rim),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _cardinal(heading),
          style: const TextStyle(
            color: _textMain,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        Container(
          width: 2,
          height: 14,
          color: _rim,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Text(
          '${heading.toStringAsFixed(0)}°',
          style: const TextStyle(
            color: _textSub,
            fontSize: 15,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HINT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HintCard extends StatelessWidget {
  const _HintCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _rim),
    ),
    child: const Row(
      children: [
        Icon(Icons.shield_moon_rounded, color: _textSub, size: 20),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'مۆبایلەکەت بە ڕێکی دابنێ و لە ئامێری کارەبایی دووری بخەرەوە.',
            style: TextStyle(
              color: _textSub,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CENTRE HUB
// ─────────────────────────────────────────────────────────────────────────────
class _CentreHub extends StatelessWidget {
  const _CentreHub();

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: _bg,
      shape: BoxShape.circle,
      border: Border.all(color: _accent, width: 4),
      boxShadow: const [
        BoxShadow(color: _accentGlow, blurRadius: 10, spreadRadius: 2),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.loc, required this.onRetry});
  final _LocStatus loc;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final msg = loc.enabled
        ? 'پێویستە دەستگەیشتن بە شوێنەکەت هەبێت\nبۆ زانینی ئاڕاستەی قیبلە.'
        : 'تکایە شوێن (GPS) کارا بکە.';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _rim),
              ),
              child: const Icon(
                Icons.location_disabled_rounded,
                color: _textSub,
                size: 40,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMain,
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: _ModernButton(
                label: 'دووبارە هەوڵبدەرەوە',
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODERN BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ModernButton extends StatefulWidget {
  const _ModernButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: _accentGlow, blurRadius: 15, offset: Offset(0, 4)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: _bg,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOC STATUS
// ─────────────────────────────────────────────────────────────────────────────
class _LocStatus {
  const _LocStatus(this.perm, this.enabled);
  final PermissionStatus perm;
  final bool enabled;
  bool get granted => perm == PermissionStatus.granted;
}

// ─────────────────────────────────────────────────────────────────────────────
// DIAL PAINTER — Clean tech marks
// ─────────────────────────────────────────────────────────────────────────────
class _DialPainter extends CustomPainter {
  static final _tickMaj = Paint()
    ..color = _tickBright
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;
  static final _tickMin = Paint()
    ..color = _tickDim
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round;
  static final _tickN = Paint()
    ..color = _accent
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

  final Map<String, TextPainter> _tp;

  _DialPainter() : _tp = _createTp();

  static Map<String, TextPainter> _createTp() {
    const styles = {
      'N': TextStyle(color: _accent,   fontSize: 16, fontWeight: FontWeight.w800),
      'E': TextStyle(color: _textSub,  fontSize: 13, fontWeight: FontWeight.w600),
      'S': TextStyle(color: _textSub,  fontSize: 13, fontWeight: FontWeight.w600),
      'W': TextStyle(color: _textSub,  fontSize: 13, fontWeight: FontWeight.w600),
    };
    return {
      for (final e in styles.entries)
        e.key: TextPainter(
          text: TextSpan(text: e.key, style: e.value),
          textDirection: TextDirection.ltr,
        )..layout(),
    };
  }

  static const _cardAngles = {
    'N': 0.0,
    'E': math.pi / 2,
    'S': math.pi,
    'W': 3 * math.pi / 2,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // ── Tick marks ──
    for (var i = 0; i < 360; i += 5) {
      final isNorth = i == 0;
      final isMaj   = i % 30 == 0;
      final len     = isNorth ? 18.0 : isMaj ? 12.0 : 6.0;
      final paint   = isNorth ? _tickN : (isMaj ? _tickMaj : _tickMin);
      final rad     = (i - 90) * math.pi / 180;
      final outer   = r - 10;
      final inner   = outer - len;

      canvas.drawLine(
        Offset(cx + outer * math.cos(rad), cy + outer * math.sin(rad)),
        Offset(cx + inner * math.cos(rad), cy + inner * math.sin(rad)),
        paint,
      );
    }

    // ── Cardinal labels ──
    final labelR = r - 45;
    _cardAngles.forEach((label, angle) {
      final tp = _tp[label]!;
      tp.paint(
        canvas,
        Offset(
          cx + labelR * math.cos(angle - math.pi / 2) - tp.width  / 2,
          cy + labelR * math.sin(angle - math.pi / 2) - tp.height / 2,
        ),
      );
    });
  }

  @override
  bool shouldRepaint(_DialPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// NEEDLE PAINTER — Razor sharp, minimalist design
// ─────────────────────────────────────────────────────────────────────────────
class _NeedlePainter extends CustomPainter {
  final TextPainter _kaaba;

  _NeedlePainter()
      : _kaaba = TextPainter(
    text: const TextSpan(
      text: '🕋',
      style: TextStyle(fontSize: 26),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;
    final cy   = size.height / 2;
    final r    = size.width  / 2;
    final tipY = cy - r + 30;
    final baseY = cy + 15;

    // Razor sleek needle path
    final path = Path()
      ..moveTo(cx, tipY)
      ..lineTo(cx - 6, baseY)
      ..lineTo(cx, baseY - 8)
      ..lineTo(cx + 6, baseY)
      ..close();

    // Solid accent color
    final needlePaint = Paint()..color = _accent;

    // Drop shadow glow
    canvas.drawShadow(path, _accent, 16, true);
    canvas.drawPath(path, needlePaint);

    // Kaaba icon
    _kaaba.paint(
      canvas,
      Offset(cx - _kaaba.width / 2, tipY - _kaaba.height - 8),
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter _) => false;
}
