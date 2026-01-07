/// Calculadora de Necessidade Hídrica
/// Fórmula base: 35ml × peso (kg)
/// Ajustes: nível de atividade + clima
library;

enum WaterActivityLevel {
  sedentary, // +0%
  lightlyActive, // +20%
  moderatelyActive, // +40%
  veryActive, // +60%
  extraActive, // +80%
}

enum ClimateType {
  veryCold, // -20%
  temperate, // +0%
  hot, // +20%
  veryHotDry, // +40%
}

class WaterIntakeResult {
  /// Consumo base em litros/dia
  final double baseLiters;

  /// Consumo ajustado em litros/dia
  final double adjustedLiters;

  /// Consumo base em ml/dia
  final double baseMl;

  /// Consumo ajustado em ml/dia
  final double adjustedMl;

  /// Número de copos de 250ml
  final int glassesOf250ml;

  /// Número de garrafas de 500ml
  final int bottlesOf500ml;

  const WaterIntakeResult({
    required this.baseLiters,
    required this.adjustedLiters,
    required this.baseMl,
    required this.adjustedMl,
    required this.glassesOf250ml,
    required this.bottlesOf500ml,
  });
}

class WaterIntakeCalculator {
  static const double mlPerKg = 35.0;

  static const Map<WaterActivityLevel, double> activityFactors = {
    WaterActivityLevel.sedentary: 0.0,
    WaterActivityLevel.lightlyActive: 0.2,
    WaterActivityLevel.moderatelyActive: 0.4,
    WaterActivityLevel.veryActive: 0.6,
    WaterActivityLevel.extraActive: 0.8,
  };

  static const Map<ClimateType, double> climateFactors = {
    ClimateType.veryCold: -0.2,
    ClimateType.temperate: 0.0,
    ClimateType.hot: 0.2,
    ClimateType.veryHotDry: 0.4,
  };

  static const Map<WaterActivityLevel, String> activityDescriptions = {
    WaterActivityLevel.sedentary: 'Sedentário',
    WaterActivityLevel.lightlyActive: 'Levemente ativo',
    WaterActivityLevel.moderatelyActive: 'Moderadamente ativo',
    WaterActivityLevel.veryActive: 'Muito ativo',
    WaterActivityLevel.extraActive: 'Extra ativo',
  };

  static const Map<ClimateType, String> climateDescriptions = {
    ClimateType.veryCold: 'Muito frio',
    ClimateType.temperate: 'Temperado/Ameno',
    ClimateType.hot: 'Quente',
    ClimateType.veryHotDry: 'Muito quente e seco',
  };

  /// Calcula necessidade hídrica diária
  static WaterIntakeResult calculate({
    required double weightKg,
    required WaterActivityLevel activityLevel,
    required ClimateType climate,
  }) {
    final baseMl = weightKg * mlPerKg;
    final activityFactor = activityFactors[activityLevel]!;
    final climateFactor = climateFactors[climate]!;

    final adjustedMl = baseMl * (1 + activityFactor + climateFactor);

    final baseLiters = baseMl / 1000;
    final adjustedLiters = adjustedMl / 1000;

    return WaterIntakeResult(
      baseLiters: double.parse(baseLiters.toStringAsFixed(2)),
      adjustedLiters: double.parse(adjustedLiters.toStringAsFixed(2)),
      baseMl: double.parse(baseMl.toStringAsFixed(0)),
      adjustedMl: double.parse(adjustedMl.toStringAsFixed(0)),
      glassesOf250ml: (adjustedMl / 250).ceil(),
      bottlesOf500ml: (adjustedMl / 500).ceil(),
    );
  }

  static String getActivityDescription(WaterActivityLevel level) {
    return activityDescriptions[level]!;
  }

  static String getClimateDescription(ClimateType climate) {
    return climateDescriptions[climate]!;
  }

  /// Dicas de hidratação
  static List<String> getHydrationTips() {
    return [
      'Distribua o consumo ao longo do dia',
      'Beba um copo de água ao acordar',
      'Durante exercícios, beba a cada 15-20 minutos',
      'Cafeína e álcool aumentam a necessidade de água',
      'Frutas e vegetais também contribuem para hidratação',
    ];
  }
}
