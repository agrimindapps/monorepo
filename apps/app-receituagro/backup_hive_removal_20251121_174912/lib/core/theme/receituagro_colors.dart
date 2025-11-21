import 'package:flutter/material.dart';

/// Cores específicas do ReceitaAgro (foco em agronegócio)
class ReceitaAgroColors {
  static const Color primary = Color(0xFF4CAF50);        // Agriculture green
  static const Color primaryLight = Color(0xFF81C784);   // Light green
  static const Color primaryDark = Color(0xFF388E3C);    // Dark green
  static const Color secondary = Color(0xFF8BC34A);      // Light green accent
  static const Color secondaryLight = Color(0xFFDCEDC8); // Very light green
  static const Color secondaryDark = Color(0xFF689F38);  // Dark green accent
  static const Color accent = Color(0xFF66BB6A);         // Medium green
  static const Color accentLight = Color(0xFFC8E6C9);    // Light accent
  static const Color accentDark = Color(0xFF2E7D32);     // Dark accent
  static const Color earth = Color(0xFF795548);          // Earth brown
  static const Color earthLight = Color(0xFFD7CCC8);     // Light earth
  static const Color earthDark = Color(0xFF5D4037);      // Dark earth
  
  static const Color harvest = Color(0xFFFF9800);        // Harvest orange
  static const Color harvestLight = Color(0xFFFFE0B2);   // Light harvest
  static const Color harvestDark = Color(0xFFE65100);    // Dark harvest
  
  static const Color seed = Color(0xFF3E2723);           // Seed brown
  static const Color leaf = Color(0xFF4CAF50);           // Leaf green
  static const Color sun = Color(0xFFFFC107);            // Sun yellow
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  static const LinearGradient earthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [earth, earthLight],
  );
  
  static const LinearGradient harvestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [harvest, harvestLight],
  );
  static Color getPrimaryShade(int shade) {
    switch (shade) {
      case 50: return const Color(0xFFE8F5E8);
      case 100: return const Color(0xFFC8E6C8);
      case 200: return const Color(0xFFA5D6A7);
      case 300: return const Color(0xFF81C784);
      case 400: return const Color(0xFF66BB6A);
      case 500: return primary;
      case 600: return const Color(0xFF43A047);
      case 700: return const Color(0xFF388E3C);
      case 800: return const Color(0xFF2E7D32);
      case 900: return const Color(0xFF1B5E20);
      default: return primary;
    }
  }
  
  static Color getSecondaryShade(int shade) {
    switch (shade) {
      case 50: return const Color(0xFFF1F8E9);
      case 100: return const Color(0xFFDCEDC8);
      case 200: return const Color(0xFFC5E1A5);
      case 300: return const Color(0xFFAED581);
      case 400: return const Color(0xFF9CCC65);
      case 500: return secondary;
      case 600: return const Color(0xFF7CB342);
      case 700: return const Color(0xFF689F38);
      case 800: return const Color(0xFF558B2F);
      case 900: return const Color(0xFF33691E);
      default: return secondary;
    }
  }

  // WCAG AA Compliant Text Colors (4.5:1 contrast minimum)
  // Use these for all text to ensure accessibility compliance

  /// Primary text color with guaranteed 4.5:1+ contrast
  /// Light mode: #212121 on white = 16.1:1 contrast
  /// Dark mode: #E0E0E0 on #121212 = 11.6:1 contrast
  static Color textPrimary(bool isDark) =>
    isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);

  /// Secondary text color with guaranteed 4.5:1+ contrast
  /// Light mode: #616161 on white = 7.0:1 contrast
  /// Dark mode: #BDBDBD on #121212 = 8.7:1 contrast
  static Color textSecondary(bool isDark) =>
    isDark ? const Color(0xFFBDBDBD) : const Color(0xFF616161);

  /// Tertiary text color with guaranteed 4.5:1+ contrast
  /// Light mode: #757575 on white = 4.9:1 contrast
  /// Dark mode: #9E9E9E on #121212 = 6.3:1 contrast
  static Color textTertiary(bool isDark) =>
    isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);

  /// Placeholder text color with guaranteed 4.5:1+ contrast
  /// Light mode: #757575 on white = 4.9:1 contrast
  /// Dark mode: #9E9E9E on #1E1E22 = 5.8:1 contrast
  static Color textPlaceholder(bool isDark) =>
    isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);

  // Background colors for different contexts

  /// Primary background color
  static Color backgroundPrimary(bool isDark) =>
    isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

  /// Secondary background color (cards, surfaces)
  static Color backgroundSecondary(bool isDark) =>
    isDark ? const Color(0xFF1E1E22) : const Color(0xFFFAFAFA);

  /// Tertiary background color (subtle differentiation)
  static Color backgroundTertiary(bool isDark) =>
    isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5);
}
