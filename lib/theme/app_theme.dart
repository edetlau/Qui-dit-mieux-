import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF231936);
  static const card = Color(0xFF1C1A29);
  static const accent = Color(0xFFFF3D00);
  static const primary = Color(0xFF55FF00);

  static Color byChallengeType(String type) {
    switch (type) {
      case "force":
        return Colors.redAccent;
      case "reflexes":
        return Colors.yellowAccent;
      case "culture":
        return Colors.blueAccent;
      case "chance":
        return Colors.greenAccent;
      default:
        return primary;
    }
  }
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: "Ahkio",

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: "Ahkio",
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white30, width: 2),
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Ahkio",
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white30),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white30),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: "Ahkio",
      color: Colors.white,
    ),
  ),
);