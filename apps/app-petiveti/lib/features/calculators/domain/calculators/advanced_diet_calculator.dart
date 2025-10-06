import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator_input.dart';
import 'base_calculator.dart';

enum AnimalSpecies {
  dog,
  cat,
}

enum LifeStage {
  puppy, // 0-12 meses
  adult, // 1-7 anos
  senior, // 7+ anos
  geriatric, // 10+ anos
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
  working,
}

enum BodyCondition {
  underweight, // BCS 1-3
  ideal, // BCS 4-5
  overweight, // BCS 6-7
  obese, // BCS 8-9
}

enum DietType {
  commercial,
  homemade,
  raw,
  mixed,
}

enum HealthCondition {
  healthy,
  kidneyDisease,
  diabetes,
  heartDisease,
  liverDisease,
  allergies,
  gastrointestinal,
  cancer,
}

class AdvancedDietInput extends CalculatorInput {
  final AnimalSpecies species;
  final double weight;
  final double? idealWeight;
  final LifeStage lifeStage;
  final ActivityLevel activityLevel;
  final BodyCondition bodyCondition;
  final DietType dietType;
  final HealthCondition healthCondition;
  final bool isNeutered;
  final bool isPregnant;
  final bool isLactating;
  final int? numberOfPuppies;
  final double? currentDailyCalories;
  final List<String>? allergies;
  final List<String>? medications;

  const AdvancedDietInput({
    required this.species,
    required this.weight,
    this.idealWeight,
    required this.lifeStage,
    required this.activityLevel,
    required this.bodyCondition,
    required this.dietType,
    required this.healthCondition,
    this.isNeutered = false,
    this.isPregnant = false,
    this.isLactating = false,
    this.numberOfPuppies,
    this.currentDailyCalories,
    this.allergies,
    this.medications,
  });

  @override
  List<Object?> get props => [
        species,
        weight,
        idealWeight,
        lifeStage,
        activityLevel,
        bodyCondition,
        dietType,
        healthCondition,
        isNeutered,
        isPregnant,
        isLactating,
        numberOfPuppies,
        currentDailyCalories,
        allergies,
        medications,
      ];

  @override
  Map<String, dynamic> toMap() {
    return {
      'species': species.name,
      'weight': weight,
      'idealWeight': idealWeight,
      'lifeStage': lifeStage.name,
      'activityLevel': activityLevel.name,
      'bodyCondition': bodyCondition.name,
      'dietType': dietType.name,
      'healthCondition': healthCondition.name,
      'isNeutered': isNeutered,
      'isPregnant': isPregnant,
      'isLactating': isLactating,
      'numberOfPuppies': numberOfPuppies,
      'currentDailyCalories': currentDailyCalories,
      'allergies': allergies,
      'medications': medications,
    };
  }

  @override
  AdvancedDietInput copyWith({
    AnimalSpecies? species,
    double? weight,
    double? idealWeight,
    LifeStage? lifeStage,
    ActivityLevel? activityLevel,
    BodyCondition? bodyCondition,
    DietType? dietType,
    HealthCondition? healthCondition,
    bool? isNeutered,
    bool? isPregnant,
    bool? isLactating,
    int? numberOfPuppies,
    double? currentDailyCalories,
    List<String>? allergies,
    List<String>? medications,
  }) {
    return AdvancedDietInput(
      species: species ?? this.species,
      weight: weight ?? this.weight,
      idealWeight: idealWeight ?? this.idealWeight,
      lifeStage: lifeStage ?? this.lifeStage,
      activityLevel: activityLevel ?? this.activityLevel,
      bodyCondition: bodyCondition ?? this.bodyCondition,
      dietType: dietType ?? this.dietType,
      healthCondition: healthCondition ?? this.healthCondition,
      isNeutered: isNeutered ?? this.isNeutered,
      isPregnant: isPregnant ?? this.isPregnant,
      isLactating: isLactating ?? this.isLactating,
      numberOfPuppies: numberOfPuppies ?? this.numberOfPuppies,
      currentDailyCalories: currentDailyCalories ?? this.currentDailyCalories,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
    );
  }
}

