import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Defines the [ThemeData] for Light and Dark modes using Material 3.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lightAccent,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        foregroundColor: AppColors.lightDisplayText,
        centerTitle: true,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.lightDisplayText,
          fontWeight: FontWeight.w300,
        ),
        bodyMedium: TextStyle(color: AppColors.lightDisplayText),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAccent,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        foregroundColor: AppColors.darkDisplayText,
        centerTitle: true,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.darkDisplayText,
          fontWeight: FontWeight.w300,
        ),
        bodyMedium: TextStyle(color: AppColors.darkDisplayText),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
