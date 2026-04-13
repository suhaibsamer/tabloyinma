import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabloy_iman/services/zakat_service.dart';
import 'package:tabloy_iman/utils/info_utils.dart';

// ──────────────────────────────────────────────
// Design Tokens
// ──────────────────────────────────────────────
abstract class _T {
  static const bg = Color(0xFF070B14);
  static const surface = Color(0xFF101726);
  static const surface2 = Color(0xFF151D2E);
  static const border = Color(0xFF25304A);

  static const primary = Color(0xFF8B5CF6);
  static const primary2 = Color(0xFF6D28D9);
  static const blue = Color(0xFF38BDF8);
  static const gold = Color(0xFFF59E0B);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFFB7185);

  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF94A3B8);
  static const faint = Color(0xFF64748B);
}

// ──────────────────────────────────────────────
// Main Screen
// ──────────────────────────────────────────────
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen>
    with SingleTickerProviderStateMixin {
  final _goldCtrl = TextEditingController();
  final _goldPriceCtrl = TextEditingController();
  final _usdCtrl = TextEditingController();
  final _iqdCtrl = TextEditingController();
  final _usdRateCtrl = TextEditingController(text: '150000');

  final _service = ZakatService();

  double _total = 0;
  double _zakat = 0;
  double _nisabIqd = 0;
  double _goldNisab = 85;
  double _moneyNisab = 0;
  bool _nisabMet = false;

  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    _loadRates();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in [
      _goldCtrl,
      _goldPriceCtrl,
      _usdCtrl,
      _iqdCtrl,
      _usdRateCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRates() async {
    final r = await _service.getZakatRates();
    if (!mounted) return;

    setState(() {
      final gp = r['gold_price'] ?? 0;
      if (gp != 0) _goldPriceCtrl.text = gp.toStringAsFixed(0);

      final dp = r['dollar_price'] ?? 1500;
      _usdRateCtrl.text = (dp * 100).toInt().toString();

      _goldNisab = r['gold_nisab'] ?? 85;
      _moneyNisab = r['money_nisab'] ?? 0;

      _calculate();
    });
  }

  void _calculate() {
    final gold = double.tryParse(_goldCtrl.text) ?? 0;
    final goldPrice = double.tryParse(_goldPriceCtrl.text) ?? 0;
    final usd = double.tryParse(_usdCtrl.text) ?? 0;
    final iqd = double.tryParse(_iqdCtrl.text) ?? 0;
    final rate = (double.tryParse(_usdRateCtrl.text) ?? 150000) / 100;

    final total = (gold * goldPrice) + (usd * rate) + iqd;
    final nisab = _moneyNisab > 0 ? _moneyNisab : (_goldNisab * goldPrice);

    setState(() {
      _total = total;
      _nisabIqd = nisab;
      _nisabMet = total >= nisab && nisab > 0;
      _zakat = _nisabMet ? total * 0.025 : 0;
    });
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: Stack(
          children: [
            _buildBackgroundGlow(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildHeroCard(),
                          const SizedBox(height: 16),
                          _buildQuickStats(),
                          const SizedBox(height: 18),
                          _buildTabs(),
                          const SizedBox(height: 16),
                          _buildTabContent(),
                          const SizedBox(height: 24),
                          _buildCalculateButton(),
                        ],
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

  // ──────────────────────────────────────────
  // Background
  // ──────────────────────────────────────────
  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        PositionedDirectional(
          top: -80,
          end: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _T.primary.withValues(alpha: 0.18),
            ),
          ),
        ),
        PositionedDirectional(
          top: 130,
          start: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _T.blue.withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Header
  // ──────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 10),
      child: Row(
        children: [
          _IconGlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          Column(
            children: const [
              Text(
                'زەکات',
                style: TextStyle(
                  color: _T.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'حیسابکردنی زەکات بە شێوەی مۆدێرن',
                style: TextStyle(
                  color: _T.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _IconGlassButton(
            icon: Icons.info_outline_rounded,
            onTap: () => InfoUtils.showInfo(
              context,
              title: 'زەکات',
              description: 'ژمێرەری زەکات بۆ ئەوەی بزانیت چەند زەکاتت لەسەر فەرزە.',
              howToUse: 'بڕی پارە یان ئاڵتوونەکەت داخڵ بکە، بەرنامەکە بڕی زەکاتی پێویستت بۆ دەژمێرێت.',
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Hero
  // ──────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: _nisabMet
              ? [
            const Color(0xFF0B1E1A),
            const Color(0xFF10261E),
          ]
              : [
            const Color(0xFF161F34),
            const Color(0xFF0F172A),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        border: Border.all(
          color: _nisabMet
              ? _T.green.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (_nisabMet ? _T.green : _T.primary).withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusPill(),
          const SizedBox(height: 18),
          const Text(
            'کۆی گشتی سامان',
            style: TextStyle(
              color: _T.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(
                  _fmt(_total),
                  style: const TextStyle(
                    color: _T.text,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'IQD',
                  style: TextStyle(
                    color: _T.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'بڕی زەکات',
                  value: _fmt(_zakat),
                  suffix: 'IQD',
                  valueColor: _nisabMet ? _T.green : _T.text,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'نیساب',
                  value: _nisabIqd > 0 ? _fmt(_nisabIqd) : '—',
                  suffix: 'IQD',
                  valueColor: _T.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    final color = _nisabMet ? _T.green : _T.red;
    final bg = color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _nisabMet ? 'نیساب پڕ بووە' : 'نیساب پڕ نەبووە',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Quick stats
  // ──────────────────────────────────────────
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MiniInfoCard(
              title: 'زێڕ',
              value: '${_goldCtrl.text.isEmpty ? 0 : _goldCtrl.text} گرام',
              icon: Icons.workspace_premium_outlined,
              iconColor: _T.gold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniInfoCard(
              title: 'دۆلار',
              value: '${_usdCtrl.text.isEmpty ? 0 : _usdCtrl.text} USD',
              icon: Icons.attach_money_rounded,
              iconColor: _T.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniInfoCard(
              title: 'دینار',
              value: '${_iqdCtrl.text.isEmpty ? 0 : _iqdCtrl.text} IQD',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: _T.green,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Tabs
  // ──────────────────────────────────────────
  Widget _buildTabs() {
    const labels = ['نرخ', 'سامان', 'نیساب'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = _tabCtrl.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabCtrl.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isActive
                      ? const LinearGradient(
                    colors: [_T.primary, _T.primary2],
                  )
                      : null,
                  color: isActive ? null : Colors.transparent,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : _T.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabCtrl.index) {
      case 0:
        return _buildRatesTab();
      case 1:
        return _buildAssetsTab();
      default:
        return _buildNisabTab();
    }
  }

  Widget _buildRatesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SectionHeader(
            title: 'نرخەکانی بازاڕ',
            subtitle: 'نرخی زێڕ و دۆلار داخل بکە',
          ),
          const SizedBox(height: 14),
          _ModernInputField(
            label: 'نرخی ١ گرام زێڕ',
            hint: '0',
            controller: _goldPriceCtrl,
            icon: Icons.workspace_premium_outlined,
            accent: _T.gold,
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 12),
          _ModernInputField(
            label: 'نرخی ١٠٠ دۆلار',
            hint: '150000',
            controller: _usdRateCtrl,
            icon: Icons.currency_exchange_rounded,
            accent: _T.blue,
            onChanged: (_) => _calculate(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SectionHeader(
            title: 'سامانەکانت',
            subtitle: 'بڕی سامانەکانی خۆت داخل بکە',
          ),
          const SizedBox(height: 14),
          _ModernInputField(
            label: 'زێڕ (گرام)',
            hint: '0',
            controller: _goldCtrl,
            icon: Icons.savings_outlined,
            accent: _T.gold,
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 12),
          _ModernInputField(
            label: 'دۆلار (USD)',
            hint: '0',
            controller: _usdCtrl,
            icon: Icons.attach_money_rounded,
            accent: _T.blue,
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 12),
          _ModernInputField(
            label: 'دینار عێراقی (IQD)',
            hint: '0',
            controller: _iqdCtrl,
            icon: Icons.payments_outlined,
            accent: _T.green,
            onChanged: (_) => _calculate(),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _SectionHeader(
            title: 'زانیاری نیساب',
            subtitle: 'بنەمای حیسابکردنی زەکات',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoDataCard(
                  title: 'نیسابی زێڕ',
                  value: _goldNisab.toStringAsFixed(0),
                  unit: 'گرام',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoDataCard(
                  title: 'نیسابی زیو',
                  value: '595',
                  unit: 'گرام',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WideInfoCard(
            title: 'نیساب بە دینار',
            value: _nisabIqd > 0 ? _fmt(_nisabIqd) : '—',
            unit: 'IQD',
          ),
          const SizedBox(height: 12),
          const _RuleTile(label: 'ڕێژەی زەکاتی مال', value: '٢.٥٪'),
          const SizedBox(height: 10),
          const _RuleTile(label: 'ڕێژەی زەکاتی کشتوکاڵ', value: '٥٪ یان ١٠٪'),
          const SizedBox(height: 10),
          const _RuleTile(label: 'ماوەی حول', value: '١ ساڵ'),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Button
  // ──────────────────────────────────────────
  Widget _buildCalculateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _calculate,
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_T.primary, _T.primary2],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: _T.primary.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'ئێستا حیساب بکە',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Reusable Widgets
// ──────────────────────────────────────────────
class _IconGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconGlassButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: _T.text, size: 18),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final Color valueColor;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.suffix,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _T.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  suffix,
                  style: const TextStyle(
                    color: _T.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MiniInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: _T.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _T.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _T.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _T.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernInputField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final Color accent;
  final ValueChanged<String> onChanged;

  const _ModernInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.accent,
    required this.onChanged,
  });

  @override
  State<_ModernInputField> createState() => _ModernInputFieldState();
}

class _ModernInputFieldState extends State<_ModernInputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _T.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _focused
              ? widget.accent.withValues(alpha: 0.65)
              : _T.border.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: _focused
            ? [
          BoxShadow(
            color: widget.accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: widget.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(widget.icon, color: widget.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focused = f),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: _T.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    style: const TextStyle(
                      color: _T.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: _T.faint,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
}

class _InfoDataCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _InfoDataCard({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _T.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: _T.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: _T.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WideInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _WideInfoCard({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _T.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: _T.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: _T.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final String label;
  final String value;

  const _RuleTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _T.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _T.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
