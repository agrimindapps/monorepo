import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'app_text_styles.dart';

/// Application theme configuration using Design Tokens
/// This consolidates all theme-related constants and eliminates duplication
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Convenience color getters
  // Consider using DesignTokens directly for new code
  static Color get primaryColor => DesignTokens.primaryColor;
  static Color get secondaryColor => DesignTokens.secondaryColor;
  static Color get accentColor => DesignTokens.accentColor;
  static Color get backgroundColor => DesignTokens.backgroundColor;
  static Color get surfaceColor => DesignTokens.surfaceColor;
  static Color get errorColor => DesignTokens.errorColor;
  static Color get successColor => DesignTokens.successColor;
  static Color get warningColor => DesignTokens.warningColor;
  static Color get infoColor => DesignTokens.infoColor;
  static Color get textPrimaryColor => DesignTokens.textPrimaryColor;
  static Color get textSecondaryColor => DesignTokens.textSecondaryColor;
  static Color get textLightColor => DesignTokens.textLightColor;
  static Color get borderColor => DesignTokens.borderColor;
  static Color get dividerColor => DesignTokens.dividerColor;
  
  // Theme type enum
  static const light = ThemeMode.light;
  static const dark = ThemeMode.dark;
  static const system = ThemeMode.system;

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.primaryColor,
        secondary: DesignTokens.secondaryColor,
        surface: DesignTokens.surfaceColor,
        error: DesignTokens.errorColor,
        onPrimary: DesignTokens.textLightColor,
        onSecondary: DesignTokens.textLightColor,
        onSurface: DesignTokens.textPrimaryColor,
        onError: DesignTokens.textLightColor,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.primaryColor,
        foregroundColor: DesignTokens.textLightColor,
        elevation: DesignTokens.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryColor,
          foregroundColor: DesignTokens.textLightColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
          elevation: 1,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: DesignTokens.primaryColor),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.errorColor, width: 2),
        ),
        filled: true,
        fillColor: DesignTokens.surfaceColor,
        contentPadding: const EdgeInsets.all(16),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: DesignTokens.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: DesignTokens.dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: DesignTokens.textSecondaryColor,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.primaryColor,
        secondary: DesignTokens.secondaryColor,
        surface: DesignTokens.surfaceDarkColor,
        error: DesignTokens.errorColor,
        onPrimary: DesignTokens.textLightColor,
        onSecondary: DesignTokens.textLightColor,
        onSurface: DesignTokens.textLightColor,
        onError: DesignTokens.textLightColor,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.backgroundDarkColor,
        foregroundColor: DesignTokens.textLightColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
      ),
      
      // Button Themes (similar to light theme but with dark adaptations)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryColor,
          foregroundColor: DesignTokens.textLightColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.button,
          elevation: 1,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: DesignTokens.backgroundDarkColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}

