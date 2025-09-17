import 'package:flutter/material.dart';

import 'receituagro_colors.dart';

/// Tema específico do ReceitaAgro
class ReceitaAgroTheme {
  /// Tema claro do ReceitaAgro
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: ReceitaAgroColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ReceitaAgroColors.primary,
      secondary: ReceitaAgroColors.secondary,
    ),
  ).copyWith(
    // Customizações específicas do ReceitaAgro
    appBarTheme: const AppBarTheme(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),
    
    // FAB personalizado
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // Bottom navigation personalizado
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ReceitaAgroColors.primary,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Chip theme personalizado
    chipTheme: ChipThemeData(
      backgroundColor: ReceitaAgroColors.secondaryLight,
      selectedColor: ReceitaAgroColors.primary,
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
          return ReceitaAgroColors.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ReceitaAgroColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),
    
    // Progress indicator personalizado
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ReceitaAgroColors.primary,
      linearTrackColor: ReceitaAgroColors.primaryLight,
      circularTrackColor: ReceitaAgroColors.primaryLight,
    ),
  );
  
  /// Tema escuro do ReceitaAgro
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: ReceitaAgroColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ReceitaAgroColors.primary,
      secondary: ReceitaAgroColors.secondary,
    ),
  ).copyWith(
    // Customizações específicas do ReceitaAgro para modo escuro
    appBarTheme: const AppBarTheme(
      backgroundColor: ReceitaAgroColors.primaryDark,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),
    
    // FAB para modo escuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    
    // Bottom navigation para modo escuro
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: ReceitaAgroColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Switch para modo escuro
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ReceitaAgroColors.primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ReceitaAgroColors.primary;
        }
        return Colors.grey.shade800;
      }),
    ),
    
    // Progress indicator para modo escuro
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ReceitaAgroColors.primaryLight,
      linearTrackColor: ReceitaAgroColors.primary,
      circularTrackColor: ReceitaAgroColors.primary,
    ),
  );
  
  /// Retorna as cores do tema baseado no modo
  static ReceitaAgroColors colorsFor(BuildContext context) {
    return ReceitaAgroColors();
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
}