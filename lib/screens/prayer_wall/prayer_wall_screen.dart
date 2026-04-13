import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/prayer_request.dart';
import '../../services/prayer_service.dart';

class PrayerWallScreen extends StatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen>
    with SingleTickerProviderStateMixin {
  final PrayerService _prayerService = PrayerService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _bg = Color(0xFF070B14);
  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);
  static const _textMuted = Color(0xFF6F7A8B);
  static const _accent = Color(0xFF7C5CFF);
  static const _accent2 = Color(0xFF46C2FF);
  static const _gold = Color(0xFFFFC96B);
  static const _green = Color(0xFF38D39F);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _showAddPrayerDialog() async {
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    final nameFocus = FocusNode();
    final contentFocus = FocusNode();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      _surface.withValues(alpha: 0.96),
                      _surface2.withValues(alpha: 0.94),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (context, setLocal) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 38,
                                height: 38,
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
                                'دوعای نوێ',
                                style: TextStyle(
                                  color: _gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'زیادکردنی پاڕانەوە',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'دەتوانیت بە ناو یان بێ ناو دوعاکەت بنووسیت',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: TextField(
                            controller: nameController,
                            focusNode: nameFocus,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'ناوەکەت',
                              hintStyle: TextStyle(
                                color: _textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: TextField(
                            controller: contentController,
                            focusNode: contentFocus,
                            maxLines: 5,
                            minLines: 4,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              height: 1.8,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                              'چی لە دڵتە لێرە بینووسە بۆ ئەوەی خەڵکی دوعات بۆ بکات...',
                              hintStyle: TextStyle(
                                color: _textMuted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'هەڵوەشاندنەوە',
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final content =
                                  contentController.text.trim();
                                  String name = nameController.text.trim();

                                  if (content.isEmpty) return;
                                  if (name.isEmpty) name = 'بێ ناو';

                                  _prayerService.addPrayerRequest(
                                    content,
                                    name,
                                  );

                                  Navigator.pop(context);
                                  _showToast();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'ناردن',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    nameController.dispose();
    contentController.dispose();
    nameFocus.dispose();
    contentFocus.dispose();
  }

  void _showToast() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surface2,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: _green.withValues(alpha: 0.25)),
        ),
        content: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: _green, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'داواکارییەکەت نێردرا، خودا لێت وەربگرێت',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPrayerDialog,
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'زیادکردنی دوعا',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _ModernBackground()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildPrayerList()),
                ],
              ),
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
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _textPrimary,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'دیواری دوعا',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showAddPrayerDialog,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: _accent,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  _accent.withValues(alpha: 0.26),
                  _accent2.withValues(alpha: 0.18),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'هاوبەشکردنی پاڕانەوە',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'دوعاکانت لێرە بنووسە',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'دوگمەی زیادکردن بکە بۆ نووسینی دوعای نوێ، وە با خەلک دوعات بۆ بکەن خوای گەورە دوعاکانتان قبول بکات',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14),
                Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<PrayerRequest>>(
        stream: _prayerService.getPrayerRequests(),
        builder: (context, snapshot) {
          final count = snapshot.data?.length ?? 0;
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Text(
                  '$count داواکاری',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrayerList() {
    return StreamBuilder<List<PrayerRequest>>(
      stream: _prayerService.getPrayerRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: _accent,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyStateModern();
        }

        final prayers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            return _PrayerCardModern(
              prayer: prayers[index],
              prayerService: _prayerService,
            );
          },
        );
      },
    );
  }
}

class _PrayerCardModern extends StatelessWidget {
  const _PrayerCardModern({
    required this.prayer,
    required this.prayerService,
  });

  final PrayerRequest prayer;
  final PrayerService prayerService;

  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);
  static const _gold = Color(0xFFFFC96B);
  static const _green = Color(0xFF38D39F);
  static const _pink = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    final userName =
    prayer.userName.trim().isEmpty ? 'بێ ناو' : prayer.userName.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            _surface.withValues(alpha: 0.96),
            _surface2.withValues(alpha: 0.92),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _gold.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: _gold,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(prayer.createdAt),
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withValues(alpha: 0.14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _gold,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              prayer.content,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 17,
                height: 1.95,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionChipModern(
                  label: 'خودا لێت وەربگرێت',
                  count: prayer.prayedCount,
                  icon: Icons.favorite_rounded,
                  color: _pink,
                  onTap: () => prayerService.incrementPrayed(prayer.id),
                ),
                _ActionChipModern(
                  label: 'ئامین',
                  count: prayer.amenCount,
                  icon: Icons.front_hand_rounded,
                  color: _green,
                  onTap: () => prayerService.incrementAmen(prayer.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'ئێستا';
    if (diff.inMinutes < 60) return '${diff.inMinutes} خولەک';
    if (diff.inHours < 24) return '${diff.inHours} کاتژمێر';
    return '${diff.inDays} ڕۆژ';
  }
}

class _ActionChipModern extends StatefulWidget {
  const _ActionChipModern({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionChipModern> createState() => _ActionChipModernState();
}

class _ActionChipModernState extends State<_ActionChipModern>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1, end: 1.10).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _pressed = true);
    _bounce.forward().then((_) => _bounce.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _pressed ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.color.withValues(alpha: _pressed ? 0.38 : 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${widget.count}',
                  key: ValueKey(widget.count),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateModern extends StatelessWidget {
  const _EmptyStateModern();

  static const _textSecondary = Color(0xFFB9C2D0);
  static const _textMuted = Color(0xFF6F7A8B);
  static const _gold = Color(0xFFFFC96B);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.12),
                border: Border.all(color: _gold.withValues(alpha: 0.22)),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: _gold,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'هێشتا هیچ داواکارییەک نییە',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'یەکەم کەس بە کە دوعاکەی خۆی لێرە هاوبەش دەکات',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernBackground extends StatelessWidget {
  const _ModernBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070B14), Color(0xFF0D1324)],
            ),
          ),
        ),
        const Positioned.fill(child: _AmbientBackground()),
        Positioned(
          top: -70,
          right: -40,
          child: _GlowBlob(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.18),
            size: 220,
          ),
        ),
        Positioned(
          bottom: 60,
          left: -50,
          child: _GlowBlob(
            color: const Color(0xFF46C2FF).withValues(alpha: 0.12),
            size: 190,
          ),
        ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AmbientPainter());
  }
}

class _AmbientPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final purpleGlow = RadialGradient(
      colors: [const Color(0x337C5CFF), Colors.transparent],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = purpleGlow.createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.85, size.height * 0.08),
            radius: size.width * 0.65,
          ),
        ),
    );

    final blueGlow = RadialGradient(
      colors: [const Color(0x2246C2FF), Colors.transparent],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = blueGlow.createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.10, size.height * 0.92),
            radius: size.width * 0.55,
          ),
        ),
    );

    final starPaint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 0.9 + 0.2;
      final opacity = (rng.nextDouble() * 60 + 15).toInt();
      starPaint.color = Colors.white.withAlpha(opacity);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
