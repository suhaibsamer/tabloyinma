import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/hifz_models.dart';

class HifzDatabaseService {
  static final HifzDatabaseService _instance = HifzDatabaseService._internal();
  factory HifzDatabaseService() => _instance;
  HifzDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hifz_progress.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hifz_verses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_number INTEGER,
            verse_number INTEGER,
            status INTEGER, -- 1: memorized, 2: review
            UNIQUE(surah_number, verse_number)
          )
        ''');
        await db.execute('''
          CREATE TABLE daily_goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target_verses INTEGER,
            completed_verses INTEGER,
            date TEXT UNIQUE
          )
        ''');
      },
    );
  }

  // Verse operations
  Future<void> updateVerseStatus(int surah, int verse, int status) async {
    final db = await database;
    if (status == 0) {
      await db.delete('hifz_verses', 
          where: 'surah_number = ? AND verse_number = ?', 
          whereArgs: [surah, verse]);
    } else {
      await db.insert(
        'hifz_verses',
        {'surah_number': surah, 'verse_number': verse, 'status': status},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Map<int, Set<int>>> getMemorizedVerses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('hifz_verses', where: 'status = 1');
    Map<int, Set<int>> result = {};
    for (var row in maps) {
      int s = row['surah_number'];
      int v = row['verse_number'];
      result.putIfAbsent(s, () => {}).add(v);
    }
    return result;
  }

  Future<Map<int, Set<int>>> getReviewVerses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('hifz_verses', where: 'status = 2');
    Map<int, Set<int>> result = {};
    for (var row in maps) {
      int s = row['surah_number'];
      int v = row['verse_number'];
      result.putIfAbsent(s, () => {}).add(v);
    }
    return result;
  }

  // Goal operations
  Future<void> setDailyGoal(int target) async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    await db.insert(
      'daily_goals',
      {'target_verses': target, 'completed_verses': 0, 'date': date},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDailyGoal() async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_goals',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<void> incrementGoalProgress() async {
    final db = await database;
    String date = DateTime.now().toIso8601String().split('T')[0];
    await db.rawUpdate(
      'UPDATE daily_goals SET completed_verses = completed_verses + 1 WHERE date = ?',
      [date],
    );
  }
}
