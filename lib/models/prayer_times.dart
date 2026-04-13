class PrayerTimes {
  final String day;
  final int id;
  final String month;
  final List<String> times;

  PrayerTimes({
    required this.day,
    required this.id,
    required this.month,
    required this.times,
  });

  String get fajr => times[0];
  String get sunrise => times[1];
  String get dhuhr => times[2];
  String get asr => times[3];
  String get maghrib => times[4];
  String get isha => times[5];

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      day: json['day'] as String,
      id: json['id'] as int,
      month: json['month'] as String,
      times: List<String>.from(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'id': id,
      'month': month,
      'time': times,
    };
  }
}

class PrayerNames {
  static const Map<String, String> cityNames = {
    'erbil': 'ھەولێر',
    'sulaymaniyah': 'سلێمانی',
    'duhok': 'دهۆک',
    'halabja': 'ھەڵەبجە',
  };

  static const Map<String, String> arabic = {
    'fajr': 'فجر',
    'sunrise': 'طلوع خورشید',
    'dhuhr': 'ظهر',
    'asr': 'عصر',
    'maghrib': 'مغرب',
    'isha': 'عشاء',
  };

  static const Map<String, String> kurdish = {
    'fajr': 'بەیانی',
    'sunrise': 'خۆرهەڵات',
    'dhuhr': 'نیوەڕۆ',
    'asr': 'عەسر',
    'maghrib': 'شێوان',
    'isha': 'خەوتنان',
  };
}

