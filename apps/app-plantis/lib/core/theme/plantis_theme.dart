import 'package:flutter/material.dart';

import 'plantis_colors.dart';

/// Tema específico do Plantis
class PlantisTheme {
  /// Tema claro do Plantis
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: PlantisColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: PlantisColors.primary,
      secondary: PlantisColors.secondary,
    ),
  ).copyWith(
    // Customizações específicas do Plantis
    appBarTheme: const AppBarTheme(
      backgroundColor: PlantisColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),

    // FAB personalizado
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PlantisColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Bottom navigation personalizado
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: PlantisColors.primary,
      unselectedItemColor: PlantisColors.primaryDark,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Navigation bar personalizado (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: PlantisColors.primary.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PlantisColors.primary);
        }
        return IconThemeData(
          color: PlantisColors.primaryDark.withValues(alpha: 0.6),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: PlantisColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: PlantisColors.primaryDark.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      elevation: 8,
    ),

    // Chip theme personalizado para plantas
    chipTheme: ChipThemeData(
      backgroundColor: PlantisColors.secondaryLight,
      selectedColor: PlantisColors.primary,
      disabledColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),

    // Switch personalizado
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primaryLight;
        }
        return Colors.grey.shade300;
      }),
    ),

    // Progress indicator personalizado
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PlantisColors.primary,
      linearTrackColor: PlantisColors.primaryLight,
      circularTrackColor: PlantisColors.primaryLight,
    ),

    // Card theme baseado no mockup - elevação e sombras aprimoradas
    cardTheme: CardThemeData(
      elevation: 0, // Controlamos a sombra manualmente
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.transparent, // Sem sombra padrão
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Scaffold theme baseado no mockup
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );

  /// Tema escuro do Plantis
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: PlantisColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: PlantisColors.primary,
      secondary: PlantisColors.secondary,
    ),
  ).copyWith(
    // Customizações específicas do Plantis para modo escuro
    appBarTheme: const AppBarTheme(
      backgroundColor: PlantisColors.primaryDark,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),

    // FAB para modo escuro
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PlantisColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),

    // Bottom navigation para modo escuro
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: PlantisColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Navigation bar para modo escuro (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: PlantisColors.primaryLight.withValues(alpha: 0.3),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PlantisColors.primaryLight);
        }
        return IconThemeData(color: Colors.grey.shade600);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: PlantisColors.primaryLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      elevation: 8,
    ),

    // Switch para modo escuro
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primaryLight;
        }
        return Colors.grey.shade600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PlantisColors.primary;
        }
        return Colors.grey.shade800;
      }),
    ),

    // Progress indicator para modo escuro
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PlantisColors.primaryLight,
      linearTrackColor: PlantisColors.primary,
      circularTrackColor: PlantisColors.primary,
    ),

    // Card theme para modo escuro baseado no mockup
    cardTheme: CardThemeData(
      elevation: 0, // Controlamos a sombra manualmente
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2D2D2D),
      shadowColor: Colors.transparent, // Sem sombra padrão
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Scaffold theme para modo escuro
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
  );

  /// Retorna as cores do tema baseado no modo
  static PlantisColors colorsFor(BuildContext context) {
    return PlantisColors();
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
