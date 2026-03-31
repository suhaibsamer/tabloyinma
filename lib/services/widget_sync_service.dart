import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'prayer_times_service.dart';
import 'prayer_service.dart';
import '../models/prayer_times.dart';

class WidgetSyncService {
  static const String _groupId = 'group.com.example.tabloy_iman'; // Should match native side
  static const String _androidWidgetName = 'TabloyImanWidget';
  static const String _iosWidgetName = 'TabloyImanWidget';

  static Future<void> syncData() async {
    try {
      // Required for iOS App Groups
      await HomeWidget.setAppGroupId(_groupId);

      // 1. Fetch Prayer Times
      final PrayerTimes? todayTimes = await PrayerTimesService.getTodayPrayerTimes();
      if (todayTimes != null) {
        final prayerMap = {
          'Fajr': todayTimes.times[0],
          'Sunrise': todayTimes.times[1],
          'Dhuhr': todayTimes.times[2],
          'Asr': todayTimes.times[3],
          'Maghrib': todayTimes.times[4],
          'Isha': todayTimes.times[5],
        };
        await HomeWidget.saveWidgetData('prayer_times', jsonEncode(prayerMap));
      }

      // 2. Fetch 5 random Duas (Prayer Requests)
      final PrayerService prayerService = PrayerService();
      List<String> duas = [];
      // We'll try to get some requests. Since getRandomPrayerRequest returns one, 
      // let's just get the latest 5 from a one-time fetch if possible, 
      // or just call getRandom 5 times (might be inefficient).
      // Let's get the latest 5.
      final snapshot = await prayerService.getPrayerRequests().first;
      if (snapshot.isNotEmpty) {
        duas = snapshot.take(5).map((e) => e.content).toList();
      }
      
      if (duas.isNotEmpty) {
        await HomeWidget.saveWidgetData('dua_batch', jsonEncode(duas));
      }

      // 3. Update Widget
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Error syncing widget data: $e');
    }
  }
}
