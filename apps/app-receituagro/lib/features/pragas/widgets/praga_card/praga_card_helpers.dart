import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Classe utilitária com helpers para PragaCard
/// 
/// Responsabilidades:
/// - Cálculos de cores baseadas no tipo de praga
/// - Mapeamento de ícones
/// - Textos de tipos
/// - Cores de card e temas
class PragaCardHelpers {
  /// Retorna a cor do card baseada no tema
  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF222228) : Colors.white;
  }

  /// Retorna a cor baseada no tipo de praga
  static Color getTypeColor(String tipoPraga) {
    switch (tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935);
      case '2': // Doenças
        return const Color(0xFFFF9800);
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }

  /// Retorna o ícone baseado no tipo de praga
  static IconData getTypeIcon(String tipoPraga) {
    switch (tipoPraga) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.triangleExclamation;
    }
  }

  /// Retorna o texto do tipo de praga
  static String getTypeText(String tipoPraga) {
    switch (tipoPraga) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta Daninha';
      default:
        return 'Praga';
    }
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