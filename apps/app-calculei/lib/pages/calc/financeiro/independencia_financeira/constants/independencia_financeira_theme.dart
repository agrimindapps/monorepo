// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes de tema para o módulo de independência financeira
class IndependenciaFinanceiraTheme {
  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
  );

  static const TextStyle errorTextStyle = TextStyle(
    height: 0,
  );

  // Input Decoration
  static InputDecoration defaultInputDecoration({
    required String labelText,
    required String hintText,
    Color? errorColor,
    Widget? prefixIcon,
    bool isDark = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF71717A) : const Color(0xFF94A3B8),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.white,
      errorStyle: errorTextStyle,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorColor ?? Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorColor ?? Colors.red,
          width: 1.5,
        ),
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF71717A) : const Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Button Styles
  static ButtonStyle getPrimaryButtonStyle(bool isDark) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      backgroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
      foregroundColor:
          isDark ? const Color(0xFFFAFAFA) : const Color(0xFF0F172A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  // Card Styles
  static const double defaultCardElevation = 2.0;
  static final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: Colors.grey.shade200,
      width: 1,
    ),
  );
  static const EdgeInsets defaultCardPadding = EdgeInsets.all(16.0);

  // Layout Constants
  static const EdgeInsets defaultPagePadding = EdgeInsets.all(16.0);
  static const double defaultSpacing = 16.0;
  static const double defaultSpacingSmall = 8.0;
  static const double largeSpacing = 24.0;

  // Colors
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static Color getResultColor(bool isDark) =>
      isDark ? Colors.green.shade300 : Colors.green;
  static Color getButtonColor(bool isDark) =>
      isDark ? Colors.blue.shade300 : Colors.blue;

  // Icons
  static const double defaultIconSize = 20.0;

  // Não instanciável
  IndependenciaFinanceiraTheme._();
}
