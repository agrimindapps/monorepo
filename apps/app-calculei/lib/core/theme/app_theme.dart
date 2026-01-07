import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium App Theme Definition
class AppTheme {
  // Private constructor
  AppTheme._();

  // ===========================================================================
  // COLORS
  // ===========================================================================

  // Primary Brand Colors (Deep Indigo/Blue)
  static const primaryLight = Color(0xFF4F46E5); // Indigo 600
  static const primaryDark = Color(0xFF6366F1); // Indigo 500

  // Secondary/Accent Colors (Teal/Cyan)
  static const secondaryLight = Color(0xFF0D9488); // Teal 600
  static const secondaryDark = Color(0xFF14B8A6); // Teal 500

  // Background Colors
  static const backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const surfaceLight = Colors.white;

  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const surfaceDark = Color(0xFF1E293B); // Slate 800

  // Error Colors
  static const errorLight = Color(0xFFDC2626); // Red 600
  static const errorDark = Color(0xFFEF4444); // Red 500

  // ===========================================================================
  // THEME DATA FACTORIES
  // ===========================================================================

  /// Returns the Light Theme Data
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      // We let Material 3 generate the surface and background colors
      // to give it a more modern, tinted look instead of pure white
      primary: primaryLight,
      secondary: secondaryLight,
      error: errorLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Removing static scaffoldBackgroundColor to allow M3 dynamic surface tones
      textTheme: _buildTextTheme(colorScheme.onSurface),

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface, // Matches background
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.primary, // Subtle tint on scroll
      ),

      cardTheme: CardThemeData(
        // Use a slightly different surface for cards to separate from background
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.05),
          colorScheme.surface,
        ),
        elevation: 0,
        // Remove the border for a cleaner "modern" look, or keep a very subtle one
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded
          side: BorderSide.none, // Cleaner look without borders
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 2, // Slight elevation usually looks more clickable
          shadowColor: primaryLight.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // More rounded
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(
          alpha: 0.7,
        ), // Semi-transparent white
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide.none, // Filled style often has no border until focus
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorLight),
        ),
        // Add floating label style
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: primaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }

  /// Returns the Dark Theme Data
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      surface: surfaceDark,
      error: errorDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF1F5F9), // Slate 100
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155), // Slate 700
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorDark),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    // Using Google Fonts (Inter is a great choice for UI)
    // If GoogleFonts is not available, we can fallback to default
    return GoogleFonts.interTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }
}
