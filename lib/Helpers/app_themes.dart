// app_theme.dart
import 'package:flutter/material.dart';
import 'package:vahanserv/Constants/constants.dart';

class AppTheme {
  static const Color primaryBlue = blue;
  static const Color primaryWhite = white;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: primaryWhite,
        surface: primaryWhite,
        onSurface: primaryBlue,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: primaryWhite,
        elevation: 4,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: primaryWhite,
        ),
      ),
      scaffoldBackgroundColor: primaryWhite,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        onPrimary: primaryWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: primaryWhite,
        elevation: 4,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.grey[900],
      ),
      scaffoldBackgroundColor: Colors.grey[900],
    );
  }
}
