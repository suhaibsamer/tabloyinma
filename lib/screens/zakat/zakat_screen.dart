import 'package:flutter/material.dart';
import '../../utils/kurdish_styles.dart';
import '../../services/theme_manager.dart';
import 'dart:math' as math;

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _goldPriceController = TextEditingController();
  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _ilsController = TextEditingController();
  final TextEditingController _usdToIlsController = TextEditingController(text: '3.7');
  
  // Debt controllers
  final TextEditingController _debtsToMeController = TextEditingController();
  final TextEditingController _debtsByMeController = TextEditingController();

  double _totalWealthIls = 0.0;
  double _zakatAmountIls = 0.0;
  bool _nisabReached = false;
  double _nisabValueIls = 0.0;

  // ── Palette ────────────────────────────────────────────────────────────
  static const _deepSpace = Color(0xFF04060F);
  static const _midnight = Color(0xFF0B0F1E);
  static const _nebula = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow = Color(0xFFE8E2FF);
  static const _accent = Color(0xFFB08AFF);
  static const _goldColor = Color(0xFFFFD97D);

  void _calculateZakat() {
    setState(() {
      double goldWeight = double.tryParse(_goldController.text) ?? 0.0;
      double goldPrice = double.tryParse(_goldPriceController.text) ?? 0.0;
      double usdAmount = double.tryParse(_usdController.text) ?? 0.0;
      double ilsAmount = double.tryParse(_ilsController.text) ?? 0.0;
      double usdRate = double.tryParse(_usdToIlsController.text) ?? 3.7;
      
      double debtsToMe = double.tryParse(_debtsToMeController.text) ?? 0.0;
      double debtsByMe = double.tryParse(_debtsByMeController.text) ?? 0.0;

      // Convert everything to ILS
      double goldValueIls = goldWeight * goldPrice;
      double usdValueIls = usdAmount * usdRate;
      
      // Formula: (Assets + Debts Owed to You) - (Debts You Owe)
      _totalWealthIls = (goldValueIls + usdValueIls + ilsAmount + debtsToMe) - debtsByMe;
      if (_totalWealthIls < 0) _totalWealthIls = 0;
      
      // Nisab is approximately 85 grams of gold
      _nisabValueIls = 85 * goldPrice;
      _nisabReached = _totalWealthIls >= _nisabValueIls && _nisabValueIls > 0;

      if (_nisabReached) {
        _zakatAmountIls = _totalWealthIls * 0.025;
      } else {
        _zakatAmountIls = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _goldController.dispose();
    _goldPriceController.dispose();
    _usdController.dispose();
    _ilsController.dispose();
    _usdToIlsController.dispose();
    _debtsToMeController.dispose();
    _debtsByMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'زەکات حیسابکردن',
          style: KurdishStyles.getTitleStyle(color: _starlight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _starlight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('نرخەکانی بازاڕ'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputCard(
                          title: 'نرخی ١ گرام ئاڵتوون (شیکڵ)',
                          controller: _goldPriceController,
                          icon: '💰',
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputCard(
                          title: 'نرخی ١ دۆلار (شیکڵ)',
                          controller: _usdToIlsController,
                          icon: '💹',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle('سەرمایەکەت'),
                  const SizedBox(height: 12),
                  _buildInputCard(
                    title: 'بڕی ئاڵتوون (گرام)',
                    controller: _goldController,
                    icon: '🟡',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 12),
                  _buildInputCard(
                    title: 'بڕی دۆلار (USD)',
                    controller: _usdController,
                    icon: '💵',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildInputCard(
                    title: 'بڕی شیکڵ (ILS)',
                    controller: _ilsController,
                    icon: '🏦',
                    color: Colors.blueAccent,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('قەرزەکان (بە شیکڵ)'),
                  const SizedBox(height: 12),
                  _buildInputCard(
                    title: 'ئەو پارەیەی خەڵک قەرزاری تۆیە',
                    controller: _debtsToMeController,
                    icon: '📥',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  _buildInputCard(
                    title: 'ئەو پارەیەی تۆ قەرزاری خەڵکیت',
                    controller: _debtsByMeController,
                    icon: '📤',
                    color: Colors.orangeAccent,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildResultSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent.withOpacity(0.2)),
      ),
      child: Text(
        'بۆ ئەنجامێکی ورد، هەموو سەرمایەکەت و ئەو قەرزانەی لەسەرتە یان لای خەڵکە بنووسە بە شیکڵ.',
        style: KurdishStyles.getKurdishStyle(color: _moonGlow, fontSize: 14),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: KurdishStyles.getKurdishStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.bold),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildInputCard({
    required String title,
    required TextEditingController controller,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _nebula,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              Expanded(
                child: Text(
                  title,
                  style: KurdishStyles.getKurdishStyle(color: _starlight.withOpacity(0.8), fontSize: 12),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: KurdishStyles.getKurdishStyle(color: _starlight, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: _starlight.withOpacity(0.2)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
            ),
            onChanged: (value) => _calculateZakat(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        _buildWealthRow('کۆی گشتی سەرمایەی پاکتاو کراو:', _totalWealthIls, _starlight),
        const SizedBox(height: 12),
        _buildWealthRow('ڕێژەی نیساب (٨٥گ ئاڵتوون):', _nisabValueIls, _goldColor),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _nisabReached ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _nisabReached ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                _nisabReached ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                color: _nisabReached ? Colors.green : Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _nisabReached ? 'زەکاتت لەسەر فەرزە' : 'زەکاتت لەسەر فەرز نییە',
                style: KurdishStyles.getTitleStyle(
                  color: _nisabReached ? Colors.green : Colors.redAccent,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _nisabReached 
                  ? 'سەرمایەکەت دوای لێدەرکردنی قەرزەکان، گەیشتووەتە ئاستی نیساب.'
                  : 'سەرمایەکەت دوای لێدەرکردنی قەرزەکان، هێشتا نەگەیشتووەتە ئاستی نیساب.',
                style: KurdishStyles.getKurdishStyle(color: _moonGlow.withOpacity(0.7), fontSize: 13),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              if (_nisabReached) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'بڕی پارەی زەکات بۆ دان:',
                        style: KurdishStyles.getKurdishStyle(color: Colors.green, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatMoney(_zakatAmountIls)} شیکڵ',
                        style: KurdishStyles.getKurdishStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWealthRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            label,
            style: KurdishStyles.getKurdishStyle(color: _moonGlow.withOpacity(0.6), fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_formatMoney(value)} شیکڵ',
          style: KurdishStyles.getKurdishStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(60, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.4 + 0.1;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(_stars[i].dx * size.width, _stars[i].dy * size.height), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
