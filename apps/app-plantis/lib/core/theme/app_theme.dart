import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

class PlantisTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: PlantisColors.primary,
      onPrimary: Colors.white,
      primaryContainer: PlantisColors.primaryLight,
      onPrimaryContainer: PlantisColors.primaryDark,
      
      secondary: PlantisColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: PlantisColors.secondaryLight,
      onSecondaryContainer: PlantisColors.secondaryDark,
      
      tertiary: PlantisColors.info,
      onTertiary: Colors.white,
      tertiaryContainer: PlantisColors.infoLight,
      
      error: PlantisColors.error,
      onError: Colors.white,
      errorContainer: PlantisColors.errorLight,
      
      surface: PlantisColors.surface,
      onSurface: PlantisColors.textPrimary,
      
      surfaceContainerHighest: PlantisColors.divider,
      surfaceContainerHigh: PlantisColors.background,
      
      outline: PlantisColors.border,
      outlineVariant: PlantisColors.divider,
      
      shadow: PlantisColors.shadow,
    ),
    
    // Typography
    textTheme: const TextTheme(
      displayLarge: PlantisTypography.displayLarge,
      displayMedium: PlantisTypography.displayMedium,
      displaySmall: PlantisTypography.displaySmall,
      headlineLarge: PlantisTypography.headlineLarge,
      headlineMedium: PlantisTypography.headlineMedium,
      headlineSmall: PlantisTypography.headlineSmall,
      titleLarge: PlantisTypography.titleLarge,
      titleMedium: PlantisTypography.titleMedium,
      titleSmall: PlantisTypography.titleSmall,
      bodyLarge: PlantisTypography.bodyLarge,
      bodyMedium: PlantisTypography.bodyMedium,
      bodySmall: PlantisTypography.bodySmall,
      labelLarge: PlantisTypography.labelLarge,
      labelMedium: PlantisTypography.labelMedium,
      labelSmall: PlantisTypography.labelSmall,
    ).apply(
      bodyColor: PlantisColors.textPrimary,
      displayColor: PlantisColors.textPrimary,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: PlantisColors.surface,
      foregroundColor: PlantisColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: PlantisTypography.titleLarge,
      iconTheme: IconThemeData(
        color: PlantisColors.textPrimary,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: PlantisColors.surface,
      shadowColor: PlantisColors.shadow,
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PlantisColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: PlantisTypography.button,
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PlantisColors.primary,
        side: const BorderSide(color: PlantisColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: PlantisTypography.button,
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PlantisColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: PlantisTypography.button,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PlantisColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PlantisColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PlantisColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PlantisColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PlantisColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PlantisColors.error, width: 2),
      ),
      labelStyle: PlantisTypography.bodyMedium.copyWith(
        color: PlantisColors.textSecondary,
      ),
      hintStyle: PlantisTypography.bodyMedium.copyWith(
        color: PlantisColors.textDisabled,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PlantisColors.surface,
      selectedItemColor: PlantisColors.primary,
      unselectedItemColor: PlantisColors.textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: PlantisTypography.labelSmall,
      unselectedLabelStyle: PlantisTypography.labelSmall,
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PlantisColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: PlantisColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: PlantisColors.surface,
      selectedColor: PlantisColors.primaryLight,
      disabledColor: PlantisColors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: PlantisTypography.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PlantisColors.border),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: PlantisColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: PlantisTypography.headlineSmall.copyWith(
        color: PlantisColors.textPrimary,
      ),
      contentTextStyle: PlantisTypography.bodyMedium.copyWith(
        color: PlantisColors.textSecondary,
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PlantisColors.textPrimary,
      contentTextStyle: PlantisTypography.bodyMedium.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PlantisColors.primary,
      linearTrackColor: PlantisColors.primaryLight,
      circularTrackColor: PlantisColors.primaryLight,
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primary;
        }
        return PlantisColors.textDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primaryLight;
        }
        return PlantisColors.divider;
      }),
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: PlantisColors.border, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primary;
        }
        return PlantisColors.textSecondary;
      }),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: PlantisColors.primary,
      onPrimary: Colors.white,
      primaryContainer: PlantisColors.primaryDark,
      onPrimaryContainer: PlantisColors.primaryLight,
      
      secondary: PlantisColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: PlantisColors.secondaryDark,
      onSecondaryContainer: PlantisColors.secondaryLight,
      
      tertiary: PlantisColors.info,
      onTertiary: Colors.white,
      tertiaryContainer: PlantisColors.info,
      
      error: PlantisColors.error,
      onError: Colors.white,
      errorContainer: PlantisColors.error,
      
      surface: PlantisColors.surfaceDark,
      onSurface: PlantisColors.textPrimaryDark,
      
      surfaceContainerHighest: PlantisColors.backgroundDark,
      surfaceContainerHigh: PlantisColors.backgroundDark,
      
      outline: PlantisColors.textSecondaryDark,
      outlineVariant: PlantisColors.backgroundDark,
      
      shadow: Colors.black,
    ),
    
    // Apply dark theme overrides
    scaffoldBackgroundColor: PlantisColors.backgroundDark,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: PlantisColors.surfaceDark,
      foregroundColor: PlantisColors.textPrimaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: PlantisColors.surfaceDark,
    ),
  );
}