class AdvancedDietResult extends CalculationResult {
  final double dailyCalories;
  final double proteinRequirement; // gramas
  final double fatRequirement; // gramas
  final double carbohydrateRequirement; // gramas
  final double fiberRequirement; // gramas
  final Map<String, double> vitamins; // UI ou mg
  final Map<String, double> minerals; // mg
  final double dailyWaterRequirement; // mL
  final int mealsPerDay;
  final double gramsPerMeal;
  final List<String> recommendedIngredients;
  final List<String> avoidedIngredients;
  final List<String> supplementRecommendations;
  final List<String> feedingInstructions;
  final Map<String, String> macronutrientBreakdown;
  final List<String> specialConsiderations;

  const AdvancedDietResult({
    required this.dailyCalories,
    required this.proteinRequirement,
    required this.fatRequirement,
    required this.carbohydrateRequirement,
    required this.fiberRequirement,
    required this.vitamins,
    required this.minerals,
    required this.dailyWaterRequirement,
    required this.mealsPerDay,
    required this.gramsPerMeal,
    required this.recommendedIngredients,
    required this.avoidedIngredients,
    required this.supplementRecommendations,
    required this.feedingInstructions,
    required this.macronutrientBreakdown,
    required this.specialConsiderations,
    required super.calculatorId,
    required super.results,
    super.recommendations = const [],
    super.summary,
    super.calculatedAt,
  });

  @override
  List<Object?> get props => [
        dailyCalories,
        proteinRequirement,
        fatRequirement,
        carbohydrateRequirement,
        fiberRequirement,
        vitamins,
        minerals,
        dailyWaterRequirement,
        mealsPerDay,
        gramsPerMeal,
        recommendedIngredients,
        avoidedIngredients,
        supplementRecommendations,
        feedingInstructions,
        macronutrientBreakdown,
        specialConsiderations,
        ...super.props,
      ];
}

class AdvancedDietCalculator extends BaseCalculator<AdvancedDietInput, AdvancedDietResult> {
  @override
  String get id => 'advanced_diet';

  @override
  String get name => 'Calculadora Avançada de Dieta';

  @override
  String get description => 'Calcula necessidades nutricionais completas baseadas em condições específicas';

  @override
  AdvancedDietResult performCalculation(AdvancedDietInput input) {
    _validateInput(input);
    final dailyCalories = _calculateDailyCalories(input);
    final macronutrients = _calculateMacronutrients(input, dailyCalories);
    final vitamins = _calculateVitamins(input);
    final minerals = _calculateMinerals(input);
    final waterRequirement = _calculateWaterRequirement(input);
    final mealsPerDay = _determineMealsPerDay(input);
    final gramsPerMeal = _calculateGramsPerMeal(input, dailyCalories);
    final recommendedIngredients = _getRecommendedIngredients(input);
    final avoidedIngredients = _getAvoidedIngredients(input);
    final supplementRecommendations = _getSupplementRecommendations(input);
    final feedingInstructions = _getFeedingInstructions(input);
    final macroBreakdown = _getMacronutrientBreakdown(macronutrients);
    final specialConsiderations = _getSpecialConsiderations(input);
    final results = <ResultItem>[
      ResultItem(
        label: 'Calorias Diárias',
        value: dailyCalories.round(),
        unit: 'kcal/dia',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Proteína',
        value: macronutrients['protein']!.toStringAsFixed(1),
        unit: 'g/dia',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Gordura',
        value: macronutrients['fat']!.toStringAsFixed(1),
        unit: 'g/dia',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Refeições por Dia',
        value: mealsPerDay,
        unit: 'refeições',
        severity: ResultSeverity.info,
      ),
    ];

    return AdvancedDietResult(
      dailyCalories: dailyCalories,
      proteinRequirement: macronutrients['protein']!,
      fatRequirement: macronutrients['fat']!,
      carbohydrateRequirement: macronutrients['carbohydrate']!,
      fiberRequirement: macronutrients['fiber']!,
      vitamins: vitamins,
      minerals: minerals,
      dailyWaterRequirement: waterRequirement,
      mealsPerDay: mealsPerDay,
      gramsPerMeal: gramsPerMeal,
      recommendedIngredients: recommendedIngredients,
      avoidedIngredients: avoidedIngredients,
      supplementRecommendations: supplementRecommendations,
      feedingInstructions: feedingInstructions,
      macronutrientBreakdown: macroBreakdown,
      specialConsiderations: specialConsiderations,
      calculatorId: 'advanced_diet',
      results: results,
      summary: 'Dieta: ${dailyCalories.round()} kcal/dia - ${mealsPerDay}x ${gramsPerMeal.round()}g',
      calculatedAt: DateTime.now(),
    );
  }

