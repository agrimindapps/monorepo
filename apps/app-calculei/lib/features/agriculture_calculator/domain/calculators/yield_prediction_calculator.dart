/// Calculadora de Previsão de Produtividade
/// Estima produção líquida considerando perdas
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

class YieldPredictionResult {
  /// Produção bruta total (kg)
  final double grossYieldKg;

  /// Produção bruta total (toneladas)
  final double grossYieldTon;

  /// Perdas estimadas (kg)
  final double lossKg;

  /// Produção líquida (kg)
  final double netYieldKg;

  /// Produção líquida (toneladas)
  final double netYieldTon;

  /// Produção líquida por hectare (kg/ha)
  final double netYieldKgHa;

  /// Valor estimado da produção (R$)
  final double estimatedValue;

  /// Recomendações
  final List<String> recommendations;

  const YieldPredictionResult({
    required this.grossYieldKg,
    required this.grossYieldTon,
    required this.lossKg,
    required this.netYieldKg,
    required this.netYieldTon,
    required this.netYieldKgHa,
    required this.estimatedValue,
    required this.recommendations,
  });
}

class YieldPredictionCalculator {
  // Preços médios de referência (R$/saca 60kg)
  static const Map<CropType, double> referencePrices = {
    CropType.corn: 75.00,
    CropType.soybean: 150.00,
    CropType.wheat: 80.00,
    CropType.rice: 90.00,
    CropType.beans: 180.00,
    CropType.coffee: 1200.00, // por saca
    CropType.sugarcane: 45.00, // por tonelada
    CropType.cotton: 130.00, // por arroba (15kg)
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

  /// Calcula previsão de produtividade
  static YieldPredictionResult calculate({
    required CropType cropType,
    required double areaHa,
    required double expectedYieldKgHa,
    required double lossPercentage,
  }) {
    // Produção bruta
    final grossYieldKg = expectedYieldKgHa * areaHa;
    final grossYieldTon = grossYieldKg / 1000;

    // Perdas
    final lossKg = grossYieldKg * (lossPercentage / 100);

    // Produção líquida
    final netYieldKg = grossYieldKg - lossKg;
    final netYieldTon = netYieldKg / 1000;
    final netYieldKgHa = netYieldKg / areaHa;

    // Valor estimado
    final estimatedValue = _calculateValue(cropType, netYieldKg);

    // Recomendações
    final recommendations = _getRecommendations(
      cropType,
      lossPercentage,
      netYieldKgHa,
    );

    return YieldPredictionResult(
      grossYieldKg: double.parse(grossYieldKg.toStringAsFixed(1)),
      grossYieldTon: double.parse(grossYieldTon.toStringAsFixed(2)),
      lossKg: double.parse(lossKg.toStringAsFixed(1)),
      netYieldKg: double.parse(netYieldKg.toStringAsFixed(1)),
      netYieldTon: double.parse(netYieldTon.toStringAsFixed(2)),
      netYieldKgHa: double.parse(netYieldKgHa.toStringAsFixed(1)),
      estimatedValue: double.parse(estimatedValue.toStringAsFixed(2)),
      recommendations: recommendations,
    );
  }

  static double _calculateValue(CropType crop, double netYieldKg) {
    final refPrice = referencePrices[crop]!;

    switch (crop) {
      case CropType.coffee:
        // Café: saca de 60kg
        final bags = netYieldKg / 60;
        return bags * refPrice;
      
      case CropType.sugarcane:
        // Cana: preço por tonelada
        final tons = netYieldKg / 1000;
        return tons * refPrice;
      
      case CropType.cotton:
        // Algodão: preço por arroba (15kg)
        final arrobas = netYieldKg / 15;
        return arrobas * refPrice;
      
      default:
        // Demais: saca de 60kg
        final bags = netYieldKg / 60;
        return bags * refPrice;
    }
  }

  static List<String> _getRecommendations(
    CropType crop,
    double lossPercentage,
    double netYieldKgHa,
  ) {
    final recommendations = <String>[];

    // Análise de perdas
    if (lossPercentage > 15) {
      recommendations.add('Perdas altas: Revise práticas de colheita e armazenamento');
    } else if (lossPercentage > 8) {
      recommendations.add('Perdas moderadas: Considere melhorias na colheita');
    } else if (lossPercentage > 3) {
      recommendations.add('Perdas normais: Mantenha boas práticas');
    } else {
      recommendations.add('Perdas baixas: Excelente eficiência!');
    }

    // Dicas por cultura
    if (crop == CropType.soybean || crop == CropType.beans) {
      recommendations.add('Leguminosas: Colha no momento adequado para evitar debulha');
    }
    if (crop == CropType.corn) {
      recommendations.add('Milho: Regule colheitadeira para minimizar grãos partidos');
    }
    if (crop == CropType.coffee) {
      recommendations.add('Café: Secagem adequada é crucial para qualidade');
    }

    // Recomendações gerais
    recommendations.add('Monitore condições climáticas no período de colheita');
    recommendations.add('Planeje logística de armazenamento antecipadamente');

    return recommendations;
  }

  static String getCropName(CropType crop) => cropNames[crop]!;
}
