import 'package:flutter/material.dart';

/// Design Tokens - Central source of truth for all design constants
/// This replaces scattered magic numbers and consolidates design decisions
abstract class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // =====================================================================
  // COLOR CONSTANTS
  // =====================================================================
  
  /// Primary colors
  static const Color primaryColor = Color(0xFF2E7D32); // Green for agriculture
  static const Color primaryLightColor = Color(0xFF4CAF50);
  static const Color primaryDarkColor = Color(0xFF1B5E20);
  
  /// Secondary colors
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF9800); // Orange for emphasis
  
  /// Surface colors
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceDarkColor = Color(0xFF121212);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color backgroundDarkColor = Color(0xFF1E1E1E);
  
  /// Status colors
  static const Color successColor = Color(0xFF388E3C);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);
  
  /// Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFFFFFFFF);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  
  /// Border & divider colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
  
  /// Livestock specific colors
  static const Color cattleColor = Color(0xFF8D6E63);
  static const Color horsesColor = Color(0xFF795548);
  static const Color sheepColor = Color(0xFFE0E0E0);
  static const Color goatsColor = Color(0xFFBCAAA4);
  static const Color pigsColor = Color(0xFFFFAB91);
  static const Color poultryColor = Color(0xFFFFCC02);
  
  /// Weather colors
  static const Color sunnyColor = Color(0xFFFFEB3B);
  static const Color cloudyColor = Color(0xFF9E9E9E);
  static const Color rainyColor = Color(0xFF2196F3);
  static const Color stormyColor = Color(0xFF673AB7);
  
  /// Market status colors
  static const Color marketUpColor = Color(0xFF4CAF50);
  static const Color marketDownColor = Color(0xFFD32F2F);
  static const Color marketNeutralColor = Color(0xFF9E9E9E);
  static const Color marketPendingColor = Color(0xFFFF9800);

  // =====================================================================
  // SPACING CONSTANTS
  // =====================================================================
  
  /// Base spacing unit (4dp)
  static const double spacingBase = 4.0;
  
  /// Common spacing values
  static const double spacingXs = 4.0;    // Extra small
  static const double spacingSm = 8.0;    // Small
  static const double spacingMd = 16.0;   // Medium (default)
  static const double spacingLg = 24.0;   // Large
  static const double spacingXl = 32.0;   // Extra large
  static const double spacingXxl = 48.0;  // Extra extra large
  
  /// Specific use cases
  static const double cardPadding = spacingMd;
  static const double screenPadding = spacingMd;
  static const double sectionSpacing = spacingLg;
  static const double itemSpacing = spacingSm;
  static const double buttonPadding = spacingMd;

  // =====================================================================
  // TYPOGRAPHY CONSTANTS
  // =====================================================================
  
  /// Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  /// Font sizes
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  
  /// Line heights (multipliers)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  
  /// Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // =====================================================================
  // BORDER RADIUS CONSTANTS
  // =====================================================================
  
  static const double borderRadiusNone = 0.0;
  static const double borderRadiusXs = 2.0;
  static const double borderRadiusSm = 4.0;
  static const double borderRadiusMd = 8.0;
  static const double borderRadiusLg = 12.0;
  static const double borderRadiusXl = 16.0;
  static const double borderRadiusXxl = 24.0;
  static const double borderRadiusCircular = 999.0; // For circular elements
  
  /// Common border radius objects
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(borderRadiusLg));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(borderRadiusMd));
  static const BorderRadius inputBorderRadius = BorderRadius.all(Radius.circular(borderRadiusMd));
  static const BorderRadius chipBorderRadius = BorderRadius.all(Radius.circular(borderRadiusXl));

  // =====================================================================
  // ELEVATION CONSTANTS
  // =====================================================================
  
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0;
  static const double elevationMd = 2.0;
  static const double elevationLg = 4.0;
  static const double elevationXl = 8.0;
  static const double elevationXxl = 16.0;
  
  /// Component specific elevations
  static const double cardElevation = elevationMd;
  static const double buttonElevation = elevationSm;
  static const double appBarElevation = elevationNone;
  static const double drawerElevation = elevationXl;
  static const double modalElevation = elevationXxl;

  // =====================================================================
  // ICON SIZE CONSTANTS
  // =====================================================================
  
  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;
  static const double iconSizeXxl = 48.0;

  // =====================================================================
  // ANIMATION DURATION CONSTANTS
  // =====================================================================
  
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  /// Specific use cases
  static const Duration buttonPressAnimation = animationDurationFast;
  static const Duration pageTransitionAnimation = animationDurationMedium;
  static const Duration modalAnimation = animationDurationMedium;

  // =====================================================================
  // COMPONENT DIMENSION CONSTANTS
  // =====================================================================
  
  /// Button heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  
  /// Input field heights
  static const double inputHeight = 48.0;
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation height
  static const double bottomNavHeight = 80.0;
  
  /// Card minimum height
  static const double cardMinHeight = 80.0;
  
  /// Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;

  // =====================================================================
  // BREAKPOINT CONSTANTS (for responsive design)
  // =====================================================================
  
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointLargeDesktop = 1440.0;

  // =====================================================================
  // HELPER METHODS
  // =====================================================================
  
  /// Get primary color swatch for ThemeData
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
  
  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointTablet;
  }
  
  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }
  
  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
  
  /// Get responsive value based on screen size
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