  void _validateInput(AdvancedDietInput input) {
    if (input.weight <= 0) {
      throw ArgumentError('Peso deve ser maior que zero');
    }
    if (input.idealWeight != null && input.idealWeight! <= 0) {
      throw ArgumentError('Peso ideal deve ser maior que zero');
    }
    if (input.isLactating && input.numberOfPuppies == null) {
      throw ArgumentError('Número de filhotes deve ser informado para lactação');
    }
  }

  double _calculateDailyCalories(AdvancedDietInput input) {
    double rer = 70 * math.pow(input.weight, 0.75).toDouble();
    double multiplier = _getCalorieMultiplier(input);
    
    double der = rer * multiplier; // Daily Energy Requirement
    if (input.isPregnant) {
      der *= 1.5;
    }
    
    if (input.isLactating && input.numberOfPuppies != null) {
      der = rer * (1.2 + 0.3 * input.numberOfPuppies!);
    }
    if (input.bodyCondition == BodyCondition.overweight) {
      der *= 0.8; // Reduzir 20% para perda de peso
    } else if (input.bodyCondition == BodyCondition.obese) {
      der *= 0.6; // Reduzir 40% para perda de peso significativa
    } else if (input.bodyCondition == BodyCondition.underweight) {
      der *= 1.2; // Aumentar 20% para ganho de peso
    }
    if (input.healthCondition == HealthCondition.diabetes) {
      der *= 0.9; // Ligeira redução para controle glicêmico
    } else if (input.healthCondition == HealthCondition.kidneyDisease) {
      der *= 0.9; // Redução moderada
    }
    
    return der;
  }

  double _getCalorieMultiplier(AdvancedDietInput input) {
    double multiplier = 1.0;
    switch (input.lifeStage) {
      case LifeStage.puppy:
        multiplier = input.species == AnimalSpecies.dog ? 3.0 : 2.5;
        break;
      case LifeStage.adult:
        multiplier = 1.8;
        break;
      case LifeStage.senior:
        multiplier = 1.4;
        break;
      case LifeStage.geriatric:
        multiplier = 1.2;
        break;
    }
    switch (input.activityLevel) {
      case ActivityLevel.sedentary:
        multiplier *= 0.8;
        break;
      case ActivityLevel.light:
        multiplier *= 1.0;
        break;
      case ActivityLevel.moderate:
        multiplier *= 1.2;
        break;
      case ActivityLevel.active:
        multiplier *= 1.4;
        break;
      case ActivityLevel.veryActive:
        multiplier *= 1.6;
        break;
      case ActivityLevel.working:
        multiplier *= 2.0;
        break;
    }
    if (input.isNeutered && input.lifeStage == LifeStage.adult) {
      multiplier *= 0.9; // Redução de 10% para animais castrados
    }
    
    return multiplier;
  }

