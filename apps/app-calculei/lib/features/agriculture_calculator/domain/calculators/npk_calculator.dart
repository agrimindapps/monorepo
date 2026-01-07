/// Calculadora de NPK - Necessidade de Fertilizantes
/// Calcula quantidade de N, P, K baseado na cultura e análise de solo
library;

enum CropType {
  corn, // Milho
  soybean, // Soja
  wheat, // Trigo
  rice, // Arroz
  beans, // Feijão
  coffee, // Café
  sugarcane, // Cana-de-açúcar
  cotton, // Algodão
}

enum SoilTexture {
  sandy, // Arenoso
  sandyLoam, // Franco-arenoso
  loam, // Franco
  clayLoam, // Franco-argiloso
  clay, // Argiloso
}

class NpkResult {
  /// Nitrogênio necessário (kg/ha)
  final double nitrogenKgHa;

  /// Fósforo necessário (kg P2O5/ha)
  final double phosphorusKgHa;

  /// Potássio necessário (kg K2O/ha)
  final double potassiumKgHa;

  /// Total de N para área
  final double totalNitrogen;

  /// Total de P2O5 para área
  final double totalPhosphorus;

  /// Total de K2O para área
  final double totalPotassium;

  /// Custo estimado (R$)
  final double estimatedCost;

  /// Recomendações de fertilizantes
  final List<FertilizerRecommendation> recommendations;

  /// Dicas de aplicação
  final List<String> applicationTips;

  const NpkResult({
    required this.nitrogenKgHa,
    required this.phosphorusKgHa,
    required this.potassiumKgHa,
    required this.totalNitrogen,
    required this.totalPhosphorus,
    required this.totalPotassium,
    required this.estimatedCost,
    required this.recommendations,
    required this.applicationTips,
  });
}

class FertilizerRecommendation {
  final String name;
  final double quantityKgHa;
  final String timing;

  const FertilizerRecommendation({
    required this.name,
    required this.quantityKgHa,
    required this.timing,
  });
}

class NpkCalculator {
  // Extração de nutrientes por tonelada de produção (kg/ton)
  static const Map<CropType, Map<String, double>> cropRequirements = {
    CropType.corn: {'n': 25.0, 'p': 8.0, 'k': 18.0},
    CropType.soybean: {'n': 80.0, 'p': 15.0, 'k': 37.0},
    CropType.wheat: {'n': 30.0, 'p': 12.0, 'k': 25.0},
    CropType.rice: {'n': 22.0, 'p': 10.0, 'k': 30.0},
    CropType.beans: {'n': 35.0, 'p': 8.0, 'k': 25.0},
    CropType.coffee: {'n': 45.0, 'p': 7.0, 'k': 40.0},
    CropType.sugarcane: {'n': 1.8, 'p': 0.8, 'k': 2.5},
    CropType.cotton: {'n': 60.0, 'p': 25.0, 'k': 45.0},
  };

  // Eficiência de aproveitamento por textura do solo
  static const Map<SoilTexture, Map<String, double>> efficiencyFactors = {
    SoilTexture.sandy: {'n': 0.60, 'p': 0.15, 'k': 0.80},
    SoilTexture.sandyLoam: {'n': 0.70, 'p': 0.20, 'k': 0.85},
    SoilTexture.loam: {'n': 0.80, 'p': 0.25, 'k': 0.90},
    SoilTexture.clayLoam: {'n': 0.75, 'p': 0.30, 'k': 0.85},
    SoilTexture.clay: {'n': 0.70, 'p': 0.20, 'k': 0.80},
  };

  static const Map<CropType, String> cropNames = {
    CropType.corn: 'Milho',
    CropType.soybean: 'Soja',
    CropType.wheat: 'Trigo',
    CropType.rice: 'Arroz',
    CropType.beans: 'Feijão',
    CropType.coffee: 'Café',
    CropType.sugarcane: 'Cana-de-açúcar',
    CropType.cotton: 'Algodão',
  };

  static const Map<SoilTexture, String> soilNames = {
    SoilTexture.sandy: 'Arenoso',
    SoilTexture.sandyLoam: 'Franco-arenoso',
    SoilTexture.loam: 'Franco',
    SoilTexture.clayLoam: 'Franco-argiloso',
    SoilTexture.clay: 'Argiloso',
  };

