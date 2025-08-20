// Flutter imports:
import 'package:flutter/material.dart';

/// Design tokens for consistent visual system
class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // SPACING - Based on 8pt grid system
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // BORDER RADIUS
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 50.0;

  // ELEVATION
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  static const double elevationXXL = 16.0;

  // ICON SIZES
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // AVATAR SIZES
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 48.0;
  static const double avatarXL = 56.0;
  static const double avatarXXL = 64.0;

  // OPACITY
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.54;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // ANIMATION DURATIONS
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationSlower = Duration(milliseconds: 500);

  // CURVES
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveBounce = Curves.bounceOut;

  // SEMANTIC COLORS (will use theme colors in practice)
  static const Color colorSuccess = Color(0xFF4CAF50);
  static const Color colorWarning = Color(0xFFFF9800);
  static const Color colorError = Color(0xFFF44336);
  static const Color colorInfo = Color(0xFF2196F3);

  // COMPONENT SPECIFIC TOKENS

  // Card tokens
  static const EdgeInsets cardPadding = EdgeInsets.all(spacing16);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(spacing12);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(spacing20);
  static const double cardElevation = elevationS;
  static const double cardRadius = radiusS;

  // List item tokens
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing12,
  );
  static const EdgeInsets listItemContentPadding = EdgeInsets.all(spacing8);
  static const double listItemMinHeight = 72.0;

  // Button tokens
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spacing24,
    vertical: spacing12,
  );
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing8,
  );
  static const double buttonRadius = radiusS;
  static const double buttonElevation = elevationS;

  // Input field tokens
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing12,
  );
  static const double inputRadius = radiusS;

  // Dialog tokens
  static const EdgeInsets dialogPadding = EdgeInsets.all(spacing24);
  static const EdgeInsets dialogContentPadding = EdgeInsets.symmetric(
    horizontal: spacing24,
    vertical: spacing20,
  );
  static const double dialogRadius = radiusL;
  static const double dialogElevation = elevationXL;

  // Snackbar tokens
  static const EdgeInsets snackbarMargin = EdgeInsets.all(spacing16);
  static const EdgeInsets snackbarPadding = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing12,
  );
  static const double snackbarRadius = radiusS;

  // Layout tokens
  static const double maxContentWidth = 1120.0;
  static const EdgeInsets pageHorizontalPadding =
      EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets pagePadding = EdgeInsets.all(spacing2);
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(vertical: spacing24);
}

/// Extension methods for common spacing patterns
extension SpacingExtensions on Widget {
  /// Add padding using design tokens
  Widget paddingToken(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// Add symmetric horizontal padding
  Widget paddingH(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Add symmetric vertical padding
  Widget paddingV(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Add all-around padding
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }
}

/// Commonly used spacing widgets
class Spacing {
  static const Widget h2 = SizedBox(width: DesignTokens.spacing2);
  static const Widget h4 = SizedBox(width: DesignTokens.spacing4);
  static const Widget h8 = SizedBox(width: DesignTokens.spacing8);
  static const Widget h12 = SizedBox(width: DesignTokens.spacing12);
  static const Widget h16 = SizedBox(width: DesignTokens.spacing16);
  static const Widget h20 = SizedBox(width: DesignTokens.spacing20);
  static const Widget h24 = SizedBox(width: DesignTokens.spacing24);
  static const Widget h32 = SizedBox(width: DesignTokens.spacing32);

  static const Widget v2 = SizedBox(height: DesignTokens.spacing2);
  static const Widget v4 = SizedBox(height: DesignTokens.spacing4);
  static const Widget v8 = SizedBox(height: DesignTokens.spacing8);
  static const Widget v12 = SizedBox(height: DesignTokens.spacing12);
  static const Widget v16 = SizedBox(height: DesignTokens.spacing16);
  static const Widget v20 = SizedBox(height: DesignTokens.spacing20);
  static const Widget v24 = SizedBox(height: DesignTokens.spacing24);
  static const Widget v32 = SizedBox(height: DesignTokens.spacing32);
}

/// Typography tokens extension
class TypographyTokens {
  // Font weights
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // Font sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;

  // Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
}
