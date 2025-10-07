import 'package:flutter/material.dart';

/// Defines the design tokens for the Gasometer application.
///
/// This class centralizes all visual design constants, such as colors, spacing,
/// and typography, to ensure a consistent and maintainable UI.
abstract class GasometerDesignTokens {
  GasometerDesignTokens._();

  /// A collection of all colors used in the application.
  abstract class Colors {
    Colors._();
    // Primary Palette
    static const Color primary = Color(0xFFFF5722); // Deep Orange
    static const Color primaryLight = Color(0xFFFF8A65);
    static const Color primaryDark = Color(0xFFE64A19);

    // Secondary & Accent
    static const Color secondary = Color(0xFF2196F3); // Blue
    static const Color secondaryLight = Color(0xFF64B5F6);
    static const Color secondaryDark = Color(0xFF1976D2);
    static const Color accent = Color(0xFF4CAF50); // Green
    static const Color accentLight = Color(0xFF81C784);
    static const Color accentDark = Color(0xFF388E3C);

    // Surface & Background
    static const Color surface = Color(0xFFFFFFFF);
    static const Color surfaceVariant = Color(0xFFF8F9FA);
    static const Color background = Color(0xFFF5F5F5);
    static const Color headerBackground = Color(0xFF2C2C2E);

    // Premium Colors
    static const Color premiumGold = Color(0xFFFFD700);
    static const Color premiumSilver = Color(0xFFC0C0C0);
    static const Color premiumBronze = Color(0xFFCD7F32);
    static const Color premiumAccent = Color(0xFFFFA500);

    // Status Colors
    static const Color success = Color(0xFF4CAF50);
    static const Color warning = Color(0xFFFF9800);
    static const Color error = Color(0xFFF44336);
    static const Color info = Color(0xFF2196F3);

    // Neutral Grayscale
    static const Color neutral50 = Color(0xFFFAFAFA);
    static const Color neutral100 = Color(0xFFF5F5F5);
    static const Color neutral200 = Color(0xFFEEEEEE);
    static const Color neutral300 = Color(0xFFE0E0E0);
    static const Color neutral500 = Color(0xFF9E9E9E);
    static const Color neutral700 = Color(0xFF616161);
    static const Color neutral900 = Color(0xFF212121);

    // Text Colors
    static const Color textPrimary = Color(0xFF1C1B1F);
    static const Color textSecondary = Color(0xFF757575);
    static const Color textOnPrimary = Color(0xFFFFFFFF);

    // Fuel-specific Colors
    static const Color fuelGasoline = Color(0xFFFF5722);
    static const Color fuelGasolineLight = Color(0xFFFFAB91);
    static const Color fuelGasolineDark = Color(0xFFBF360C);
    static const Color fuelEthanol = Color(0xFF4CAF50);
    static const Color fuelEthanolLight = Color(0xFFA5D6A7);
    static const Color fuelEthanolDark = Color(0xFF2E7D32);
    static const Color fuelDiesel = Color(0xFF795548);
    static const Color fuelDieselLight = Color(0xFFBCAAA4);
    static const Color fuelDieselDark = Color(0xFF5D4037);
    static const Color fuelGas = Color(0xFF9C27B0);
    static const Color fuelGasLight = Color(0xFFCE93D8);
    static const Color fuelGasDark = Color(0xFF7B1FA2);

    // Analytics Colors
    static const Color analyticsBlue = Color(0xFF4299E1);
    static const Color analyticsGreen = Color(0xFF48BB78);
    static const Color analyticsPurple = Color(0xFF9F7AEA);

    // Chart Colors
    static const List<Color> chartColors = [
      Color(0xFFFF5722), // Orange
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Amber
      Color(0xFF9C27B0), // Purple
      Color(0xFF607D8B), // Blue Grey
      Color(0xFFE91E63), // Pink
      Color(0xFF795548), // Brown
    ];
  }

  /// A collection of spacing and padding values.
  abstract class Spacing {
    Spacing._();
    static const double xs = 4.0;
    static const double sm = 8.0;
    static const double md = 12.0;
    static const double lg = 16.0;
    static const double xl = 20.0;
    static const double xxl = 24.0;
    static const double xxxl = 32.0;
  }

  /// A collection of standardized icon sizes.
  abstract class IconSizes {
    IconSizes._();
    static const double xs = 16.0;
    static const double sm = 20.0;
    static const double md = 24.0;
    static const double lg = 28.0;
    static const double xl = 32.0;
    static const double xxl = 40.0;
    static const double xxxl = 48.0;
  }

  /// A collection of border radius values.
  abstract class Radii {
    Radii._();
    static const double xs = 4.0;
    static const double sm = 6.0;
    static const double md = 8.0;
    static const double lg = 12.0;
    static const double xl = 16.0;
    static const double xxl = 20.0;
    static const double round = 50.0;
  }

  /// A collection of elevation values.
  abstract class Elevations {
    Elevations._();
    static const double none = 0.0;
    static const double xs = 1.0;
    static const double sm = 2.0;
    static const double md = 4.0;
    static const double lg = 8.0;
    static const double xl = 16.0;
  }

  /// A collection of opacity values.
  abstract class Opacities {
    Opacities._();
    static const double disabled = 0.38;
    static const double secondary = 0.6;
    static const double hint = 0.5;
    static const double divider = 0.12;
    static const double overlay = 0.1;
    static const double backdrop = 0.5;
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
    static const double f11 = 11.0;
    static const double f12 = 12.0;
    static const double f14 = 14.0;
    static const double f16 = 16.0;
    static const double f18 = 18.0;
    static const double f20 = 20.0;
    static const double f24 = 24.0;
    static const double f32 = 32.0;
  }

