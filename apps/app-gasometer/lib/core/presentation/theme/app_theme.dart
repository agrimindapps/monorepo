import 'package:flutter/material.dart';

import '../../theme/gasometer_colors.dart';
import '../../theme/gasometer_theme.dart';

/// Wrapper para manter compatibilidade com código existente
/// Mapeia para o GasometerTheme atual
class AppTheme {
  /// Instância única para acesso estático
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();

  /// Cores do tema
  static AppColors get colors => AppColors._instance;

  /// Estilos de texto do tema
  static AppTextStyles get textStyles => AppTextStyles._instance;

  /// Tema claro
  static ThemeData get lightTheme => GasometerTheme.lightTheme;

  /// Tema escuro
  static ThemeData get darkTheme => GasometerTheme.darkTheme;

  /// Verifica se está no modo escuro
  static bool isDarkMode(BuildContext context) {
    return GasometerTheme.isDarkMode(context);
  }

  /// Retorna a cor primária baseada no tema atual
  static Color primaryColor(BuildContext context) {
    return GasometerTheme.primaryColor(context);
  }

  /// Retorna a cor de superficie baseada no tema atual
  static Color surfaceColor(BuildContext context) {
    return GasometerTheme.surfaceColor(context);
  }

  /// Retorna a cor de texto baseada no tema atual
  static Color textColor(BuildContext context) {
    return GasometerTheme.textColor(context);
  }
}

/// Classe para cores do tema com compatibility layer
class AppColors {
  static final AppColors _instance = AppColors._internal();
  factory AppColors() => _instance;
  AppColors._internal();

  // Cores primárias
  Color get primary => GasometerColors.primary;
  Color get primaryLight => GasometerColors.primaryLight;
  Color get primaryDark => GasometerColors.primaryDark;

  // Cores secundárias
  Color get secondary => GasometerColors.secondary;
  Color get secondaryLight => GasometerColors.secondaryLight;
  Color get secondaryDark => GasometerColors.secondaryDark;

  // Cores de status
  Color get success => GasometerColors.efficiency;
  Color get warning => GasometerColors.warning;
  Color get error => GasometerColors.danger;
  Color get info => GasometerColors.info;

  // Cores de superficie
  Color get surface => Colors.white;
  Color get surfaceVariant => Colors.grey.shade50;
  Color get onSurface => Colors.black87;
  Color get onSurfaceVariant => Colors.black54;

  // Cores de container de erro
  Color get errorContainer => GasometerColors.danger.withValues(alpha: 0.1);
  Color get onErrorContainer => GasometerColors.danger;

  // Cores de outline
  Color get outline => Colors.grey.shade300;
}

/// Classe para estilos de texto com compatibility layer
class AppTextStyles {
  static final AppTextStyles _instance = AppTextStyles._internal();
  factory AppTextStyles() => _instance;
  AppTextStyles._internal();

  // Display styles
  TextStyle? get displayLarge => const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  TextStyle? get displayMedium => const TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  TextStyle? get displaySmall => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Headline styles
  TextStyle? get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  TextStyle? get headlineMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  TextStyle? get headlineSmall => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  // Title styles
  TextStyle? get titleLarge => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  TextStyle? get titleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  TextStyle? get titleSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Label styles
  TextStyle? get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  TextStyle? get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  TextStyle? get labelSmall => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Body styles
  TextStyle? get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );

  TextStyle? get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  TextStyle? get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}