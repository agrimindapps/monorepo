import 'package:flutter/material.dart';

/// Nebula-themed color palette for Nebulalist app
///
/// Colors inspired by nebula/galaxy aesthetic with
/// purple, cyan, and deep space tones
class NebulaColors {
  NebulaColors._();

  // Primary Colors - Purple nebula tones
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPurpleLight = Color(0xFFA78BFA);
  static const Color primaryPurpleDark = Color(0xFF7C3AED);

  // Accent Colors - Cyan/Teal cosmic tones
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCyanLight = Color(0xFF22D3EE);
  static const Color accentCyanDark = Color(0xFF0891B2);

  // Background Colors - Deep space
  static const Color backgroundDark = Color(0xFF0F0A1A);
  static const Color backgroundMedium = Color(0xFF1A1425);
  static const Color backgroundLight = Color(0xFF251D35);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF1E1833);
  static const Color surfaceLight = Color(0xFFF8F7FC);

  // Nebula Gradient Colors
  static const Color nebulaPink = Color(0xFFEC4899);
  static const Color nebulaBlue = Color(0xFF3B82F6);
  static const Color nebulaIndigo = Color(0xFF6366F1);

  // Star/Highlight Colors
  static const Color starWhite = Color(0xFFF8FAFC);
  static const Color starGold = Color(0xFFFBBF24);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, accentCyan],
  );

  static const LinearGradient nebulaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundDark,
      primaryPurpleDark,
      backgroundMedium,
    ],
  );

  static const LinearGradient darkSpaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0518),
      Color(0xFF1A0D2E),
      Color(0xFF16082A),
    ],
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      nebulaPink,
      primaryPurple,
      nebulaIndigo,
      accentCyan,
    ],
  );

  // Paywall specific gradient
  static const LinearGradient paywallGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0518), // Very dark purple/black
      Color(0xFF1A0D2E), // Dark purple
      Color(0xFF2D1B4E), // Medium dark purple
      Color(0xFF1A0D2E), // Dark purple
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );
}
