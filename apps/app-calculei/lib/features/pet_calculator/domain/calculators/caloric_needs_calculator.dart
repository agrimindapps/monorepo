/// Calculadora de Necessidades Calóricas de Pets
/// Calcula a energia diária necessária para cães e gatos
library;

enum PetSpecies { dog, cat }

enum LifeStage {
  puppy,
  young,
  adult,
  senior,
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
}

class CaloricNeedsResult {
  /// Requerimento Energético em Repouso (RER) em kcal/dia
  final double rer;

  /// Requerimento Energético Diário (DER) em kcal/dia
  final double der;

  /// Estágio de vida do pet
  final String lifeStageText;

  /// Nível de atividade
  final String activityLevelText;

  /// Recomendações alimentares
  final List<String> recommendations;

  /// Quantidade aproximada de ração (gramas/dia)
  final double foodAmountGrams;

  const CaloricNeedsResult({
    required this.rer,
    required this.der,
    required this.lifeStageText,
    required this.activityLevelText,
    required this.recommendations,
    required this.foodAmountGrams,
  });
}

class CaloricNeedsCalculator {
  /// Multiplicadores por estágio de vida
  static const Map<LifeStage, double> _lifeStageMultipliers = {
    LifeStage.puppy: 3.0,
    LifeStage.young: 2.0,
    LifeStage.adult: 1.6,
    LifeStage.senior: 1.4,
  };

  /// Multiplicadores por nível de atividade
  static const Map<ActivityLevel, double> _activityMultipliers = {
    ActivityLevel.sedentary: 0.8,
    ActivityLevel.light: 1.0,
    ActivityLevel.moderate: 1.2,
    ActivityLevel.active: 1.4,
  };

  /// Fator de redução para pets castrados
  static const double _neuteredFactor = 0.9;

  /// Kcal médio por grama de ração seca
  static const double _averageKcalPerGram = 3.5;

  /// Calcula as necessidades calóricas do pet
  static CaloricNeedsResult calculate({
    required double weightKg,
    required PetSpecies species,
    required LifeStage lifeStage,
    required ActivityLevel activityLevel,
    required bool isNeutered,
  }) {
    // Validação
    if (weightKg <= 0 || weightKg > 100) {
      throw ArgumentError('Peso deve estar entre 0 e 100 kg');
    }

    // Cálculo do RER (Resting Energy Requirement)
    // RER = 70 × peso^0.75
    final rer = 70 * _power(weightKg, 0.75);

    // Cálculo do DER (Daily Energy Requirement)
    final lifeStageMultiplier = _lifeStageMultipliers[lifeStage]!;
    final activityMultiplier = _activityMultipliers[activityLevel]!;
    final neuteredMultiplier = isNeutered ? _neuteredFactor : 1.0;

    final der = rer *
        lifeStageMultiplier *
        activityMultiplier *
        neuteredMultiplier;

    final lifeStageText = _getLifeStageText(lifeStage);
    final activityLevelText = _getActivityLevelText(activityLevel);
    final recommendations = _getRecommendations(
      species,
      lifeStage,
      activityLevel,
      isNeutered,
    );

    // Quantidade de ração em gramas
    final foodAmountGrams = der / _averageKcalPerGram;

    return CaloricNeedsResult(
      rer: rer,
      der: der,
      lifeStageText: lifeStageText,
      activityLevelText: activityLevelText,
      recommendations: recommendations,
      foodAmountGrams: foodAmountGrams,
    );
  }

  static double _power(double base, double exponent) {
    // Implementação simples de potência para evitar import math
    // x^0.75 = x^(3/4) = (x^3)^(1/4)
    if (exponent == 0.75) {
      final cubed = base * base * base;
      return _nthRoot(cubed, 4);
    }
    return base;
  }

  static double _nthRoot(double x, int n) {
    // Método de Newton-Raphson para raiz n-ésima
    double guess = x / n;
    for (int i = 0; i < 10; i++) {
      double nextGuess = ((n - 1) * guess + x / _pow(guess, n - 1)) / n;
      if ((nextGuess - guess).abs() < 0.0001) break;
      guess = nextGuess;
    }
    return guess;
  }

  static double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  static String _getLifeStageText(LifeStage stage) {
    return switch (stage) {
      LifeStage.puppy => 'Filhote (até 1 ano)',
      LifeStage.young => 'Jovem (1-2 anos)',
      LifeStage.adult => 'Adulto (2-7 anos)',
      LifeStage.senior => 'Idoso (7+ anos)',
    };
  }

  static String _getActivityLevelText(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentário (pouca atividade)',
      ActivityLevel.light => 'Leve (passeios curtos)',
      ActivityLevel.moderate => 'Moderado (passeios diários)',
      ActivityLevel.active => 'Ativo (exercícios intensos)',
    };
  }

  static List<String> _getRecommendations(
    PetSpecies species,
    LifeStage lifeStage,
    ActivityLevel activityLevel,
    bool isNeutered,
  ) {
    final pet = species == PetSpecies.dog ? 'cão' : 'gato';
    final recommendations = <String>[
      'Divida a porção diária em 2-3 refeições',
      'Sempre deixe água fresca disponível',
      'Ajuste a quantidade conforme peso e atividade',
    ];

    if (lifeStage == LifeStage.puppy) {
      recommendations.add('Use ração específica para filhotes');
      recommendations.add('Consulte o veterinário sobre suplementação');
    }

    if (lifeStage == LifeStage.senior) {
      recommendations.add('Considere ração para $pet idoso');
      recommendations.add('Monitore mudanças no apetite');
    }

    if (isNeutered) {
      recommendations.add('Pets castrados têm menor gasto energético');
      recommendations.add('Monitore o peso regularmente');
    }

    if (activityLevel == ActivityLevel.active) {
      recommendations.add('Considere suplementação para pets ativos');
      recommendations.add('Aumente hidratação após exercícios');
    }

    return recommendations;
  }
}
