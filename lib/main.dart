import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabloy_iman/screens/home/page/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tabloy_iman/services/notification_service.dart';
import 'package:tabloy_iman/services/theme_manager.dart';
import 'package:tabloy_iman/services/quran_audio_service.dart';
import 'package:tabloy_iman/services/audio_preferences_service.dart';
import 'package:tabloy_iman/services/widget_sync_service.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Timezone
    tz_data.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      debugPrint('Could not get local timezone: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Baghdad')); // Default to Baghdad/Erbil
    }

    debugPrint('Firebase initializing...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized.');
    
    debugPrint('AudioPreferencesService initializing...');
    await AudioPreferencesService().init();
    debugPrint('AudioPreferencesService initialized.');

    debugPrint('QuranAudioService initializing...');
    await QuranAudioService.init();
    debugPrint('QuranAudioService initialized.');
    
    debugPrint('NotificationService initializing...');
    await NotificationService().initialize();
    debugPrint('NotificationService initialized.');
    
    debugPrint('ThemeManager initializing...');
    await ThemeManager().init();
    debugPrint('ThemeManager initialized.');
    
    debugPrint('Date formatting initializing...');
    await initializeDateFormatting('en_US', null);
    debugPrint('Date formatting initialized.');

    // Sync widget data
    WidgetSyncService.syncData();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: QuranAudioService.handler),
          ChangeNotifierProvider.value(value: AudioPreferencesService()),
        ],
        child: const MyApp(),
      ),
    );
    } catch (e) {
    debugPrint('FATAL ERROR in main: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: QuranAudioService.handler),
          ChangeNotifierProvider.value(value: AudioPreferencesService()),
        ],
        child: const MyApp(),
      ),
    );
    }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager().themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Tabloy Iman',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fa', 'IQ'), // Kurdish
            Locale('ar', 'AE'), // Arabic
          ],
          locale: const Locale('fa', 'IQ'),
          home: const HomePage(),
        );
      },
    );
  }
}

