import 'package:flutter/material.dart';

import 'minigames_colors.dart';

/// Tema do MiniGames - Vibrante e colorido para jogos
class MinigamesTheme {
  MinigamesTheme._();

  // ============================================================================
  // Tema Claro
  // ============================================================================
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: MinigamesColors.primary,
      onPrimary: Colors.white,
      primaryContainer: MinigamesColors.primaryLight,
      onPrimaryContainer: MinigamesColors.primaryDark,
      secondary: MinigamesColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: MinigamesColors.secondaryLight,
      onSecondaryContainer: MinigamesColors.secondaryDark,
      tertiary: MinigamesColors.accent,
      onTertiary: Colors.black,
      tertiaryContainer: MinigamesColors.accentLight,
      onTertiaryContainer: MinigamesColors.accentDark,
      surface: MinigamesColors.surfaceLight,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: Colors.white,
      surfaceContainer: Color(0xFFF8F5FF),
      surfaceContainerHigh: Color(0xFFF0EBFF),
      surfaceContainerLow: Color(0xFFFCFAFF),
      surfaceContainerLowest: Colors.white,
      error: MinigamesColors.error,
      onError: Colors.white,
      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFF5F5F5),
      shadow: Color(0x1F7C4DFF),
    ),
  ).copyWith(
    scaffoldBackgroundColor: MinigamesColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: MinigamesColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
        letterSpacing: 0.5,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MinigamesColors.accent,
      foregroundColor: Colors.black,
      elevation: 8,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: MinigamesColors.primary,
      unselectedItemColor: Colors.grey.shade500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: MinigamesColors.primaryLight.withValues(alpha: 0.3),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: MinigamesColors.primary,
            size: 26,
          );
        }
        return IconThemeData(
          color: Colors.grey.shade500,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: MinigamesColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          );
        }
        return TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        );
      }),
      elevation: 8,
      height: 80,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      shadowColor: MinigamesColors.primary.withValues(alpha: 0.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MinigamesColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MinigamesColors.primary,
        side: const BorderSide(color: MinigamesColors.primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MinigamesColors.primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: MinigamesColors.primary,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MinigamesColors.primaryLight.withValues(alpha: 0.2),
      selectedColor: MinigamesColors.primary,
      disabledColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
        fontFamily: 'Inter',
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MinigamesColors.primaryDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MinigamesColors.primary,
      linearTrackColor: MinigamesColors.primaryLight,
      circularTrackColor: MinigamesColors.primaryLight,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: MinigamesColors.primary,
      inactiveTrackColor: MinigamesColors.primaryLight.withValues(alpha: 0.3),
      thumbColor: MinigamesColors.primary,
      overlayColor: MinigamesColors.primary.withValues(alpha: 0.2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MinigamesColors.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MinigamesColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: MinigamesColors.primary,
      textColor: Color(0xFF1A1A2E),
    ),
  );

  // ============================================================================
  // Tema Escuro
  // ============================================================================
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: MinigamesColors.primaryLight,
      onPrimary: Colors.black,
      primaryContainer: MinigamesColors.primaryDark,
      onPrimaryContainer: MinigamesColors.primaryLight,
      secondary: MinigamesColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: MinigamesColors.secondaryDark,
      onSecondaryContainer: MinigamesColors.secondaryLight,
      tertiary: MinigamesColors.accent,
      onTertiary: Colors.black,
      tertiaryContainer: MinigamesColors.accentDark,
      onTertiaryContainer: MinigamesColors.accentLight,
      surface: MinigamesColors.surfaceDark,
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF2D2D44),
      surfaceContainer: Color(0xFF1E1E32),
      surfaceContainerHigh: Color(0xFF252540),
      surfaceContainerLow: Color(0xFF1A1A2E),
      surfaceContainerLowest: Color(0xFF12121F),
      error: MinigamesColors.errorLight,
      onError: Colors.black,
      outline: Color(0xFF4A4A5A),
      outlineVariant: Color(0xFF2A2A3A),
      shadow: Color(0x4F000000),
    ),
  ).copyWith(
    scaffoldBackgroundColor: MinigamesColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E32),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
        letterSpacing: 0.5,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MinigamesColors.accent,
      foregroundColor: Colors.black,
      elevation: 8,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E32),
      selectedItemColor: MinigamesColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E32),
      indicatorColor: MinigamesColors.primaryLight.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: MinigamesColors.primaryLight,
            size: 26,
          );
        }
        return IconThemeData(
          color: Colors.grey.shade600,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: MinigamesColors.primaryLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          );
        }
        return TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        );
      }),
      elevation: 8,
      height: 80,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF1E1E32),
      shadowColor: Colors.black.withValues(alpha: 0.4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MinigamesColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MinigamesColors.primaryLight,
        side: const BorderSide(color: MinigamesColors.primaryLight, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MinigamesColors.primaryLight,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: MinigamesColors.primaryLight,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MinigamesColors.primaryDark.withValues(alpha: 0.3),
      selectedColor: MinigamesColors.primaryLight,
      disabledColor: Colors.grey.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E32),
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Inter',
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MinigamesColors.primaryDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MinigamesColors.primaryLight,
      linearTrackColor: MinigamesColors.primaryDark,
      circularTrackColor: MinigamesColors.primaryDark,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: MinigamesColors.primaryLight,
      inactiveTrackColor: MinigamesColors.primaryDark.withValues(alpha: 0.3),
      thumbColor: MinigamesColors.primaryLight,
      overlayColor: MinigamesColors.primaryLight.withValues(alpha: 0.2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MinigamesColors.primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MinigamesColors.primary;
        }
        return Colors.grey.shade800;
      }),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: MinigamesColors.primaryLight,
      textColor: Colors.white,
    ),
  );

  // ============================================================================
  // Helpers
  // ============================================================================
  
  /// Verifica se está no modo escuro
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Retorna a cor primária baseada no tema atual
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Retorna a cor de superficie baseada no tema atual
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Retorna a cor de texto baseada no tema atual
  static Color textColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}
