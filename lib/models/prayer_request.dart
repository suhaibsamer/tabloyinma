import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequest {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final int amenCount;
  final int prayedCount;

  PrayerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.amenCount = 0,
    this.prayedCount = 0,
  });

  factory PrayerRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrayerRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'بێ ناو',
      content: data['content'] ?? '',
      createdAt: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amenCount: data['amenCount'] ?? 0,
      prayedCount: data['prayedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'amenCount': amenCount,
      'prayedCount': prayedCount,
    };
  }
}

