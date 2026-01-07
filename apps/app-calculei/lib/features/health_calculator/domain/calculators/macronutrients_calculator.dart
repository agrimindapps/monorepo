/// Calculadora de Macronutrientes
/// Distribui calorias entre carboidratos, proteínas e gorduras
/// Conversão: Carbs = 4 kcal/g, Proteínas = 4 kcal/g, Gorduras = 9 kcal/g
library;

enum DietGoal {
  maintenance, // Manutenção
  weightLoss, // Perda de peso
  weightGain, // Ganho de peso
  muscleGain, // Ganho de massa muscular
  lowCarb, // Low carb
}

class MacroDistribution {
  final int carbsPercent;
  final int proteinPercent;
  final int fatPercent;

  const MacroDistribution({
    required this.carbsPercent,
    required this.proteinPercent,
    required this.fatPercent,
  });
}

class MacronutrientsResult {
  /// Calorias totais do dia
  final double totalCalories;

  /// Carboidratos
  final double carbsGrams;
  final double carbsCalories;
  final int carbsPercent;

  /// Proteínas
  final double proteinGrams;
  final double proteinCalories;
  final int proteinPercent;

  /// Gorduras
  final double fatGrams;
  final double fatCalories;
  final int fatPercent;

  /// Objetivo selecionado
  final DietGoal goal;

  const MacronutrientsResult({
    required this.totalCalories,
    required this.carbsGrams,
    required this.carbsCalories,
    required this.carbsPercent,
    required this.proteinGrams,
    required this.proteinCalories,
    required this.proteinPercent,
    required this.fatGrams,
    required this.fatCalories,
    required this.fatPercent,
    required this.goal,
  });
}

class MacronutrientsCalculator {
  /// Calorias por grama
  static const double carbsCaloriesPerGram = 4.0;
  static const double proteinCaloriesPerGram = 4.0;
  static const double fatCaloriesPerGram = 9.0;

  /// Distribuições padrão por objetivo
  static const Map<DietGoal, MacroDistribution> defaultDistributions = {
    DietGoal.maintenance: MacroDistribution(
      carbsPercent: 50,
      proteinPercent: 25,
      fatPercent: 25,
    ),
    DietGoal.weightLoss: MacroDistribution(
      carbsPercent: 40,
      proteinPercent: 35,
      fatPercent: 25,
    ),
    DietGoal.weightGain: MacroDistribution(
      carbsPercent: 55,
      proteinPercent: 25,
      fatPercent: 20,
    ),
    DietGoal.muscleGain: MacroDistribution(
      carbsPercent: 45,
      proteinPercent: 35,
      fatPercent: 20,
    ),
    DietGoal.lowCarb: MacroDistribution(
      carbsPercent: 20,
      proteinPercent: 40,
      fatPercent: 40,
    ),
  };

  static const Map<DietGoal, String> goalDescriptions = {
    DietGoal.maintenance: 'Manutenção',
    DietGoal.weightLoss: 'Perda de peso',
    DietGoal.weightGain: 'Ganho de peso',
    DietGoal.muscleGain: 'Ganho de massa muscular',
    DietGoal.lowCarb: 'Low Carb',
  };

  /// Calcula distribuição de macronutrientes
  static MacronutrientsResult calculate({
    required double dailyCalories,
    required DietGoal goal,
    MacroDistribution? customDistribution,
  }) {
    final distribution = customDistribution ?? defaultDistributions[goal]!;

    // Calcular calorias por macro
    final carbsCalories = dailyCalories * (distribution.carbsPercent / 100);
    final proteinCalories =
        dailyCalories * (distribution.proteinPercent / 100);
    final fatCalories = dailyCalories * (distribution.fatPercent / 100);

    // Converter para gramas
    final carbsGrams = carbsCalories / carbsCaloriesPerGram;
    final proteinGrams = proteinCalories / proteinCaloriesPerGram;
    final fatGrams = fatCalories / fatCaloriesPerGram;

    return MacronutrientsResult(
      totalCalories: dailyCalories,
      carbsGrams: double.parse(carbsGrams.toStringAsFixed(0)),
      carbsCalories: double.parse(carbsCalories.toStringAsFixed(0)),
      carbsPercent: distribution.carbsPercent,
      proteinGrams: double.parse(proteinGrams.toStringAsFixed(0)),
      proteinCalories: double.parse(proteinCalories.toStringAsFixed(0)),
      proteinPercent: distribution.proteinPercent,
      fatGrams: double.parse(fatGrams.toStringAsFixed(0)),
      fatCalories: double.parse(fatCalories.toStringAsFixed(0)),
      fatPercent: distribution.fatPercent,
      goal: goal,
    );
  }

  /// Calcula macros com distribuição personalizada
  static MacronutrientsResult calculateCustom({
    required double dailyCalories,
    required int carbsPercent,
    required int proteinPercent,
    required int fatPercent,
  }) {
    // Validar que soma = 100%
    final total = carbsPercent + proteinPercent + fatPercent;
    if (total != 100) {
      throw ArgumentError(
        'A soma das porcentagens deve ser 100%. Atual: $total%',
      );
    }

    return calculate(
      dailyCalories: dailyCalories,
      goal: DietGoal.maintenance,
      customDistribution: MacroDistribution(
        carbsPercent: carbsPercent,
        proteinPercent: proteinPercent,
        fatPercent: fatPercent,
      ),
    );
  }

  static String getGoalDescription(DietGoal goal) {
    return goalDescriptions[goal]!;
  }

  /// Dicas por objetivo
  static List<String> getTipsForGoal(DietGoal goal) {
    return switch (goal) {
      DietGoal.maintenance => [
        'Mantenha consistência nas refeições',
        'Priorize proteínas em cada refeição',
        'Inclua vegetais em abundância',
      ],
      DietGoal.weightLoss => [
        'Aumente proteínas para preservar massa muscular',
        'Prefira carboidratos complexos',
        'Mantenha déficit calórico moderado (300-500 kcal)',
      ],
      DietGoal.weightGain => [
        'Faça refeições frequentes (5-6x ao dia)',
        'Inclua carboidratos pós-treino',
        'Não pule o café da manhã',
      ],
      DietGoal.muscleGain => [
        'Consuma 1.6-2.2g de proteína por kg',
        'Distribua proteínas ao longo do dia',
        'Treine com progressão de carga',
      ],
      DietGoal.lowCarb => [
        'Foco em gorduras saudáveis (azeite, abacate, castanhas)',
        'Evite açúcares e farinhas refinadas',
        'Mantenha hidratação adequada',
      ],
    };
  }
}
