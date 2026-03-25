import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4D7CFF),
      primary: const Color(0xFF4D7CFF),
      surface: const Color(0xFFF8F9FB),
      onSurface: const Color(0xFF1A1F36),
      secondary: const Color(0xFF697386),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1F36)),
      systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark icons for light theme
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1F36),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4D7CFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF4D7CFF),
      surface: const Color(0xFF0F1219),
      onSurface: const Color(0xFFECEEF2),
      secondary: const Color(0xFF9CA3AF),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1219),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFECEEF2)),
      systemOverlayStyle: SystemUiOverlayStyle.light, // Light icons for dark theme
      titleTextStyle: TextStyle(
        color: Color(0xFFECEEF2),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
