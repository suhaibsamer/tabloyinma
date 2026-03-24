import 'package:flutter/material.dart';
import '../../services/name_dictionary_service.dart';

class NameDictionaryScreen extends StatefulWidget {
  const NameDictionaryScreen({super.key});

  @override
  State<NameDictionaryScreen> createState() => _NameDictionaryScreenState();
}

class _NameDictionaryScreenState extends State<NameDictionaryScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _allNames = [];
  List<dynamic> _filteredNames = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Design tokens
  static const Color _bg            = Color(0xFF080C18);
  static const Color _surface       = Color(0xFF0F1424);
  static const Color _surfaceHigh   = Color(0xFF161B2E);
  static const Color _accent        = Color(0xFF7C6AFA);
  static const Color _accentSoft    = Color(0xFF9D8FFF);
  static const Color _accentGlow    = Color(0x337C6AFA);
  static const Color _textPrimary   = Color(0xFFF0EDFF);
  static const Color _textSecondary = Color(0xFF8B8BA8);
  static const Color _border        = Color(0xFF1E2340);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _applyFilters();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      bool exists = await NameDictionaryService.checkIfFileExists();
      if (!exists) await NameDictionaryService.downloadJson();
      final dynamic data = await NameDictionaryService.loadNames();
      if (data is List) {
        _allNames = data;
      } else if (data is Map && data.containsKey('names')) {
        _allNames = data['names'] as List<dynamic>;
      } else {
        _allNames = [];
      }
      _applyFilters();
    } catch (e) {
      _error = 'هەڵەیەک ڕوویدا لە کاتی بارکردنی داتا: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final genderFilter = _tabController.index == 0
        ? null
        : (_tabController.index == 1 ? 'کوڕ' : 'کچ');

    final filtered = _allNames.where((item) {
      final name    = item['name']?.toString() ?? '';
      final meaning = item['meaning']?.toString() ?? '';
      final gender  = item['gender']?.toString() ?? '';
      if (genderFilter != null && gender != genderFilter) return false;
      if (query.isNotEmpty &&
          !name.toLowerCase().contains(query) &&
          !meaning.toLowerCase().contains(query)) return false;
      return true;
    }).toList();

    setState(() => _filteredNames = filtered);
  }

  void _openMeaningSheet(String name, String meaning, bool isBoy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MeaningBottomSheet(
        name: name,
        meaning: meaning,
        isBoy: isBoy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildResultCount()),
          _isLoading
              ? const SliverFillRemaining(child: _LoadingView())
              : _error != null
              ? SliverFillRemaining(child: _ErrorView(message: _error!))
              : _filteredNames.isEmpty
              ? const SliverFillRemaining(child: _EmptyView())
              : _buildNameList(),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  // expandedHeight covers only the hero section above the pinned TabBar.
  // We use a plain Column inside the background so nothing overlaps.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      // hero section height (no TabBar — TabBar added separately via `bottom`)
      expandedHeight: 120,
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // The title shown when collapsed (scrolled up)
      title: const Text(
        'فەرهەنگی ناوەکان',
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () async {
              await NameDictionaryService.downloadJson();
              _loadData();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.sync_rounded, color: _accentSoft, size: 18),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // Disable the built-in title so our custom one above handles collapsed
        titlePadding: EdgeInsets.zero,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1424), Color(0xFF14102A)],
            ),
          ),
          child: Stack(
            children: [
              // Glow orb
              Positioned(
                top: -20, right: -10,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_accent.withOpacity(0.16), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Hero content — aligned to bottom-right, clear of status bar
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Badge label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'فەرهەنگ',
                            style: TextStyle(
                              color: _accentSoft,
                              fontSize: 11,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 5, height: 5,
                            decoration: BoxDecoration(
                              color: _accentSoft,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: _accent.withOpacity(0.9),
                                blurRadius: 6,
                              )],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Main title
                      const Text(
                        'ناوەکان',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _buildTabBar(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _surface,
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _accent.withOpacity(0.15),
          border: Border.all(color: _accent.withOpacity(0.4), width: 1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelColor: _accentSoft,
        unselectedLabelColor: _textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'هەمووی'),
          Tab(text: 'کوڕان'),
          Tab(text: 'کچان'),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    final hasText = _searchController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasText ? _accent.withOpacity(0.5) : _border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasText
                  ? _accent.withOpacity(0.1)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'بگەڕێ بۆ ناو یان مانا...',
            hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
            // Clear button on the left (prefix in RTL = visual right-to-left left)
            prefixIcon: hasText
                ? IconButton(
              icon: const Icon(Icons.cancel_rounded,
                  color: _textSecondary, size: 19),
              onPressed: () => _searchController.clear(),
            )
                : null,
            // Search icon on the right
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.search_rounded, color: _accentSoft, size: 22),
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          ),
        ),
      ),
    );
  }

  // ── Result count row ───────────────────────────────────────────────────────
  Widget _buildResultCount() {
    final total      = _allNames.length;
    final showing    = _filteredNames.length;
    final isFiltered = showing != total && total > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFiltered) ...[
            Text(
              'لە $total',
              style: TextStyle(
                color: _textSecondary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$showing ناو',
                  style: const TextStyle(
                    color: _accentSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    color: _accentSoft, shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Name list ──────────────────────────────────────────────────────────────
  SliverList _buildNameList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item    = _filteredNames[index];
          final name    = item['name']    ?? 'بێ ناو';
          final meaning = item['meaning'] ?? 'بێ مانا';
          final gender  = item['gender']  ?? '';
          final isBoy   = gender == 'کوڕ';
          return _NameCard(
            name: name,
            meaning: meaning,
            isBoy: isBoy,
            onTap: () => _openMeaningSheet(name, meaning, isBoy),
          );
        },
        childCount: _filteredNames.length,
      ),
    );
  }
}

