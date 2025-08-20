// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../../models/17_peso_model.dart';

/// Peso calculations utilities shared across browse and cadastro contexts
class PesoCalculations {
  
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