  /// A collection of standardized animation durations and curves.
  abstract class Animations {
    Animations._();
    // Durations
    static const Duration fast = Duration(milliseconds: 150);
    static const Duration normal = Duration(milliseconds: 250);
    static const Duration slow = Duration(milliseconds: 350);

    // Curves
    static const Curve standard = Curves.easeInOut;
    static const Curve enter = Curves.easeOut;
    static const Curve exit = Curves.easeIn;
    static const Curve bounce = Curves.elasticOut;
  }

  /// A collection of breakpoints for building responsive layouts.
  abstract class Breakpoints {
    Breakpoints._();
    static const double mobile = 480.0;
    static const double tablet = 768.0;
    static const double desktop = 1024.0;
    static const double wide = 1200.0;
  }

  /// A collection of maximum width constraints for content areas.
  abstract class MaxWidths {
    MaxWidths._();
    static const double content = 1200.0;
    static const double dialog = 500.0;
  }

  /// A collection of dimensions for loading indicators.
  abstract class Loaders {
    Loaders._();
    static const double indicatorSize = 24.0;
    static const double strokeWidth = 3.0;
  }

  /// A collection of dimensions for skeleton UI components.
  abstract class Skeletons {
    Skeletons._();
    static const double height = 16.0;
    static const double heightSmall = 12.0;
    static const double heightLarge = 20.0;
    static const double cardHeight = 120.0;
    static const double avatarSize = 40.0;
  }

  /// A collection of reusable gradients.
  abstract class Gradients {
    Gradients._();
    static const LinearGradient primary = LinearGradient(
      colors: [Colors.primaryLight, Colors.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient secondary = LinearGradient(
      colors: [Colors.secondaryLight, Colors.secondaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient accent = LinearGradient(
      colors: [Colors.accentLight, Colors.accentDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient gasoline = LinearGradient(
      colors: [Colors.fuelGasoline, Colors.fuelGasolineLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient ethanol = LinearGradient(
      colors: [Colors.fuelEthanol, Colors.fuelEthanolLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient diesel = LinearGradient(
      colors: [Colors.fuelDiesel, Colors.fuelDieselLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    static const LinearGradient premium = LinearGradient(
      colors: [Colors.premiumGold, Colors.premiumAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// The minimum touch target size for accessible UI elements.
  static const double minTouchTarget = 48.0;

  // --- HELPER METHODS ---

  /// Returns a fuel-specific color based on the fuel type string.
  static Color getFuelTypeColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'gasoline':
      case 'gasolina':
        return Colors.fuelGasoline;
      case 'ethanol':
      case 'etanol':
        return Colors.fuelEthanol;
      case 'diesel':
        return Colors.fuelDiesel;
      case 'gas':
      case 'gnv':
        return Colors.fuelGas;
      default:
        return Colors.primary;
    }
  }

  /// Returns an appropriate text color for a given background color.
  static Color getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.textPrimary
        : Colors.textOnPrimary;
  }

  // --- RESPONSIVE HELPERS ---

  /// Returns `true` if the screen width is considered mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  /// Returns `true` if the screen width is considered tablet.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.tablet && width < Breakpoints.desktop;
  }

  /// Returns `true` if the screen width is considered desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.desktop;

  /// Returns a responsive spacing value based on the screen size.
  static double responsiveSpacing(BuildContext context) {
    if (isMobile(context)) return Spacing.lg;
    if (isTablet(context)) return Spacing.xl;
    return Spacing.xxl;
  }

  /// Returns a responsive icon size based on the screen size.
  static double adaptiveIconSize(BuildContext context) {
    if (isMobile(context)) return IconSizes.md;
    if (isTablet(context)) return IconSizes.lg;
    return IconSizes.xl;
  }

  // --- MATERIAL COLOR SWATCHES ---

  /// The primary color swatch, based on the application's primary color (Deep Orange).
  static const MaterialColor primarySwatch = MaterialColor(0xFFFF5722, {
    50: Color(0xFFFBE9E7),
    100: Color(0xFFFFCCBC),
    200: Color(0xFFFFAB91),
    300: Color(0xFFFF8A65),
    400: Color(0xFFFF7043),
    500: Color(0xFFFF5722),
    600: Color(0xFFF4511E),
    700: Color(0xFFE64A19),
    800: Color(0xFFD84315),
    900: Color(0xFFBF360C),
  });

  /// The secondary color swatch, based on the application's secondary color (Blue).
  static const MaterialColor secondarySwatch = MaterialColor(0xFF2196F3, {
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(0xFF2196F3),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  });
}

/// An extension to provide convenient access to [GasometerDesignTokens] via the [BuildContext].
extension GasometerDesignTokensExtension on BuildContext {
  /// Provides quick access to the design tokens.
  GasometerDesignTokens get tokens => GasometerDesignTokens();

  /// Returns `true` if the current screen width is considered mobile.
  bool get isMobile => GasometerDesignTokens.isMobile(this);

  /// Returns `true` if the current screen width is considered tablet.
  bool get isTablet => GasometerDesignTokens.isTablet(this);

  /// Returns `true` if the current screen width is considered desktop.
  bool get isDesktop => GasometerDesignTokens.isDesktop(this);

  /// Returns a responsive spacing value appropriate for the screen size.
  double get adaptiveSpacing => GasometerDesignTokens.responsiveSpacing(this);

  /// Returns a responsive icon size appropriate for the screen size.
  double get adaptiveIconSize => GasometerDesignTokens.adaptiveIconSize(this);
}