  Map<String, double> _calculateMacronutrients(AdvancedDietInput input, double calories) {
    Map<String, double> percentages = _getMacronutrientPercentages(input);
    
    double proteinCalories = calories * percentages['protein']! / 100;
    double fatCalories = calories * percentages['fat']! / 100;
    double carbCalories = calories * percentages['carbohydrate']! / 100;
    
    return {
      'protein': proteinCalories / 4, // gramas
      'fat': fatCalories / 9, // gramas
      'carbohydrate': carbCalories / 4, // gramas
      'fiber': input.weight * percentages['fiber']!, // gramas baseado no peso
    };
  }

  Map<String, double> _getMacronutrientPercentages(AdvancedDietInput input) {
    Map<String, double> base;
    
    if (input.species == AnimalSpecies.dog) {
      base = {
        'protein': 25.0, // %
        'fat': 15.0, // %
        'carbohydrate': 50.0, // %
        'fiber': 0.5, // g/kg peso
      };
    } else {
      base = {
        'protein': 45.0, // %
        'fat': 20.0, // %
        'carbohydrate': 5.0, // %
        'fiber': 0.3, // g/kg peso
      };
    }
    if (input.lifeStage == LifeStage.puppy) {
      base['protein'] = base['protein']! * 1.5; // Filhotes precisam mais proteína
      base['fat'] = base['fat']! * 1.3;
    } else if (input.lifeStage == LifeStage.senior) {
      base['protein'] = base['protein']! * 1.2; // Idosos precisam proteína de qualidade
    }
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      base['protein'] = base['protein']! * 0.8; // Reduzir proteína
    } else if (input.healthCondition == HealthCondition.diabetes) {
      base['fiber'] = base['fiber']! * 2.0; // Aumentar fibra
      base['carbohydrate'] = base['carbohydrate']! * 0.7; // Reduzir carboidratos
    } else if (input.healthCondition == HealthCondition.gastrointestinal) {
      base['fat'] = base['fat']! * 0.7; // Reduzir gordura
      base['fiber'] = base['fiber']! * 1.5; // Aumentar fibra moderadamente
    }
    
