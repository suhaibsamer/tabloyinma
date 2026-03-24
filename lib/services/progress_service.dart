import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'daily_progress.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE prayer_progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE,
            fajr INTEGER DEFAULT 0,
            dhuhr INTEGER DEFAULT 0,
            asr INTEGER DEFAULT 0,
            maghrib INTEGER DEFAULT 0,
            isha INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE zikr_progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            zikr_id TEXT,
            count INTEGER DEFAULT 0,
            UNIQUE(date, zikr_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE quran_progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hijri_day INTEGER,
            hijri_month INTEGER,
            hijri_year INTEGER,
            pages INTEGER DEFAULT 0,
            UNIQUE(hijri_day, hijri_month, hijri_year)
          )
        ''');
      },
    );
  }

  // Quran operations
  Future<Map<String, int>> getMonthlyQuranProgress(int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quran_progress',
      where: 'hijri_month = ? AND hijri_year = ?',
      whereArgs: [month, year],
    );
    
    Map<String, int> result = {};
    for (var map in maps) {
      result[map['hijri_day'].toString()] = map['pages'] as int;
    }
    return result;
  }

  Future<void> updateQuranProgress(int day, int month, int year, int pages) async {
    final db = await database;
    await db.insert(
      'quran_progress',
      {
        'hijri_day': day,
        'hijri_month': month,
        'hijri_year': year,
        'pages': pages
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Prayer operations
  Future<Map<String, int>> getDailyPrayers() async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'prayer_progress',
      where: 'date = ?',
      whereArgs: [date],
    );
    
    if (maps.isNotEmpty) {
      return {
        'fajr': maps.first['fajr'] as int,
        'dhuhr': maps.first['dhuhr'] as int,
        'asr': maps.first['asr'] as int,
        'maghrib': maps.first['maghrib'] as int,
        'isha': maps.first['isha'] as int,
      };
    }
    
    // Create new entry for today
    await db.insert('prayer_progress', {'date': date});
    return {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0};
  }

  Future<void> togglePrayer(String prayer, bool completed) async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    await db.update(
      'prayer_progress',
      {prayer: completed ? 1 : 0},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // Zikr operations
  Future<int> getZikrCount(String zikrId) async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'zikr_progress',
      where: 'date = ? AND zikr_id = ?',
      whereArgs: [date, zikrId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    }
    return 0;
  }

  Future<void> updateZikrCount(String zikrId, int count) async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    await db.insert(
      'zikr_progress',
      {'date': date, 'zikr_id': zikrId, 'count': count},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
