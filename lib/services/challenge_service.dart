import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ensure user is signed in
  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Stream of all public group challenges
  Stream<List<Challenge>> getGlobalChallenges() {
    return _firestore.collection('challenges')
        .snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList());
  }

  // Stream of user stats
  Stream<UserStats> getUserStats() {
    String userId = _auth.currentUser?.uid ?? 'anonymous';
    return _firestore.collection('user_stats').doc(userId).snapshots().map(
        (doc) => UserStats.fromFirestore(doc));
  }

  // Stream of ranking
  Stream<List<ChallengeParticipant>> getChallengeRanking(String challengeId) {
    return _firestore.collection('challenges').doc(challengeId).collection('participants')
        .orderBy('progress', descending: true)
        .orderBy('lastUpdated', descending: false)
        .limit(50)
        .snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ChallengeParticipant.fromFirestore(doc)).toList());
  }

  // Stream of monthly ranking based on Hijri month
  Stream<List<ChallengeParticipant>> getMonthlyRanking(String challengeId) {
    HijriCalendar hijri = HijriCalendar.now();
    return _firestore.collection('challenges').doc(challengeId).collection('participants')
        .where('hijriMonth', isEqualTo: hijri.hMonth)
        .where('hijriYear', isEqualTo: hijri.hYear)
        .orderBy('dailyProgress', descending: true)
        .limit(50)
        .snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => ChallengeParticipant.fromFirestore(doc)).toList());
  }

  // Get a specific challenge by its ID
  Future<Challenge?> getChallengeById(String challengeId) async {
    try {
      final doc = await _firestore.collection('challenges').doc(challengeId).get();
      if (doc.exists) {
        return Challenge.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting challenge by ID: $e');
    }
    return null;
  }

  // Create a new global challenge
  Future<void> createChallenge({
    required String title, 
    required String description, 
    required int target, 
    required int points,
    String? verseText,
    DateTime? targetDate,
    bool isKhatm = false,
    int? maxParticipants,
    bool isPublic = true,
  }) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      
      final docRef = await _firestore.collection('challenges').add({
        'title': title,
        'description': description,
        'targetCount': target,
        'pointsAwarded': points,
        'participantCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'verseText': verseText,
        'targetDate': targetDate != null ? Timestamp.fromDate(targetDate) : null,
        'isKhatm': isKhatm,
        'maxParticipants': maxParticipants,
        'isPublic': isPublic,
        'creatorId': userId,
      });
      
      await joinChallenge(docRef.id);
    } catch (e) {
      print('Error creating challenge: $e');
      rethrow;
    }
  }

  // Join a challenge
  Future<bool> joinChallenge(String challengeId) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      final prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('user_display_name') ?? 'بەکارهێنەر';
      HijriCalendar hijri = HijriCalendar.now();

      DocumentReference userRef = _firestore.collection('user_stats').doc(userId);
      DocumentReference challengeRef = _firestore.collection('challenges').doc(challengeId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot challengeDoc = await transaction.get(challengeRef);
        if (!challengeDoc.exists) return false;

        final challengeData = challengeDoc.data() as Map<String, dynamic>;
        final int currentParticipants = challengeData['participantCount'] ?? 0;
        final int? maxP = challengeData['maxParticipants'];

        if (maxP != null && currentParticipants >= maxP) {
          return false; // Full
        }

        DocumentSnapshot userDoc = await transaction.get(userRef);
        List<dynamic> activeChallenges = [];
        
        if (userDoc.exists) {
          activeChallenges = List.from(userDoc.get('activeChallenges') ?? []);
        }
        
        if (!activeChallenges.any((c) => c['challengeId'] == challengeId)) {
          activeChallenges.add({
            'challengeId': challengeId,
            'currentProgress': 0,
            'isCompleted': false,
            'startedAt': FieldValue.serverTimestamp(),
          });
          
          // Use set with merge to either create or update the user doc
          transaction.set(userRef, {
            'activeChallenges': activeChallenges,
            'points': userDoc.exists ? (userDoc.get('points') ?? 0) : 0,
            'level': userDoc.exists ? (userDoc.get('level') ?? 1) : 1,
          }, SetOptions(merge: true));
          
          transaction.set(challengeRef.collection('participants').doc(userId), {
            'name': userName,
            'progress': 0,
            'dailyProgress': 0,
            'hijriMonth': hijri.hMonth,
            'hijriYear': hijri.hYear,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          
          transaction.update(challengeRef, {
            'participantCount': FieldValue.increment(1)
          });
        }
        return true;
      });
    } catch (e) {
      print('Error joining challenge: $e');
      return false;
    }
  }

  // Update progress for an active challenge
  Future<void> updateChallengeProgress(String challengeId, int progressToAdd) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      HijriCalendar hijri = HijriCalendar.now();
      
      DocumentReference userRef = _firestore.collection('user_stats').doc(userId);
      DocumentReference participantRef = _firestore.collection('challenges').doc(challengeId).collection('participants').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<dynamic> activeChallenges = List.from(userDoc.get('activeChallenges') ?? []);
        int index = activeChallenges.indexWhere((c) => c['challengeId'] == challengeId);

        if (index != -1) {
          int oldProgress = activeChallenges[index]['currentProgress'] ?? 0;
          int newProgress = (oldProgress + progressToAdd).clamp(0, 30);
          activeChallenges[index]['currentProgress'] = newProgress;
          
          transaction.update(userRef, {'activeChallenges': activeChallenges});
          
          // Monthly tracking logic
          DocumentSnapshot partDoc = await transaction.get(participantRef);
          int dailyProgress = progressToAdd;
          
          if (partDoc.exists) {
            int lastMonth = partDoc.get('hijriMonth') ?? 0;
            int lastYear = partDoc.get('hijriYear') ?? 0;
            
            if (lastMonth == hijri.hMonth && lastYear == hijri.hYear) {
              dailyProgress = (partDoc.get('dailyProgress') ?? 0) + progressToAdd;
            }
          }

          transaction.set(participantRef, {
            'progress': newProgress,
            'dailyProgress': dailyProgress,
            'hijriMonth': hijri.hMonth,
            'hijriYear': hijri.hYear,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      print('Error updating challenge progress: $e');
    }
  }

  // Check if user is joined in a challenge
  Future<bool> isUserJoined(String challengeId) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      final doc = await _firestore.collection('challenges').doc(challengeId).collection('participants').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Stream of participant data for a specific user
  Stream<ChallengeParticipant?> getParticipantData(String challengeId) {
    String userId = _auth.currentUser?.uid ?? 'anonymous';
    return _firestore.collection('challenges').doc(challengeId).collection('participants').doc(userId).snapshots().map(
        (doc) => doc.exists ? ChallengeParticipant.fromFirestore(doc) : null);
  }

  // Sync full monthly progress from local to online
  Future<void> syncFullMonthlyProgress(String challengeId, Map<String, int> localProgress) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      HijriCalendar hijri = HijriCalendar.now();
      
      int totalPages = 0;
      localProgress.forEach((day, pages) {
        totalPages += pages;
      });

      DocumentReference participantRef = _firestore.collection('challenges').doc(challengeId).collection('participants').doc(userId);
      
      await participantRef.set({
        'daysProgress': localProgress,
        'dailyProgress': totalPages,
        'hijriMonth': hijri.hMonth,
        'hijriYear': hijri.hYear,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing full monthly progress: $e');
    }
  }

  // Update specific day progress (1-30)
  Future<void> updateDailyProgress(String challengeId, int dayIndex, int pages) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      HijriCalendar hijri = HijriCalendar.now();
      
      DocumentReference participantRef = _firestore.collection('challenges').doc(challengeId).collection('participants').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot partDoc = await transaction.get(participantRef);
        if (!partDoc.exists) return;

        Map<String, dynamic> data = partDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> daysProgress = Map<String, dynamic>.from(data['daysProgress'] ?? {});
        
        int oldDayPages = daysProgress[dayIndex.toString()] ?? 0;
        daysProgress[dayIndex.toString()] = pages;
        
        int totalMonthlyProgress = (data['dailyProgress'] ?? 0) - oldDayPages + pages;

        transaction.update(participantRef, {
          'daysProgress': daysProgress,
          'dailyProgress': totalMonthlyProgress,
          'hijriMonth': hijri.hMonth,
          'hijriYear': hijri.hYear,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error updating daily progress: $e');
    }
  }

  // Add points and update level
  Future<void> addPoints(int pointsToAdd) async {
    try {
      await ensureSignedIn();
      String userId = _auth.currentUser!.uid;
      DocumentReference userRef = _firestore.collection('user_stats').doc(userId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          transaction.set(userRef, {
            'points': pointsToAdd,
            'level': 1,
            'activeChallenges': [],
          });
        } else {
          int newPoints = (snapshot.get('points') ?? 0) + pointsToAdd;
          int newLevel = (newPoints / 500).floor() + 1;
          transaction.update(userRef, {
            'points': newPoints,
            'level': newLevel,
          });
        }
      });
    } catch (e) {
      print('Error adding points: $e');
    }
  }
}