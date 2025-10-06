import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'base_colors.dart';
import 'base_typography.dart';

/// Tema base que pode ser customizado por cada app
class BaseTheme {
  /// Constrói um tema claro com cores customizadas
  static ThemeData buildLightTheme({
    required Color primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    Map<String, Color>? customColors,
  }) {
    final secondary = secondaryColor ?? primaryColor;
    final textTheme = BaseTypography.textTheme(fontFamily);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: BaseColors.white,
        primaryContainer: Color.lerp(primaryColor, BaseColors.white, 0.8),
        onPrimaryContainer: primaryColor,
        
        secondary: secondary,
        onSecondary: BaseColors.white,
        secondaryContainer: Color.lerp(secondary, BaseColors.white, 0.8),
        onSecondaryContainer: secondary,
        
        tertiary: BaseColors.info,
        onTertiary: BaseColors.white,
        tertiaryContainer: BaseColors.infoLight,
        onTertiaryContainer: BaseColors.infoDark,
        
        error: BaseColors.error,
        onError: BaseColors.white,
        errorContainer: BaseColors.errorLight,
        onErrorContainer: BaseColors.errorDark,
        
        surface: BaseColors.surfaceLight,
        onSurface: BaseColors.textPrimaryLight,
        
        surfaceContainerHighest: BaseColors.dividerLight,
        surfaceContainerHigh: BaseColors.backgroundLight,
        
        outline: BaseColors.borderLight,
        outlineVariant: BaseColors.dividerLight,
        
        shadow: BaseColors.shadow,
        scrim: BaseColors.black,
      ),
      scaffoldBackgroundColor: BaseColors.backgroundLight,
      textTheme: textTheme.apply(
        bodyColor: BaseColors.textPrimaryLight,
        displayColor: BaseColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: BaseColors.surfaceLight,
        foregroundColor: BaseColors.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: BaseTypography.titleLarge.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(
          color: BaseColors.textPrimaryLight,
        ),
        actionsIconTheme: const IconThemeData(
          color: BaseColors.textPrimaryLight,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: BaseColors.surfaceLight,
        shadowColor: BaseColors.shadow,
        surfaceTintColor: BaseColors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: BaseColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: BaseTypography.button.copyWith(fontFamily: fontFamily),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: BaseTypography.button.copyWith(fontFamily: fontFamily),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: BaseTypography.button.copyWith(fontFamily: fontFamily),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BaseColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BaseColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BaseColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BaseColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BaseColors.error, width: 2),
        ),
        labelStyle: BaseTypography.bodyMedium.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textSecondaryLight,
        ),
        hintStyle: BaseTypography.bodyMedium.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textDisabledLight,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BaseColors.surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: BaseColors.textSecondaryLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: BaseTypography.labelSmall.copyWith(fontFamily: fontFamily),
        unselectedLabelStyle: BaseTypography.labelSmall.copyWith(fontFamily: fontFamily),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: BaseColors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: BaseColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: BaseColors.surfaceLight,
        selectedColor: Color.lerp(primaryColor, BaseColors.white, 0.8),
        disabledColor: BaseColors.dividerLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: BaseTypography.labelMedium.copyWith(fontFamily: fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: BaseColors.borderLight),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: BaseColors.surfaceLight,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        titleTextStyle: BaseTypography.headlineSmall.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textPrimaryLight,
        ),
        contentTextStyle: BaseTypography.bodyMedium.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textSecondaryLight,
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BaseColors.textPrimaryLight,
        contentTextStyle: BaseTypography.bodyMedium.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color.lerp(primaryColor, BaseColors.white, 0.8),
        circularTrackColor: Color.lerp(primaryColor, BaseColors.white, 0.8),
      ),
    );
  }
  
  /// Constrói um tema escuro com cores customizadas
  static ThemeData buildDarkTheme({
    required Color primaryColor,
    Color? secondaryColor,
    String? fontFamily,
    Map<String, Color>? customColors,
  }) {
    final secondary = secondaryColor ?? primaryColor;
    final textTheme = BaseTypography.textTheme(fontFamily);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: BaseColors.white,
        primaryContainer: Color.lerp(primaryColor, BaseColors.black, 0.6),
        onPrimaryContainer: Color.lerp(primaryColor, BaseColors.white, 0.8),
        
        secondary: secondary,
        onSecondary: BaseColors.black,
        secondaryContainer: Color.lerp(secondary, BaseColors.black, 0.6),
        onSecondaryContainer: Color.lerp(secondary, BaseColors.white, 0.8),
        
        tertiary: BaseColors.info,
        onTertiary: BaseColors.white,
        tertiaryContainer: BaseColors.infoDark,
        onTertiaryContainer: BaseColors.infoLight,
        
        error: BaseColors.error,
        onError: BaseColors.white,
        errorContainer: BaseColors.errorDark,
        onErrorContainer: BaseColors.errorLight,
        
        surface: BaseColors.surfaceDark,
        onSurface: BaseColors.textPrimaryDark,
        
        surfaceContainerHighest: BaseColors.dividerDark,
        surfaceContainerHigh: BaseColors.backgroundDark,
        
        outline: BaseColors.borderDark,
        outlineVariant: BaseColors.dividerDark,
        
        shadow: BaseColors.shadowDark,
        scrim: BaseColors.black,
      ),
      scaffoldBackgroundColor: BaseColors.backgroundDark,
      textTheme: textTheme.apply(
        bodyColor: BaseColors.textPrimaryDark,
        displayColor: BaseColors.textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: BaseColors.surfaceDark,
        foregroundColor: BaseColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: BaseTypography.titleLarge.copyWith(
          fontFamily: fontFamily,
          color: BaseColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: BaseColors.textPrimaryDark,
        ),
        actionsIconTheme: const IconThemeData(
          color: BaseColors.textPrimaryDark,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: BaseColors.surfaceDark,
        shadowColor: BaseColors.shadowDark,
        surfaceTintColor: BaseColors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: BaseColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: BaseTypography.button.copyWith(fontFamily: fontFamily),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BaseColors.surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: BaseColors.textSecondaryDark,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: BaseTypography.labelSmall.copyWith(fontFamily: fontFamily),
        unselectedLabelStyle: BaseTypography.labelSmall.copyWith(fontFamily: fontFamily),
      ),
    );
  }
}
