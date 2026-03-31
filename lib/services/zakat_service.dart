import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zakat.dart';

class ZakatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ZakatThreshold>> getZakatThresholds() {
    return _firestore
        .collection('zakat_thresholds')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Store ID for updates/deletes
              return ZakatThreshold.fromFirestore(data);
            })
            .toList());
  }

  Future<Map<String, double>> getZakatRates() async {
    try {
      final doc = await _firestore.collection('settings').doc('zakat').get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'dollar_price': (data['dollar_price'] ?? 1500).toDouble(),
          'gold_price': (data['gold_price'] ?? 0).toDouble(),
          'gold_nisab': (data['gold_nisab'] ?? 85).toDouble(),
          'money_nisab': (data['money_nisab'] ?? 0).toDouble(),
        };
      }
    } catch (e) {
      print('Error fetching zakat rates: $e');
    }
    return {
      'dollar_price': 1500,
      'gold_price': 0,
      'gold_nisab': 85,
      'money_nisab': 0,
    };
  }

  // --- Update Methods ---

  Future<void> updateZakatRates(double dollarPrice, double goldPrice, {double? goldNisab, double? moneyNisab}) async {
    final data = {
      'dollar_price': dollarPrice,
      'gold_price': goldPrice,
    };
    if (goldNisab != null) data['gold_nisab'] = goldNisab;
    if (moneyNisab != null) data['money_nisab'] = moneyNisab;
    
    await _firestore.collection('settings').doc('zakat').set(data, SetOptions(merge: true));
  }

  Future<void> addOrUpdateThreshold(ZakatThreshold threshold, {String? id}) async {
    final data = {
      'title': threshold.title,
      'amount': threshold.amount,
      'order': threshold.order,
    };
    
    if (id != null) {
      await _firestore.collection('zakat_thresholds').doc(id).update(data);
    } else {
      await _firestore.collection('zakat_thresholds').add(data);
    }
  }

  Future<void> deleteThreshold(String id) async {
    await _firestore.collection('zakat_thresholds').doc(id).delete();
  }
}
