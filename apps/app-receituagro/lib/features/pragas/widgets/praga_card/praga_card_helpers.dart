import 'package:app_receituagro/core/di/injection.dart' as di;
import 'package:flutter/material.dart';

import '../../presentation/services/pragas_type_service.dart';

/// Classe utilitária com helpers para PragaCard
///
/// Refactored to use PragasTypeService for type-related logic (SOLID compliance)
///
/// Responsabilidades:
/// - Cores de card e temas (UI theming)
/// - Delegação para PragasTypeService para lógica de tipos
class PragaCardHelpers {
  // Lazy-initialized service instance
  static PragasTypeService? _typeService;

  static PragasTypeService get _service {
    _typeService ??= di.getIt<PragasTypeService>();
    return _typeService!;
  }

  /// Retorna a cor do card baseada no tema
  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF222228) : Colors.white;
  }

  /// Retorna a cor baseada no tipo de praga
  /// Delegates to PragasTypeService
  static Color getTypeColor(String tipoPraga) {
    return _service.getTypeColor(tipoPraga);
  }

  /// Retorna o ícone baseado no tipo de praga
  /// Delegates to PragasTypeService
  static IconData getTypeIcon(String tipoPraga) {
    return _service.getTypeIcon(tipoPraga);
  }

  /// Retorna o texto do tipo de praga
  /// Delegates to PragasTypeService
  static String getTypeText(String tipoPraga) {
    return _service.getTypeLabel(tipoPraga);
  }

  /// Retorna cor de texto baseada no tema
  static Color getTextColor(bool isDarkMode, {bool isSecondary = false}) {
    if (isDarkMode) {
      return isSecondary ? Colors.grey.shade300 : Colors.white;
    }
    return isSecondary ? Colors.grey.shade600 : Colors.black87;
  }

  /// Retorna cor de ícones baseada no tema
  static Color getIconColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;
  }
}
