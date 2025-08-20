// Flutter imports:
import 'package:flutter/foundation.dart';

/// Utilitários para conversão segura de tipos
class TypeConversionUtils {
  /// Converte string para double de forma segura
  static double safeDoubleFromString(String value,
      {double defaultValue = 0.0}) {
    if (value.isEmpty) return defaultValue;

    try {
      // Remove espaços em branco e substitui vírgula por ponto
      final normalizedValue = value.trim().replaceAll(',', '.');

      // Verifica se é um número válido
      if (!_isValidNumber(normalizedValue)) {
        return defaultValue;
      }

      final result = double.parse(normalizedValue);

      // Verifica se o resultado é finito (não é NaN ou infinity)
      if (!result.isFinite) {
        return defaultValue;
      }

      return result;
    } catch (e) {
      // Log do erro para debugging
      debugPrint('Erro na conversão de string para double: $e, valor: $value');
      return defaultValue;
    }
  }

  /// Converte string para int de forma segura
  static int safeIntFromString(String value, {int defaultValue = 0}) {
    if (value.isEmpty) return defaultValue;

    try {
      // Remove espaços em branco
      final normalizedValue = value.trim();

      // Verifica se é um número válido
      if (!_isValidInteger(normalizedValue)) {
        return defaultValue;
      }

      return int.parse(normalizedValue);
    } catch (e) {
      // Log do erro para debugging
      debugPrint('Erro na conversão de string para int: $e, valor: $value');
      return defaultValue;
    }
  }

  /// Converte double para string formatada
  static String doubleToString(double value, {int decimalPlaces = 2}) {
    if (!value.isFinite) {
      return '0.00';
    }

    return value.toStringAsFixed(decimalPlaces);
  }

  /// Verifica se uma string representa um número válido
  static bool _isValidNumber(String value) {
    if (value.isEmpty) return false;

    // Pattern para números com decimais opcionais
    final numberPattern = RegExp(r'^-?\d+(\.\d+)?$');
    return numberPattern.hasMatch(value);
  }

  /// Verifica se uma string representa um inteiro válido
  static bool _isValidInteger(String value) {
    if (value.isEmpty) return false;

    // Pattern para números inteiros
    final integerPattern = RegExp(r'^-?\d+$');
    return integerPattern.hasMatch(value);
  }

  /// Normaliza string numérica (remove espaços, troca vírgula por ponto)
  static String normalizeNumericString(String value) {
    return value.trim().replaceAll(',', '.');
  }

  /// Valida se uma string pode ser convertida para double
  static bool isValidDouble(String value) {
    if (value.isEmpty) return false;

    try {
      final normalizedValue = normalizeNumericString(value);
      if (!_isValidNumber(normalizedValue)) return false;

      final result = double.parse(normalizedValue);
      return result.isFinite;
    } catch (e) {
      return false;
    }
  }

  /// Valida se uma string pode ser convertida para int
  static bool isValidInteger(String value) {
    if (value.isEmpty) return false;

    try {
      final normalizedValue = value.trim();
      if (!_isValidInteger(normalizedValue)) return false;

      int.parse(normalizedValue);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Converte valores null ou inválidos para string vazia
  static String safeStringFromValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  /// Converte timestamp para DateTime de forma segura
  static DateTime safeDateTimeFromTimestamp(int timestamp,
      {DateTime? defaultValue}) {
    try {
      if (timestamp <= 0) {
        return defaultValue ?? DateTime.now();
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint(
          'Erro na conversão de timestamp para DateTime: $e, timestamp: $timestamp');
      return defaultValue ?? DateTime.now();
    }
  }

  /// Converte DateTime para timestamp de forma segura
  static int safeTimestampFromDateTime(DateTime dateTime) {
    try {
      return dateTime.millisecondsSinceEpoch;
    } catch (e) {
      debugPrint('Erro na conversão de DateTime para timestamp: $e');
      return DateTime.now().millisecondsSinceEpoch;
    }
  }
}
