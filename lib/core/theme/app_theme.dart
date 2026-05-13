import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Medical & Professional Palette
  static const Color primaryTeal = Color(0xFF1DA2BD); // Primary Brand
  static const Color deepTeal = Color(0xFF02303A); // Backgrounds/Text
  static const Color lightTeal = Color(0xFFE0F7FA); // Accent/BG
  static const Color accentOrange = Color(0xFFDE6B48); // Highlights
  static const Color softGrey = Color(0xFF686868); // Secondary Text
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F7F8);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: deepTeal,
        surface: pureWhite,
        brightness: Brightness.light,
      ),
    );

    final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.tajawal(
        fontWeight: FontWeight.w900,
        color: deepTeal,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontWeight: FontWeight.w900,
        color: deepTeal,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontWeight: FontWeight.w800,
        color: deepTeal,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontWeight: FontWeight.w600,
        color: deepTeal,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontWeight: FontWeight.w500,
        color: softGrey,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: offWhite,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: pureWhite,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryTeal,
          foregroundColor: pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
