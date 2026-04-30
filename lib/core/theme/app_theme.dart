import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color sand = Color(0xFFF4E9DA);
  static const Color coral = Color(0xFFDE6B48);
  static const Color teal = Color(0xFF0F6E6E);
  static const Color pine = Color(0xFF12343B);
  static const Color mist = Color(0xFFE8F3F1);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
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
      scaffoldBackgroundColor: sand,
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
          borderSide: const BorderSide(color: coral, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: teal,
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
        selectedItemColor: teal,
        unselectedItemColor: Color(0xFF7A8C90),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
