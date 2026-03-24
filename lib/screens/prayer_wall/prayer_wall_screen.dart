import 'package:flutter/material.dart';
import '../../models/prayer_request.dart';
import '../../services/prayer_service.dart';
import 'dart:math' as math;

class PrayerWallScreen extends StatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen>
    with SingleTickerProviderStateMixin {
  final PrayerService _prayerService = PrayerService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;
  bool _isNameFocused = false;

  // --- Design Tokens ---
  static const _canvas = Color(0xFF0A0C14);
  static const _surfaceElevated = Color(0xFF181D2E);
  static const _rimLight = Color(0xFF252D44);

  static const _gold = Color(0xFFD4A853);
  static const _goldDim = Color(0x66D4A853); // Fixed hex

  static const _jade = Color(0xFF3ECFA0);
  static const _jadeDim = Color(0x4D3ECFA0); // Fixed hex

  static const _inkPrimary = Color(0xFFF2EFE8);
  static const _inkSecondary = Color(0xFF9A9EB8);
  static const _inkTertiary = Color(0xFF4A4F6A);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _nameFocusNode.addListener(() {
      setState(() => _isNameFocused = _nameFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _focusNode.dispose();
    _nameFocusNode.dispose();
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_controller.text.trim().isEmpty) return;
    String name = _nameController.text.trim();
    if (name.isEmpty) name = 'بێ ناو';
    _prayerService.addPrayerRequest(_controller.text.trim(), name);
    _controller.clear();
    _nameController.clear();
    FocusScope.of(context).unfocus();
    _showToast();
  }

  void _showToast() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _jadeDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: _jade, size: 16),
            ),
            const SizedBox(width: 12),
            const Text(
              'داواکارییەکەت نێردرا، خودا لێت وەربگرێت',
              style: TextStyle(
                color: _inkPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        backgroundColor: _surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _jade.withAlpha(60)),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildInputSection(),
                  _buildDivider(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _rimLight),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _inkSecondary, size: 15),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'دیواری دوعا و پاڕانەوە',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: _inkPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'دووعاکانت گوێیان لێ دەدرێت',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: _inkTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (_isFocused || _isNameFocused) ? _gold.withAlpha(100) : _rimLight,
            width: (_isFocused || _isNameFocused) ? 1.5 : 1.0,
          ),
          boxShadow: (_isFocused || _isNameFocused)
              ? [
            BoxShadow(
              color: _gold.withAlpha(20),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: _inkPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'ناوەکەت (یان بێ ناو)...',
                hintStyle: TextStyle(
                  color: _inkTertiary,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 8),
              ),
            ),
            const Divider(color: _rimLight, height: 1),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: _inkPrimary,
                fontSize: 14,
                height: 1.6,
              ),
              decoration: const InputDecoration(
                hintText:
                'چی لە دڵتە لێرە بینوسە بۆ ئەوەی خەڵکی دوعات بۆ بکات...',
                hintStyle: TextStyle(
                  color: _inkTertiary,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        color: _inkTertiary, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'تایبەت',
                      style: TextStyle(color: _inkTertiary, fontSize: 11),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _submitRequest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A853), Color(0xFFB8893C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'ناردن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: _rimLight),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: StreamBuilder<List<PrayerRequest>>(
              stream: _prayerService.getPrayerRequests(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Text(
                  '$count داواکاری',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: _inkTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(height: 1, color: _rimLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList() {
    return StreamBuilder<List<PrayerRequest>>(
      stream: _prayerService.getPrayerRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: _gold.withAlpha(150),
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyState();
        }
        final prayers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            return _PrayerCard(
              prayer: prayers[index],
              prayerService: _prayerService,
              index: index,
            );
          },
        );
      },
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRequest prayer;
  final PrayerService prayerService;
  final int index;

  static const _surfaceElevated = Color(0xFF181D2E);
  static const _rimLight = Color(0xFF252D44);
  static const _gold = Color(0xFFD4A853);
  static const _goldDim = Color(0x66D4A853);
  static const _jade = Color(0xFF3ECFA0);
  static const _jadeDim = Color(0x4D3ECFA0);
  static const _inkPrimary = Color(0xFFF2EFE8);
  static const _inkSecondary = Color(0xFF9A9EB8);
  static const _inkTertiary = Color(0xFF4A4F6A);

  const _PrayerCard({
    required this.prayer,
    required this.prayerService,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rimLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: _gold.withAlpha(10),
          highlightColor: _gold.withAlpha(5),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCardHeader(),
                const SizedBox(height: 12),
                Text(
                  prayer.content,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: _inkPrimary,
                    fontSize: 14,
                    height: 1.7,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 14),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _gold.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _gold.withAlpha(40)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded,
                  color: _inkTertiary, size: 11),
              const SizedBox(width: 4),
              Text(
                _formatTime(prayer.createdAt),
                style:
                const TextStyle(color: _inkTertiary, fontSize: 11),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: _goldDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: _gold, size: 14),
            ),
            const SizedBox(width: 8),
            const Text(
              'بێ ناوچاو',
              style: TextStyle(
                color: _inkSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: _rimLight);
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _ActionChip(
          label: 'خودا لێت وەربگرێت',
          count: prayer.prayedCount,
          icon: Icons.favorite_rounded,
          color: const Color(0xFFE8607A),
          dimColor: const Color(0x28E8607A),
          onTap: () => prayerService.incrementPrayed(prayer.id),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          label: 'ئامین',
          count: prayer.amenCount,
          icon: Icons.front_hand_rounded,
          color: _jade,
          dimColor: _jadeDim,
          onTap: () => prayerService.incrementAmen(prayer.id),
        ),
      ],
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

class _ActionChip extends StatefulWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color dimColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.dimColor,
    required this.onTap,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _scale;
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _tapped = true);
    _bounce.forward().then((_) => _bounce.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _tapped
              ? widget.dimColor.withAlpha(80)
              : widget.dimColor.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color.withAlpha(_tapped ? 80 : 40),
          ),
        ),
        child: ScaleTransition(
          scale: _scale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color.withAlpha(220),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  '${widget.count}',
                  key: ValueKey(widget.count),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _EmptyState extends StatelessWidget {
  static const _gold = Color(0xFFD4A853);
  static const _goldDim = Color(0x66D4A853);
  static const _inkTertiary = Color(0xFF4A4F6A);

  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _goldDim,
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withAlpha(60)),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: _gold,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'هیچ داواکارییەک نییە هێشتا',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: _inkTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'یەکەم کەس بە کە دووعاکەت هاوبەش دەکەیت',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFF363B55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _AmbientPainter());
}

class _AmbientPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldGradient = RadialGradient(
      colors: [
        const Color(0x2DD4A853), // Fixed hex
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = goldGradient.createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.85, size.height * 0.05),
            radius: size.width * 0.65,
          ),
        ),
    );

    final jadeGradient = RadialGradient(
      colors: [
        const Color(0x1F3ECFA0), // Fixed hex
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = jadeGradient.createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.1, size.height * 0.9),
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
  bool shouldRepaint(covariant CustomPainter old) => false;
}
