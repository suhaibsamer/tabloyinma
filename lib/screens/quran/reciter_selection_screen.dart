import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reciter_service.dart';
import '../../services/quran_audio_service.dart';
import '../../models/reciter.dart';
import '../../utils/kurdish_styles.dart';
import 'dart:math' as math;

class ReciterSelectionScreen extends StatefulWidget {
  const ReciterSelectionScreen({Key? key}) : super(key: key);

  @override
  _ReciterSelectionScreenState createState() => _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState extends State<ReciterSelectionScreen> {
  final ReciterService _reciterService = ReciterService();
  final TextEditingController _searchController = TextEditingController();
  List<Reciter> _filteredReciters = [];

  static const _deepSpace = Color(0xFF04060F);
  static const _midnight  = Color(0xFF0B0F1E);
  static const _nebula    = Color(0xFF131829);
  static const _starlight = Color(0xFFF0EEF8);
  static const _moonGlow  = Color(0xFFE8E2FF);
  static const _teal      = Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    _filteredReciters = _reciterService.allReciters;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredReciters = _reciterService.search(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepSpace,
      appBar: AppBar(
        backgroundColor: _deepSpace,
        elevation: 0,
        title: Text('هەڵبژاردنی قورئانخوێن', style: KurdishStyles.getTitleStyle(color: _starlight, fontSize: 18)),
        iconTheme: const IconThemeData(color: _moonGlow),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: _starlight),
                  decoration: InputDecoration(
                    hintText: 'گەڕان بۆ قورئانخوێن...',
                    hintStyle: KurdishStyles.getKurdishStyle(color: _moonGlow.withOpacity(0.5), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: _teal),
                    filled: true,
                    fillColor: _midnight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _teal.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _teal.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: _teal),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredReciters.length,
                  itemBuilder: (context, index) {
                    final reciter = _filteredReciters[index];
                    return _buildReciterTile(context, reciter);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReciterTile(BuildContext context, Reciter reciter) {
    final audioService = Provider.of<QuranAudioService>(context);
    final isSelected = audioService.reciterId == reciter.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          audioService.setReciter(reciter.id);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? _teal.withOpacity(0.1) : _midnight,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? _teal : _teal.withOpacity(0.1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isSelected ? _teal : _nebula,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    reciter.name[0],
                    style: TextStyle(
                      color: isSelected ? _deepSpace : _teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciter.name,
                      style: KurdishStyles.getKurdishStyle(
                        color: _starlight,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (reciter.style != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _teal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              reciter.style!,
                              style: const TextStyle(color: _teal, fontSize: 10),
                            ),
                          ),
                        Text(
                          reciter.bitrate,
                          style: TextStyle(color: _moonGlow.withOpacity(0.5), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: _teal),
            ],
          ),
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
