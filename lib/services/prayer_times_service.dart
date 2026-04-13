import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';

class PrayerTimesService {
  static List<dynamic>? _cachedData;
  static String? _cachedCity;

  static Future<List<dynamic>?> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final city = prefs.getString('selectedCity') ?? 'erbil';
      
      if (_cachedData != null && _cachedCity == city) {
        return _cachedData;
      }

      final String response =
          await rootBundle.loadString('assets/prayer-times/$city.json');
      _cachedData = json.decode(response);
      _cachedCity = city;
      return _cachedData;
    } catch (e) {
      print('Error loading prayer times: $e');
      return null;
    }
  }

  static Future<PrayerTimes?> getPrayerTimesForDate(DateTime date) async {
    final data = await _loadData();
    if (data == null) return null;

    final String day = date.day.toString();
    final String month = date.month.toString();

    final dayData = data.firstWhere(
      (element) => element['day'] == day && element['month'] == month,
      orElse: () => null,
    );

    if (dayData != null) {
      return PrayerTimes.fromJson(dayData);
    }

    return null;
  }

  static Future<PrayerTimes?> getTodayPrayerTimes() async {
    return getPrayerTimesForDate(DateTime.now());
  }

  static Future<List<PrayerTimes>> getNext7DaysPrayerTimes() async {
    final data = await _loadData();
    if (data == null) return [];

    List<PrayerTimes> list = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final String day = date.day.toString();
      final String month = date.month.toString();

      final dayData = data.firstWhere(
        (element) => element['day'] == day && element['month'] == month,
        orElse: () => null,
      );

      if (dayData != null) {
        list.add(PrayerTimes.fromJson(dayData));
      }
    }
    return list;
  }
}

