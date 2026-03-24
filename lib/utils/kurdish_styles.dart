import 'package:flutter/material.dart';
import '../services/theme_manager.dart';

class KurdishStyles {
  static TextStyle getArabicStyle({double fontSize = 20, Color? color}) {
    final delta = ThemeManager().fontSizeDelta.value;
    return TextStyle(
      fontSize: fontSize + delta,
      color: color,
      height: 1.8,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle getKurdishStyle({double fontSize = 16, Color? color, FontWeight fontWeight = FontWeight.w500}) {
    final delta = ThemeManager().fontSizeDelta.value;
    return TextStyle(
      fontSize: fontSize + delta,
      color: color,
      height: 1.7,
      fontWeight: fontWeight,
    );
  }

  static TextStyle getTitleStyle({double fontSize = 18, Color? color}) {
    final delta = ThemeManager().fontSizeDelta.value;
    return TextStyle(
      fontSize: fontSize + delta,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }
}
