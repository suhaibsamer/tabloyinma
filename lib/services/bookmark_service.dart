import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkService {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  static const String _bookmarkKey = 'quran_bookmarks';

  Future<void> toggleBookmark(int chapterNumber, int verseNumber, String chapterName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    
    bool exists = false;
    int indexToRemove = -1;
    
    for (int i = 0; i < bookmarks.length; i++) {
      final Map<String, dynamic> data = json.decode(bookmarks[i]);
      if (data['chapterNumber'] == chapterNumber && data['verseNumber'] == verseNumber) {
        exists = true;
        indexToRemove = i;
        break;
      }
    }
    
    if (exists) {
      bookmarks.removeAt(indexToRemove);
    } else {
      final bookmarkData = {
        'chapterNumber': chapterNumber,
        'verseNumber': verseNumber,
        'chapterName': chapterName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      bookmarks.add(json.encode(bookmarkData));
    }
    
    await prefs.setStringList(_bookmarkKey, bookmarks);
  }

  Future<bool> isBookmarked(int chapterNumber, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    
    for (var b in bookmarks) {
      final Map<String, dynamic> data = json.decode(b);
      if (data['chapterNumber'] == chapterNumber && data['verseNumber'] == verseNumber) {
        return true;
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarkKey) ?? [];
    return bookmarks.map((b) => json.decode(b) as Map<String, dynamic>).toList()
      ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
  }
}

