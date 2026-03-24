import 'package:flutter/material.dart';
import 'package:tabloy_iman/screens/home/page/home_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tabloy_iman/services/notification_service.dart';
import 'package:tabloy_iman/services/theme_manager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Firebase initializing...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized.');
    
    debugPrint('NotificationService initializing...');
    await NotificationService().initialize();
    debugPrint('NotificationService initialized.');
    
    debugPrint('ThemeManager initializing...');
    await ThemeManager().init();
    debugPrint('ThemeManager initialized.');
    
    debugPrint('Date formatting initializing...');
    await initializeDateFormatting('en_US', null);
    debugPrint('Date formatting initialized.');
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('FATAL ERROR in main: $e');
    // Still try to run the app even if initialization fails
    runApp(const MyApp());
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
          home: const HomePage(),
        );
      },
    );
  }
}
