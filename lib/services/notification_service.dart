import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'prayer_times_service.dart';
import 'audio_preferences_service.dart';
import 'adhan_download_service.dart';
import '../models/prayer_times.dart';
import '../main.dart';
import '../screens/prayer_times/athan_player_screen.dart';
import 'dart:io';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

@pragma('vm:entry-point')
Future<void> showAthanNotificationBackground(int id, Map<String, dynamic> data) async {
  debugPrint('Alarm triggered for id: $id');
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  
  // Use System Default Sound as requested
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'athan_channel_v5', // New Channel ID
    'کاتی بانگ',
    channelDescription: 'Prayer time notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    sound: null, // null uses default system sound
    fullScreenIntent: false,
    styleInformation: BigTextStyleInformation(''),
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await localNotifications.show(
    id: id,
    title: data['title'] as String?,
    body: data['body'] as String?,
    notificationDetails: notificationDetails,
    payload: data['payload'] as String?,
  );
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
      
      if (Platform.isAndroid) {
        await AndroidAlarmManager.initialize();
      }

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

      // Request permissions for Android 12+ and 13+
      if (Platform.isAndroid) {
        // Request notification permission first
        await Permission.notification.request();

        // Resolve platform specific implementation for exact alarms
        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          await androidPlugin.requestExactAlarmsPermission();
        }
        
        // Request schedule exact alarm permission specifically
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
        
        // Handle battery optimization
        if (await Permission.ignoreBatteryOptimizations.isDenied) {
          await _showBatteryOptimizationDialog();
        }
      }

      // 3. Handle foreground messages
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

  Future<void> _showBatteryOptimizationDialog() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('باشکردنی پاتری'),
        content: const Text(
          'بۆ ئەوەی بانگەکان لە کاتی خۆیاندا کار بکەن، تکایە "Disable Battery Optimization" هەڵبژێرە بۆ ئەم ئەپە.',
          style: TextStyle(fontFamily: 'KurdishFont'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پاشان'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Permission.ignoreBatteryOptimizations.request();
            },
            child: const Text('ڕێکخستنەکان'),
          ),
        ],
      ),
    );
  }

  Future<NotificationDetails> _getNotificationDetails(String athanSound, {bool useDefaultSound = true}) async {
    AndroidNotificationSound? androidSound;
    String? iosSound;

    // Force default sound as requested for the new channel
    if (!useDefaultSound) {
      if (athanSound == AdhanDownloadService.fileName) {
        final customPath = await AdhanDownloadService.getCustomAdhanPath();
        if (customPath != null && await File(customPath).exists()) {
          if (Platform.isAndroid) {
            androidSound = UriAndroidNotificationSound(customPath);
          } else if (Platform.isIOS) {
            iosSound = AdhanDownloadService.fileName;
          }
        }
      }
      // Fallback to bundled sound if custom sound is not available or not selected
      androidSound ??= RawResourceAndroidNotificationSound(athanSound);
      iosSound ??= '$athanSound.mp3';
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        'athan_channel_v5', // New ID to reset cache
        'Athan Notifications',
        channelDescription: 'Prayer time notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: useDefaultSound ? null : androidSound, // null uses default system sound
        fullScreenIntent: false,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: useDefaultSound ? null : iosSound,
      ),
    );
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final athanSound = AudioPreferencesService().selectedAthanSound;
    final notificationDetails = await _getNotificationDetails(athanSound);

    await _localNotifications.show(
      id: 0,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> schedulePrayerNotifications() async {
    try {
      await _localNotifications.cancelAll();
      if (Platform.isAndroid) {
        // Cancel all existing alarms
        for (int i = 0; i < 50; i++) {
          await AndroidAlarmManager.cancel(100 + i);
        }
      }

      final athanSound = AudioPreferencesService().selectedAthanSound;
      final notificationDetails = await _getNotificationDetails(athanSound);

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
          final String title = 'کاتی بانگ';
          final String body = 'بانگی ${prayerKurdishLabels[i]} لە شاری $cityName';
          final String payload = 'athan_${prayerKurdishLabels[i]}';

          await _localNotifications.zonedSchedule(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            payload: payload,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
          
          notificationId++;
        }
      }
      debugPrint('Scheduled $notificationId notifications.');
    } catch (e) {
      debugPrint('Error scheduling: $e');
    }
  }
}

