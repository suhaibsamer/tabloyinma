import 'package:flutter/material.dart';
import 'package:tabloy_iman/services/bookmark_service.dart';
import 'package:tabloy_iman/services/quran_service.dart';
import 'quran_chapter_screen.dart';

class QuranBookmarksScreen extends StatefulWidget {
  const QuranBookmarksScreen({super.key});

  @override
  State<QuranBookmarksScreen> createState() => _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends State<QuranBookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final QuranService _quranService = QuranService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    await _quranService.loadQuranData();
    final bookmarks = await _bookmarkService.getBookmarks();
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0f172a) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('ئایەتە پاشکەوتکراوەکان'),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF059669)))
          : _bookmarks.isEmpty
          ? _buildEmptyState(isDarkMode)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = _bookmarks[index];
          return _buildBookmarkCard(bookmark, isDarkMode);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: isDarkMode ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'هیچ ئایەتێک پاشکەوت نەکراوە',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Map<String, dynamic> bookmark, bool isDarkMode) {
    final int chapterNumber = bookmark['chapterNumber'];
    final int verseNumber = bookmark['verseNumber'];
    final String chapterName = bookmark['chapterName'];
    
    final verses = _quranService.getVersesForChapter(chapterNumber);
    final verse = verses.firstWhere((v) => v.verse == verseNumber);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuranChapterScreen(
              chapterNumber: chapterNumber,
              chapterName: chapterName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1e293b) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_rounded, color: Color(0xFF059669)),
                  onPressed: () async {
                    await _bookmarkService.toggleBookmark(chapterNumber, verseNumber, chapterName);
                    _loadBookmarks();
                  },
                ),
                Text(
                  '$chapterName - ئایەتی $verseNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              verse.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 18,
                height: 2.0,
                fontFamily: 'Amiri',
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

