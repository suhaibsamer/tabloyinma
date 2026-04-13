import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<double> fontSizeDelta = ValueNotifier(0.0);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeName = prefs.getString('themeMode') ?? 'light';
    themeMode.value = _getThemeModeFromName(themeModeName);
    fontSizeDelta.value = prefs.getDouble('fontSizeDelta') ?? 0.0;
  }

  Future<void> setThemeMode(String modeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', modeName);
    themeMode.value = _getThemeModeFromName(modeName);
  }

  Future<void> setFontSizeDelta(double delta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeDelta', delta);
    fontSizeDelta.value = delta;
  }

  ThemeMode _getThemeModeFromName(String name) {
    return switch (name) {
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }
}

