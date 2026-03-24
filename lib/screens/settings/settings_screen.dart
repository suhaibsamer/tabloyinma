import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ─────────────────────────────────────────────────────────────────────────────
  // PALETTE — OLED & Emerald Accent
  // ─────────────────────────────────────────────────────────────────────────────
  static const _bg          = Color(0xFF090A0C);
  static const _card        = Color(0xFF141518);
  static const _rim         = Color(0xFF26282D);
  static const _accent      = Color(0xFF00E676);
  static const _accentGlow  = Color(0x1A00E676);
  static const _textMain    = Color(0xFFF3F4F6);
  static const _textSub     = Color(0xFF9CA3AF);

  String _selectedCity = 'erbil';

  final List<Map<String, dynamic>> _cities = [
    {'value': 'erbil', 'name': 'هەولێر', 'emoji': '🏙️'},
    {'value': 'sulaymaniyah', 'name': 'سلێمانی', 'emoji': '🏔️'},
    {'value': 'duhok', 'name': 'دهۆک', 'emoji': '🌲'},
    {'value': 'halabja', 'name': 'هەڵەبجە', 'emoji': '🌄'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCity = prefs.getString('selectedCity') ?? 'erbil';
    });
  }

  Future<void> _setSelectedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
    setState(() {
      _selectedCity = city;
    });

    // Reschedule prayer notifications
    await NotificationService().schedulePrayerNotifications();

    if (mounted) {
      final cityName = _cities.firstWhere((c) => c['value'] == city)['name'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('شار گۆڕدرا بۆ $cityName', textAlign: TextAlign.right),
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DIALOG FOR ABOUT US
  // ─────────────────────────────────────────────────────────────────────────────
  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _rim),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentGlow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_rounded, color: _accent, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'دەربارەی ئێمە',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ئەم ئەپڵیکەیشنە لەلایەن تیمی گەشەپێدانی Tee Studio دروستکراوە بە مەبەستی خزمەتکردنی موسڵمانان.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSub, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Divider(color: _rim, thickness: 1),
                const SizedBox(height: 16),
                const Text(
                  'تیمی گەشەپێدان',
                  style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _buildTeamMember('دیزاینەر و گەشەپێدەر', 'Tee Studio'),
                const SizedBox(height: 8),
                _buildTeamMember('بەڕێوەبەری پڕۆژە', 'تیمی Tee Studio'),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: _accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Text(
                      'داخستن',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _bg, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamMember(String role, String name) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$role:',
          style: const TextStyle(color: _textSub, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(color: _textMain, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DIALOG FOR ABOUT APP
  // ─────────────────────────────────────────────────────────────────────────────
  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _rim),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: _accent, size: 40),
                const SizedBox(height: 20),
                const Text(
                  'دەربارەی ئەپڵیکەیشن',
                  style: TextStyle(color: _textMain, fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ئەپڵیکەیشنی تابلۆی ئیمان، یاریدەدەرێکی تەواوی موسڵمانە بۆ ئەنجامدانی پەرستشەکانی ڕۆژانە بە شێوەیەکی ئاسان و مۆدێرن.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textSub, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                const Text(
                  'گرنگترین تایبەتمەندییەکان:',
                  style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildAppFeature('🕌', 'کاتەکانی بانگ و ئاگادارکەرەوەی بانگ'),
                        _buildAppFeature('📖', 'قورئانی پیرۆز بە دەنگی قورئانخوێنەکان'),
                        _buildAppFeature('📝', 'خەتمی قورئان و حیفزی قورئان'),
                        _buildAppFeature('📿', 'تەسبیحی ئەلیکترۆنی و زیکرەکان'),
                        _buildAppFeature('🕋', 'دیاریکردنی وردی قیبلە'),
                        _buildAppFeature('✨', '٩٩ ناوی پیرۆزی خودای گەورە'),
                        _buildAppFeature('📈', 'بەدواداچوونی بەرەوپێشچوونی ڕۆژانە'),
                        _buildAppFeature('📅', 'ڕۆژژمێری کۆچی و زاینی'),
                        _buildAppFeature('🏆', 'تەحەدییە ئاینییەکان'),
                        _buildAppFeature('💰', 'ژمێرەری زەکات بە شێوەیەکی ورد'),
                        _buildAppFeature('🤲', 'فێربوونی نوێژە فەرز و سوننەتەکان'),
                        _buildAppFeature('📚', 'فەرهەنگی ناوەکان و ئادابە ئیسلامییەکان'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(16)),
                    child: const Text('باشە', textAlign: TextAlign.center, style: TextStyle(color: _bg, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: _textMain, fontSize: 13), textDirection: TextDirection.rtl)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DIALOG FOR CITY SELECTION
  // ─────────────────────────────────────────────────────────────────────────────
  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _rim),
              boxShadow: const [
                BoxShadow(color: Color(0x20000000), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                const Text(
                  'شارەکەت هەڵبژێرە',
                  style: TextStyle(
                    color: _textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'بۆ ڕێکخستنی کاتەکانی بانگ',
                  style: TextStyle(color: _textSub, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Cities List
                ..._cities.map((city) {
                  final isSelected = _selectedCity == city['value'];
                  return GestureDetector(
                    onTap: () {
                      _setSelectedCity(city['value']);
                      Navigator.pop(context); // Close dialog
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? _accentGlow : _bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? _accent.withOpacity(0.5) : _rim),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(city['emoji'], style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Text(
                                city['name'],
                                style: TextStyle(
                                  color: isSelected ? _accent : _textMain,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: _accent, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location Section
              _buildSectionHeader(
                icon: Icons.map_outlined,
                title: 'شوێن',
                subtitle: 'کاتەکانی بانگ بەپێی شار',
              ),
              const SizedBox(height: 16),
              _buildLocationTile(), // <--- NEW BUTTON FOR DIALOG

              const SizedBox(height: 48),

              // About Section
              _buildSectionHeader(
                icon: Icons.info_outline_rounded,
                title: 'زانیاری',
                subtitle: 'دەربارەی ئەپڵیکەیشن و گەشەپێدەر',
              ),
              const SizedBox(height: 20),

              _buildClickableTile(Icons.auto_awesome_outlined, 'دەربارەی ئەپڵیکەیشن', 'بینین', _showAboutAppDialog),
              _buildClickableTile(Icons.groups_rounded, 'تیمی گەشەپێدان', 'بینین', _showAboutUsDialog),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UI COMPONENTS
  // ─────────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'ڕێکخستنەکان',
        style: TextStyle(color: _textMain, fontWeight: FontWeight.w600, fontSize: 18),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rim),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _textMain, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title, required String subtitle}) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _accentGlow, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _accent, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(color: _textMain, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: _textSub, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // The new tile that opens the dialog
  Widget _buildLocationTile() {
    // Find the currently selected city to display its name
    final currentCity = _cities.firstWhere(
          (c) => c['value'] == _selectedCity,
      orElse: () => _cities[0],
    );

    return GestureDetector(
      onTap: _showCitySelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _rim),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(Icons.location_city_rounded, color: _textSub, size: 22),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'شاری ئێستا',
                style: TextStyle(color: _textSub, fontSize: 14, fontWeight: FontWeight.w500),
                textDirection: TextDirection.rtl,
              ),
            ),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  currentCity['name'],
                  style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w700),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _textSub, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableTile(IconData icon, String title, String actionText, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _rim),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, color: _accent, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: _textSub, fontSize: 14, fontWeight: FontWeight.w500),
                textDirection: TextDirection.rtl,
              ),
            ),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  actionText,
                  style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_back_ios_new_rounded, color: _accent, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}