import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../../services/audio_preferences_service.dart';
import '../../services/reciter_service.dart';
import '../../services/adhan_download_service.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF070B14);
  static const _bg2 = Color(0xFF0D1324);
  static const _surface = Color(0xFF121A2F);
  static const _surface2 = Color(0xFF18233D);
  static const _accent = Color(0xFF7C5CFF);
  static const _accent2 = Color(0xFF46C2FF);
  static const _gold = Color(0xFFFFC96B);
  static const _green = Color(0xFF38D39F);
  static const _red = Color(0xFFFF6B6B);
  static const _textPrimary = Color(0xFFF8F7FC);
  static const _textSecondary = Color(0xFFB9C2D0);
  static const _textMuted = Color(0xFF6F7A8B);

  String _selectedCity = 'erbil';

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  final AudioPlayer _previewPlayer = AudioPlayer();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _cities = [
    {'value': 'erbil', 'name': 'هەولێر', 'emoji': '🏙️', 'desc': 'پایتەخت'},
    {'value': 'sulaymaniyah', 'name': 'سلێمانی', 'emoji': '🏔️', 'desc': 'شارەوانی'},
    {'value': 'duhok', 'name': 'دهۆک', 'emoji': '🌲', 'desc': 'باکوور'},
    {'value': 'halabja', 'name': 'هەڵەبجە', 'emoji': '🌄', 'desc': 'ڕۆژهەڵات'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _selectedCity = prefs.getString('selectedCity') ?? 'erbil';
    });
  }

  Future<void> _setSelectedCity(String city) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
    setState(() => _selectedCity = city);
    await NotificationService().schedulePrayerNotifications();

    final cityName = _cities.firstWhere((c) => c['value'] == city)['name'];
    _showCustomSnackBar('شار گۆڕدرا بۆ $cityName', _accent);
  }

  void _showCustomSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surface2,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        content: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active_rounded, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
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
  void dispose() {
    _previewPlayer.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _cityName {
    return _cities.firstWhere((c) => c['value'] == _selectedCity)['name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _ModernSettingsBackground()),
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 28),
                    child: Column(
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 18),
                        _buildSectionTitle('ڕێکخستنە سەرەکییەکان'),
                        const SizedBox(height: 12),
                        _buildMainCards(),
                        const SizedBox(height: 18),
                        _buildSectionTitle('زانیاری و پشتیوانی'),
                        const SizedBox(height: 12),
                        _buildInfoCards(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      centerTitle: true,
      expandedHeight: 90,
      automaticallyImplyLeading: true,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _textPrimary,
              size: 18,
            ),
          ),
        ),
      ),
      title: const Text(
        'ڕێکخستن',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return ScaleTransition(
      scale: _pulseAnim,
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
                  _accent.withValues(alpha: 0.28),
                  _accent2.withValues(alpha: 0.18),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'کۆنترۆڵی ئەپەکەت',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'ڕێکخستن بە شێوازێکی مۆدێرن',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'شار، دەنگی بانگ، زەکات و زانیارییەکانی ئەپ لە یەک شوێن',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: _accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        ),
      ],
    );
  }

  Widget _buildMainCards() {
    return Consumer<AudioPreferencesService>(
      builder: (context, audioPrefs, _) {
        final currentAthan = audioPrefs.availableAthans.firstWhere(
          (a) => a['file'] == audioPrefs.selectedAthanSound,
          orElse: () => audioPrefs.availableAthans.first,
        );
        
        final currentReciter = ReciterService().getById(audioPrefs.selectedReciterId);

        return Column(
          children: [
            _buildSettingsTile(
              icon: Icons.location_on_rounded,
              iconColor: _accent2,
              title: 'شار',
              subtitle: _cityName,
              trailingText: 'گۆڕین',
              onTap: _showCitySelectionDialog,
            ),
            // const SizedBox(height: 12),
            // _buildSettingsTile(
            //   icon: Icons.mosque_rounded,
            //   iconColor: _gold,
            //   title: 'دەنگی بانگ',
            //   subtitle: currentAthan['name']!,
            //   trailingText: 'هەڵبژاردن',
            //   onTap: _showAthanSelectionDialog,
            // ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.record_voice_over_rounded,
              iconColor: _green,
              title: 'قورئانخوێنی بنەڕەتی',
              subtitle: currentReciter.name,
              trailingText: 'گۆڕین',
              onTap: _showReciterSelectionDialog,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.info_outline_rounded,
          iconColor: _accent,
          title: 'دەربارەی ئەپ',
          subtitle: 'تایبەتمەندی و وردەکارییەکان',
          trailingText: 'بینە',
          onTap: _showAboutAppDialog,
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.groups_rounded,
          iconColor: _gold,
          title: 'دەربارەی ئێمە',
          subtitle: 'Tee Studio',
          trailingText: 'بینە',
          onTap: _showAboutUsDialog,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              _surface.withValues(alpha: 0.96),
              _surface2.withValues(alpha: 0.90),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: iconColor.withValues(alpha: 0.18)),
              ),
              child: Text(
                trailingText,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _showAthanSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, _, _) {
        double downloadProgress = 0;
        bool isDownloading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer<AudioPreferencesService>(
              builder: (context, audioPrefs, _) {
                return Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'دەنگی بانگ',
                            style: TextStyle(color: _textPrimary, fontSize: 19, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 18),
                          ...audioPrefs.availableAthans.map((athan) {
                            final isSelected = audioPrefs.selectedAthanSound == athan['file'];
                            final isCustom = athan['id'] == 'custom';
                            
                            return FutureBuilder<bool>(
                              future: isCustom ? AdhanDownloadService.isAdhanDownloaded() : Future.value(true),
                              builder: (context, snapshot) {
                                final isDownloaded = snapshot.data ?? false;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _accent.withValues(alpha: 0.12) : _bg2.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? _accent.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      if (isCustom && !isDownloaded) {
                                        if (isDownloading) return;
                                        setDialogState(() => isDownloading = true);
                                        final path = await AdhanDownloadService.downloadAdhan(
                                          onProgress: (p) => setDialogState(() => downloadProgress = p),
                                        );
                                        setDialogState(() => isDownloading = false);
                                        if (path != null) {
                                          audioPrefs.setSelectedAthan(athan['file']!);
                                          _showCustomSnackBar('بانگ بە سەرکەوتوویی دابەزی', _green);
                                        } else {
                                          _showCustomSnackBar('کێشەیەک لە داونلۆد دروست بوو', _red);
                                        }
                                      } else {
                                        audioPrefs.setSelectedAthan(athan['file']!);
                                      }
                                    },
                                    title: Text(
                                      athan['name']!,
                                      style: TextStyle(
                                        color: isSelected ? _accent : _textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    subtitle: isCustom && isDownloading
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: LinearProgressIndicator(
                                              value: downloadProgress,
                                              color: _accent,
                                              backgroundColor: _bg2,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          )
                                        : (isCustom && !isDownloaded 
                                            ? const Text('بۆ بەکارهێنان دەبێت دایبگریت', 
                                                style: TextStyle(color: _textMuted, fontSize: 10), 
                                                textAlign: TextAlign.start) 
                                            : null),
                                    leading: isDownloading && isCustom 
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: _accent)) 
                                      : IconButton(
                                      icon: Icon(
                                        isCustom && !isDownloaded ? Icons.download_for_offline_rounded : Icons.play_circle_fill_rounded, 
                                        color: isCustom && !isDownloaded ? _textMuted : _accent2
                                      ),
                                      onPressed: () async {
                                        if (isCustom && !isDownloaded) {
                                          if (isDownloading) return;
                                          setDialogState(() => isDownloading = true);
                                          final path = await AdhanDownloadService.downloadAdhan(
                                            onProgress: (p) => setDialogState(() => downloadProgress = p),
                                          );
                                          setDialogState(() => isDownloading = false);
                                          if (path != null) {
                                            audioPrefs.setSelectedAthan(athan['file']!);
                                            _showCustomSnackBar('بانگ بە سەرکەوتوویی دابەزی', _green);
                                          } else {
                                            _showCustomSnackBar('کێشەیەک لە داونلۆد دروست بوو', _red);
                                          }
                                        } else {
                                          try {
                                            await _previewPlayer.stop();
                                            if (isCustom) {
                                               final path = await AdhanDownloadService.getCustomAdhanPath();
                                               if (path != null && await File(path).exists()) {
                                                 await _previewPlayer.setFilePath(path);
                                               } else {
                                                 _showCustomSnackBar('فایلی دەنگ نەدۆزرایەوە', _red);
                                                 return;
                                               }
                                            } else {
                                               // Check if file exists in assets before playing
                                               // Since we noticed missing assets, let's be safe
                                               try {
                                                  await _previewPlayer.setAsset('assets/notfication/${athan['file']}.mp3');
                                               } catch (e) {
                                                  _showCustomSnackBar('ئەم دەنگە لە ئێستادا بەردەست نییە', _red);
                                                  return;
                                               }
                                            }
                                            await _previewPlayer.play();
                                            _showCustomSnackBar('پێشبینینی ${athan['name']}', _accent2);
                                          } catch (e) {
                                            _showCustomSnackBar('هەڵە لە لێدان', _red);
                                          }
                                        }
                                      },
                                    ),
                                    trailing: isSelected 
                                      ? const Icon(Icons.check_circle_rounded, color: _accent)
                                      : (isCustom && !isDownloaded ? const Icon(Icons.cloud_download_rounded, color: _textMuted) : null),
                                  ),
                                );
                              }
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        );
      },
    );
  }

  void _showReciterSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, _, _) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final reciters = ReciterService().search(_searchQuery);
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'قورئانخوێن هەڵبژێرە',
                        style: TextStyle(color: _textPrimary, fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _bg2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          textAlign: TextAlign.right,
                          onChanged: (v) => setDialogState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'گەڕان بۆ قورئانخوێن...',
                            hintStyle: TextStyle(color: _textMuted),
                            prefixIcon: Icon(Icons.search, color: _accent),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: reciters.length,
                          itemBuilder: (context, index) {
                            final r = reciters[index];
                            final isSelected = AudioPreferencesService().selectedReciterId == r.id;
                            return ListTile(
                              onTap: () {
                                AudioPreferencesService().setSelectedReciter(r.id);
                                Navigator.pop(ctx);
                              },
                              title: Text(
                                r.name,
                                style: TextStyle(
                                  color: isSelected ? _accent : _textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Text(
                                r.bitrate,
                                style: const TextStyle(color: _textMuted, fontSize: 10),
                                textAlign: TextAlign.right,
                              ),
                              trailing: isSelected ? const Icon(Icons.check, color: _accent) : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCitySelectionDialog() {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, _) => _buildCityDialogContent(ctx),
    );
  }

  Widget _buildCityDialogContent(BuildContext ctx) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'شارەکەت هەڵبژێرە',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              ..._cities.map((city) {
                final isSelected = _selectedCity == city['value'];
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _setSelectedCity(city['value']);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _accent.withValues(alpha: 0.12)
                          : _bg2.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _accent.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: _accent, size: 20)
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              city['name'],
                              style: TextStyle(
                                color: isSelected ? _accent : _textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              city['desc'],
                              style: const TextStyle(
                                color: _textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(city['emoji'], style: const TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutUsDialog() {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, _) => _buildAboutUsDialogContent(ctx),
    );
  }

  Widget _buildAboutUsDialogContent(BuildContext ctx) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withValues(alpha: 0.12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/app logo/Tee studio.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'دەربارەی ئێمە',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ئەم ئەپڵیکەیشنە لەلایەن تیمی گەشەپێدانی Tee Studio دروستکراوە بە مەبەستی خزمەتکردنی موسڵمانان.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 18),
              _buildMemberCard(
                '🎨',
                'دیزاینەر و گەشەپێدەر',
                'Tee Studio',
                url: 'https://www.instagram.com/tee_studio87?igsh=YWR6bGhxNzRqYXFp&utm_source=qr',
              ),
              const SizedBox(height: 10),
              _buildMemberCard(
                '📋',
                'بەڕێوەبەری پڕۆژە',
                'تیمی Tee Studio',
                url: 'https://t.me/teestudio87',
              ),
              const SizedBox(height: 18),
              _buildDialogButton('داخستن', Icons.close_rounded, () {
                Navigator.pop(ctx);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(
      String emoji,
      String role,
      String name, {
        String? url,
      }) {
    return GestureDetector(
      onTap: url == null
          ? null
          : () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg2.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: url != null
                ? _accent.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            if (url != null)
              Icon(Icons.open_in_new_rounded, color: _accent.withValues(alpha: 0.65), size: 16),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(emoji, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }

  void _showAboutAppDialog() {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, _) => _buildAboutAppDialogContent(ctx),
    );
  }

  Widget _buildAboutAppDialogContent(BuildContext ctx) {
    final features = [
      ('🕌', 'کاتەکانی بانگ و ئاگادارکەرەوە'),
      ('📖', 'قورئانی پیرۆز بە دەنگی قورئانخوێنەکان'),
      ('📝', 'خەتمی قورئان و حیفز'),
      ('📿', 'تەسبیحی ئەلیکترۆنی و زیکرەکان'),
      ('🕋', 'دیاریکردنی وردی قیبلە'),
      ('✨', '٩٩ ناوی پیرۆزی خودا'),
      ('📈', 'بەدواداچوونی بەرەوپێشچوونی ڕۆژانە'),
      ('📅', 'ڕۆژژمێری کۆچی و زاینی'),
      ('🏆', 'تەحەدییە ئاینییەکان'),
      ('💰', 'ژمێرەری زەکات'),
      ('🤲', 'فێربوونی نوێژ'),
      ('📚', 'فەرهەنگی ناوەکان'),
    ];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  gradient: LinearGradient(
                    colors: [
                      _accent.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: _accent, size: 30),
                    SizedBox(height: 10),
                    Text(
                      'دەربارەی ئەپڵیکەیشن',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'یاریدەدەرێکی تەواوی موسڵمانە بۆ ئەنجامدانی پەرستشەکانی ڕۆژانە بە شێوەیەکی مۆدێرن.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: features.map((f) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bg2.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                f.$2,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(f.$1, style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildDialogButton('باشە', Icons.check_rounded, () {
                  Navigator.pop(ctx);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accent, Color(0xFF5E47E8)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSettingsBackground extends StatelessWidget {
  const _ModernSettingsBackground();

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
        PositionedDirectional(
          top: -80,
          end: -40,
          child: _GlowBlob(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.16),
            size: 220,
          ),
        ),
        PositionedDirectional(
          top: 180,
          start: -50,
          child: _GlowBlob(
            color: const Color(0xFF46C2FF).withValues(alpha: 0.12),
            size: 180,
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
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

