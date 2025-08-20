// Utilitário para cor de risco (pode ser incorporado ao controller futuramente)

// Flutter imports:
import 'package:flutter/material.dart';

class DensidadeOsseaUtils {
  static Color getColorForRisk(String resultado, bool isDark) {
    if (resultado.contains('Baixo risco')) {
      return isDark ? Colors.green.shade300 : Colors.green;
    } else if (resultado.contains('Risco moderado')) {
      return isDark ? Colors.amber.shade300 : Colors.amber;
    } else if (resultado.contains('Alto risco')) {
      return isDark ? Colors.orange.shade300 : Colors.orange;
    } else {
      return isDark ? Colors.red.shade300 : Colors.red;
    }
  }
}
