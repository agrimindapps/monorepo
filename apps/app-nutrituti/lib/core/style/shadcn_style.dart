// STUB: Temporary stub to fix compilation errors
// TODO: Implement proper ShadcnStyle or migrate to Material Design

import 'package:flutter/material.dart';

class ShadcnStyle {
  // Text Styles
  static TextStyle headingLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  }

  static TextStyle headingMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  static TextStyle headingSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  }

  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);
  }

  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
  }

  // Colors
  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color error(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color onPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color onSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondary;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color onBackground(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color onError(BuildContext context) {
    return Theme.of(context).colorScheme.onError;
  }

  // Border Radius
  static BorderRadius borderRadiusSmall = BorderRadius.circular(4);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(8);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(12);
  static BorderRadius borderRadiusXLarge = BorderRadius.circular(16);

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Shadows
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Static colors (used without BuildContext)
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color mutedTextColor = Color(0xFF757575);

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMedium,
        ),
      );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: const BorderSide(color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMedium,
        ),
      );
}
