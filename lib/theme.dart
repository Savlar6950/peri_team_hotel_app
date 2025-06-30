import 'package:flutter/material.dart';

class AppColors {
  static const purple = Color(0xFF392A87);
  static const red = Color(0xFFE05045);
  static const navy = Color(0xFF1C1C3C);
  static const white = Color(0xFFFFFFFF);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.purple,
  scaffoldBackgroundColor: AppColors.purple,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.red,
    secondary: AppColors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.red,
      foregroundColor: AppColors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.white),
    bodyMedium: TextStyle(color: AppColors.white),
  ),
);
