import 'package:flutter/material.dart';
import 'plantis_colors.dart';
import 'plantis_design_tokens.dart';

/// Settings-specific theme configuration for Plantis app
class SettingsTheme {
  const SettingsTheme._(); // Private constructor

  // MARK: - Theme Data

  /// Light theme configuration for settings
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: PlantisColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: PlantisColors.primary,
      secondary: PlantisColors.secondary,
      tertiary: PlantisColors.accent,
      surface: Colors.white,
      surfaceContainer: Colors.grey.shade50,
      surfaceContainerHighest: Colors.grey.shade100,
      onSurface: PlantisColors.textPrimary,
      onSurfaceVariant: PlantisColors.textSecondary,
    ),
    useMaterial3: true,
    fontFamily: 'SF Pro Display', // iOS-style font for clean settings UI
  );

  /// Dark theme configuration for settings
  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: PlantisColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: PlantisColors.primaryLight,
      secondary: PlantisColors.secondaryLight,
      tertiary: PlantisColors.accentLight,
      surface: const Color(0xFF1C1C1E),
      surfaceContainer: const Color(0xFF2C2C2E),
      surfaceContainerHighest: const Color(0xFF3A3A3C),
      onSurface: Colors.white,
      onSurfaceVariant: Colors.grey.shade400,
    ),
    useMaterial3: true,
    fontFamily: 'SF Pro Display',
  );

  // MARK: - Component Themes

  /// Settings item theme configuration
  static SettingsItemThemeData get settingsItemTheme => const SettingsItemThemeData(
    height: PlantisDesignTokens.settingsItemHeight,
    padding: EdgeInsets.symmetric(
      horizontal: PlantisDesignTokens.settingsItemPadding,
      vertical: PlantisDesignTokens.spacing3,
    ),
    iconSize: PlantisDesignTokens.settingsIconSize,
    iconContainerSize: PlantisDesignTokens.settingsIconContainer,
    borderRadius: PlantisDesignTokens.radiusLG,
    animationDuration: PlantisDesignTokens.durationFast,
  );

  /// Settings card theme configuration
  static SettingsCardThemeData get settingsCardTheme => const SettingsCardThemeData(
    padding: EdgeInsets.all(PlantisDesignTokens.cardPadding),
    margin: EdgeInsets.only(bottom: PlantisDesignTokens.spacing4),
    borderRadius: PlantisDesignTokens.cardRadius,
    elevation: PlantisDesignTokens.cardElevation,
    expandAnimationDuration: PlantisDesignTokens.durationMedium,
    hoverAnimationDuration: PlantisDesignTokens.durationFast,
  );

  /// Premium component theme configuration
  static PremiumThemeData get premiumTheme => const PremiumThemeData(
    primaryColor: PlantisColors.sun,
    lightColor: PlantisColors.sunLight,
    badgeRadius: PlantisDesignTokens.premiumBadgeRadius,
    indicatorSize: PlantisDesignTokens.premiumIndicatorSize,
    glowAnimationDuration: Duration(seconds: 2),
    rotateAnimationDuration: Duration(seconds: 3),
  );

  // MARK: - Typography

  /// Settings page typography theme
  static TextTheme get textTheme => const TextTheme(
    // Headers
    headlineLarge: TextStyle(
      fontSize: PlantisDesignTokens.fontSize5XL,
      fontWeight: PlantisDesignTokens.fontWeightBold,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: PlantisDesignTokens.fontSize4XL,
      fontWeight: PlantisDesignTokens.fontWeightBold,
      letterSpacing: -0.25,
    ),
    headlineSmall: TextStyle(
      fontSize: PlantisDesignTokens.fontSize3XL,
      fontWeight: PlantisDesignTokens.fontWeightSemiBold,
    ),

    // Titles
    titleLarge: TextStyle(
      fontSize: PlantisDesignTokens.fontSize2XL,
      fontWeight: PlantisDesignTokens.fontWeightSemiBold,
    ),
    titleMedium: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeLG,
      fontWeight: PlantisDesignTokens.fontWeightMedium,
    ),
    titleSmall: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeBase,
      fontWeight: PlantisDesignTokens.fontWeightMedium,
    ),

    // Body text
    bodyLarge: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeLG,
      fontWeight: PlantisDesignTokens.fontWeightNormal,
    ),
    bodyMedium: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeBase,
      fontWeight: PlantisDesignTokens.fontWeightNormal,
    ),
    bodySmall: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeSM,
      fontWeight: PlantisDesignTokens.fontWeightNormal,
    ),

    // Labels
    labelLarge: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeBase,
      fontWeight: PlantisDesignTokens.fontWeightMedium,
    ),
    labelMedium: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeSM,
      fontWeight: PlantisDesignTokens.fontWeightMedium,
    ),
    labelSmall: TextStyle(
      fontSize: PlantisDesignTokens.fontSizeXS,
      fontWeight: PlantisDesignTokens.fontWeightMedium,
    ),
  );

  // MARK: - Button Themes

  /// Elevated button theme for settings
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, PlantisDesignTokens.buttonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: PlantisDesignTokens.buttonPaddingHorizontal,
        vertical: PlantisDesignTokens.buttonPaddingVertical,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlantisDesignTokens.buttonRadius),
      ),
      elevation: PlantisDesignTokens.elevationSM,
      backgroundColor: PlantisColors.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: PlantisDesignTokens.fontSizeLG,
        fontWeight: PlantisDesignTokens.fontWeightSemiBold,
      ),
    ),
  );

  /// Text button theme for settings
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: PlantisDesignTokens.spacing4,
        vertical: PlantisDesignTokens.spacing3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusMD),
      ),
      foregroundColor: PlantisColors.primary,
      textStyle: const TextStyle(
        fontSize: PlantisDesignTokens.fontSizeBase,
        fontWeight: PlantisDesignTokens.fontWeightMedium,
      ),
    ),
  );

  // MARK: - Input Themes

  /// Input decoration theme for settings forms
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
      borderSide: const BorderSide(
        color: PlantisColors.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
      borderSide: const BorderSide(
        color: PlantisColors.error,
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
      borderSide: const BorderSide(
        color: PlantisColors.error,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: PlantisDesignTokens.spacing4,
      vertical: PlantisDesignTokens.spacing3,
    ),
  );

  // MARK: - Dialog Theme

  /// Dialog theme for settings modals
  static DialogTheme get dialogTheme => DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PlantisDesignTokens.radius2XL),
    ),
    elevation: PlantisDesignTokens.elevationXL,
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      fontSize: PlantisDesignTokens.fontSizeXL,
      fontWeight: PlantisDesignTokens.fontWeightBold,
      color: PlantisColors.textPrimary,
    ),
    contentTextStyle: const TextStyle(
      fontSize: PlantisDesignTokens.fontSizeBase,
      fontWeight: PlantisDesignTokens.fontWeightNormal,
      color: PlantisColors.textSecondary,
    ),
  );

  // MARK: - Switch Theme

  /// Switch theme for settings toggles
  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return PlantisColors.primary;
      }
      return Colors.grey.shade400;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return PlantisColors.primary.withOpacity(0.5);
      }
      return Colors.grey.shade300;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // MARK: - Helper Methods

  /// Get appropriate theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Apply settings-specific customizations to existing theme
  static ThemeData applySettingsCustomizations(ThemeData baseTheme) {
    return baseTheme.copyWith(
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      dialogTheme: dialogTheme,
      switchTheme: switchTheme,
    );
  }
}

// MARK: - Custom Theme Data Classes

/// Theme data for settings items
class SettingsItemThemeData {
  final double height;
  final EdgeInsets padding;
  final double iconSize;
  final double iconContainerSize;
  final double borderRadius;
  final Duration animationDuration;

  const SettingsItemThemeData({
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.iconContainerSize,
    required this.borderRadius,
    required this.animationDuration,
  });
}

/// Theme data for settings cards
class SettingsCardThemeData {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double elevation;
  final Duration expandAnimationDuration;
  final Duration hoverAnimationDuration;

  const SettingsCardThemeData({
    required this.padding,
    required this.margin,
    required this.borderRadius,
    required this.elevation,
    required this.expandAnimationDuration,
    required this.hoverAnimationDuration,
  });
}

/// Theme data for premium components
class PremiumThemeData {
  final Color primaryColor;
  final Color lightColor;
  final double badgeRadius;
  final double indicatorSize;
  final Duration glowAnimationDuration;
  final Duration rotateAnimationDuration;

  const PremiumThemeData({
    required this.primaryColor,
    required this.lightColor,
    required this.badgeRadius,
    required this.indicatorSize,
    required this.glowAnimationDuration,
    required this.rotateAnimationDuration,
  });
}