    return base;
  }

  Map<String, double> _calculateVitamins(AdvancedDietInput input) {
    final vitamins = <String, double>{};
    
    vitamins['A'] = input.weight * 100; // UI/kg
    vitamins['D'] = input.weight * 10; // UI/kg
    vitamins['E'] = input.weight * 1; // mg/kg
    vitamins['K'] = input.weight * 0.1; // mg/kg
    vitamins['B1'] = input.weight * 0.02; // mg/kg
    vitamins['B2'] = input.weight * 0.05; // mg/kg
    vitamins['B6'] = input.weight * 0.02; // mg/kg
    vitamins['B12'] = input.weight * 0.0003; // mg/kg
    vitamins['C'] = input.species == AnimalSpecies.cat ? 0 : input.weight * 1; // mg/kg (cães só se estressados)
    vitamins['Folato'] = input.weight * 0.002; // mg/kg
    vitamins['Niacina'] = input.weight * 0.2; // mg/kg
    if (input.isPregnant || input.isLactating) {
      vitamins.forEach((key, value) => vitamins[key] = value * 1.5);
    }
    
    if (input.lifeStage == LifeStage.puppy) {
      vitamins.forEach((key, value) => vitamins[key] = value * 2.0);
    }
    
    return vitamins;
  }

  Map<String, double> _calculateMinerals(AdvancedDietInput input) {
    final minerals = <String, double>{};
    
    minerals['Cálcio'] = input.weight * 120; // mg/kg
    minerals['Fósforo'] = input.weight * 100; // mg/kg
    minerals['Sódio'] = input.weight * 30; // mg/kg
    minerals['Potássio'] = input.weight * 60; // mg/kg
    minerals['Magnésio'] = input.weight * 8; // mg/kg
    minerals['Ferro'] = input.weight * 1.5; // mg/kg
    minerals['Zinco'] = input.weight * 1.5; // mg/kg
    minerals['Cobre'] = input.weight * 0.15; // mg/kg
    minerals['Manganês'] = input.weight * 0.12; // mg/kg
    minerals['Iodo'] = input.weight * 0.035; // mg/kg
    minerals['Selênio'] = input.weight * 0.003; // mg/kg
    if (input.healthCondition == HealthCondition.heartDisease) {
      minerals['Sódio'] = minerals['Sódio']! * 0.5; // Reduzir sódio
    }
    
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      minerals['Fósforo'] = minerals['Fósforo']! * 0.7; // Reduzir fósforo
    }
    
    return minerals;
  }

  double _calculateWaterRequirement(AdvancedDietInput input) {
    double waterNeed = input.weight * 55;
    if (input.dietType == DietType.raw || input.dietType == DietType.homemade) {
      waterNeed *= 0.8; // Alimentos úmidos requerem menos água adicional
    }
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      waterNeed *= 1.5; // Aumentar hidratação
    } else if (input.healthCondition == HealthCondition.diabetes) {
      waterNeed *= 1.3; // Diabéticos bebem mais água
    }
    
    if (input.isLactating) {
      waterNeed *= 2.0; // Lactação requer muito mais água
    }
    
    return waterNeed;
  }

  int _determineMealsPerDay(AdvancedDietInput input) {
    switch (input.lifeStage) {
      case LifeStage.puppy:
        return 4; // Filhotes comem mais frequentemente
      case LifeStage.adult:
        return 2; // Adultos: 2 refeições
      case LifeStage.senior:
      case LifeStage.geriatric:
        return 3; // Idosos: refeições menores mais frequentes
    }
  }

  double _calculateGramsPerMeal(AdvancedDietInput input, double calories) {
    double caloriesPerGram = 3.5;
    
    if (input.dietType == DietType.raw) {
      caloriesPerGram = 2.0; // Dieta crua tem menos densidade calórica
    } else if (input.dietType == DietType.homemade) {
      caloriesPerGram = 2.5; // Caseira intermediária
    }
    
    double totalGrams = calories / caloriesPerGram;
    int mealsPerDay = _determineMealsPerDay(input);
    
    return totalGrams / mealsPerDay;
  }

  List<String> _getRecommendedIngredients(AdvancedDietInput input) {
    final ingredients = <String>[];
    if (input.species == AnimalSpecies.dog) {
      ingredients.addAll([
        '🍖 Frango sem pele',
        '🐟 Peixe (salmão, sardinha)',
        '🥚 Ovos cozidos',
        '🐄 Carne bovina magra',
      ]);
    } else {
      ingredients.addAll([
        '🐟 Peixes gordurosos (salmão, atum)',
        '🍖 Frango com pele',
        '🐄 Carne bovina',
        '🐏 Cordeiro',
      ]);
    }
    if (input.species == AnimalSpecies.dog) {
      ingredients.addAll([
        '🍠 Batata doce',
        '🌾 Arroz integral',
        '🥕 Cenoura',
        '🥒 Abobrinha',
      ]);
    }
    if (input.healthCondition == HealthCondition.diabetes) {
      ingredients.addAll([
        '🥬 Vegetais folhosos',
        '🥦 Brócolis',
        '🫘 Feijão verde',
      ]);
    }
    
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      ingredients.addAll([
        '🐟 Peixes de baixo fósforo',
        '🥚 Clara de ovo',
      ]);
    }
    
    return ingredients;
  }

  List<String> _getAvoidedIngredients(AdvancedDietInput input) {
    final avoided = <String>[
      '🍫 Chocolate',
      '🧄 Alho e cebola',
      '🍇 Uvas e passas',
      '🥑 Abacate',
      '🧂 Alimentos salgados',
    ];
    if (input.allergies != null) {
      avoided.addAll(input.allergies!.map((allergy) => '❌ $allergy'));
    }
    if (input.healthCondition == HealthCondition.diabetes) {
      avoided.addAll([
        '🍬 Açúcares simples',
        '🍞 Pão branco',
        '🥔 Batata comum',
      ]);
    }
    
    if (input.healthCondition == HealthCondition.heartDisease) {
      avoided.addAll([
        '🧂 Alimentos ricos em sódio',
        '🥓 Carnes processadas',
      ]);
    }
    
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      avoided.addAll([
        '🐟 Peixes ricos em fósforo',
        '🥜 Nozes e sementes',
      ]);
    }
    
    return avoided;
  }

  List<String> _getSupplementRecommendations(AdvancedDietInput input) {
    final supplements = <String>[];
    
    if (input.dietType == DietType.homemade || input.dietType == DietType.raw) {
      supplements.addAll([
        '💊 Complexo vitamínico',
        '🦴 Suplemento de cálcio',
        '🐟 Óleo de peixe (ômega-3)',
      ]);
    }
    
    if (input.lifeStage == LifeStage.senior || input.lifeStage == LifeStage.geriatric) {
      supplements.addAll([
        '🦴 Glucosamina/Condroitina',
        '🧠 Antioxidantes',
      ]);
    }
    
    if (input.healthCondition == HealthCondition.kidneyDisease) {
      supplements.addAll([
        '🔗 Quelantes de fósforo',
        '💊 Suporte renal',
      ]);
    }
    
    return supplements;
  }

  List<String> _getFeedingInstructions(AdvancedDietInput input) {
    final instructions = <String>[];
    
    instructions.addAll([
      '⏰ Alimentar em horários regulares',
      '🥛 Água fresca sempre disponível',
      '📏 Medir porções com precisão',
      '⚖️ Monitorar peso semanalmente',
    ]);
    
    if (input.bodyCondition != BodyCondition.ideal) {
      instructions.add('📊 Reavaliar necessidades a cada 2 semanas');
    }
    
    if (input.healthCondition != HealthCondition.healthy) {
      instructions.addAll([
        '🩺 Monitoramento veterinário regular',
        '📋 Manter diário alimentar',
      ]);
    }
    
    return instructions;
  }

  Map<String, String> _getMacronutrientBreakdown(Map<String, double> macros) {
    return {
      'Proteína': '${macros['protein']!.toStringAsFixed(1)}g',
      'Gordura': '${macros['fat']!.toStringAsFixed(1)}g',
      'Carboidrato': '${macros['carbohydrate']!.toStringAsFixed(1)}g',
      'Fibra': '${macros['fiber']!.toStringAsFixed(1)}g',
    };
  }

  List<String> _getSpecialConsiderations(AdvancedDietInput input) {
    final considerations = <String>[];
    
    if (input.isPregnant) {
      considerations.add('🤰 GESTAÇÃO: Aumentar gradualmente a partir da 5ª semana');
    }
    
    if (input.isLactating) {
      considerations.add('🤱 LACTAÇÃO: Alimentação livre durante as primeiras semanas');
    }
    
    if (input.healthCondition != HealthCondition.healthy) {
      considerations.add('🏥 CONDIÇÃO MÉDICA: Acompanhamento veterinário obrigatório');
    }
    
    if (input.bodyCondition != BodyCondition.ideal) {
      considerations.add('⚖️ PESO: Ajustar porções baseado na resposta corporal');
    }
    
    return considerations;
  }

  @override
  List<String> getInputValidationErrors(AdvancedDietInput input) {
    final errors = <String>[];
    if (input.weight <= 0) {
      errors.add('Peso deve ser maior que zero');
    }
    if (input.idealWeight != null && input.idealWeight! <= 0) {
      errors.add('Peso ideal deve ser maior que zero');
    }
    if (input.isLactating && input.numberOfPuppies == null) {
      errors.add('Número de filhotes deve ser informado para lactação');
    }
    return errors;
  }

  @override
  AdvancedDietResult createErrorResult(String message, [AdvancedDietInput? input]) {
    return AdvancedDietResult(
      dailyCalories: 0,
      proteinRequirement: 0,
      fatRequirement: 0,
      carbohydrateRequirement: 0,
      fiberRequirement: 0,
      vitamins: const {},
      minerals: const {},
      dailyWaterRequirement: 0,
      mealsPerDay: 0,
      gramsPerMeal: 0,
      recommendedIngredients: const [],
      avoidedIngredients: const [],
      supplementRecommendations: const [],
      feedingInstructions: const [],
      macronutrientBreakdown: const {},
      specialConsiderations: const [],
      calculatorId: id,
      results: [ResultItem(
        label: 'Erro',
        value: message,
        severity: ResultSeverity.danger,
      )],
      summary: 'Erro no cálculo: $message',
      calculatedAt: DateTime.now(),
    );
  }

  @override
  AdvancedDietInput createInputFromMap(Map<String, dynamic> inputs) {
    return AdvancedDietInput(
      species: AnimalSpecies.values.firstWhere(
        (e) => e.name == inputs['species'],
        orElse: () => AnimalSpecies.dog,
      ),
      weight: (inputs['weight'] as num?)?.toDouble() ?? 0.0,
      idealWeight: (inputs['idealWeight'] as num?)?.toDouble(),
      lifeStage: LifeStage.values.firstWhere(
        (e) => e.name == inputs['lifeStage'],
        orElse: () => LifeStage.adult,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == inputs['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      bodyCondition: BodyCondition.values.firstWhere(
        (e) => e.name == inputs['bodyCondition'],
        orElse: () => BodyCondition.ideal,
      ),
      dietType: DietType.values.firstWhere(
        (e) => e.name == inputs['dietType'],
        orElse: () => DietType.commercial,
      ),
      healthCondition: HealthCondition.values.firstWhere(
        (e) => e.name == inputs['healthCondition'],
        orElse: () => HealthCondition.healthy,
      ),
      isNeutered: inputs['isNeutered'] as bool? ?? false,
      isPregnant: inputs['isPregnant'] as bool? ?? false,
      isLactating: inputs['isLactating'] as bool? ?? false,
      numberOfPuppies: inputs['numberOfPuppies'] as int?,
      currentDailyCalories: (inputs['currentDailyCalories'] as num?)?.toDouble(),
      allergies: (inputs['allergies'] as List<dynamic>?)?.cast<String>(),
      medications: (inputs['medications'] as List<dynamic>?)?.cast<String>(),
    );
  }

  @override
  Map<String, dynamic> getInputParameters() {
    return {
      'species': {
        'type': 'enum',
        'label': 'Espécie',
        'options': AnimalSpecies.values,
        'required': true,
      },
      'weight': {
        'type': 'double',
        'label': 'Peso atual (kg)',
        'min': 0.1,
        'max': 100.0,
        'step': 0.1,
        'required': true,
      },
      'idealWeight': {
        'type': 'double',
        'label': 'Peso ideal (kg)',
        'min': 0.1,
        'max': 100.0,
        'step': 0.1,
        'required': false,
      },
      'lifeStage': {
        'type': 'enum',
        'label': 'Estágio de vida',
        'options': LifeStage.values,
        'required': true,
      },
      'activityLevel': {
        'type': 'enum',
        'label': 'Nível de atividade',
        'options': ActivityLevel.values,
        'required': true,
      },
      'bodyCondition': {
        'type': 'enum',
        'label': 'Condição corporal',
        'options': BodyCondition.values,
        'required': true,
      },
      'dietType': {
        'type': 'enum',
        'label': 'Tipo de dieta',
        'options': DietType.values,
        'required': true,
      },
      'healthCondition': {
        'type': 'enum',
        'label': 'Condição de saúde',
        'options': HealthCondition.values,
        'required': true,
      },
      'isNeutered': {
        'type': 'bool',
        'label': 'É castrado/esterilizado?',
        'required': true,
      },
      'isPregnant': {
        'type': 'bool',
        'label': 'Está gestante?',
        'required': false,
      },
      'isLactating': {
        'type': 'bool',
        'label': 'Está lactando?',
        'required': false,
      },
      'numberOfPuppies': {
        'type': 'int',
        'label': 'Número de filhotes (se lactando)',
        'min': 1,
        'max': 15,
        'step': 1,
        'required': false,
      },
    };
  }
}

