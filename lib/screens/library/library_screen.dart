import 'package:flutter/material.dart';
import 'package:tabloy_iman/models/book.dart';
import 'package:tabloy_iman/services/library_service.dart';
import 'pdf_viewer_screen.dart';
import 'dart:math' as math;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  
  final List<Book> _books = [
    Book(
      id: 'sample_book_1',
      title: 'نموونەی کتێب',
      author: 'نووسەر',
      driveLink: 'https://drive.google.com/file/d/1IxyPEJ7olEz6Re_8n5_Hq3rAC4wUhypj/view?usp=sharing',
    ),
  ];

  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloaded = {};

  @override
  void initState() {
    super.initState();
    _checkDownloads();
  }

  Future<void> _checkDownloads() async {
    for (var book in _books) {
      final downloaded = await _libraryService.isBookDownloaded(book.id);
      setState(() {
        _isDownloaded[book.id] = downloaded;
      });
    }
  }

  Future<void> _handleBookTap(Book book) async {
    if (_isDownloaded[book.id] == true) {
      final path = await _libraryService.getBookPath(book.id);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(path: path, title: book.title),
          ),
        );
      }
    } else {
      _downloadBook(book);
    }
  }

  Future<void> _downloadBook(Book book) async {
    setState(() {
      _downloadProgress[book.id] = 0.0;
    });

    try {
      await _libraryService.downloadBook(book, (received, total) {
        if (total != -1) {
          setState(() {
            _downloadProgress[book.id] = received / total;
          });
        }
      });
      setState(() {
        _isDownloaded[book.id] = true;
        _downloadProgress.remove(book.id);
      });
    } catch (e) {
      setState(() {
        _downloadProgress.remove(book.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('هەڵەیەک ڕوویدا لە کاتی داگرتن: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color deepSpace = Color(0xFF04060F);
    const Color midnight  = Color(0xFF0B0F1E);
    const Color nebula    = Color(0xFF131829);
    const Color starlight = Color(0xFFF0EEF8);
    const Color accent    = Color(0xFFB08AFF);

    return Scaffold(
      backgroundColor: deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'کتێبخانە',
          style: TextStyle(color: starlight, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _StarfieldBackground()),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                final progress = _downloadProgress[book.id];
                final isDownloaded = _isDownloaded[book.id] ?? false;

                return GestureDetector(
                  onTap: () => _handleBookTap(book),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: midnight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDownloaded ? accent.withValues(alpha: 0.3) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: nebula,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.book_rounded, color: Colors.white24, size: 30),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              if (progress != null) ...[
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white10,
                                  color: accent,
                                  minHeight: 4,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isDownloaded ? Icons.menu_book_rounded : Icons.download_rounded,
                          color: isDownloaded ? accent : Colors.white24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StarfieldBackground extends StatelessWidget {
  const _StarfieldBackground();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarfieldPainter());
}

class _StarfieldPainter extends CustomPainter {
  static final _stars = List.generate(80, (i) {
    final rng = math.Random(i * 137);
    return Offset(rng.nextDouble(), rng.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final rng = math.Random(i * 137);
      final radius = rng.nextDouble() * 1.2 + 0.3;
      final opacity = rng.nextDouble() * 0.45 + 0.1;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

