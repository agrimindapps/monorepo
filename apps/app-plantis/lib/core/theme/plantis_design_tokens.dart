import 'package:flutter/material.dart';
import 'plantis_colors.dart';

/// Extended design tokens for Plantis app with enhanced settings support
class PlantisDesignTokens {
  const PlantisDesignTokens._(); // Private constructor

  // MARK: - Spacing Tokens

  /// Spacing scale based on 4px baseline
  static const double spacing1 = 4.0;   // 4px
  static const double spacing2 = 8.0;   // 8px
  static const double spacing3 = 12.0;  // 12px
  static const double spacing4 = 16.0;  // 16px
  static const double spacing5 = 20.0;  // 20px
  static const double spacing6 = 24.0;  // 24px
  static const double spacing7 = 28.0;  // 28px
  static const double spacing8 = 32.0;  // 32px
  static const double spacing9 = 36.0;  // 36px
  static const double spacing10 = 40.0; // 40px
  static const double spacing12 = 48.0; // 48px
  static const double spacing16 = 64.0; // 64px
  static const double spacing20 = 80.0; // 80px

  // MARK: - Border Radius Tokens

  static const double radiusNone = 0.0;
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radius2XL = 20.0;
  static const double radius3XL = 24.0;
  static const double radiusFull = 9999.0;

  // MARK: - Elevation Tokens

  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
  static const double elevation2XL = 16.0;
  static const double elevation3XL = 24.0;

  // MARK: - Animation Duration Tokens

  static const Duration durationInstant = Duration(milliseconds: 50);
  static const Duration durationQuick = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 750);
  static const Duration durationSlowest = Duration(milliseconds: 1000);

  // MARK: - Typography Scale

  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 28.0;
  static const double fontSize5XL = 32.0;
  static const double fontSize6XL = 36.0;

  // MARK: - Font Weights

  static const FontWeight fontWeightThin = FontWeight.w100;
  static const FontWeight fontWeightExtraLight = FontWeight.w200;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  static const FontWeight fontWeightBlack = FontWeight.w900;

  // MARK: - Icon Sizes

  static const double iconSizeXS = 12.0;
  static const double iconSizeSM = 16.0;
  static const double iconSizeBase = 20.0;
  static const double iconSizeLG = 24.0;
  static const double iconSizeXL = 28.0;
  static const double iconSize2XL = 32.0;
  static const double iconSize3XL = 36.0;
  static const double iconSize4XL = 40.0;

  // MARK: - Component Specific Tokens

  /// Settings components sizing
  static const double settingsItemHeight = 56.0;
  static const double settingsItemPadding = 16.0;
  static const double settingsIconSize = 18.0;
  static const double settingsIconContainer = 32.0;

  /// Card components
  static const double cardPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double cardElevation = 2.0;

  /// Button components
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 12.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;

  // MARK: - Plant-themed Component Tokens

  /// Premium components
  static const double premiumBadgeRadius = 8.0;
  static const double premiumIndicatorSize = 24.0;

  /// Plant-themed animations
  static const Duration leafGrowDuration = Duration(milliseconds: 800);
  static const Duration flowerBloomDuration = Duration(milliseconds: 1200);
  static const Duration waterRippleDuration = Duration(milliseconds: 600);

  /// Interactive states
  static const double hoverScaleUp = 1.02;
  static const double pressScaleDown = 0.98;
  static const Duration interactionDuration = Duration(milliseconds: 150);

  // MARK: - Helper Methods

  /// Get appropriate spacing based on context
  static double getContextualSpacing(SpacingContext context) {
    switch (context) {
      case SpacingContext.tight:
        return spacing2;
      case SpacingContext.normal:
        return spacing4;
      case SpacingContext.comfortable:
        return spacing6;
      case SpacingContext.spacious:
        return spacing8;
    }
  }

  /// Get appropriate radius based on component type
  static double getComponentRadius(ComponentType type) {
    switch (type) {
      case ComponentType.button:
        return radiusLG;
      case ComponentType.card:
        return radiusXL;
      case ComponentType.dialog:
        return radius2XL;
      case ComponentType.sheet:
        return radius3XL;
      case ComponentType.input:
        return radiusMD;
    }
  }

  /// Get appropriate elevation based on component hierarchy
  static double getComponentElevation(ElevationLevel level) {
    switch (level) {
      case ElevationLevel.flat:
        return elevationNone;
      case ElevationLevel.raised:
        return elevationSM;
      case ElevationLevel.floating:
        return elevationMD;
      case ElevationLevel.modal:
        return elevationXL;
      case ElevationLevel.dropdown:
        return elevation2XL;
    }
  }

  // MARK: - Semantic Color Helpers

  /// Get semantic color based on state
  static Color getSemanticColor(SemanticState state) {
    switch (state) {
      case SemanticState.success:
        return PlantisColors.success;
      case SemanticState.warning:
        return PlantisColors.warning;
      case SemanticState.error:
        return PlantisColors.error;
      case SemanticState.info:
        return PlantisColors.water;
      case SemanticState.premium:
        return PlantisColors.sun;
    }
  }

  /// Get semantic color variant (light version)
  static Color getSemanticColorLight(SemanticState state) {
    switch (state) {
      case SemanticState.success:
        return PlantisColors.successLight;
      case SemanticState.warning:
        return PlantisColors.warningLight;
      case SemanticState.error:
        return PlantisColors.errorLight;
      case SemanticState.info:
        return PlantisColors.waterLight;
      case SemanticState.premium:
        return PlantisColors.sunLight;
    }
  }

  // MARK: - Box Shadow Presets

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // MARK: - Plant-themed Gradients

  static const LinearGradient leafGradient = LinearGradient(
    colors: [PlantisColors.leaf, PlantisColors.leafLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flowerGradient = LinearGradient(
    colors: [PlantisColors.flower, PlantisColors.flowerLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunGradient = LinearGradient(
    colors: [PlantisColors.sun, PlantisColors.sunLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [PlantisColors.water, PlantisColors.waterLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient soilGradient = LinearGradient(
    colors: [PlantisColors.soil, PlantisColors.soilLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // MARK: - Animation Curves

  static const Curve plantGrowCurve = Curves.easeOutBack;
  static const Curve leafFallCurve = Curves.easeInQuart;
  static const Curve waterFlowCurve = Curves.easeInOut;
  static const Curve sunRiseCurve = Curves.easeOutQuint;
}

// MARK: - Enums

enum SpacingContext {
  tight,
  normal,
  comfortable,
  spacious,
}

enum ComponentType {
  button,
  card,
  dialog,
  sheet,
  input,
}

enum ElevationLevel {
  flat,
  raised,
  floating,
  modal,
  dropdown,
}

enum SemanticState {
  success,
  warning,
  error,
  info,
  premium,
}