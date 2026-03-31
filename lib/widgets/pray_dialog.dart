import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tabloy_iman/models/prayer_request.dart';
import 'package:tabloy_iman/services/prayer_service.dart';

class PrayDialog extends StatefulWidget {
  final PrayerRequest prayer;
  final VoidCallback onDismiss;

  const PrayDialog({
    super.key,
    required this.prayer,
    required this.onDismiss,
  });

  static void show(BuildContext context) async {
    final PrayerService prayerService = PrayerService();
    final prayer = await prayerService.getRandomPrayerRequest();

    if (prayer == null || !context.mounted) return;

    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => PrayDialog(
        prayer: prayer,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 10), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  State<PrayDialog> createState() => _PrayDialogState();
}

class _PrayDialogState extends State<PrayDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  static const _bg = Color(0xFF0B1020);
  static const _surface = Color(0xFF151C31);
  static const _surface2 = Color(0xFF1B2440);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB7C0CE);
  static const _accent = Color(0xFF7C5CFF);
  static const _accent2 = Color(0xFF46C2FF);
  static const _gold = Color(0xFFFFC96B);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() {
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.black.withOpacity(0.72),
        child: Stack(
          children: [
            Positioned(
              top: 120,
              right: -40,
              child: _GlowBlob(
                color: _accent.withOpacity(0.18),
                size: 180,
              ),
            ),
            Positioned(
              bottom: 140,
              left: -50,
              child: _GlowBlob(
                color: _accent2.withOpacity(0.14),
                size: 160,
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  _surface.withOpacity(0.95),
                                  _surface2.withOpacity(0.92),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.30),
                                  blurRadius: 28,
                                  offset: const Offset(0, 16),
                                ),
                                BoxShadow(
                                  color: _gold.withOpacity(0.08),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _dismiss,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                            Colors.white.withOpacity(0.08),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: _textSecondary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _gold.withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _gold.withOpacity(0.22),
                                        ),
                                      ),
                                      child: const Text(
                                        'دیواری دوعا',
                                        style: TextStyle(
                                          color: _gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _gold.withOpacity(0.95),
                                        const Color(0xFFFFB347),
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withOpacity(0.25),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.volunteer_activism_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'دوعایەک بۆت هات',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'لەلایەن ${widget.prayer.userName}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _textSecondary.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: _bg.withOpacity(0.34),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                  ),
                                  child: Text(
                                    widget.prayer.content,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontSize: 17,
                                      height: 1.9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                        value: 1 - _progressController.value,
                                        minHeight: 6,
                                        backgroundColor:
                                        Colors.white.withOpacity(0.06),
                                        valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          _gold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'ئەم پەنجەرەیە دوای 10 چرکە داخراو دەبێت',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _textSecondary.withOpacity(0.65),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _dismiss,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text(
                                      'باشە',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}