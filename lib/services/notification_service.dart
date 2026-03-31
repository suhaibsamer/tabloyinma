import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_times_service.dart';
import 'audio_preferences_service.dart';
import '../models/prayer_times.dart';
import '../main.dart';
import '../screens/prayer_times/athan_player_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      debugPrint('Initializing NotificationService...');
      
      // 1. Initialize Firebase Messaging
      try {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Firebase permission request timed out or failed: $e');
      }
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.startsWith('athan_')) {
            final prayerName = response.payload!.replaceFirst('athan_', '');
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => AthanPlayerScreen(prayerName: prayerName)),
            );
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // 3. Initialize Timezone
      tz_data.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showNotification(message);
        }
      });

      // Schedule notifications
      await schedulePrayerNotifications();
      debugPrint('NotificationService initialized.');
    } catch (e) {
      debugPrint('Error in NotificationService.initialize: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final athanSound = AudioPreferencesService().selectedAthanSound;
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'adhan_channel_v7',
      'Adhan Notifications',
      channelDescription: 'Prayer time notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(athanSound),
    );
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: '$athanSound.mp3',
    );
    await _localNotifications.show(
      id: 0,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  Future<void> schedulePrayerNotifications() async {
    try {
      await _localNotifications.cancelAll();
      final athanSound = AudioPreferencesService().selectedAthanSound;

      final List<PrayerTimes> upcomingDays =
          await PrayerTimesService.getNext7DaysPrayerTimes();
      
      if (upcomingDays.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final city = prefs.getString('selectedCity') ?? 'erbil';
      final cityName = PrayerNames.cityNames[city.toLowerCase()] ?? city;

      int notificationId = 100;
      final DateTime now = DateTime.now();

      for (int dayIndex = 0; dayIndex < upcomingDays.length; dayIndex++) {
        final day = upcomingDays[dayIndex];
        final DateTime scheduledDateBase = now.add(Duration(days: dayIndex));
        
        final int year = scheduledDateBase.year;
        final int month = int.tryParse(day.month) ?? 1;
        final int dateDay = int.tryParse(day.day) ?? 1;

        final List<String> prayerKurdishLabels = ['بەیانی', 'خۆرهەڵات', 'نیوەڕۆ', 'عەسر', 'شێوان', 'خەوتنان'];

        for (int i = 0; i < day.times.length; i++) {
          if (i == 1) continue; // Skip Sunrise

          final timeParts = day.times[i].split(':');
          if (timeParts.length < 2) continue;
          
          final int hour = int.tryParse(timeParts[0]) ?? 0;
          final int minute = int.tryParse(timeParts[1]) ?? 0;

          final DateTime prayerDateTime = DateTime(year, month, dateDay, hour, minute);
          if (prayerDateTime.isBefore(now)) continue;

          final tz.TZDateTime scheduledDate = tz.TZDateTime.from(prayerDateTime, tz.local);

          await _localNotifications.zonedSchedule(
            id: notificationId++,
            title: 'کاتی بانگ',
            body: 'بانگی ${prayerKurdishLabels[i]} لە شاری $cityName',
            scheduledDate: scheduledDate,
            payload: 'athan_${prayerKurdishLabels[i]}',
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                'adhan_channel_v7',
                'Adhan Notifications',
                channelDescription: 'Prayer time notifications',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                sound: RawResourceAndroidNotificationSound(athanSound),
                styleInformation: const BigTextStyleInformation(''),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: '$athanSound.mp3',
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling: $e');
    }
  }
}
