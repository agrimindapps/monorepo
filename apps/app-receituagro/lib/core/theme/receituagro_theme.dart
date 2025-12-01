import 'package:flutter/material.dart';

import 'receituagro_colors.dart';

/// Tema específico do ReceitaAgro
class ReceitaAgroTheme {
  const ReceitaAgroTheme._(); // Private constructor
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
      surface: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHighest: Colors.grey.shade100,
      surfaceContainerHigh: Colors.grey.shade50,
      // Corrige cores de texto para evitar o amarelo do Material 3
      onSurface: const Color(0xFF212121), // Texto primário escuro
      onSurfaceVariant: const Color(0xFF616161), // Texto secundário
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Cor de fundo das páginas
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ReceitaAgroColors.primary,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: false, // Oculta labels dos inativos
      showSelectedLabels: true,    // Mostra label do ativo
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: ReceitaAgroColors.secondaryLight,
      selectedColor: ReceitaAgroColors.primary,
      disabledColor: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
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
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ReceitaAgroColors.primary,
      linearTrackColor: ReceitaAgroColors.primaryLight,
      circularTrackColor: ReceitaAgroColors.primaryLight,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE8E8E8), // Mais próximo do fundo mas ainda visível
      thickness: 1,
      space: 1,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      shadowColor: Colors.black12,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
      surface: const Color(0xFF1C1C1E),
      surfaceContainer: const Color(0xFF2C2C2E),
      surfaceContainerHighest: const Color(0xFF3A3A3C),
      surfaceContainerHigh: const Color(0xFF2C2C2E),
      surfaceContainerLow: const Color(0xFF1C1C1E),
      // Corrige cores de texto para modo escuro
      onSurface: const Color(0xFFE0E0E0), // Texto primário claro
      onSurfaceVariant: const Color(0xFFBDBDBD), // Texto secundário
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
  ).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: ReceitaAgroColors.primaryDark,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ReceitaAgroColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: ReceitaAgroColors.primaryLight,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: false, // Oculta labels dos inativos
      showSelectedLabels: true,    // Mostra label do ativo
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
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
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ReceitaAgroColors.primaryLight,
      linearTrackColor: ReceitaAgroColors.primary,
      circularTrackColor: ReceitaAgroColors.primary,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade700,
      thickness: 1,
      space: 1,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2C2C2E),
      shadowColor: Colors.black26,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
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
