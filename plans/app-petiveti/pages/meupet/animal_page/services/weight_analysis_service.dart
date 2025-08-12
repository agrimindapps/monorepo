// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../../../../models/17_peso_model.dart';

class WeightAnalysisService {
  // Analyze weight trends over time
  static Map<String, dynamic> analyzeTrends(List<PesoAnimal> pesos) {
    if (pesos.length < 2) {
      return {
        'trend': 'insufficient_data',
        'direction': 'stable',
        'rate': 0.0,
        'confidence': 0.0,
      };
    }

    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    // Calculate linear regression for trend analysis
    final regression = _calculateLinearRegression(sortedPesos);

    String direction = 'stable';
    if (regression['slope']! > 0.1) {
      direction = 'increasing';
    } else if (regression['slope']! < -0.1) {
      direction = 'decreasing';
    }

    return {
      'trend': regression['r_squared']! > 0.5 ? 'strong' : 'weak',
      'direction': direction,
      'rate': regression['slope'], // kg per day
      'confidence': regression['r_squared'],
      'prediction_30_days': _predictWeight(sortedPesos, 30),
      'prediction_60_days': _predictWeight(sortedPesos, 60),
      'prediction_90_days': _predictWeight(sortedPesos, 90),
    };
  }

  // Detect weight anomalies
  static List<Map<String, dynamic>> detectAnomalies(List<PesoAnimal> pesos) {
    if (pesos.length < 3) return [];

    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    final anomalies = <Map<String, dynamic>>[];
    final weights = sortedPesos.map((p) => p.peso).toList();

    // Calculate moving average and standard deviation
    for (int i = 2; i < sortedPesos.length; i++) {
      final window = weights.sublist(0, i);
      final mean = window.reduce((a, b) => a + b) / window.length;
      final variance =
          window.map((w) => (w - mean) * (w - mean)).reduce((a, b) => a + b) /
              window.length;
      final stdDev = math.sqrt(variance);

      final currentWeight = weights[i];
      final zScore = stdDev > 0 ? (currentWeight - mean) / stdDev : 0;

      // Flag as anomaly if z-score > 2 (95% confidence)
      if (zScore.abs() > 2) {
        anomalies.add({
          'peso': sortedPesos[i],
          'z_score': zScore,
          'expected_range': {
            'min': mean - 2 * stdDev,
            'max': mean + 2 * stdDev,
          },
          'severity': zScore.abs() > 3 ? 'high' : 'medium',
          'type': zScore > 0 ? 'weight_gain' : 'weight_loss',
        });
      }
    }

    return anomalies;
  }

  // Calculate weight change velocity
  static Map<String, dynamic> calculateVelocity(List<PesoAnimal> pesos) {
    if (pesos.length < 2) {
      return {
        'current_velocity': 0.0,
        'average_velocity': 0.0,
        'max_velocity': 0.0,
        'min_velocity': 0.0,
        'velocities': <double>[],
      };
    }

    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    final velocities = <double>[];

    for (int i = 1; i < sortedPesos.length; i++) {
      final previous = sortedPesos[i - 1];
      final current = sortedPesos[i];

      final timeDiff = (current.dataPesagem - previous.dataPesagem) /
          (1000 * 60 * 60 * 24); // days
      final weightDiff = current.peso - previous.peso;

      if (timeDiff > 0) {
        velocities.add(weightDiff / timeDiff); // kg per day
      }
    }

    if (velocities.isEmpty) {
      return {
        'current_velocity': 0.0,
        'average_velocity': 0.0,
        'max_velocity': 0.0,
        'min_velocity': 0.0,
        'velocities': <double>[],
      };
    }

    return {
      'current_velocity': velocities.last,
      'average_velocity':
          velocities.reduce((a, b) => a + b) / velocities.length,
      'max_velocity': velocities.reduce((a, b) => a > b ? a : b),
      'min_velocity': velocities.reduce((a, b) => a < b ? a : b),
      'velocities': velocities,
    };
  }

