/// Calculadora de Dosagem de Fertilizantes
/// Calcula quantidade de produto baseado em área, tipo de fertilizante e taxa desejada
library;

enum FertilizerType {
  urea, // Ureia (45% N)
  map, // MAP (52% P2O5, 11% N)
  dap, // DAP (45% P2O5, 18% N)
  kcl, // Cloreto de Potássio (60% K2O)
  superSimple, // Superfosfato Simples (18% P2O5)
  superTriple, // Superfosfato Triplo (41% P2O5)
  sulfatoAmonio, // Sulfato de Amônio (21% N)
  nitratoAmonio, // Nitrato de Amônio (33% N)
}

class FertilizerDosingResult {
  /// Total de nutriente puro necessário (kg)
  final double totalNutrientKg;

  /// Quantidade de produto comercial necessário (kg)
  final double productKg;

  /// Quantidade de produto por hectare (kg/ha)
  final double productKgHa;

  /// Custo estimado total (R$)
  final double estimatedCost;

  /// Número de sacas (50kg) necessárias
  final int bagsNeeded;

  /// Dicas de aplicação
  final List<String> applicationTips;

  const FertilizerDosingResult({
    required this.totalNutrientKg,
    required this.productKg,
    required this.productKgHa,
    required this.estimatedCost,
    required this.bagsNeeded,
    required this.applicationTips,
  });
}

class FertilizerDosingCalculator {
  // Teor de nutrientes por tipo de fertilizante (%)
  static const Map<FertilizerType, Map<String, dynamic>> fertilizerData = {
    FertilizerType.urea: {
      'nutrient': 'N',
      'content': 45.0,
      'price_per_kg': 4.50,
      'name': 'Ureia',
    },
    FertilizerType.map: {
      'nutrient': 'P₂O₅',
      'content': 52.0,
      'price_per_kg': 8.00,
      'name': 'MAP',
    },
    FertilizerType.dap: {
      'nutrient': 'P₂O₅',
      'content': 45.0,
      'price_per_kg': 7.50,
      'name': 'DAP',
    },
    FertilizerType.kcl: {
      'nutrient': 'K₂O',
      'content': 60.0,
      'price_per_kg': 5.50,
      'name': 'KCl',
    },
    FertilizerType.superSimple: {
      'nutrient': 'P₂O₅',
      'content': 18.0,
      'price_per_kg': 3.00,
      'name': 'Superfosfato Simples',
    },
    FertilizerType.superTriple: {
      'nutrient': 'P₂O₅',
      'content': 41.0,
      'price_per_kg': 6.50,
      'name': 'Superfosfato Triplo',
    },
    FertilizerType.sulfatoAmonio: {
      'nutrient': 'N',
      'content': 21.0,
      'price_per_kg': 3.50,
      'name': 'Sulfato de Amônio',
    },
    FertilizerType.nitratoAmonio: {
      'nutrient': 'N',
      'content': 33.0,
      'price_per_kg': 5.00,
      'name': 'Nitrato de Amônio',
    },
  };

  /// Calcula dosagem de fertilizante
  static FertilizerDosingResult calculate({
    required double areaHa,
    required FertilizerType fertilizerType,
    required double desiredRateKgHa,
  }) {
    final fertData = fertilizerData[fertilizerType]!;
    final nutrientContent = fertData['content'] as double;
    final pricePerKg = fertData['price_per_kg'] as double;

    // Total de nutriente puro necessário
    final totalNutrientKg = desiredRateKgHa * areaHa;

    // Quantidade de produto comercial necessária
    final productKg = totalNutrientKg / (nutrientContent / 100);

    // Quantidade por hectare
    final productKgHa = desiredRateKgHa / (nutrientContent / 100);

    // Custo estimado
    final estimatedCost = productKg * pricePerKg;

    // Número de sacas (50kg)
    final bagsNeeded = (productKg / 50).ceil();

    // Dicas de aplicação
    final applicationTips = _getApplicationTips(fertilizerType, productKgHa);

    return FertilizerDosingResult(
      totalNutrientKg: double.parse(totalNutrientKg.toStringAsFixed(1)),
      productKg: double.parse(productKg.toStringAsFixed(1)),
      productKgHa: double.parse(productKgHa.toStringAsFixed(1)),
      estimatedCost: double.parse(estimatedCost.toStringAsFixed(2)),
      bagsNeeded: bagsNeeded,
      applicationTips: applicationTips,
    );
  }

  static List<String> _getApplicationTips(
    FertilizerType type,
    double kgHa,
  ) {
    final tips = <String>[];

    // Dicas por tipo de fertilizante
    switch (type) {
      case FertilizerType.urea:
        tips.add('Ureia: Evite aplicar em dias chuvosos (perda por volatilização)');
        tips.add('Incorpore ao solo quando possível para reduzir perdas');
        break;
      case FertilizerType.map:
      case FertilizerType.dap:
        tips.add('Fosfatados: Aplicar no sulco de plantio para melhor aproveitamento');
        break;
      case FertilizerType.kcl:
        tips.add('KCl: Pode ser aplicado em área total ou parcelado');
        break;
      case FertilizerType.sulfatoAmonio:
        tips.add('Sulfato de Amônio: Indicado para solos alcalinos');
        tips.add('Fonte de enxofre (S) além de nitrogênio');
        break;
      case FertilizerType.nitratoAmonio:
        tips.add('Nitrato de Amônio: Absorção rápida, ideal para cobertura');
        break;
      default:
        break;
    }

    // Dicas gerais
    if (kgHa > 400) {
      tips.add('Alta dosagem: Considere parcelar aplicação');
    }
    tips.add('Calibre o distribuidor antes da aplicação');
    tips.add('Use EPI durante o manuseio');

    return tips;
  }

  static String getFertilizerName(FertilizerType type) =>
      fertilizerData[type]!['name'] as String;

  static String getNutrientName(FertilizerType type) =>
      fertilizerData[type]!['nutrient'] as String;

  static double getNutrientContent(FertilizerType type) =>
      fertilizerData[type]!['content'] as double;
}
