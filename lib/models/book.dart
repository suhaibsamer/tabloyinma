class Book {
  final String id;
  final String title;
  final String author;
  final String driveLink;
  final String? coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.driveLink,
    this.coverUrl,
  });

  String get downloadUrl {
    // Convert sharing link to download link
    // https://drive.google.com/file/d/1IxyPEJ7olEz6Re_8n5_Hq3rAC4wUhypj/view?usp=sharing
    final regExp = RegExp(r'/d/([^/]+)');
    final match = regExp.firstMatch(driveLink);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return driveLink;
  }
}

