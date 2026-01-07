import 'package:flutter/material.dart';

/// Shadcn-inspired design system styles
/// Adapts to the current theme (Light/Dark)
class ShadcnStyle {
  // ===========================================================================
  // CONSTANTS (Legacy Support)
  // ===========================================================================
  static const Color textColor = Color(0xFF1F2937);
  static const Color primaryColor = Color(0xFF3B82F6);
  static const Color secondaryColor = Color(0xFF6B7280);

  // ===========================================================================
  // TEXT STYLES
  // ===========================================================================

  static TextStyle getHeaderStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        );
  }

  static TextStyle getSubtleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        );
  }

  // ===========================================================================
  // BUTTON STYLES
  // ===========================================================================

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: Colors.indigo.withValues(alpha: 0.3),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // Use a softer, tinted border instead of plain grey
        side: const BorderSide(color: Color(0xFFE0E7FF), width: 1.5), // Indigo 100
      );

  // ===========================================================================
  // DECORATIONS
  // ===========================================================================

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Premium Glassmorphism Decoration
  static BoxDecoration glassDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.indigo.withValues(alpha: 0.1),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
