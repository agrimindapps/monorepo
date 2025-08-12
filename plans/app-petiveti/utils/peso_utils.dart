// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/17_peso_model.dart';

/// Central peso utilities for app-petiveti
class PesoUtils {
  
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

  /// Validate peso value
  static String? validatePesoValue(double? peso) {
    if (peso == null || peso <= 0) {
      return 'O peso deve ser maior que zero';
    }
    if (peso > 500) {
      return 'O peso deve ser menor que 500kg';
    }
    return null;
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

  /// Calculate BMI (Body Mass Index) approximation
  static double? calculateBMI(double peso, String animalType) {
    // Simplified BMI calculation for pets
    switch (animalType) {
      case 'Cachorro':
        return peso / 0.45; // Simplified formula
      case 'Gato':
        return peso / 0.35; // Different formula for cats
      default:
        return null;
    }
  }

  /// Calculate average peso over time period
  static double calculateAveragePeso(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0;
    
    final total = pesos.fold<double>(0, (sum, peso) => sum + peso.peso);
    return total / pesos.length;
  }

  /// Calculate peso variance
  static double calculatePesoVariance(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return 0;
    
    final average = calculateAveragePeso(pesos);
    final squaredDifferences = pesos.map((peso) => math.pow(peso.peso - average, 2));
    final sumSquaredDifferences = squaredDifferences.fold<double>(0, (sum, diff) => sum + diff);
    
    return sumSquaredDifferences / (pesos.length - 1);
  }

  /// Calculate peso standard deviation
  static double calculatePesoStandardDeviation(List<PesoAnimal> pesos) {
    return math.sqrt(calculatePesoVariance(pesos));
  }

  /// Find peso outliers using standard deviation
  static List<PesoAnimal> findPesoOutliers(List<PesoAnimal> pesos, {double threshold = 2.0}) {
    if (pesos.length < 3) return [];
    
    final average = calculateAveragePeso(pesos);
    final standardDeviation = calculatePesoStandardDeviation(pesos);
    
    return pesos.where((peso) {
      final zScore = (peso.peso - average).abs() / standardDeviation;
      return zScore > threshold;
    }).toList();
  }

  /// Generate peso chart data points
  static List<ChartDataPoint> generateChartData(List<PesoAnimal> pesos) {
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    return sortedPesos.map((peso) => ChartDataPoint(
      x: peso.dataPesagem.toDouble(),
      y: peso.peso,
      label: '${peso.dataPesagem}', // Will be formatted by date utils
      peso: peso,
    )).toList();
  }

  /// Calculate trend line points
  static List<ChartDataPoint> calculateTrendLine(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return [];
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    // Simple linear regression
    final n = sortedPesos.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (final peso in sortedPesos) {
      final x = peso.dataPesagem.toDouble();
      final y = peso.peso;
      
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Generate trend line points
    final firstX = sortedPesos.first.dataPesagem.toDouble();
    final lastX = sortedPesos.last.dataPesagem.toDouble();
    
    return [
      ChartDataPoint(
        x: firstX,
        y: slope * firstX + intercept,
        label: 'Trend Start',
      ),
      ChartDataPoint(
        x: lastX,
        y: slope * lastX + intercept,
        label: 'Trend End',
      ),
    ];
  }

  /// Group pesos by time period
  static Map<String, List<PesoAnimal>> groupPesosByMonth(List<PesoAnimal> pesos) {
    final groups = <String, List<PesoAnimal>>{};
    
    for (final peso in pesos) {
      final date = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      final key = '${date.month.toString().padLeft(2, '0')}/${date.year}';
      
      groups.putIfAbsent(key, () => []).add(peso);
    }
    
    return groups;
  }

  /// Calculate peso growth rate (kg per month)
  static double? calculateGrowthRate(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return null;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final firstPeso = sortedPesos.first;
    final lastPeso = sortedPesos.last;
    
    final pesoChange = lastPeso.peso - firstPeso.peso;
    final timeDiffInDays = (lastPeso.dataPesagem - firstPeso.dataPesagem) / (1000 * 60 * 60 * 24);
    final monthsDiff = timeDiffInDays / 30.44; // Average days in month
    
    return monthsDiff > 0 ? pesoChange / monthsDiff : null;
  }

  /// Format growth rate for display
  static String formatGrowthRate(double? growthRate) {
    if (growthRate == null) return 'N/A';
    
    final sign = growthRate >= 0 ? '+' : '';
    return '$sign${growthRate.toStringAsFixed(2)} kg/mês';
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

  /// Calculate ideal peso range based on animal data
  static Map<String, double>? calculateIdealPesoRange(String animalType, String? breed) {
    // This would typically use a comprehensive database
    // For now, using simplified ranges
    
    switch (animalType) {
      case 'Cachorro':
        return _getDogIdealRange(breed);
      case 'Gato':
        return {'min': 2.5, 'max': 5.5};
      default:
        return null;
    }
  }

  static Map<String, double> _getDogIdealRange(String? breed) {
    // Simplified breed-based ranges
    switch (breed?.toLowerCase()) {
      case 'chihuahua':
        return {'min': 1.5, 'max': 3.0};
      case 'yorkshire':
        return {'min': 2.0, 'max': 3.5};
      case 'golden retriever':
        return {'min': 25.0, 'max': 35.0};
      case 'labrador':
        return {'min': 25.0, 'max': 36.0};
      case 'pastor alemão':
        return {'min': 22.0, 'max': 40.0};
      default:
        return {'min': 5.0, 'max': 30.0}; // General range
    }
  }

  /// Validation functions
  static String? validatePeso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Peso é obrigatório';
    }
    
    final peso = parsePeso(value);
    
    if (peso == null) {
      return 'Peso deve ser um número válido';
    }
    
    if (peso <= 0) {
      return 'Peso deve ser maior que zero';
    }
    
    if (peso > 500) {
      return 'Peso muito alto, verifique se está correto';
    }
    
    if (peso < 0.01) {
      return 'Peso muito baixo, verifique se está correto';
    }
    
    return null;
  }

  /// Validates peso specifically for dogs
  static String? validateDogPeso(String? value) {
    final baseError = validatePeso(value);
    if (baseError != null) return baseError;
    
    final peso = parsePeso(value)!;
    
    if (peso > 100) {
      return 'Peso muito alto para um cão';
    }
    
    if (peso < 0.5) {
      return 'Peso muito baixo para um cão';
    }
    
    return null;
  }

  /// Validates peso specifically for cats
  static String? validateCatPeso(String? value) {
    final baseError = validatePeso(value);
    if (baseError != null) return baseError;
    
    final peso = parsePeso(value)!;
    
    if (peso > 20) {
      return 'Peso muito alto para um gato';
    }
    
    if (peso < 0.2) {
      return 'Peso muito baixo para um gato';
    }
    
    return null;
  }

  /// Validates peso change for alerts
  static String? validatePesoChange(double currentPeso, double? previousPeso) {
    if (previousPeso == null) return null;
    
    final difference = currentPeso - previousPeso;
    final percentageChange = (difference / previousPeso) * 100;
    
    if (percentageChange.abs() > 50) {
      return 'Mudança de peso muito drástica (${percentageChange.toStringAsFixed(1)}%)';
    }
    
    return null;
  }

  /// Validates if peso is within expected range for animal age
  static String? validatePesoForAge(double peso, DateTime birthDate, String animalType) {
    final age = DateTime.now().difference(birthDate).inDays;
    
    if (animalType == 'Cachorro') {
      if (age < 30 && peso > 5) { // Puppy less than 1 month
        return 'Peso alto para filhote tão novo';
      }
      
      if (age < 90 && peso > 15) { // Puppy less than 3 months
        return 'Peso alto para filhote';
      }
    } else if (animalType == 'Gato') {
      if (age < 30 && peso > 1) { // Kitten less than 1 month
        return 'Peso alto para filhote tão novo';
      }
      
      if (age < 90 && peso > 2) { // Kitten less than 3 months
        return 'Peso alto para filhote';
      }
    }
    
    return null;
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

/// Data point for chart visualization
class ChartDataPoint {
  final double x;
  final double y;
  final String label;
  final PesoAnimal? peso;

  const ChartDataPoint({
    required this.x,
    required this.y,
    required this.label,
    this.peso,
  });

  @override
  String toString() => 'ChartDataPoint(x: $x, y: $y, label: $label)';
}
