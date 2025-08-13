import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'gasometer_colors.dart';

/// Tema específico do GasOMeter usando BaseTheme
class GasometerTheme {
  /// Tema claro do GasOMeter
  static ThemeData get lightTheme => BaseTheme.buildLightTheme(
    primaryColor: GasometerColors.primary,
    secondaryColor: GasometerColors.secondary,
    fontFamily: 'Inter',
  ).copyWith(
    // Customizações específicas do GasOMeter
    appBarTheme: BaseTheme.buildLightTheme(
      primaryColor: GasometerColors.primary,
      secondaryColor: GasometerColors.secondary,
    ).appBarTheme.copyWith(
      backgroundColor: GasometerColors.primary,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),
    
    // FAB personalizado
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: GasometerColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // Bottom navigation personalizado
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: GasometerColors.primary,
      unselectedItemColor: GasometerColors.primaryDark,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Chip theme personalizado para combustíveis
    chipTheme: ChipThemeData(
      backgroundColor: GasometerColors.secondaryLight.withValues(alpha: 0.2),
      selectedColor: GasometerColors.primary,
      disabledColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    
    // Switch personalizado
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GasometerColors.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GasometerColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),
    
    // Progress indicator personalizado
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GasometerColors.primary,
      linearTrackColor: GasometerColors.primaryLight,
      circularTrackColor: GasometerColors.primaryLight,
    ),
    
    // Card theme personalizado para fuel cards
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: GasometerColors.primary.withValues(alpha: 0.1),
    ),
    
    // Elevated button personalizado
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GasometerColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  
  /// Tema escuro do GasOMeter
  static ThemeData get darkTheme => BaseTheme.buildDarkTheme(
    primaryColor: GasometerColors.primary,
    secondaryColor: GasometerColors.secondary,
    fontFamily: 'Inter',
  ).copyWith(
    // Customizações específicas do GasOMeter para modo escuro
    appBarTheme: BaseTheme.buildDarkTheme(
      primaryColor: GasometerColors.primary,
      secondaryColor: GasometerColors.secondary,
    ).appBarTheme.copyWith(
      backgroundColor: GasometerColors.primaryDark,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),
    
    // FAB para modo escuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: GasometerColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // Bottom navigation para modo escuro
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: GasometerColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Switch para modo escuro
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GasometerColors.primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GasometerColors.primary;
        }
        return Colors.grey.shade800;
      }),
    ),
    
    // Progress indicator para modo escuro
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GasometerColors.primaryLight,
      linearTrackColor: GasometerColors.primary,
      circularTrackColor: GasometerColors.primary,
    ),
    
    // Card theme para modo escuro
    cardTheme: CardThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2D2D2D),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
    
    // Elevated button para modo escuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GasometerColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  
  /// Retorna as cores do tema baseado no modo
  static GasometerColors colorsFor(BuildContext context) {
    return GasometerColors();
  }
  
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
  
  /// Retorna a cor específica para um tipo de combustível
  static Color fuelColor(String fuelType) {
    return GasometerColors.getFuelColor(fuelType);
  }
}