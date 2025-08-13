// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../../../core/utils/global_theme_helper.dart';

/// Service simplificado para gerenciamento de tema
/// Usa apenas o controlador global unificado
class ThemeService {
  // Singleton pattern
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();
  ThemeService._();

  // ========== OPERAÇÕES DE TEMA ==========

  /// Alterna tema usando o controlador global
  ThemeResult toggleTheme() {
    try {
      debugPrint('🎨 ThemeService: Alternando tema');

      GlobalThemeHelper.toggleTheme();
      debugPrint('✅ ThemeService: Tema alternado via GlobalThemeHelper');

      return const ThemeResult(
        success: true,
        method: 'GlobalThemeHelper',
        message: 'Tema alternado com sucesso',
      );
    } catch (e) {
      debugPrint('❌ ThemeService: Erro ao alternar tema: $e');
      return ThemeResult(
        success: false,
        error: e.toString(),
        message: 'Erro ao alternar tema',
      );
    }
  }

  /// Obtém estado atual do tema
  bool get isDarkTheme => GlobalThemeHelper.isDark;

  /// Obtém tema atual
  String get currentThemeName => isDarkTheme ? 'Escuro' : 'Claro';

  // ========== UTILITÁRIOS ==========

  /// Força atualização do tema
  void forceThemeUpdate() {
    try {
      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().forceThemeUpdate();
      }
    } catch (e) {
      debugPrint('⚠️ ThemeService: Erro ao forçar atualização: $e');
    }
  }

  /// Log de debug das informações do tema
  void logThemeInfo() {
    GlobalThemeHelper.logThemeInfo();
  }

  /// Reset do service (útil para testes)
  void reset() {
    _instance = null;
    GlobalThemeHelper.resetCache();
  }
}

/// Classe para resultado das operações de tema
class ThemeResult {
  final bool success;
  final String? method;
  final String? message;
  final String? error;

  const ThemeResult({
    required this.success,
    this.method,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'ThemeResult(success: $success, method: $method, message: $message, error: $error)';
  }
}
