/// Calculadora de Peso Ideal para Pets
/// Estima o peso ideal baseado em ECC e características do pet
library;

enum PetSpecies { dog, cat }

enum BreedSize { small, medium, large, giant }

class PetIdealWeightResult {
  /// Peso ideal estimado (kg)
  final double idealWeight;

  /// Peso mínimo saudável (kg)
  final double minIdealWeight;

  /// Peso máximo saudável (kg)
  final double maxIdealWeight;

  /// Peso a perder/ganhar (kg) - negativo = perder, positivo = ganhar
  final double weightChange;

  /// Percentual de mudança necessária
  final double changePercentage;

  /// Classificação atual
  final String currentClassification;

  /// Recomendações
  final List<String> recommendations;

  /// Meta é perder peso?
  final bool shouldLoseWeight;

  /// Meta é ganhar peso?
  final bool shouldGainWeight;

  const PetIdealWeightResult({
    required this.idealWeight,
    required this.minIdealWeight,
    required this.maxIdealWeight,
    required this.weightChange,
    required this.changePercentage,
    required this.currentClassification,
    required this.recommendations,
    required this.shouldLoseWeight,
    required this.shouldGainWeight,
  });
}

class PetIdealWeightCalculator {
  /// Faixas de peso ideais por porte (para cães)
  static const Map<BreedSize, Map<String, double>> _breedSizeRanges = {
    BreedSize.small: {'min': 2.0, 'max': 10.0},
    BreedSize.medium: {'min': 10.0, 'max': 25.0},
    BreedSize.large: {'min': 25.0, 'max': 45.0},
    BreedSize.giant: {'min': 45.0, 'max': 90.0},
  };

  /// Faixa ideal para gatos
  static const Map<String, double> _catWeightRange = {'min': 3.0, 'max': 7.0};

  /// Calcula o peso ideal do pet
  static PetIdealWeightResult calculate({
    required PetSpecies species,
    required BreedSize breedSize,
    required double currentWeight,
    required int bcsScore,
  }) {
    // Validação
    if (currentWeight <= 0 || currentWeight > 100) {
      throw ArgumentError('Peso deve estar entre 0 e 100 kg');
    }
    if (bcsScore < 1 || bcsScore > 9) {
      throw ArgumentError('BCS deve estar entre 1 e 9');
    }

    // Cálculo do peso ideal baseado no BCS
    // BCS 5 = ideal, cada ponto acima/abaixo = ~10% de diferença
    // Fórmula: idealWeight = currentWeight × (1 - ((BCS - 5) × 0.1))
    final bcsDeviation = bcsScore - 5;
    final idealWeight = currentWeight * (1 - (bcsDeviation * 0.1));

    // Faixa de peso ideal baseada na raça/porte
    final Map<String, double> weightRange = species == PetSpecies.cat
        ? _catWeightRange
        : _breedSizeRanges[breedSize]!;

    double minIdealWeight = weightRange['min']!;
    double maxIdealWeight = weightRange['max']!;

    // Ajusta faixa se o peso ideal calculado estiver fora dos limites
    if (idealWeight < minIdealWeight) {
      minIdealWeight = idealWeight * 0.95;
      maxIdealWeight = idealWeight * 1.05;
    } else if (idealWeight > maxIdealWeight) {
      minIdealWeight = idealWeight * 0.95;
      maxIdealWeight = idealWeight * 1.05;
    } else {
      // Faixa de ±5% em torno do peso ideal
      minIdealWeight = idealWeight * 0.95;
      maxIdealWeight = idealWeight * 1.05;
    }

    // Peso a mudar
    final weightChange = idealWeight - currentWeight;
    final changePercentage = (weightChange / currentWeight * 100).abs();

    final shouldLoseWeight = weightChange < -0.5;
    final shouldGainWeight = weightChange > 0.5;

    final currentClassification = _getBcsClassification(bcsScore);
    final recommendations = _getRecommendations(
      species,
      bcsScore,
      shouldLoseWeight,
      shouldGainWeight,
      weightChange.abs(),
    );

    return PetIdealWeightResult(
      idealWeight: idealWeight,
      minIdealWeight: minIdealWeight,
      maxIdealWeight: maxIdealWeight,
      weightChange: weightChange,
      changePercentage: changePercentage,
      currentClassification: currentClassification,
      recommendations: recommendations,
      shouldLoseWeight: shouldLoseWeight,
      shouldGainWeight: shouldGainWeight,
    );
  }

  static String _getBcsClassification(int bcs) {
    if (bcs <= 3) return 'Abaixo do Peso (BCS $bcs/9)';
    if (bcs <= 5) return 'Peso Ideal (BCS $bcs/9)';
    if (bcs <= 7) return 'Sobrepeso (BCS $bcs/9)';
    return 'Obesidade (BCS $bcs/9)';
  }

  static List<String> _getRecommendations(
    PetSpecies species,
    int bcsScore,
    bool shouldLoseWeight,
    bool shouldGainWeight,
    double weightChangeAbs,
  ) {
    final recommendations = <String>[];

    if (shouldLoseWeight) {
      recommendations.add('🎯 META: Perda de peso gradual e saudável');
      recommendations.add('Reduza ração em 10-25% ou use ração light');
      recommendations.add('Evite petiscos e comida humana');
      recommendations.add('Aumente exercícios progressivamente');
      recommendations.add('Meta saudável: perder 1-2% do peso por semana');

      if (weightChangeAbs > 2.0) {
        recommendations.add(
          '⚠️ Perda significativa necessária - acompanhamento veterinário',
        );
      }

      recommendations.add('Monitore o peso semanalmente');
      recommendations.add('Consulte veterinário para plano alimentar');
    } else if (shouldGainWeight) {
      recommendations.add('🎯 META: Ganho de peso controlado');
      recommendations.add('Aumente a frequência das refeições');
      recommendations.add('Considere ração hipercalórica');
      recommendations.add('Descarte causas médicas (parasitas, doenças)');
      recommendations.add('Ofereça alimentação palatável e aquecida');
      recommendations.add('⚠️ Consulte veterinário para investigar a causa');
    } else {
      recommendations.add('✅ Peso atual está na faixa ideal!');
      recommendations.add('Mantenha a dieta e rotina atuais');
      recommendations.add('Continue exercícios regulares');
      recommendations.add('Monitore o peso mensalmente');
      recommendations.add('Ajuste porções se houver mudança de atividade');
    }

    recommendations.add(
      'Peso ideal varia entre indivíduos - considere estrutura óssea',
    );
    recommendations.add(
      'Use BCS (Escore de Condição Corporal) além da balança',
    );

    return recommendations;
  }

  static String getBreedSizeDescription(BreedSize size) {
    return switch (size) {
      BreedSize.small => 'Pequeno (até 10kg)',
      BreedSize.medium => 'Médio (10-25kg)',
      BreedSize.large => 'Grande (25-45kg)',
      BreedSize.giant => 'Gigante (45kg+)',
    };
  }
}
