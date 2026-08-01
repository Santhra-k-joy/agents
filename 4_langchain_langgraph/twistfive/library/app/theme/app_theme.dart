import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color gold = Color(0xFFD4AF37);
  static const Color cream = Color(0xFFE8DCC8);
  static const Color darkBg = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF2A2A2A);
  static const Color boardWood = Color(0xFF4A3728);

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: gold,
      secondary: cream,
      surface: darkBg,
      onSurface: cream,
      outline: gold.withValues(alpha: 0.5),
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: cream,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: cream),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: cream,
        fontSize: 32,
        fontWeight: FontWeight.w300,
      ),
      titleLarge: TextStyle(
        color: cream,
        fontSize: 22,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(color: cream, fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF999999), fontSize: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: cream,
        side: BorderSide(color: gold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
