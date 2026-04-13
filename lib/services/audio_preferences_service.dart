import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'quran_audio_service.dart';
import 'adhan_download_service.dart';

class AudioPreferencesService extends ChangeNotifier {
  static final AudioPreferencesService _instance = AudioPreferencesService._internal();
  factory AudioPreferencesService() => _instance;
  AudioPreferencesService._internal();

  static const String _athanSoundKey = 'selected_athan_sound';
  static const String _reciterKey = 'selected_reciter';

  String _selectedAthanSound = 'adhan_sound'; // Default filename in res/raw and ios/Runner
  String _selectedReciterId = 'Alafasy_128kbps';

  String get selectedAthanSound => _selectedAthanSound;
  String get selectedReciterId => _selectedReciterId;

  final List<Map<String, String>> availableAthans = [
    {'id': 'adhan_sound', 'name': 'Default Athan', 'file': 'adhan_sound'},
    {'id': 'makkah', 'name': 'Makkah', 'file': 'adhan_makkah'},
    {'id': 'madinah', 'name': 'Madinah', 'file': 'adhan_madinah'},
    {'id': 'alaqsa', 'name': 'Al-Aqsa', 'file': 'adhan_alaqsa'},
    {'id': 'custom', 'name': 'بانگی دەستکاریکراو', 'file': AdhanDownloadService.fileName},
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedAthanSound = prefs.getString(_athanSoundKey) ?? 'adhan_sound';
    _selectedReciterId = prefs.getString(_reciterKey) ?? 'Alafasy_128kbps';
    notifyListeners();
  }

  Future<void> setSelectedAthan(String soundFile) async {
    _selectedAthanSound = soundFile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_athanSoundKey, soundFile);
    
    // Crucial: Re-schedule notifications with new sound
    await NotificationService().schedulePrayerNotifications();
    
    notifyListeners();
  }

  Future<void> setSelectedReciter(String reciterId) async {
    _selectedReciterId = reciterId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);
    
    // Update Quran Audio Service
    await QuranAudioService.handler.setReciter(reciterId);
    
    notifyListeners();
  }
}

