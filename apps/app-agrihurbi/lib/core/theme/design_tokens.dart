import 'package:flutter/material.dart';

/// A centralized source of truth for all design constants in the application.
///
/// This class uses nested static classes to organize design tokens, replacing
/// scattered magic numbers and consolidating design decisions into a single,
/// easy-to-navigate file.
abstract class DesignTokens {
  DesignTokens._();

  /// A collection of all colors used in the application.
  abstract class Colors {
    Colors._();

    // Primary Palette
    static const Color primary = Color(0xFF2E7D32); // Green for agriculture
    static const Color primaryLight = Color(0xFF4CAF50);
    static const Color primaryDark = Color(0xFF1B5E20);

    // Secondary & Accent
    static const Color secondary = Color(0xFF4CAF50);
    static const Color accent = Color(0xFFFF9800); // Orange for emphasis

    // Surface & Background
    static const Color surface = Color(0xFFFFFFFF);
    static const Color surfaceDark = Color(0xFF121212);
    static const Color background = Color(0xFFF5F5F5);
    static const Color backgroundDark = Color(0xFF1E1E1E);

    // Status Colors
    static const Color success = Color(0xFF388E3C);
    static const Color error = Color(0xFFD32F2F);
    static const Color warning = Color(0xFFF57C00);
    static const Color info = Color(0xFF1976D2);

    // Text Colors
    static const Color textPrimary = Color(0xFF212121);
    static const Color textSecondary = Color(0xFF757575);
    static const Color textLight = Color(0xFFFFFFFF);
    static const Color textDisabled = Color(0xFFBDBDBD);

    // Border & Divider
    static const Color border = Color(0xFFE0E0E0);
    static const Color divider = Color(0xFFBDBDBD);

    // Livestock Category Colors
    static const Color cattle = Color(0xFF8D6E63);
    static const Color horses = Color(0xFF795548);
    static const Color sheep = Color(0xFFE0E0E0);
    static const Color goats = Color(0xFFBCAAA4);
    static const Color pigs = Color(0xFFFFAB91);
    static const Color poultry = Color(0xFFFFCC02);

    // Weather Colors
    static const Color sunny = Color(0xFFFFEB3B);
    static const Color cloudy = Color(0xFF9E9E9E);
    static const Color rainy = Color(0xFF2196F3);
    static const Color stormy = Color(0xFF673AB7);

    // Market Status Colors
    static const Color marketUp = Color(0xFF4CAF50);
    static const Color marketDown = Color(0xFFD32F2F);
    static const Color marketNeutral = Color(0xFF9E9E9E);
    static const Color marketPending = Color(0xFFFF9800);
  }

  /// A collection of spacing and padding values based on a 4dp grid.
  abstract class Spacing {
    Spacing._();
    static const double xs = 4.0; // Extra small
    static const double sm = 8.0; // Small
    static const double md = 16.0; // Medium (default)
    static const double lg = 24.0; // Large
    static const double xl = 32.0; // Extra large
    static const double xxl = 48.0; // Extra extra large
  }

  /// A collection of typography-related constants.
  abstract class Typography {
    Typography._();
    // Font Weights
    static const FontWeight light = FontWeight.w300;
    static const FontWeight regular = FontWeight.w400;
    static const FontWeight medium = FontWeight.w500;
    static const FontWeight semiBold = FontWeight.w600;
    static const FontWeight bold = FontWeight.w700;

    // Font Sizes
    static const double f10 = 10.0;
    static const double f12 = 12.0;
    static const double f14 = 14.0;
    static const double f16 = 16.0;
    static const double f18 = 18.0;
    static const double f20 = 20.0;
    static const double f22 = 22.0;
    static const double f24 = 24.0;
    static const double f28 = 28.0;
    static const double f32 = 32.0;

    // Line Heights (multipliers)
    static const double lineHeightTight = 1.2;
    static const double lineHeightNormal = 1.4;
    static const double lineHeightRelaxed = 1.6;

    // Letter Spacing
    static const double letterSpacingTight = -0.5;
    static const double letterSpacingNormal = 0.0;
    static const double letterSpacingWide = 0.5;
  }

  /// A collection of border radius values.
  abstract class Radii {
    Radii._();
    static const double none = 0.0;
    static const double xs = 2.0;
    static const double sm = 4.0;
    static const double md = 8.0;
    static const double lg = 12.0;
    static const double xl = 16.0;
    static const double xxl = 24.0;
    static const double circular = 999.0;
  }

  /// A collection of pre-configured [BorderRadius] objects.
  abstract class Borders {
    Borders._();
    static const BorderRadius card = BorderRadius.all(Radius.circular(Radii.lg));
    static const BorderRadius button = BorderRadius.all(Radius.circular(Radii.md));
    static const BorderRadius input = BorderRadius.all(Radius.circular(Radii.md));
    static const BorderRadius chip = BorderRadius.all(Radius.circular(Radii.xl));
  }

  /// A collection of elevation values based on Material Design guidelines.
  abstract class Elevations {
    Elevations._();
    static const double none = 0.0;
    static const double sm = 1.0;
    static const double md = 2.0;
    static const double lg = 4.0;
    static const double xl = 8.0;
    static const double xxl = 16.0;
  }

  /// A collection of standardized icon sizes.
  abstract class IconSizes {
    IconSizes._();
    static const double xs = 16.0;
    static const double sm = 20.0;
    static const double md = 24.0;
    static const double lg = 32.0;
    static const double xl = 40.0;
    static const double xxl = 48.0;
  }

  /// A collection of standardized animation durations.
  abstract class Animations {
    Animations._();
    static const Duration fast = Duration(milliseconds: 150);
    static const Duration medium = Duration(milliseconds: 300);
    static const Duration slow = Duration(milliseconds: 500);
  }

  /// A collection of default dimensions for common UI components.
  abstract class Dimensions {
    Dimensions._();
    // Heights
    static const double buttonHeightSmall = 32.0;
    static const double buttonHeightMedium = 40.0;
    static const double buttonHeightLarge = 48.0;
    static const double inputHeight = 48.0;
    static const double appBarHeight = 56.0;
    static const double bottomNavHeight = 80.0;
    static const double cardMinHeight = 80.0;

    // Avatar Sizes
    static const double avatarSmall = 32.0;
    static const double avatarMedium = 48.0;
    static const double avatarLarge = 64.0;
  }

  /// A collection of breakpoints for building responsive layouts.
  abstract class Breakpoints {
    Breakpoints._();
    static const double mobile = 480.0;
    static const double tablet = 768.0;
    static const double desktop = 1024.0;
    static const double largeDesktop = 1440.0;
  }

  /// A [MaterialColor] swatch generated from the primary color for use in [ThemeData].
  static MaterialColor get primarySwatch {
    return const MaterialColor(0xFF2E7D32, {
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF2E7D32),
      600: Color(0xFF2E7D32),
      700: Color(0xFF1B5E20),
      800: Color(0xFF1B5E20),
      900: Color(0xFF1B5E20),
    });
  }

  // --- Responsive Helpers ---

  /// Returns `true` if the screen width is considered mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  /// Returns `true` if the screen width is considered tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet &&
      MediaQuery.of(context).size.width < Breakpoints.desktop;

  /// Returns `true` if the screen width is considered desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  /// Returns a value based on the current screen size.
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}