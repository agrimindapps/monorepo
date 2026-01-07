/// Calculadora de Taxa de Semeadura
/// Calcula quantidade de sementes necessárias por área
library;

enum SeedCropType {
  corn, // Milho
  soybean, // Soja
  wheat, // Trigo
  rice, // Arroz
  beans, // Feijão
  cotton, // Algodão
  sunflower, // Girassol
  sorghum, // Sorgo
}

class SeedRateResult {
  /// Sementes por hectare
  final int seedsPerHa;

  /// Peso por hectare (kg/ha)
  final double weightKgHa;

  /// Total de sementes para área
  final int totalSeeds;

  /// Peso total (kg)
  final double totalWeightKg;

  /// Eficiência de estabelecimento (%)
  final double establishmentEfficiency;

  /// Índice de qualidade (0-100)
  final double qualityIndex;

  /// Classificação de qualidade
  final String qualityClass;

  /// Recomendações
  final List<String> recommendations;

  const SeedRateResult({
    required this.seedsPerHa,
    required this.weightKgHa,
    required this.totalSeeds,
    required this.totalWeightKg,
    required this.establishmentEfficiency,
    required this.qualityIndex,
    required this.qualityClass,
    required this.recommendations,
  });
}

class SeedRateCalculator {
  // Peso de 1000 sementes padrão por cultura (gramas)
  static const Map<SeedCropType, double> defaultThousandSeedWeight = {
    SeedCropType.corn: 320.0,
    SeedCropType.soybean: 180.0,
    SeedCropType.wheat: 40.0,
    SeedCropType.rice: 28.0,
    SeedCropType.beans: 280.0,
    SeedCropType.cotton: 100.0,
    SeedCropType.sunflower: 70.0,
    SeedCropType.sorghum: 30.0,
  };

  // População recomendada por cultura (plantas/ha)
  static const Map<SeedCropType, int> recommendedPopulation = {
    SeedCropType.corn: 65000,
    SeedCropType.soybean: 300000,
    SeedCropType.wheat: 3500000,
    SeedCropType.rice: 1500000,
    SeedCropType.beans: 240000,
    SeedCropType.cotton: 100000,
    SeedCropType.sunflower: 50000,
    SeedCropType.sorghum: 180000,
  };

  static const Map<SeedCropType, String> cropNames = {
    SeedCropType.corn: 'Milho',
    SeedCropType.soybean: 'Soja',
    SeedCropType.wheat: 'Trigo',
    SeedCropType.rice: 'Arroz',
    SeedCropType.beans: 'Feijão',
    SeedCropType.cotton: 'Algodão',
    SeedCropType.sunflower: 'Girassol',
    SeedCropType.sorghum: 'Sorgo',
  };

  /// Calcula taxa de semeadura
  static SeedRateResult calculate({
    required SeedCropType crop,
    required int targetPopulation, // plantas/ha desejadas
    required double germinationRate, // % (0-100)
    required double seedPurity, // % (0-100)
    required double fieldLosses, // % (0-30)
    required double thousandSeedWeight, // gramas
    required double areaHa,
    double safetyMargin = 5.0, // % margem de segurança
  }) {
    // Converter para decimais
    final germination = germinationRate / 100;
    final purity = seedPurity / 100;
    final losses = fieldLosses / 100;
    final margin = safetyMargin / 100;

    // Eficiência de estabelecimento
    final efficiency = germination * purity * (1 - losses);

    // Sementes necessárias por hectare
    final seedsPerHa = (targetPopulation / efficiency * (1 + margin)).round();

    // Peso por hectare (kg/ha)
    final weightKgHa = (seedsPerHa * thousandSeedWeight) / 1000000;

    // Totais para área
    final totalSeeds = (seedsPerHa * areaHa).round();
    final totalWeightKg = weightKgHa * areaHa;

    // Índice de qualidade (média ponderada)
    final qualityIndex = (germinationRate * 0.4) +
        (seedPurity * 0.3) +
        ((100 - fieldLosses) * 0.3);

    final qualityClass = _getQualityClass(qualityIndex);
    final recommendations = _getRecommendations(
      efficiency * 100,
      qualityIndex,
      crop,
    );

    return SeedRateResult(
      seedsPerHa: seedsPerHa,
      weightKgHa: double.parse(weightKgHa.toStringAsFixed(2)),
      totalSeeds: totalSeeds,
      totalWeightKg: double.parse(totalWeightKg.toStringAsFixed(2)),
      establishmentEfficiency: double.parse((efficiency * 100).toStringAsFixed(1)),
      qualityIndex: double.parse(qualityIndex.toStringAsFixed(1)),
      qualityClass: qualityClass,
      recommendations: recommendations,
    );
  }

  static String _getQualityClass(double index) {
    if (index >= 90) return 'Excelente';
    if (index >= 75) return 'Boa';
    if (index >= 60) return 'Regular';
    return 'Ruim';
  }

  static List<String> _getRecommendations(
    double efficiency,
    double qualityIndex,
    SeedCropType crop,
  ) {
    final recs = <String>[];

    if (efficiency < 70) {
      recs.add('⚠️ Baixa eficiência - verificar qualidade das sementes');
    }

    if (qualityIndex < 70) {
      recs.add('⚠️ Qualidade comprometida - considerar novo lote');
    }

    recs.add('Realizar teste de germinação antes do plantio');
    recs.add('Calibrar equipamentos para distribuição uniforme');
    recs.add('Monitorar emergência para confirmar estabelecimento');

    // Específicas por cultura
    if (crop == SeedCropType.corn) {
      recs.add('Espaçamento recomendado: 70-90 cm entre linhas');
    }
    if (crop == SeedCropType.soybean) {
      recs.add('Tratar sementes com inoculante e fungicida');
    }

    return recs;
  }

  static String getCropName(SeedCropType crop) => cropNames[crop]!;
  
  static double getDefaultSeedWeight(SeedCropType crop) =>
      defaultThousandSeedWeight[crop]!;
      
  static int getRecommendedPopulation(SeedCropType crop) =>
      recommendedPopulation[crop]!;
}
