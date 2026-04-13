import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class NameDictionaryService {
  static const String _fileName = 'names_dictionary.json';
  
  // Direct download link for the provided Google Drive file
  static const String _googleDriveUrl = 'https://docs.google.com/uc?export=download&id=1Hg2Y75QKqIW095Tzv8CGVz2NbOjOBQr9';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  static Future<bool> checkIfFileExists() async {
    final file = await _localFile;
    return await file.exists();
  }

  static Future<void> downloadJson() async {
    try {
      final file = await _localFile;
      final dio = Dio();
      
      // If the URL is still the placeholder, we might want to throw or log
      if (_googleDriveUrl.contains('YOUR_GOOGLE_DRIVE_DIRECT_LINK_HERE')) {
        debugPrint('Warning: Google Drive URL is not set. Using local mock data if available.');
        return;
      }

      await dio.download(_googleDriveUrl, file.path);
      debugPrint('Downloaded JSON to ${file.path}');
    } catch (e) {
      debugPrint('Error downloading JSON: $e');
      rethrow;
    }
  }

  static Future<dynamic> loadNames() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content);
      } else {
        // Return null or empty structure
        return null;
      }
    } catch (e) {
      debugPrint('Error loading names: $e');
      return null;
    }
  }
}

