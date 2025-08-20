// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

/// Core peso utilities shared across browse and cadastro contexts
class PesoCore {
  
  /// Format peso value for display
  static String formatPeso(double peso) {
    if (peso == peso.roundToDouble()) {
      return peso.toStringAsFixed(0);
    } else {
      return peso.toStringAsFixed(1);
    }
  }

  /// Format peso with unit
  static String formatPesoWithUnit(double peso) {
    return '${formatPeso(peso)} kg';
  }

  /// Format peso with precision
  static String formatPesoWithPrecision(double peso, int precision) {
    return '${peso.toStringAsFixed(precision)} kg';
  }

  /// Format peso change with sign
  static String formatPesoChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  /// Format peso change as percentage
  static String formatPesoChangePercentage(double change, double previousPeso) {
    if (previousPeso == 0) return '0%';
    
    final percentage = (change / previousPeso) * 100;
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  /// Parse peso from string (handles comma as decimal separator)
  static double? parsePeso(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    // Replace comma with dot for parsing
    final cleanValue = value.trim().replaceAll(',', '.');
    return double.tryParse(cleanValue);
  }

  /// Alternative method name for compatibility
  static double parsePesoFromString(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^\d.,]'), '');
    final normalizedValue = cleanValue.replaceAll(',', '.');
    return double.tryParse(normalizedValue) ?? 0.0;
  }

  /// Clean peso input string
  static String cleanPesoInput(String input) {
    // Remove any non-numeric characters except comma and dot
    return input.replaceAll(RegExp(r'[^\d,.]'), '');
  }

  /// Round peso value
  static double roundPeso(double peso, {int decimalPlaces = 2}) {
    final factor = math.pow(10, decimalPlaces);
    return (peso * factor).round() / factor;
  }

  /// Check if peso is in valid range
  static bool isValidPesoRange(double peso) {
    return peso > 0 && peso <= 500;
  }

  /// Get peso category
  static String getPesoCategory(double peso) {
    if (peso < 1) return 'Muito Leve';
    if (peso < 5) return 'Leve';
    if (peso < 15) return 'Médio';
    if (peso < 30) return 'Grande';
    if (peso < 50) return 'Muito Grande';
    return 'Gigante';
  }

  /// Get peso category color
  static Color getPesoCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
      case 'abaixo do peso':
        return const Color(0xFFFFA726); // Orange
      case 'normal':
        return const Color(0xFF4CAF50); // Green
      case 'overweight':
      case 'acima do peso':
        return const Color(0xFFFF7043); // Deep Orange
      case 'obese':
      case 'obeso':
        return const Color(0xFFE53935); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get peso status icon
  static String getPesoStatusIcon(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
      case 'abaixo do peso':
        return '⚠️';
      case 'normal':
        return '✅';
      case 'overweight':
      case 'acima do peso':
        return '⚠️';
      case 'obese':
      case 'obeso':
        return '🚨';
      default:
        return '❓';
    }
  }

  /// Generate peso suggestions
  static List<double> generatePesoSuggestions(double? currentPeso) {
    if (currentPeso == null || currentPeso <= 0) {
      return [0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0];
    }

    final suggestions = <double>[];
    final baseValues = [0.1, 0.2, 0.5, 1.0, 2.0, 5.0];
    
    for (final base in baseValues) {
      if (currentPeso - base > 0) suggestions.add(currentPeso - base);
      suggestions.add(currentPeso + base);
    }

    return suggestions.where((peso) => peso > 0 && peso <= 500).toSet().toList()
      ..sort();
  }

  /// Convert peso to different units
  static Map<String, double> convertPesoToUnits(double pesoInKg) {
    return {
      'kg': pesoInKg,
      'g': pesoInKg * 1000,
      'lb': pesoInKg * 2.20462,
      'oz': pesoInKg * 35.274,
    };
  }

  /// Format peso in different units
  static String formatPesoInUnit(double pesoInKg, String unit) {
    final conversions = convertPesoToUnits(pesoInKg);
    final value = conversions[unit] ?? pesoInKg;
    
    switch (unit) {
      case 'kg':
        return '${value.toStringAsFixed(1)} kg';
      case 'g':
        return '${value.toStringAsFixed(0)} g';
      case 'lb':
        return '${value.toStringAsFixed(1)} lb';
      case 'oz':
        return '${value.toStringAsFixed(1)} oz';
      default:
        return '${value.toStringAsFixed(1)} kg';
    }
  }

  /// Export peso to JSON
  static Map<String, dynamic> exportToJson({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
  }) {
    return {
      'animalId': animalId,
      'peso': peso,
      'dataPesagem': dataPesagem.millisecondsSinceEpoch,
      'dataPesagemFormatada': '${dataPesagem.day.toString().padLeft(2, '0')}/${dataPesagem.month.toString().padLeft(2, '0')}/${dataPesagem.year}',
      'pesoFormatado': formatPesoWithUnit(peso),
      'categoria': getPesoCategory(peso),
      'observacoes': observacoes,
    };
  }
}