// ─── Meaning Bottom Sheet ─────────────────────────────────────────────────────

class _MeaningBottomSheet extends StatelessWidget {
  const _MeaningBottomSheet({
    required this.name,
    required this.meaning,
    required this.isBoy,
  });
  final String name;
  final String meaning;
  final bool isBoy;

  static const Color _surface     = Color(0xFF0F1424);
  static const Color _surfaceHigh = Color(0xFF161B2E);
  static const Color _accentSoft  = Color(0xFF9D8FFF);
  static const Color _boyBlue     = Color(0xFF4A9EFF);
  static const Color _girlPink    = Color(0xFFFF6B9D);
  static const Color _textPrimary    = Color(0xFFF0EDFF);
  static const Color _textSecondary  = Color(0xFF8B8BA8);
  static const Color _border      = Color(0xFF1E2340);

  @override
  Widget build(BuildContext context) {
    final color       = isBoy ? _boyBlue : _girlPink;
    final genderLabel = isBoy ? 'کوڕ' : 'کچ';
    final genderIcon  = isBoy ? '♂' : '♀';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: color.withOpacity(0.3), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(genderIcon, style: TextStyle(color: color, fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(genderLabel,
                        style: TextStyle(
                            color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Text(
                name,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: color.withOpacity(0.3), blurRadius: 12)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('ماناکەی',
                  style: TextStyle(
                      color: _accentSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, _accentSoft.withOpacity(0.3)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surfaceHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Text(
              meaning,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFD4D0F0),
                fontSize: 15,
                height: 1.8,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _textSecondary,
                side: BorderSide(color: _border, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('داخستن',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Name Card ────────────────────────────────────────────────────────────────

class _NameCard extends StatelessWidget {
  const _NameCard({
    required this.name,
    required this.meaning,
    required this.isBoy,
    required this.onTap,
  });
  final String name;
  final String meaning;
  final bool isBoy;
  final VoidCallback onTap;

  static const Color _surfaceHigh   = Color(0xFF161B2E);
  static const Color _textPrimary   = Color(0xFFF0EDFF);
  static const Color _textSecondary = Color(0xFF8B8BA8);
  static const Color _boyBlue       = Color(0xFF4A9EFF);
  static const Color _girlPink      = Color(0xFFFF6B9D);
  static const Color _border        = Color(0xFF1E2340);

  @override
  Widget build(BuildContext context) {
    final color       = isBoy ? _boyBlue : _girlPink;
    final genderIcon  = isBoy ? '♂' : '♀';
    final genderLabel = isBoy ? 'کوڕ' : 'کچ';
    final preview     = meaning.length > 44
        ? '${meaning.substring(0, 44)}...'
        : meaning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Text(genderIcon,
                          style: TextStyle(color: color, fontSize: 12)),
                      const SizedBox(width: 3),
                      Text(genderLabel,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded,
                    color: _textSecondary.withOpacity(0.4), size: 18),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(preview,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: _textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Utility views ────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 36, height: 36,
          child: CircularProgressIndicator(
              color: Color(0xFF7C6AFA), strokeWidth: 2.5),
        ),
        SizedBox(height: 16),
        Text('داتا بار دەکرێت...',
            style: TextStyle(color: Color(0xFF8B8BA8), fontSize: 14)),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 36),
          ),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  color: Color(0xFF8B8BA8), fontSize: 14, height: 1.6)),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B2E),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1E2340)),
          ),
          child: const Icon(Icons.search_off_rounded,
              size: 40, color: Color(0xFF3D3D5C)),
        ),
        const SizedBox(height: 20),
        const Text('هیچ ناوێک نەدۆزرایەوە',
            style: TextStyle(
                color: Color(0xFF8B8BA8),
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const Text('گۆڕانکاری بکە لە فلتەرەکان',
            style: TextStyle(color: Color(0xFF3D3D5C), fontSize: 13)),
      ],
    ),
  );
}