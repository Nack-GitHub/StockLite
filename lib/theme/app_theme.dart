import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors from Design Specs
  static const Color primary = Color(0xFF00425E);
  static const Color primaryContainer = Color(0xFF005B7F);
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);
  static const Color surfaceLow = Color(0xFFEDEEEF);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFF70787E);
  static const Color secondary = Color(0xFF50606D);
  static const Color onSurfaceVariant = Color(0xFF40484E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: background,
        onSurface: onBackground,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: onBackground,
        ),
        displayMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: onBackground,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: onBackground,
        ),
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          color: onBackground,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
      ),

      // Component Themes
      cardTheme: CardThemeData(
        color: surfaceLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE1E3E4), // surface-variant
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x20176589), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
