import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'design_tokens.dart';

/// A centralized class for the application's theme configuration.
///
/// This class constructs the [ThemeData] for both light and dark modes using
/// the constants defined in [GasometerDesignTokens] and [AppTextStyles].
class AppTheme {
  AppTheme._();

  /// The light theme configuration for the application.
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        colors: _lightColorScheme,
      );

  /// The dark theme configuration for the application.
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        colors: _darkColorScheme,
      );

  /// The base color scheme for the light theme.
  static const _lightColorScheme = ColorScheme.light(
    primary: GasometerDesignTokens.Colors.primary,
    onPrimary: GasometerDesignTokens.Colors.textOnPrimary,
    secondary: GasometerDesignTokens.Colors.secondary,
    onSecondary: GasometerDesignTokens.Colors.textOnPrimary,
    surface: GasometerDesignTokens.Colors.surface,
    onSurface: GasometerDesignTokens.Colors.textPrimary,
    background: GasometerDesignTokens.Colors.background,
    onBackground: GasometerDesignTokens.Colors.textPrimary,
    error: GasometerDesignTokens.Colors.error,
    onError: GasometerDesignTokens.Colors.textOnPrimary,
    outline: GasometerDesignTokens.Colors.neutral300,
    shadow: GasometerDesignTokens.Colors.neutral900,
  );

  /// The base color scheme for the dark theme.
  static const _darkColorScheme = ColorScheme.dark(
    primary: GasometerDesignTokens.Colors.primaryLight,
    onPrimary: GasometerDesignTokens.Colors.textPrimary,
    secondary: GasometerDesignTokens.Colors.secondaryLight,
    onSecondary: GasometerDesignTokens.Colors.textPrimary,
    surface: GasometerDesignTokens.Colors.neutral700,
    onSurface: GasometerDesignTokens.Colors.textOnPrimary,
    background: GasometerDesignTokens.Colors.neutral900,
    onBackground: GasometerDesignTokens.Colors.textOnPrimary,
    error: GasometerDesignTokens.Colors.error,
    onError: GasometerDesignTokens.Colors.textOnPrimary,
    outline: GasometerDesignTokens.Colors.neutral500,
    shadow: GasometerDesignTokens.Colors.neutral900,
  );

  /// A private helper to build a [ThemeData] object.
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colors,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? colors.surface : colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: GasometerDesignTokens.Elevations.sm,
        titleTextStyle: AppTextStyles.title.copyWith(color: colors.onPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: GasometerDesignTokens.Elevations.lg,
        shape: const CircleBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withOpacity(GasometerDesignTokens.Opacities.secondary),
        elevation: GasometerDesignTokens.Elevations.lg,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        elevation: GasometerDesignTokens.Elevations.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.xl),
        ),
        color: colors.surface,
        shadowColor: colors.shadow.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: GasometerDesignTokens.Elevations.sm,
          padding: const EdgeInsets.symmetric(
            horizontal: GasometerDesignTokens.Spacing.xl,
            vertical: GasometerDesignTokens.Spacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.lg),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.primary
              : colors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colors.primary.withOpacity(0.5)
              : colors.surfaceVariant;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primary.withOpacity(0.2),
        circularTrackColor: colors.primary.withOpacity(0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.secondary.withOpacity(0.2),
        selectedColor: colors.primary,
        disabledColor: colors.onSurface.withOpacity(GasometerDesignTokens.Opacities.disabled),
        padding: const EdgeInsets.symmetric(
          horizontal: GasometerDesignTokens.Spacing.md,
          vertical: GasometerDesignTokens.Spacing.sm,
        ),
        labelStyle: AppTextStyles.label,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.xxl),
          side: BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onSurface,
        textColor: colors.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.all(GasometerDesignTokens.Spacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.md),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.md),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.md),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GasometerDesignTokens.Radii.md),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      textTheme: _buildTextTheme(colors.onSurface),
    );
  }

  /// Builds the [TextTheme] by applying the correct base color.
  static TextTheme _buildTextTheme(Color onSurfaceColor) {
    return TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: onSurfaceColor),
      displayMedium: AppTextStyles.display.copyWith(fontSize: 50, color: onSurfaceColor),
      displaySmall: AppTextStyles.display.copyWith(fontSize: 42, color: onSurfaceColor),
      headlineLarge: AppTextStyles.headline.copyWith(color: onSurfaceColor),
      headlineMedium: AppTextStyles.headline.copyWith(fontSize: 28, color: onSurfaceColor),
      headlineSmall: AppTextStyles.headline.copyWith(fontSize: 24, color: onSurfaceColor),
      titleLarge: AppTextStyles.title.copyWith(color: onSurfaceColor),
      titleMedium: AppTextStyles.subtitle.copyWith(color: onSurfaceColor),
      titleSmall: AppTextStyles.subtitle.copyWith(fontSize: 14, color: onSurfaceColor),
      bodyLarge: AppTextStyles.body.copyWith(fontSize: 16, color: onSurfaceColor),
      bodyMedium: AppTextStyles.body.copyWith(color: onSurfaceColor),
      bodySmall: AppTextStyles.caption.copyWith(color: onSurfaceColor),
      labelLarge: AppTextStyles.button.copyWith(color: onSurfaceColor),
      labelMedium: AppTextStyles.label.copyWith(color: onSurfaceColor),
      labelSmall: AppTextStyles.overline.copyWith(color: onSurfaceColor),
    );
  }
}