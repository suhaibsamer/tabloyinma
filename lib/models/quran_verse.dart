class QuranVerse {
  final int chapter;
  final int verse;
  final String text;

  QuranVerse({
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    return QuranVerse(
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      text: json['text'] as String,
    );
  }
}

class QuranChapter {
  final int number;
  final List<QuranVerse> verses;

  QuranChapter({
    required this.number,
    required this.verses,
  });
}