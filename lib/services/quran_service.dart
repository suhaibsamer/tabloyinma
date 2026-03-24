import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_verse.dart';

class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  List<QuranChapter> _chapters = [];
  List<QuranVerse> _flattenedVerses = [];

  Future<void> loadQuranData() async {
    if (_chapters.isNotEmpty) return; // Already loaded

    try {
      final String response = await rootBundle.loadString('assets/quran.data/quran.json');
      final Map<String, dynamic> jsonData = json.decode(response);

      _chapters = [];
      _flattenedVerses = [];

      jsonData.forEach((chapterKey, versesData) {
        final int chapterNumber = int.parse(chapterKey);
        final List<QuranVerse> verses = [];

        for (final verseData in versesData) {
          final verse = QuranVerse.fromJson(verseData);
          verses.add(verse);
          _flattenedVerses.add(verse);
        }

        _chapters.add(QuranChapter(
          number: chapterNumber,
          verses: verses,
        ));
      });

      // Sort chapters by number
      _chapters.sort((a, b) => a.number.compareTo(b.number));
    } catch (e) {
      rethrow;
    }
  }

  List<QuranChapter> get chapters => _chapters;
  List<QuranVerse> get flattenedVerses => _flattenedVerses;

  List<QuranVerse> getVersesForChapter(int chapterNumber) {
    final chapter = _chapters.firstWhere(
      (c) => c.number == chapterNumber,
      orElse: () => QuranChapter(number: chapterNumber, verses: []),
    );
    return chapter.verses;
  }

  int get totalChapters => _chapters.length;
  int get totalVerses => _flattenedVerses.length;

  QuranChapter? getChapter(int chapterNumber) {
    try {
      return _chapters.firstWhere((c) => c.number == chapterNumber);
    } catch (e) {
      return null;
    }
  }
}
