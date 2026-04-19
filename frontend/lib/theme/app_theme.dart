import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2D6CDF);
  static const Color accentBlue = Color(0xFF4E8BF5);
  static const Color darkCard = Color(0xFF1E2A3A);
  static const Color lightBg = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF15253C);
  static const Color textMuted = Color(0xFF6B7A90);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        foregroundColor: textDark,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
