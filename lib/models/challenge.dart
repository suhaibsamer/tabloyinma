import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int participantCount;
  final int? maxParticipants;
  final String category;
  final int durationDays;
  final int pointsAwarded;
  final String? verseText;
  final DateTime? targetDate;
  final bool isKhatm;
  final bool isPublic;
  final String creatorId;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.participantCount,
    this.maxParticipants,
    required this.category,
    required this.durationDays,
    required this.pointsAwarded,
    this.verseText,
    this.targetDate,
    this.isKhatm = false,
    this.isPublic = true,
    required this.creatorId,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetCount: data['targetCount'] ?? 0,
      participantCount: data['participantCount'] ?? 0,
      maxParticipants: data['maxParticipants'],
      category: data['category'] ?? 'General',
      durationDays: data['durationDays'] ?? 7,
      pointsAwarded: data['pointsAwarded'] ?? 100,
      verseText: data['verseText'],
      targetDate: data['targetDate'] != null ? (data['targetDate'] as Timestamp).toDate() : null,
      isKhatm: data['isKhatm'] ?? false,
      isPublic: data['isPublic'] ?? true,
      creatorId: data['creatorId'] ?? '',
    );
  }
}

class UserChallengeProgress {
  final String challengeId;
  final int currentProgress;
  final bool isCompleted;
  final DateTime startedAt;

  UserChallengeProgress({
    required this.challengeId,
    required this.currentProgress,
    required this.isCompleted,
    required this.startedAt,
  });

  factory UserChallengeProgress.fromMap(Map<String, dynamic> map) {
    return UserChallengeProgress(
      challengeId: map['challengeId'] ?? '',
      currentProgress: map['currentProgress'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      startedAt: (map['startedAt'] is Timestamp) 
          ? (map['startedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
}

class ChallengeParticipant {
  final String uid;
  final String name;
  final int progress;
  final int? dailyProgress;
  final DateTime lastUpdated;
  final int? hijriMonth;
  final int? hijriYear;
  final Map<String, int> daysProgress;

  ChallengeParticipant({
    required this.uid,
    required this.name,
    required this.progress,
    this.dailyProgress,
    required this.lastUpdated,
    this.hijriMonth,
    this.hijriYear,
    this.daysProgress = const {},
  });

  factory ChallengeParticipant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, int> dp = {};
    if (data['daysProgress'] != null) {
      (data['daysProgress'] as Map).forEach((k, v) {
        dp[k.toString()] = v as int;
      });
    }
    return ChallengeParticipant(
      uid: doc.id,
      name: data['name'] ?? 'بەکارهێنەر',
      progress: data['progress'] ?? 0,
      dailyProgress: data['dailyProgress'],
      lastUpdated: data['lastUpdated'] != null ? (data['lastUpdated'] as Timestamp).toDate() : DateTime.now(),
      hijriMonth: data['hijriMonth'],
      hijriYear: data['hijriYear'],
      daysProgress: dp,
    );
  }
}

class UserStats {
  final int points;
  final int level;
  final List<UserChallengeProgress> activeChallenges;

  UserStats({
    required this.points,
    required this.level,
    required this.activeChallenges,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) {
      return UserStats(points: 0, level: 1, activeChallenges: []);
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserStats(
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
      activeChallenges: (data['activeChallenges'] as List? ?? [])
          .map((c) => UserChallengeProgress.fromMap(c))
          .toList(),
    );
  }

  String get levelTitle {
    if (level < 5) return 'دەستپێکەر';
    if (level < 15) return 'کۆشەر';
    if (level < 30) return 'خۆڕاگر';
    return 'پێشەنگ';
  }
}