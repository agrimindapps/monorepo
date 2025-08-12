// Flutter

// Flutter imports:
import 'package:flutter/material.dart';

/// Service responsável pelas configurações de tema e cores
class VeiculosThemeService {
  // Cores de borda de cards
  static Color getCardBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
  }

  // Cores de fundo do avatar
  static Color getAvatarBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  // Cores de ícones
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  // Cores de fundo quando não há dados
  static Color getNoDataBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF424242)
        : const Color(0xFFF5F5F5);
  }

  // Cores de ícones informativos
  static Color getInfoIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade700;
  }

  // Cores para estados de sucesso
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade400
        : Colors.green.shade600;
  }

  // Cores para estados de erro
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade400
        : Colors.red.shade600;
  }

  // Cores para estados informativos
  static Color getInfoColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade400
        : Colors.blue.shade600;
  }

  // Cores de texto primário
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  // Cores de texto secundário
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade600;
  }
}
