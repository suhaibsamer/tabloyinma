class HifzSurahProgress {
  final int surahNumber;
  final String surahName;
  final int totalVerses;
  final Set<int> memorizedVerses;
  final Set<int> reviewVerses;

  HifzSurahProgress({
    required this.surahNumber,
    required this.surahName,
    required this.totalVerses,
    required this.memorizedVerses,
    required this.reviewVerses,
  });

  double get progress => totalVerses == 0 ? 0 : memorizedVerses.length / totalVerses;
}

class HifzGoal {
  final int id;
  final int targetVerses;
  final DateTime date;
  final int completedVerses;

  HifzGoal({
    required this.id,
    required this.targetVerses,
    required this.date,
    this.completedVerses = 0,
  });
}

