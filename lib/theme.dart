import 'package:flutter/material.dart';

class AppColors {
  static const bg0 = Color(0xFF070811);
  static const bg1 = Color(0xFF0D0F1A);
  static const panel = Color(0xCC121420);
  static const panelSoft = Color(0x0AFFFFFF);
  static const border = Color(0x14FFFFFF);
  static const borderStrong = Color(0x24FFFFFF);
  static const textPrimary = Color(0xFFEEF0F8);
  static const textSecondary = Color(0xFFA7ADC4);
  static const textTertiary = Color(0xFF6B7290);
  static const blue = Color(0xFF5B8CFF);
  static const violet = Color(0xFFA76BFF);
  static const green = Color(0xFF5FE3A1);
  static const amber = Color(0xFFFFC163);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, violet],
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg0,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.violet,
        surface: AppColors.bg1,
      ),
    );
  }
}
