import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Figma Design Colors
  static const Color primaryOrange = Color(0xFFD4883B); // Main orange/brown
  static const Color primaryDark = Color(0xFFC97E3E); // Darker orange
  static const Color sand = Color(0xFFF5F1EB); // Light background
  static const Color coral = Color(0xFFDE6B48); // Accent color
  static const Color teal = Color(0xFF0F6E6E); // Legacy (for compatibility)
  static const Color pine = Color(0xFF2C2C2C); // Dark text
  static const Color mist = Color(0xFFE8F3F1); // Light accent
  static const Color lightBg = Color(0xFFFAF8F5); // Very light background

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        primary: primaryOrange,
        secondary: coral,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
    );

    final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.tajawal(
        fontWeight: FontWeight.w800,
        color: pine,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontWeight: FontWeight.w800,
        color: pine,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontWeight: FontWeight.w700,
        color: pine,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontWeight: FontWeight.w500,
        color: pine,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontWeight: FontWeight.w500,
        color: pine.withValues(alpha: 0.88),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: lightBg,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryOrange, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: Color(0xFF7A8C90),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
