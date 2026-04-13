import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class CallTimesService {
  static const String _callTimesKey = 'call_times';

  // Add a new call time
  static Future<void> addCallTime({
    required String type, // 'incoming' or 'outgoing'
    String? contactName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    final newCallTime = {
      'datetime': now.toIso8601String(),
      'type': type,
      'contactName': contactName ?? 'Unknown Contact',
    };

    // Get existing call times
    final callTimesJson = prefs.getString(_callTimesKey);
    List<Map<String, dynamic>> callTimes = [];
    
    if (callTimesJson != null) {
      final List<dynamic> decodedList = json.decode(callTimesJson);
      callTimes = decodedList.cast<Map<String, dynamic>>();
    }

    // Add the new call time
    callTimes.add(newCallTime);

    // Keep only the most recent 50 call times to prevent excessive storage
    if (callTimes.length > 50) {
      callTimes = callTimes.sublist(callTimes.length - 50);
    }

    // Save back to preferences
    await prefs.setString(_callTimesKey, json.encode(callTimes));
  }

  // Get all call times
  static Future<List<Map<String, dynamic>>> getCallTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final callTimesJson = prefs.getString(_callTimesKey);
    
    if (callTimesJson != null) {
      final List<dynamic> decodedList = json.decode(callTimesJson);
      return decodedList.cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  // Clear all call times
  static Future<void> clearCallTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_callTimesKey);
  }

  // Format datetime for display
  static String formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }
}
