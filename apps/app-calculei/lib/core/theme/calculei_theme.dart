import 'package:flutter/material.dart';

import 'calculei_colors.dart';

/// Tema do Calculei otimizado
class CalculeiTheme {
  /// Tema claro simplificado
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: CalculeiColors.primary,
      onPrimary: Colors.white,
      secondary: CalculeiColors.secondary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceContainerHighest: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Color(0xFFF8F9FA),
      surfaceContainerLow: Color(0xFFFCFCFC),
      surfaceContainerLowest: Colors.white,
      inverseSurface: Color(0xFF1C1C1E),
      onInverseSurface: Colors.white,
      error: Color(0xFFF44336),
      onError: Colors.white,
      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFF5F5F5),
      shadow: Color(0x1F000000),
      scrim: Color(0x80000000),
      inversePrimary: CalculeiColors.primaryLight,
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: CalculeiColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CalculeiColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: CalculeiColors.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: CalculeiColors.primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: CalculeiColors.primary,
            size: 24,
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
            color: CalculeiColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: CalculeiColors.primary.withValues(alpha: 0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CalculeiColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CalculeiColors.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CalculeiColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CalculeiColors.primary,
      linearTrackColor: CalculeiColors.primaryLight,
      circularTrackColor: CalculeiColors.primaryLight,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CalculeiColors.secondaryLight.withValues(alpha: 0.2),
      selectedColor: CalculeiColors.primary,
      disabledColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF1A1C1E),
      textColor: Color(0xFF1A1C1E),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CalculeiColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF44336)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF616161),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: CalculeiColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  /// Tema escuro simplificado
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: CalculeiColors.primary,
      onPrimary: Colors.white,
      secondary: CalculeiColors.secondary,
      onSecondary: Colors.white,
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF2D2D2D),
      surfaceContainer: Color(0xFF242424),
      surfaceContainerHigh: Color(0xFF2A2A2A),
      surfaceContainerLow: Color(0xFF1F1F1F),
      surfaceContainerLowest: Color(0xFF0F0F0F),
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      error: Color(0xFFF44336),
      onError: Colors.white,
      outline: Color(0xFF4A4A4A),
      outlineVariant: Color(0xFF2A2A2A),
      shadow: Color(0x4F000000),
      scrim: Color(0x80000000),
      inversePrimary: CalculeiColors.primaryLight,
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: CalculeiColors.primaryDark,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CalculeiColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: CalculeiColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: CalculeiColors.primaryLight.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: CalculeiColors.primaryLight,
            size: 24,
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
            color: CalculeiColors.primaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2D2D2D),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CalculeiColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CalculeiColors.primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CalculeiColors.primary;
        }
        return Colors.grey.shade800;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: CalculeiColors.primaryLight,
      linearTrackColor: CalculeiColors.primary,
      circularTrackColor: CalculeiColors.primary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CalculeiColors.secondaryLight.withValues(alpha: 0.2),
      selectedColor: CalculeiColors.primary,
      disabledColor: Colors.grey.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFFE2E3E3),
      textColor: Color(0xFFE2E3E3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A4A4A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A4A4A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: CalculeiColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF44336)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: CalculeiColors.primaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
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
