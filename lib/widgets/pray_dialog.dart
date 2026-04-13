import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/prayer_request.dart';

class PrayDialog extends StatefulWidget {
  final PrayerRequest prayer;

  const PrayDialog({super.key, required this.prayer});

  static void show(BuildContext context) {
    // For now we simulate a new prayer. In a real app this would be triggered by a notification or stream.
    final mockPrayer = PrayerRequest(
      id: '1',
      userId: 'mock_user',
      content: 'خوایە گیان شیفای هەموو نەخۆشێک بدەیت و ڕەحم بە مردووەکانمان بکەیت، ئامین.',
      userName: 'ڕەوەند عوسمان',
      createdAt: DateTime.now(),
      amenCount: 12,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => PrayDialog(prayer: mockPrayer),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PrayDialog> createState() => _PrayDialogState();
}

class _PrayDialogState extends State<PrayDialog> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  static const _bg = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _textPrimary = Color(0xFFF8FAFC);
  static const _textSecondary = Color(0xFF94A3B8);
  static const _accent = Color(0xFF8B5CF6);
  static const _gold = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _progressController.forward().then((_) {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -50,
                  child: _GlowBlob(color: _accent, size: 300),
                ),
                Positioned(
                  bottom: -80,
                  left: -40,
                  child: _GlowBlob(color: _gold, size: 250),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _dismiss,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
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
                                  color: _gold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _gold.withValues(alpha: 0.22),
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
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _gold.withValues(alpha: 0.95),
                                const Color(0xFFFFB347),
                              ],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withValues(alpha: 0.25),
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
                            color: _textSecondary.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _bg.withValues(alpha: 0.34),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Text(
                              widget.prayer.content,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 17,
                                height: 1.9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      value: 1 - _progressController.value,
                                      minHeight: 6,
                                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                                      valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'ئەم پەنجەرەیە دوای 10 چرکە داخراو دەبێت',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _textSecondary.withValues(alpha: 0.65),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _dismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
            colors: [color.withValues(alpha: 0.2), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
