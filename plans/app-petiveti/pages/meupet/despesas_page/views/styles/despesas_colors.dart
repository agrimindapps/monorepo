// Flutter imports:
import 'package:flutter/material.dart';

class DespesasColors {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF2563EB);
  static const Color borderError = Color(0xFFEF4444);
  
  // Cores específicas para tipos de despesas
  static const Map<String, Color> tipoColors = {
    'consulta': Color(0xFF4CAF50),
    'vacina': Color(0xFF2196F3),
    'medicamento': Color(0xFFFF9800),
    'exame': Color(0xFF9C27B0),
    'cirurgia': Color(0xFFE53935),
    'emergência': Color(0xFFE91E63),
    'banho e tosa': Color(0xFF00BCD4),
    'alimentação': Color(0xFF8BC34A),
    'petiscos': Color(0xFFFFC107),
    'brinquedos': Color(0xFFFF5722),
    'acessórios': Color(0xFF673AB7),
    'hospedagem': Color(0xFF795548),
    'transporte': Color(0xFF607D8B),
    'seguro': Color(0xFF3F51B5),
    'outros': Color(0xFF9E9E9E),
  };
  
  // Cores com opacidade
  static Color get primaryWithOpacity => primaryColor.withValues(alpha: 0.1);
  static Color get successWithOpacity => successColor.withValues(alpha: 0.1);
  static Color get errorWithOpacity => errorColor.withValues(alpha: 0.1);
  static Color get warningWithOpacity => warningColor.withValues(alpha: 0.1);
  static Color get infoWithOpacity => infoColor.withValues(alpha: 0.1);
  
  static Color get shadowColor => Colors.black.withValues(alpha: 0.1);
  static Color get overlayColor => Colors.black.withValues(alpha: 0.5);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );
  
  // Sombras
  static BoxShadow get cardShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get buttonShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  // Helper para obter cor por tipo
  static Color getTipoColor(String tipo) {
    return tipoColors[tipo.toLowerCase()] ?? tipoColors['outros']!;
  }
  
  static Color getTipoColorWithOpacity(String tipo, {double opacity = 0.1}) {
    return getTipoColor(tipo).withValues(alpha: opacity);
  }
}
