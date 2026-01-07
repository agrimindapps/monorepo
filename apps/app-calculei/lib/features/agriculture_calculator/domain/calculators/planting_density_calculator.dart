/// Calculadora de Densidade de Plantio
/// Calcula número de plantas por hectare e total para área
library;

class PlantingDensityResult {
  /// Plantas por hectare
  final int plantsPerHa;

  /// Total de plantas para a área
  final int totalPlants;

  /// Área ocupada por planta (m²)
  final double areaPerPlant;

  /// Metros lineares de plantio por hectare
  final double linearMetersHa;

  /// Custo estimado com mudas/sementes (R$)
  final double estimatedCost;

  /// Recomendações de plantio
  final List<String> recommendations;

  const PlantingDensityResult({
    required this.plantsPerHa,
    required this.totalPlants,
    required this.areaPerPlant,
    required this.linearMetersHa,
    required this.estimatedCost,
    required this.recommendations,
  });
}

class PlantingDensityCalculator {
  /// Calcula densidade de plantio
  static PlantingDensityResult calculate({
    required double rowSpacingM,
    required double plantSpacingM,
    required double areaHa,
    double costPerPlant = 0.0,
  }) {
    // 1 hectare = 10.000 m²
    const double hectareM2 = 10000;

    // Plantas por hectare
    final plantsPerHa = (hectareM2 / (rowSpacingM * plantSpacingM)).round();

    // Total de plantas para a área
    final totalPlants = (plantsPerHa * areaHa).round();

    // Área ocupada por planta
    final areaPerPlant = rowSpacingM * plantSpacingM;

    // Metros lineares por hectare
    final linearMetersHa = hectareM2 / rowSpacingM;

    // Custo estimado
    final estimatedCost = totalPlants * costPerPlant;

    // Recomendações
    final recommendations = _getRecommendations(
      rowSpacingM,
      plantSpacingM,
      plantsPerHa,
    );

    return PlantingDensityResult(
      plantsPerHa: plantsPerHa,
      totalPlants: totalPlants,
      areaPerPlant: double.parse(areaPerPlant.toStringAsFixed(2)),
      linearMetersHa: double.parse(linearMetersHa.toStringAsFixed(1)),
      estimatedCost: double.parse(estimatedCost.toStringAsFixed(2)),
      recommendations: recommendations,
    );
  }

  static List<String> _getRecommendations(
    double rowSpacing,
    double plantSpacing,
    int plantsPerHa,
  ) {
    final recommendations = <String>[];

    // Densidade
    if (plantsPerHa > 50000) {
      recommendations.add('Alta densidade: Atenção à competição entre plantas');
      recommendations.add('Requerer maior controle de pragas e doenças');
    } else if (plantsPerHa > 20000) {
      recommendations.add('Densidade moderada a alta');
    } else if (plantsPerHa > 5000) {
      recommendations.add('Densidade moderada: Boa ventilação entre plantas');
    } else {
      recommendations.add('Baixa densidade: Ideal para culturas de grande porte');
    }

    // Espaçamento
    if (rowSpacing > 2.0) {
      recommendations.add('Espaçamento largo: Facilita mecanização');
    }

    if (plantSpacing < 0.3) {
      recommendations.add('Plantas muito próximas: Atenção à adubação');
    }

    // Recomendações gerais
    recommendations.add('Marque linhas com precisão para uniformidade');
    recommendations.add('Considere 5-10% de mudas extras (replantio)');
    recommendations.add('Ajuste densidade conforme fertilidade do solo');

    return recommendations;
  }
}
