/// Calculadora de Ração Animal
/// Calcula necessidades de alimentação para pecuária
library;

enum AnimalType {
  cattle, // Gado bovino
  pig, // Suíno
  chicken, // Frango
}

class FeedCalculatorResult {
  /// Consumo diário por animal (kg)
  final double dailyFeedPerAnimal;

  /// Consumo diário total (kg)
  final double dailyFeedTotal;

  /// Consumo total no período (kg)
  final double totalFeed;

  /// Consumo total (toneladas)
  final double totalFeedTons;

  /// Custo estimado (R$)
  final double estimatedCost;

  /// Sacas de ração (60kg)
  final int bagsNeeded;

  /// Recomendações de manejo
  final List<String> recommendations;

  const FeedCalculatorResult({
    required this.dailyFeedPerAnimal,
    required this.dailyFeedTotal,
    required this.totalFeed,
    required this.totalFeedTons,
    required this.estimatedCost,
    required this.bagsNeeded,
    required this.recommendations,
  });
}

class FeedCalculator {
  // Percentual de consumo diário baseado no peso vivo
  static const Map<AnimalType, double> feedPercentages = {
    AnimalType.cattle: 2.5, // 2.5% do peso vivo
    AnimalType.pig: 3.0, // 3.0% do peso vivo
    AnimalType.chicken: 10.0, // 10.0% do peso vivo (aves consomem mais proporcionalmente)
  };

  // Preço médio da ração (R$/kg)
  static const Map<AnimalType, double> feedPrices = {
    AnimalType.cattle: 1.80,
    AnimalType.pig: 2.50,
    AnimalType.chicken: 2.20,
  };

  static const Map<AnimalType, String> animalNames = {
    AnimalType.cattle: 'Gado Bovino',
    AnimalType.pig: 'Suíno',
    AnimalType.chicken: 'Frango',
  };

  /// Calcula necessidade de ração
  static FeedCalculatorResult calculate({
    required AnimalType animalType,
    required double weightKg,
    required int numAnimals,
    required int days,
  }) {
    final feedPercentage = feedPercentages[animalType]!;
    final pricePerKg = feedPrices[animalType]!;

    // Consumo diário por animal
    final dailyFeedPerAnimal = weightKg * (feedPercentage / 100);

    // Consumo diário total
    final dailyFeedTotal = dailyFeedPerAnimal * numAnimals;

    // Consumo total no período
    final totalFeed = dailyFeedTotal * days;
    final totalFeedTons = totalFeed / 1000;

    // Custo estimado
    final estimatedCost = totalFeed * pricePerKg;

    // Sacas necessárias (60kg)
    final bagsNeeded = (totalFeed / 60).ceil();

    // Recomendações
    final recommendations = _getRecommendations(
      animalType,
      dailyFeedPerAnimal,
      numAnimals,
    );

    return FeedCalculatorResult(
      dailyFeedPerAnimal: double.parse(dailyFeedPerAnimal.toStringAsFixed(2)),
      dailyFeedTotal: double.parse(dailyFeedTotal.toStringAsFixed(1)),
      totalFeed: double.parse(totalFeed.toStringAsFixed(1)),
      totalFeedTons: double.parse(totalFeedTons.toStringAsFixed(2)),
      estimatedCost: double.parse(estimatedCost.toStringAsFixed(2)),
      bagsNeeded: bagsNeeded,
      recommendations: recommendations,
    );
  }

  static List<String> _getRecommendations(
    AnimalType type,
    double dailyFeed,
    int numAnimals,
  ) {
    final recommendations = <String>[];

    // Recomendações por espécie
    switch (type) {
      case AnimalType.cattle:
        recommendations.add('Bovinos: Forneça volumoso (silagem/pastagem) além do concentrado');
        recommendations.add('Divida ração em 2-3 refeições diárias');
        recommendations.add('Água fresca e limpa à vontade');
        break;
      
      case AnimalType.pig:
        recommendations.add('Suínos: Ajuste ração conforme fase (crescimento/terminação)');
        recommendations.add('Evite desperdício usando comedouros adequados');
        recommendations.add('Forneça 2-3 refeições diárias em horários fixos');
        break;
      
      case AnimalType.chicken:
        recommendations.add('Frangos: Ração deve estar sempre disponível');
        recommendations.add('Proteja de umidade e contaminação');
        recommendations.add('Ajuste granulometria conforme idade das aves');
        break;
    }

    // Recomendações gerais
    if (numAnimals > 100) {
      recommendations.add('Grande plantel: Considere armazenamento adequado para ração a granel');
    }

    recommendations.add('Armazene em local seco e arejado');
    recommendations.add('Respeite prazo de validade da ração');
    recommendations.add('Monitore conversão alimentar regularmente');

    return recommendations;
  }

  static String getAnimalName(AnimalType type) => animalNames[type]!;
}