  // Generate weight goals and recommendations
  static Map<String, dynamic> generateRecommendations(
    List<PesoAnimal> pesos,
    double targetWeight,
    String animalType,
  ) {
    if (pesos.isEmpty) {
      return {
        'recommendations': ['Começar monitoramento regular de peso'],
        'target_achievable': false,
        'estimated_timeline': null,
      };
    }

    final currentWeight = pesos.last.peso;
    final weightDifference = targetWeight - currentWeight;
    final trends = analyzeTrends(pesos);

    final recommendations = <String>[];
    bool targetAchievable = true;
    String? estimatedTimeline;

    // Calculate timeline based on current trend
    if (trends['rate'] != 0) {
      final daysToTarget = weightDifference / trends['rate'];
      if (daysToTarget > 0 && daysToTarget < 365) {
        estimatedTimeline = '${daysToTarget.round()} dias';
      }
    }

    // Generate specific recommendations
    if (weightDifference > 0) {
      // Need to gain weight
      recommendations.addAll([
        'Aumentar gradualmente a quantidade de ração',
        'Considerar ração com maior valor calórico',
        'Consultar veterinário sobre suplementação',
        'Monitorar semanalmente',
      ]);

      if (weightDifference > currentWeight * 0.2) {
        recommendations.add('Meta de ganho muito alta - consultar veterinário');
        targetAchievable = false;
      }
    } else if (weightDifference < 0) {
      // Need to lose weight
      recommendations.addAll([
        'Reduzir gradualmente a quantidade de ração',
        'Aumentar atividade física',
        'Evitar petiscos extras',
        'Pescar diariamente durante o período de perda',
      ]);

      if (weightDifference.abs() > currentWeight * 0.2) {
        recommendations.add('Meta de perda muito alta - consultar veterinário');
        targetAchievable = false;
      }
    } else {
      // Maintain current weight
      recommendations.addAll([
        'Manter rotina atual de alimentação',
        'Continuar atividade física regular',
        'Monitorar mensalmente',
      ]);
    }

    // Add type-specific recommendations
    if (animalType.toLowerCase().contains('gato')) {
      recommendations.addAll([
        'Estimular brincadeiras para exercício',
        'Controlar acesso a comida (gatos tendem a comer em excesso)',
      ]);
    } else if (animalType.toLowerCase().contains('cachorro')) {
      recommendations.addAll([
        'Passeios regulares para exercício',
        'Treinamento pode ajudar com disciplina alimentar',
      ]);
    }

    return {
      'recommendations': recommendations,
      'target_achievable': targetAchievable,
      'estimated_timeline': estimatedTimeline,
      'weight_difference': weightDifference,
      'safe_rate': _getSafeWeightChangeRate(animalType),
    };
  }

  // Calculate seasonal weight patterns
  static Map<String, dynamic> analyzeSeasonalPatterns(List<PesoAnimal> pesos) {
    if (pesos.length < 12) {
      return {'insufficient_data': true};
    }

    final seasonalData = <int, List<double>>{
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: [],
      7: [],
      8: [],
      9: [],
      10: [],
      11: [],
      12: []
    };

    for (final peso in pesos) {
      final date = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      seasonalData[date.month]!.add(peso.peso);
    }

    final monthlyAverages = <int, double>{};
    seasonalData.forEach((month, weights) {
      if (weights.isNotEmpty) {
        monthlyAverages[month] =
            weights.reduce((a, b) => a + b) / weights.length.toDouble();
      }
    });

    // Find patterns
    final maxMonth =
        monthlyAverages.entries.reduce((a, b) => a.value > b.value ? a : b);
    final minMonth =
        monthlyAverages.entries.reduce((a, b) => a.value < b.value ? a : b);

    return {
      'monthly_averages': monthlyAverages,
      'peak_month': maxMonth.key,
      'peak_weight': maxMonth.value,
      'low_month': minMonth.key,
      'low_weight': minMonth.value,
      'seasonal_variation': maxMonth.value - minMonth.value,
    };
  }

  // Helper method for linear regression
  static Map<String, double> _calculateLinearRegression(
      List<PesoAnimal> pesos) {
    final n = pesos.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // Use index as x (time)
      final y = pesos[i].peso;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Calculate R-squared
    final yMean = sumY / n;
    double ssRes = 0, ssTot = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = pesos[i].peso;
      final yPred = slope * x + intercept;

      ssRes += (y - yPred) * (y - yPred);
      ssTot += (y - yMean) * (y - yMean);
    }

    final rSquared = ssTot > 0 ? 1 - (ssRes / ssTot) : 0;

    return {
      'slope': slope.toDouble(),
      'intercept': intercept.toDouble(),
      'r_squared': rSquared.toDouble(),
    };
  }

  // Predict future weight based on trend
  static double _predictWeight(List<PesoAnimal> pesos, int daysAhead) {
    final regression = _calculateLinearRegression(pesos);
    final lastIndex = pesos.length - 1;
    final futureIndex =
        lastIndex + (daysAhead / 7); // Assuming weekly measurements

    return regression['slope']! * futureIndex + regression['intercept']!;
  }

  // Get safe weight change rate for animal type
  static double _getSafeWeightChangeRate(String animalType) {
    // Safe weight change rates (kg per week)
    if (animalType.toLowerCase().contains('gato')) {
      return 0.1; // 100g per week for cats
    } else if (animalType.toLowerCase().contains('cachorro')) {
      return 0.2; // 200g per week for dogs
    }
    return 0.15; // General safe rate
  }
}
