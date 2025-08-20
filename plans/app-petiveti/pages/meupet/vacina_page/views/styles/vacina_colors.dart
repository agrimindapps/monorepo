// Flutter imports:
import 'package:flutter/material.dart';

class VacinaColors {
  // Status colors for vaccines (theme-aware)
  static Color atrasada(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade300
        : Colors.red;
  }
  
  static Color proximaDoVencimento(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade300
        : Colors.orange;
  }
  
  static Color emDia(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.green;
  }
  
  // Text colors for status (theme-aware)
  static Color textoAtrasada(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade200
        : Colors.red.shade700;
  }
  
  static Color textoProximaDoVencimento(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade200
        : Colors.orange.shade700;
  }
  
  static Color textoEmDia(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }
  
  // Background colors for sections (theme-aware)
  static Color fundoAtrasada(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade900.withValues(alpha: 0.2)
        : Colors.red.shade50;
  }
  
  static Color fundoProximaDoVencimento(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.amber.shade900.withValues(alpha: 0.2)
        : Colors.amber.shade50;
  }
  
  // Error and status colors (theme-aware)
  static Color erro(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade300
        : Colors.red.shade400;
  }
  
  static Color erroTexto(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade200
        : Colors.red.shade700;
  }
  
  // General colors (theme-aware)
  static Color cinza(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey;
  }
  
  static Color cinzaClaro(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade400;
  }
  
  static Color branco(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
  }
  
  // Legacy static colors for backward compatibility (deprecated)
  @Deprecated('Use atrasada(context) instead for theme-aware colors')
  static const Color atrasadaLegacy = Colors.red;
  @Deprecated('Use proximaDoVencimento(context) instead for theme-aware colors')
  static const Color proximaDoVencimentoLegacy = Colors.orange;
  @Deprecated('Use emDia(context) instead for theme-aware colors')
  static const Color emDiaLegacy = Colors.green;
  @Deprecated('Use cinza(context) instead for theme-aware colors')
  static const Color cinzaLegacy = Colors.grey;
  @Deprecated('Use branco(context) instead for theme-aware colors')
  static const Color brancoLegacy = Colors.white;
  
  /// Helper method to check if current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get theme-appropriate surface color
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  /// Get theme-appropriate text color
  static Color onSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}
