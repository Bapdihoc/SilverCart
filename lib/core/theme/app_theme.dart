import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    useMaterial3: true,
  );

  // Theme dành riêng cho người cao tuổi
  static ThemeData elderlyTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.elderlyPrimary,
      primary: AppColors.elderlyPrimary,
      secondary: AppColors.elderlySecondary,
      background: AppColors.elderlyBackground,
      error: AppColors.elderlyError,
      surface: AppColors.elderlyCardBackground,
    ),
    scaffoldBackgroundColor: AppColors.elderlyBackground,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.elderlyText,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.elderlyText,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.elderlyText,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.elderlyText,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.elderlyText,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.elderlyPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      toolbarHeight: 70, // Tăng chiều cao AppBar
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.elderlyPrimary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        minimumSize: const Size(120, 56), // Tăng kích thước button
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.elderlyBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.elderlyBorder, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.elderlyPrimary, width: 3),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.elderlyTextSecondary,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.elderlyTextSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: AppColors.elderlyCardBackground,
    ),
    cardTheme: CardTheme(
      color: AppColors.elderlyCardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.elderlyBorder, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.elderlyPrimary,
      unselectedItemColor: AppColors.elderlyTextSecondary,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    useMaterial3: true,
  );
} 