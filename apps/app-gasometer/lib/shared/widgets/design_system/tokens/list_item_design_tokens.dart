import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

/// Defines design tokens specifically for creating standardized list items.
///
/// This class complements the global [GasometerDesignTokens] with values
/// tailored to list item components, ensuring visual consistency.
abstract class ListItemDesignTokens {
  ListItemDesignTokens._();

  /// Sizing and layout dimensions for list items.
  abstract class Dimensions {
    Dimensions._();
    static const double dateColumnWidth = 80.0;
    static const double dividerThickness = 1.0;
    static const double cardMinHeight = 80.0;
    static const double minimumTouchTarget = 48.0;
  }

  /// Padding and margin values for list items.
  abstract class Paddings {
    Paddings._();
    static EdgeInsets get card =>
        const EdgeInsets.all(GasometerDesignTokens.spacingLg);
    static EdgeInsets get content => const EdgeInsets.symmetric(
          horizontal: GasometerDesignTokens.spacingMd,
          vertical: GasometerDesignTokens.spacingSm,
        );
    static EdgeInsets get dateColumn => const EdgeInsets.only(
          right: GasometerDesignTokens.spacingMd,
          top: GasometerDesignTokens.spacingSm,
          bottom: GasometerDesignTokens.spacingSm,
        );
  }

  /// Spacing values for internal elements of list items.
  abstract class Spacing {
    Spacing._();
    static double get infoItems => GasometerDesignTokens.spacingSm;
    static double get badge => GasometerDesignTokens.spacingXs;
  }

  /// Color tokens for list items.
  abstract class Colors {
    Colors._();
    static Color get divider => GasometerDesignTokens.colorNeutral300;
    static Color get cardBackground => GasometerDesignTokens.colorBackground;
    static Color get cardHover =>
        GasometerDesignTokens.colorPrimaryLight.withOpacity(0.1);
  }

  /// [TextStyle] tokens for list items.
  abstract class TextStyles {
    TextStyles._();
    static TextStyle get date => TextStyle(
          fontSize: GasometerDesignTokens.fontSizeSm,
          fontWeight: GasometerDesignTokens.fontWeightMedium,
          color: GasometerDesignTokens.colorTextSecondary,
        );
    static TextStyle get month => TextStyle(
          fontSize: GasometerDesignTokens.fontSizeXs,
          fontWeight: GasometerDesignTokens.fontWeightRegular,
          color: GasometerDesignTokens.colorTextSecondary,
        );
    static TextStyle get infoLabel => TextStyle(
          fontSize: GasometerDesignTokens.fontSizeXs,
          fontWeight: GasometerDesignTokens.fontWeightRegular,
          color: GasometerDesignTokens.colorTextSecondary,
        );
    static TextStyle get infoValue => TextStyle(
          fontSize: GasometerDesignTokens.fontSizeSm,
          fontWeight: GasometerDesignTokens.fontWeightMedium,
          color: GasometerDesignTokens.colorTextPrimary,
        );
  }

  /// Border and shadow tokens for list items.
  abstract class Borders {
    Borders._();
    static BorderRadius get cardRadius =>
        BorderRadius.circular(GasometerDesignTokens.radiusCard);
    static BorderRadius get badgeRadius =>
        BorderRadius.circular(GasometerDesignTokens.radiusSm);
    static List<BoxShadow> get cardShadow => [
          BoxShadow(
            color: GasometerDesignTokens.colorNeutral500.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
  }

  /// Animation-related tokens for list items.
  abstract class Animations {
    Animations._();
    static const Duration duration = Duration(milliseconds: 200);
    static const Curve curve = Curves.easeInOut;
  }

  /// Breakpoints for responsive design.
  abstract class Breakpoints {
    Breakpoints._();
    static const double mobile = 600.0;
    static const double tablet = 900.0;
  }

  /// Returns a responsive card padding based on the screen width.
  static EdgeInsets getResponsiveCardPadding(double screenWidth) {
    if (screenWidth < Breakpoints.mobile) {
      return const EdgeInsets.all(GasometerDesignTokens.spacingMd);
    } else if (screenWidth < Breakpoints.tablet) {
      return const EdgeInsets.all(GasometerDesignTokens.spacingLg);
    } else {
      return const EdgeInsets.all(GasometerDesignTokens.spacingXl);
    }
  }

  /// Returns a responsive width for the date column based on the screen width.
  static double getResponsiveDateWidth(double screenWidth) {
    if (screenWidth < Breakpoints.mobile) {
      return Dimensions.dateColumnWidth * 0.8;
    }
    return Dimensions.dateColumnWidth;
  }
}