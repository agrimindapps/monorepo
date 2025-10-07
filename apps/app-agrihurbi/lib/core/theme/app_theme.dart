import 'package:flutter/material.dart';

import 'app_text_styles.dart';
import 'design_tokens.dart';

/// A centralized class for the application's theme configuration.
///
/// This class constructs the [ThemeData] for both light and dark modes using
/// the constants defined in [DesignTokens] and [AppTextStyles], ensuring a
/// consistent and maintainable design system.
class AppTheme {
  AppTheme._();

  /// Exposes the available theme modes.
  static const light = ThemeMode.light;
  static const dark = ThemeMode.dark;
  static const system = ThemeMode.system;

  /// The light theme configuration for the application.
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      colors: _lightColorScheme,
    );
  }

  /// The dark theme configuration for the application.
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: _darkColorScheme,
    );
  }

  /// The base color scheme for the light theme.
  static const _lightColorScheme = ColorScheme.light(
    primary: DesignTokens.Colors.primary,
    secondary: DesignTokens.Colors.secondary,
    surface: DesignTokens.Colors.surface,
    background: DesignTokens.Colors.background,
    error: DesignTokens.Colors.error,
    onPrimary: DesignTokens.Colors.textLight,
    onSecondary: DesignTokens.Colors.textLight,
    onSurface: DesignTokens.Colors.textPrimary,
    onBackground: DesignTokens.Colors.textPrimary,
    onError: DesignTokens.Colors.textLight,
  );

  /// The base color scheme for the dark theme.
  static const _darkColorScheme = ColorScheme.dark(
    primary: DesignTokens.Colors.primary,
    secondary: DesignTokens.Colors.secondary,
    surface: DesignTokens.Colors.surfaceDark,
    background: DesignTokens.Colors.backgroundDark,
    error: DesignTokens.Colors.error,
    onPrimary: DesignTokens.Colors.textLight,
    onSecondary: DesignTokens.Colors.textLight,
    onSurface: DesignTokens.Colors.textLight,
    onBackground: DesignTokens.Colors.textLight,
    onError: DesignTokens.Colors.textLight,
  );

  /// A private helper method to build a [ThemeData] object.
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colors,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _buildTextTheme(colors.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? colors.surface : colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: DesignTokens.Elevations.none,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: colors.onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.Spacing.lg,
            vertical: DesignTokens.Spacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: DesignTokens.Borders.button),
          textStyle: AppTextStyles.button,
          elevation: DesignTokens.Elevations.sm,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.Spacing.lg,
            vertical: DesignTokens.Spacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: DesignTokens.Borders.button),
          side: BorderSide(color: colors.primary),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.Spacing.md,
            vertical: DesignTokens.Spacing.sm,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: DesignTokens.Borders.input,
          borderSide: BorderSide(color: DesignTokens.Colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.Borders.input,
          borderSide: BorderSide(color: DesignTokens.Colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.Borders.input,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.Borders.input,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.Borders.input,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.all(DesignTokens.Spacing.md),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: DesignTokens.Elevations.md,
        shape: const RoundedRectangleBorder(borderRadius: DesignTokens.Borders.card),
        margin: const EdgeInsets.all(DesignTokens.Spacing.sm),
      ),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.Colors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: isDark ? DesignTokens.Colors.textLight : DesignTokens.Colors.textSecondary,
        size: DesignTokens.IconSizes.md,
      ),
      textTheme: textTheme,
    );
  }

  /// Builds the [TextTheme] by applying the correct text color.
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: textColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: textColor),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: textColor.withOpacity(0.7),
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: textColor.withOpacity(0.7),
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: textColor.withOpacity(0.7),
      ),
    );
  }
}