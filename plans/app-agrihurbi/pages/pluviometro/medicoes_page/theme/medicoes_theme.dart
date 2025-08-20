// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';

/// Sistema de tema específico para a página de medições
class MedicoesTheme {
  // Core Colors - baseados no ShadcnStyle para consistência
  static Color get primaryColor => ShadcnStyle.textColor;
  static Color get backgroundColor => ShadcnStyle.backgroundColor;
  static Color get surfaceColor =>
      ShadcnStyle.borderColor.withValues(alpha: 0.1);
  static Color get borderColor => ShadcnStyle.borderColor;
  static Color get textColor => ShadcnStyle.textColor;
  static Color get mutedTextColor => ShadcnStyle.mutedTextColor;
  static Color get labelColor => ShadcnStyle.mutedTextColor;

  // Status Colors
  static Color get successColor => const Color(0xFF22C55E); // Green 500
  static Color get warningColor => const Color(0xFFF59E0B); // Amber 500
  static Color get errorColor => const Color(0xFFEF4444); // Red 500
  static Color get infoColor => const Color(0xFF3B82F6); // Blue 500

  // Measurement Specific Colors
  static Color get rainColor => const Color(0xFF0EA5E9); // Sky 500
  static Color get noRainColor => mutedTextColor.withValues(alpha: 0.6);
  static Color get highRainColor => const Color(0xFF1D4ED8); // Blue 700
  static Color get mediumRainColor => const Color(0xFF3B82F6); // Blue 500
  static Color get lowRainColor => const Color(0xFF60A5FA); // Blue 400

  // Card Colors
  static Color get cardBackgroundColor => backgroundColor;
  static Color get cardBorderColor => borderColor;
  static Color get cardShadowColor => textColor.withValues(alpha: 0.1);

  // Interactive States
  static Color get hoverColor => textColor.withValues(alpha: 0.05);
  static Color get pressedColor => textColor.withValues(alpha: 0.1);
  static Color get focusColor => const Color(0xFF94A3B8);
  static Color get selectedColor => primaryColor.withValues(alpha: 0.1);

  // Typography Scale
  static TextStyle get headingLarge => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.25,
      );

  static TextStyle get headingSmall => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedTextColor,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: labelColor,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: labelColor,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: labelColor,
      );

  // Number formatting styles
  static TextStyle get statisticValue => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      );

  static TextStyle get statisticLabel => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: labelColor,
      );

  static TextStyle get measurementValue => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  static TextStyle get measurementUnit => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedTextColor,
      );

  // Spacing System
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  // Border Radius
  static BorderRadius get radiusNone => BorderRadius.zero;
  static BorderRadius get radiusSmall => BorderRadius.circular(4.0);
  static BorderRadius get radiusMedium => BorderRadius.circular(8.0);
  static BorderRadius get radiusLarge => BorderRadius.circular(12.0);
  static BorderRadius get radiusXL => BorderRadius.circular(16.0);
  static BorderRadius get radiusFull => BorderRadius.circular(9999.0);

  // Shadows
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: cardShadowColor,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: cardShadowColor,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: cardShadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Component Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: radiusMedium,
        border: Border.all(color: cardBorderColor),
        boxShadow: shadowSmall,
      );

  static BoxDecoration get statisticCardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: radiusLarge,
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      );

  static BoxDecoration get dailyItemDecoration => BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: radiusMedium,
        border: Border.all(color: cardBorderColor),
      );

  static BoxDecoration get iconContainerDecoration => BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
      );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: borderColor),
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      );

  static ButtonStyle get ghostButtonStyle => TextButton.styleFrom(
        foregroundColor: primaryColor,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      );

  // Helper Methods for State Colors
  static Color getRainIntensityColor(double quantidade) {
    if (quantidade == 0) return noRainColor;
    if (quantidade < 5) return lowRainColor;
    if (quantidade < 20) return mediumRainColor;
    return highRainColor;
  }

  static Color getStatisticIconColor(String statType) {
    switch (statType.toLowerCase()) {
      case 'total':
        return rainColor;
      case 'media':
      case 'média':
        return infoColor;
      case 'maximo':
      case 'máximo':
        return warningColor;
      case 'dias':
        return successColor;
      default:
        return primaryColor;
    }
  }

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXL = 32.0;

  // Layout Constraints
  static const double maxContentWidth = 800.0;
  static const double minCardHeight = 64.0;
  static const double carouselHeight = 400.0;
  static const double dailyItemHeight = 72.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1280.0;

  // Helper method to determine if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Helper method to determine if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  // Helper method to determine if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Adaptive padding based on screen size
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(space3);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(space4);
    } else {
      return const EdgeInsets.all(space6);
    }
  }

  // Adaptive spacing based on screen size
  static double getAdaptiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return space2;
    } else if (isTablet(context)) {
      return space3;
    } else {
      return space4;
    }
  }
}