  /// Calcula necessidade de NPK
  static NpkResult calculate({
    required CropType crop,
    required double expectedYieldTonHa,
    required double soilNMgDm3,
    required double soilPMgDm3,
    required double soilKMgDm3,
    required SoilTexture soilTexture,
    required double areaHa,
    double organicMatterPercent = 3.0,
  }) {
    final requirements = cropRequirements[crop]!;
    final efficiency = efficiencyFactors[soilTexture]!;

    // Necessidade da cultura (kg/ha)
    final cropNeedN = requirements['n']! * expectedYieldTonHa;
    final cropNeedP = requirements['p']! * expectedYieldTonHa;
    final cropNeedK = requirements['k']! * expectedYieldTonHa;

    // Fornecimento do solo (conversão mg/dm³ -> kg/ha)
    final soilSupplyN = soilNMgDm3 * 2.0;
    final soilSupplyP = soilPMgDm3 * 2.0 * 2.29; // Para P2O5
    final soilSupplyK = soilKMgDm3 * 2.0 * 1.20; // Para K2O

    // Bônus de matéria orgânica para N
    final omBonus = (organicMatterPercent > 2.0)
        ? (organicMatterPercent - 2.0) * 10.0
        : 0.0;

    // Necessidade líquida (considerando eficiência)
    var needN = (cropNeedN - soilSupplyN - omBonus) / efficiency['n']!;
    var needP = (cropNeedP - soilSupplyP) / efficiency['p']!;
    var needK = (cropNeedK - soilSupplyK) / efficiency['k']!;

    // Não pode ser negativo
    needN = needN.clamp(0, 500);
    needP = needP.clamp(0, 300);
    needK = needK.clamp(0, 400);

    // Totais para a área
    final totalN = needN * areaHa;
    final totalP = needP * areaHa;
    final totalK = needK * areaHa;

    // Custo estimado (preços médios)
    // Ureia (45% N) = R$ 4,50/kg → R$ 10,00/kg de N
    // MAP (52% P2O5) = R$ 8,00/kg → R$ 15,38/kg de P2O5
    // KCl (60% K2O) = R$ 5,50/kg → R$ 9,17/kg de K2O
    final costN = totalN * 10.00;
    final costP = totalP * 15.38;
    final costK = totalK * 9.17;
    final estimatedCost = costN + costP + costK;

    // Recomendações de fertilizantes
    final recommendations = _getRecommendations(needN, needP, needK, crop);
    final applicationTips = _getApplicationTips(crop, soilTexture);

    return NpkResult(
      nitrogenKgHa: double.parse(needN.toStringAsFixed(1)),
      phosphorusKgHa: double.parse(needP.toStringAsFixed(1)),
      potassiumKgHa: double.parse(needK.toStringAsFixed(1)),
      totalNitrogen: double.parse(totalN.toStringAsFixed(1)),
      totalPhosphorus: double.parse(totalP.toStringAsFixed(1)),
      totalPotassium: double.parse(totalK.toStringAsFixed(1)),
      estimatedCost: double.parse(estimatedCost.toStringAsFixed(2)),
      recommendations: recommendations,
      applicationTips: applicationTips,
    );
  }

  static List<FertilizerRecommendation> _getRecommendations(
    double n,
    double p,
    double k,
    CropType crop,
  ) {
    final recommendations = <FertilizerRecommendation>[];

    // Ureia (45% N)
    if (n > 0) {
      final ureiaKg = n / 0.45;
      recommendations.add(FertilizerRecommendation(
        name: 'Ureia (45% N)',
        quantityKgHa: double.parse(ureiaKg.toStringAsFixed(1)),
        timing: crop == CropType.corn ? '30% plantio, 70% cobertura' : 'Plantio',
      ));
    }

    // MAP (52% P2O5, 11% N)
    if (p > 0) {
      final mapKg = p / 0.52;
      recommendations.add(FertilizerRecommendation(
        name: 'MAP (52% P₂O₅)',
        quantityKgHa: double.parse(mapKg.toStringAsFixed(1)),
        timing: 'Plantio (sulco)',
      ));
    }

    // KCl (60% K2O)
    if (k > 0) {
      final kclKg = k / 0.60;
      recommendations.add(FertilizerRecommendation(
        name: 'KCl (60% K₂O)',
        quantityKgHa: double.parse(kclKg.toStringAsFixed(1)),
        timing: 'Plantio ou cobertura',
      ));
    }

    return recommendations;
  }

  static List<String> _getApplicationTips(CropType crop, SoilTexture texture) {
    final tips = <String>[];

    // Dicas por cultura
    if (crop == CropType.soybean) {
      tips.add('Soja fixa N biologicamente - reduza adubação nitrogenada');
    }
    if (crop == CropType.corn) {
      tips.add('Parcele o N: 30% no plantio e 70% em cobertura (V4-V6)');
    }
    if (crop == CropType.coffee) {
      tips.add('Parcele em 3-4 aplicações durante o ciclo');
    }

    // Dicas por textura
    if (texture == SoilTexture.sandy || texture == SoilTexture.sandyLoam) {
      tips.add('Solo arenoso: parcele aplicações para evitar lixiviação');
    }
    if (texture == SoilTexture.clay || texture == SoilTexture.clayLoam) {
      tips.add('Solo argiloso: P pode ser aplicado em área total');
    }

    // Dicas gerais
    tips.add('Realize análise de solo atualizada a cada 2 anos');
    tips.add('Considere adubação de cobertura baseada no desenvolvimento');

    return tips;
  }

  static String getCropName(CropType crop) => cropNames[crop]!;
  static String getSoilName(SoilTexture texture) => soilNames[texture]!;
}
