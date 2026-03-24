import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../models/prayer_request.dart';

class PrayerService {
  final CollectionReference _prayersCollection = FirebaseFirestore.instance.collection('prayer_requests');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Post a new prayer request
  Future<void> addPrayerRequest(String content, String userName) async {
    String userId = _auth.currentUser?.uid ?? 'anonymous';
    await _prayersCollection.add({
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'amenCount': 0,
      'prayedCount': 0,
      'voters': [], // To prevent multiple votes per user (simplified)
    });
  }

  // Stream of prayer requests ordered by timestamp
  Stream<List<PrayerRequest>> getPrayerRequests() {
    return _prayersCollection
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PrayerRequest.fromFirestore(doc)).toList());
  }

  // Increment Amen count
  Future<void> incrementAmen(String prayerId) async {
    await _prayersCollection.doc(prayerId).update({
      'amenCount': FieldValue.increment(1),
    });
  }

  // Increment "I Prayed" count
  Future<void> incrementPrayed(String prayerId) async {
    await _prayersCollection.doc(prayerId).update({
      'prayedCount': FieldValue.increment(1),
    });
  }

  // Get a single random prayer request
  Future<PrayerRequest?> getRandomPrayerRequest() async {
    try {
      final snapshot = await _prayersCollection.limit(20).get();
      if (snapshot.docs.isEmpty) return null;
      
      final random = math.Random();
      final randomIndex = random.nextInt(snapshot.docs.length);
      return PrayerRequest.fromFirestore(snapshot.docs[randomIndex]);
    } catch (e) {
      return null;
    }
  }
}
