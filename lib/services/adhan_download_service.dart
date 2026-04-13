import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AdhanDownloadService {
  static const String _adhanUrl = 'https://drive.google.com/uc?export=download&id=1uoMetc167IyUtwWVXm5tK9HB2u8ycT-J';
  static const String fileName = 'custom_adhan.mp3';
  static const String _prefKey = 'custom_adhan_path';

  static Future<String?> getCustomAdhanPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  static Future<bool> isAdhanDownloaded() async {
    final path = await getCustomAdhanPath();
    if (path == null) return false;
    return await File(path).exists();
  }

  static Future<String?> downloadAdhan({Function(double)? onProgress}) async {
    try {
      Directory? directory;
      if (Platform.isIOS) {
        final libraryDir = await getLibraryDirectory();
        final soundsPath = '${libraryDir.path}/Sounds';
        final soundsDir = Directory(soundsPath);
        if (!await soundsDir.exists()) {
          await soundsDir.create(recursive: true);
        }
        directory = soundsDir;
      } else {
        // On Android, use application documents directory
        final appDir = await getApplicationDocumentsDirectory();
        directory = appDir;
      }
      final String path = '${directory.path}/$fileName';
      
      final dio = Dio();
      await dio.download(
        _adhanUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, path);
      
      return path;
    } catch (e) {
      debugPrint('Error downloading Adhan: $e');
      return null;
    }
  }

  static Future<void> removeCustomAdhan() async {
    final path = await getCustomAdhanPath();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}

