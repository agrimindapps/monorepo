import 'package:flutter/material.dart';

/// Shadcn-inspired design system styles
/// TODO: Implement complete shadcn design system
class ShadcnStyle {
  // Colors
  static const Color textColor = Color(0xFF1F2937); // Gray 800
  static const Color primaryColor = Color(0xFF3B82F6); // Blue 500
  static const Color secondaryColor = Color(0xFF6B7280); // Gray 500

  // Text Button Style
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: secondaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );

  // Primary Button Style
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      );

  // Card Style
  static ShapeDecoration get cardDecoration => ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
