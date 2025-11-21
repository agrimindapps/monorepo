import 'dart:convert';

import 'package:flutter/material.dart';

/// Helpers estáticos para DataInspectorPage
///
/// Responsabilidades:
/// - Formatação de JSON e valores
/// - Cores e ícones por tipo de dado
/// - Utilitários de formatação
class DataInspectorHelpers {
  DataInspectorHelpers._();

  /// Retorna cor baseada no tipo de dado
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return Colors.blue;
      case 'int':
        return Colors.green;
      case 'double':
        return Colors.orange;
      case 'bool':
        return Colors.purple;
      case 'list':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Retorna ícone baseado no tipo de dado
  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'string':
        return Icons.text_fields;
      case 'int':
      case 'double':
        return Icons.numbers;
      case 'bool':
        return Icons.toggle_on;
      case 'list':
        return Icons.list;
      default:
        return Icons.settings;
    }
  }

  /// Formata qualquer dado como JSON indentado
  static String formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Formata valor com auto-detecção de JSON strings
  static String formatValue(dynamic value) {
    if (value is String) {
      try {
        final decoded = json.decode(value);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } catch (e) {
        return value;
      }
    }
    return formatJson(value);
  }
}
