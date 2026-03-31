import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../utils/kurdish_styles.dart';

class AthanPlayerScreen extends StatefulWidget {
  final String prayerName;
  const AthanPlayerScreen({Key? key, required this.prayerName}) : super(key: key);

  @override
  _AthanPlayerScreenState createState() => _AthanPlayerScreenState();
}

class _AthanPlayerScreenState extends State<AthanPlayerScreen> with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _pulseController;
  
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _teal      = Color(0xFF22D3EE);
  static const _gold      = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setAsset('assets/notfication/notefcation.mp3');
      _player.play();
    } catch (e) {
      debugPrint("Error loading Athan: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          _buildBackgroundGlow(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'کاتی بانگ',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'بانگی ${widget.prayerName}',
                    style: KurdishStyles.getTitleStyle(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(height: 60),
                  _buildAnimatedIcon(),
                  const SizedBox(height: 80),
                  _buildStopButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                _teal.withOpacity(0.15),
                _deepSpace.withOpacity(0.8),
              ],
              radius: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _teal.withOpacity(0.2 * _pulseController.value),
                blurRadius: 40,
                spreadRadius: 10 * _pulseController.value,
              ),
            ],
            border: Border.all(
              color: _teal.withOpacity(0.3 + (0.7 * _pulseController.value)),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.notifications_active_rounded,
              size: 100,
              color: Color.lerp(_teal, _gold, _pulseController.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: () {
        _player.stop();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stop_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'ڕاگرتنی بانگ',
              style: KurdishStyles.getKurdishStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(60, (i) => Offset(math.Random(i * 137).nextDouble(), math.Random(i * 137).nextDouble()));
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      paint.color = Colors.white.withOpacity(math.Random(i * 137).nextDouble() * 0.4 + 0.1);
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), math.Random(i * 137).nextDouble() * 1.2 + 0.3, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
