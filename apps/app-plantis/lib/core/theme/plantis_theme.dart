import 'package:flutter/material.dart';

import 'plantis_colors.dart';

/// Tema específico do Plantis
class PlantisTheme {
  /// Tema claro do Plantis
  static ThemeData get lightTheme =>
      ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: PlantisColors.primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: PlantisColors.primary,
              secondary: PlantisColors.secondary,
            ),
      ).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: PlantisColors.primary,
          unselectedItemColor: PlantisColors.primaryDark,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
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
        chipTheme: ChipThemeData(
          backgroundColor: PlantisColors.secondaryLight,
          selectedColor: PlantisColors.primary,
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
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PlantisColors.primary,
          linearTrackColor: PlantisColors.primaryLight,
          circularTrackColor: PlantisColors.primaryLight,
        ),
        cardTheme: CardThemeData(
          elevation: 0, // Controlamos a sombra manualmente
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: Colors.transparent, // Sem sombra padrão
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: PlantisColors.primary,
          headerForegroundColor: Colors.white,
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlantisColors.primary;
            }
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return null;
          }),
          todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
          todayForegroundColor: WidgetStateProperty.all(PlantisColors.primary),
          todayBorder: const BorderSide(color: PlantisColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          dialBackgroundColor: PlantisColors.primaryLight.withValues(
            alpha: 0.2,
          ),
          hourMinuteColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlantisColors.primary.withValues(alpha: 0.2);
            }
            return Colors.grey.withValues(alpha: 0.1);
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(8),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(8),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      );

  /// Tema escuro do Plantis
  static ThemeData get darkTheme =>
      ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: PlantisColors.primary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: PlantisColors.primary,
              secondary: PlantisColors.secondary,
            ),
      ).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: PlantisColors.primaryDark,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: CircleBorder(),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: PlantisColors.primaryLight,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
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
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PlantisColors.primaryLight,
          linearTrackColor: PlantisColors.primary,
          circularTrackColor: PlantisColors.primary,
        ),
        cardTheme: CardThemeData(
          elevation: 0, // Controlamos a sombra manualmente
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF2D2D2D),
          shadowColor: Colors.transparent, // Sem sombra padrão
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF2D2D2D),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: const Color(0xFF2D2D2D),
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: PlantisColors.primaryDark,
          headerForegroundColor: Colors.white,
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlantisColors.primary;
            }
            return Colors.transparent;
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return null;
          }),
          todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
          todayForegroundColor: WidgetStateProperty.all(
            PlantisColors.primaryLight,
          ),
          todayBorder: const BorderSide(
            color: PlantisColors.primaryLight,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFF2D2D2D),
          dialBackgroundColor: PlantisColors.primary.withValues(alpha: 0.2),
          hourMinuteColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlantisColors.primary.withValues(alpha: 0.3);
            }
            return Colors.grey.withValues(alpha: 0.2);
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF2D2D2D),
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF2D2D2D)),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(8),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF2D2D2D)),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(8),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
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
