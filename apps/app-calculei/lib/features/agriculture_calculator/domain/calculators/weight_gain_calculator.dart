/// Calculadora de Ganho de Peso
/// Estima tempo necessário para atingir peso alvo baseado em ganho diário
library;

enum AnimalType {
  cattle, // Gado bovino
  pig, // Suíno
  sheep, // Ovino
  goat, // Caprino
}

class WeightGainResult {
  /// Dias necessários para atingir peso alvo
  final int daysNeeded;

  /// Semanas necessárias
  final int weeksNeeded;

  /// Ganho de peso total (kg)
  final double totalGain;

  /// Eficiência de conversão alimentar estimada
  final double feedEfficiency;

  /// Consumo total estimado de ração (kg)
  final double totalFeedKg;

  /// Custo estimado com alimentação (R$)
  final double feedCost;

  /// Data estimada de abate/venda
  final DateTime estimatedDate;

  /// Recomendações
  final List<String> recommendations;

  const WeightGainResult({
    required this.daysNeeded,
    required this.weeksNeeded,
    required this.totalGain,
    required this.feedEfficiency,
    required this.totalFeedKg,
    required this.feedCost,
    required this.estimatedDate,
    required this.recommendations,
  });
}

class WeightGainCalculator {
  // Conversão alimentar média (kg ração / kg ganho)
  static const Map<AnimalType, double> feedConversion = {
    AnimalType.cattle: 8.0, // 8kg ração para 1kg ganho
    AnimalType.pig: 3.0, // 3kg ração para 1kg ganho
    AnimalType.sheep: 6.0,
    AnimalType.goat: 7.0,
  };

  // Preço médio da ração (R$/kg)
  static const Map<AnimalType, double> feedPrices = {
    AnimalType.cattle: 1.80,
    AnimalType.pig: 2.50,
    AnimalType.sheep: 2.00,
    AnimalType.goat: 2.00,
  };

  static const Map<AnimalType, String> animalNames = {
    AnimalType.cattle: 'Bovino',
    AnimalType.pig: 'Suíno',
    AnimalType.sheep: 'Ovino',
    AnimalType.goat: 'Caprino',
  };

  /// Calcula tempo e custo para ganho de peso
  static WeightGainResult calculate({
    required double initialWeight,
    required double targetWeight,
    required double dailyGainKg,
    required AnimalType animalType,
  }) {
    // Ganho total necessário
    final totalGain = targetWeight - initialWeight;

    // Dias necessários
    final daysNeeded = (totalGain / dailyGainKg).ceil();
    final weeksNeeded = (daysNeeded / 7).ceil();

    // Eficiência de conversão
    final feedEfficiency = feedConversion[animalType]!;

    // Consumo total de ração
    final totalFeedKg = totalGain * feedEfficiency;

    // Custo com alimentação
    final pricePerKg = feedPrices[animalType]!;
    final feedCost = totalFeedKg * pricePerKg;

    // Data estimada
    final estimatedDate = DateTime.now().add(Duration(days: daysNeeded));

    // Recomendações
    final recommendations = _getRecommendations(
      animalType,
      dailyGainKg,
      daysNeeded,
    );

    return WeightGainResult(
      daysNeeded: daysNeeded,
      weeksNeeded: weeksNeeded,
      totalGain: double.parse(totalGain.toStringAsFixed(1)),
      feedEfficiency: double.parse(feedEfficiency.toStringAsFixed(1)),
      totalFeedKg: double.parse(totalFeedKg.toStringAsFixed(1)),
      feedCost: double.parse(feedCost.toStringAsFixed(2)),
      estimatedDate: estimatedDate,
      recommendations: recommendations,
    );
  }

  static List<String> _getRecommendations(
    AnimalType type,
    double dailyGain,
    int days,
  ) {
    final recommendations = <String>[];

    // Análise de ganho diário
    switch (type) {
      case AnimalType.cattle:
        if (dailyGain > 1.5) {
          recommendations.add('Excelente ganho para bovinos! Mantenha o manejo');
        } else if (dailyGain > 1.0) {
          recommendations.add('Bom ganho de peso para bovinos');
        } else {
          recommendations.add('Ganho moderado: Revise nutrição e sanidade');
        }
        recommendations.add('Bovinos: Pesagem mensal para monitorar desempenho');
        break;

      case AnimalType.pig:
        if (dailyGain > 0.8) {
          recommendations.add('Excelente ganho para suínos!');
        } else if (dailyGain > 0.6) {
          recommendations.add('Bom ganho de peso para suínos');
        } else {
          recommendations.add('Ganho baixo: Verifique qualidade da ração');
        }
        recommendations.add('Suínos: Pesagem semanal recomendada');
        break;

      case AnimalType.sheep:
      case AnimalType.goat:
        if (dailyGain > 0.3) {
          recommendations.add('Excelente ganho para pequenos ruminantes!');
        } else if (dailyGain > 0.2) {
          recommendations.add('Bom ganho de peso');
        } else {
          recommendations.add('Ganho moderado: Revise alimentação');
        }
        break;
    }

    // Recomendações por período
    if (days > 180) {
      recommendations.add('Período longo: Planeje manejo em fases');
    }

    // Recomendações gerais
    recommendations.add('Monitore condição corporal regularmente');
    recommendations.add('Mantenha controle sanitário em dia');
    recommendations.add('Ajuste ração conforme fase de crescimento');

    return recommendations;
  }

  static String getAnimalName(AnimalType type) => animalNames[type]!;
}
