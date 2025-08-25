import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calorie_input.dart';
import '../entities/calorie_output.dart';
import 'calculator_strategy.dart';

/// Estratégia especializada para cálculo de necessidades calóricas
/// Implementa fórmulas veterinárias padrão para RER e DER
class CalorieCalculatorStrategy extends CalculatorStrategy<CalorieInput, CalorieOutput>
    with SpeciesAwareStrategy, AgeAwareStrategy, WeightAwareStrategy {
  
  static const CalorieCalculatorStrategy _instance = CalorieCalculatorStrategy._();
  const CalorieCalculatorStrategy._();
  factory CalorieCalculatorStrategy() => _instance;

  @override
  String get id => 'calorie_calculator_v1';

  @override
  String get name => 'Calculadora de Necessidades Calóricas';

  @override
  String get description => 
      'Calcula RER, DER e necessidades nutricionais baseadas em parâmetros veterinários';

  @override
  String get version => '1.0.0';

  @override
  CalorieOutput calculate(CalorieInput input) {
    final validationErrors = validateInput(input);
    if (validationErrors.isNotEmpty) {
      throw InvalidInputException(
        'Entrada inválida para cálculo calórico',
        validationErrors,
        errorCode: 'INVALID_CALORIE_INPUT',
      );
    }

    try {
      // 1. Calcular RER (Resting Energy Requirement)
      final rer = _calculateRestingEnergyRequirement(input);
      
      // 2. Calcular fatores multiplicadores
      final factors = _calculateMultipliers(input);
      
      // 3. Calcular DER (Daily Energy Requirement)
      final der = _calculateDailyEnergyRequirement(rer, factors, input);
      
      // 4. Calcular necessidades de macronutrientes
      final macronutrients = _calculateMacronutrients(der, input);
      
      // 5. Calcular necessidade hídrica
      final waterNeed = _calculateWaterRequirement(input);
      
      // 6. Gerar recomendações de alimentação
      final feedingRec = _generateFeedingRecommendations(der, input);
      
      // 7. Gerar conselhos de manejo de peso
      final weightAdvice = _generateWeightManagementAdvice(input);
      
      // 8. Gerar ajustes nutricionais
      final nutritionalAdj = _generateNutritionalAdjustments(input);
      
      // 9. Gerar considerações especiais
      final specialConsiderations = _generateSpecialConsiderations(input);
      
      // 10. Compilar detalhes do cálculo
      final calculationDetails = _generateCalculationDetails(rer, factors, input);
      
      // 11. Criar itens de resultado
      final results = _buildResultItems(rer, der, macronutrients, waterNeed, input);
      
      // 12. Gerar recomendações e alertas
      final recommendations = _generateRecommendations(input, der, rer);

      return CalorieOutput(
        input: input,
        restingEnergyRequirement: rer,
        dailyEnergyRequirement: der,
        proteinRequirement: macronutrients['protein']!,
        fatRequirement: macronutrients['fat']!,
        carbohydrateRequirement: macronutrients['carbohydrate']!,
        waterRequirement: waterNeed,
        feedingRecommendations: feedingRec,
        weightManagementAdvice: weightAdvice,
        nutritionalAdjustments: nutritionalAdj,
        specialConsiderations: specialConsiderations,
        calculationDetails: calculationDetails,
        calculatorId: id,
        results: results,
        recommendations: recommendations,
        summary: _generateSummary(der, feedingRec),
        calculatedAt: DateTime.now(),
      );
      
    } catch (e) {
      throw CalculationException(
        'Erro no cálculo de necessidades calóricas: $e',
        errorCode: 'CALORIE_CALCULATION_ERROR',
        originalError: e,
      );
    }
  }

  @override
  List<String> validateInput(CalorieInput input) {
    final errors = <String>[];

    // Validar peso
    if (input.weight <= 0) {
      errors.add('Peso deve ser maior que zero');
    }
    if (input.weight > 150) {
      errors.add('Peso muito alto (máximo 150kg)');
    }
    if (input.weight < 0.1) {
      errors.add('Peso muito baixo (mínimo 0.1kg)');
    }

    // Validar peso ideal se fornecido
    if (input.idealWeight != null) {
      if (input.idealWeight! <= 0) {
        errors.add('Peso ideal deve ser maior que zero');
      }
      if (input.idealWeight! > 150) {
        errors.add('Peso ideal muito alto (máximo 150kg)');
      }
    }

    // Validar idade
    if (input.age < 0) {
      errors.add('Idade não pode ser negativa');
    }
    if (input.age > 300) { // 25 anos
      errors.add('Idade muito alta (máximo 300 meses)');
    }

    // Validar número de filhotes para lactação
    if (input.isLactating && (input.numberOfOffspring == null || input.numberOfOffspring! <= 0)) {
      errors.add('Número de filhotes deve ser informado para animais em lactação');
    }
    
    if (input.numberOfOffspring != null && input.numberOfOffspring! > 20) {
      errors.add('Número de filhotes muito alto (máximo 20)');
    }

    // Validar combinações lógicas
    if (input.isPregnant && input.isLactating) {
      errors.add('Animal não pode estar gestante e lactando simultaneamente');
    }

    // Validar idade vs estado fisiológico
    if (input.isYoung && input.age > 12) {
      errors.add('Estado de crescimento inconsistente com idade acima de 12 meses');
    }

    return errors;
  }

  /// Calcula RER usando fórmulas veterinárias padrão
  double _calculateRestingEnergyRequirement(CalorieInput input) {
    final weight = input.weight;
    
    // Fórmula para animais > 2kg: RER = 70 × peso^0.75
    // Fórmula para animais ≤ 2kg: RER = 30 × peso + 70
    if (weight > 2.0) {
      return (70 * math.pow(weight, 0.75)).toDouble();
    } else {
      return (30 * weight) + 70;
    }
  }

  /// Calcula todos os fatores multiplicadores para DER
  Map<String, double> _calculateMultipliers(CalorieInput input) {
    final factors = <String, double>{};
    
    // Fator fisiológico base
    factors['physiological'] = input.physiologicalState.baseFactor;
    
    // Ajuste para lactação (fator adicional por filhote)
    if (input.isLactating && input.numberOfOffspring != null) {
      factors['lactation_bonus'] = 0.25 * input.numberOfOffspring!;
    } else {
      factors['lactation_bonus'] = 0.0;
    }
    
    // Fator de atividade
    factors['activity'] = input.activityLevel.factor;
    
    // Fator de condição corporal
    factors['body_condition'] = input.bodyConditionScore.factor;
    
    // Fator ambiental
    factors['environmental'] = input.environmentalCondition.factor;
    
    // Fator médico
    factors['medical'] = input.medicalCondition.factor;
    
    // Ajuste por idade (para animais jovens e idosos)
    factors['age'] = _getAgeAdjustmentFactor(input);
    
    // Ajuste por espécie específica
    factors['species'] = _getSpeciesAdjustmentFactor(input);
    
    return factors;
  }

  /// Calcula DER aplicando todos os fatores
  double _calculateDailyEnergyRequirement(
    double rer, 
    Map<String, double> factors, 
    CalorieInput input,
  ) {
    double der = rer;
    
    // Aplicar fator fisiológico base
    der *= factors['physiological']!;
    
    // Adicionar bônus de lactação se aplicável
    if (input.isLactating) {
      der += rer * factors['lactation_bonus']!;
    }
    
    // Aplicar outros fatores multiplicativos
    der *= factors['activity']!;
    der *= factors['body_condition']!;
    der *= factors['environmental']!;
    der *= factors['medical']!;
    der *= factors['age']!;
    der *= factors['species']!;
    
    return der;
  }

  /// Calcula necessidades de macronutrientes
  Map<String, double> _calculateMacronutrients(double totalCalories, CalorieInput input) {
    // Percentuais base por espécie (base AAFCO/FEDIAF)
    Map<String, double> proteinPercent, fatPercent, carbPercent;
    
    if (input.species == AnimalSpecies.dog) {
      proteinPercent = {'min': 18.0, 'optimal': 25.0};
      fatPercent = {'min': 5.5, 'optimal': 15.0};
      carbPercent = {'max': 60.0, 'optimal': 50.0};
    } else { // cat
      proteinPercent = {'min': 26.0, 'optimal': 45.0};
      fatPercent = {'min': 9.0, 'optimal': 20.0};
      carbPercent = {'max': 10.0, 'optimal': 5.0};
    }
    
    // Ajustes por estado fisiológico
    if (input.isYoung) {
      proteinPercent['optimal'] = proteinPercent['optimal']! * 1.5;
      fatPercent['optimal'] = fatPercent['optimal']! * 1.3;
    } else if (input.isSenior) {
      proteinPercent['optimal'] = proteinPercent['optimal']! * 1.2;
    }
    
    // Ajustes por condições médicas
    if (input.medicalCondition == MedicalCondition.kidneyDisease) {
      proteinPercent['optimal'] = proteinPercent['optimal']! * 0.8;
    } else if (input.medicalCondition == MedicalCondition.diabetes) {
      carbPercent['optimal'] = carbPercent['optimal']! * 0.7;
    }
    
    // Converter percentuais em gramas
    final proteinCal = totalCalories * (proteinPercent['optimal']! / 100);
    final fatCal = totalCalories * (fatPercent['optimal']! / 100);
    final carbCal = totalCalories * (carbPercent['optimal']! / 100);
    
    return {
      'protein': proteinCal / 4.0, // 4 kcal/g
      'fat': fatCal / 9.0, // 9 kcal/g
      'carbohydrate': carbCal / 4.0, // 4 kcal/g
    };
  }

  /// Calcula necessidade hídrica diária
  double _calculateWaterRequirement(CalorieInput input) {
    // Base: 50-70 ml/kg/dia
    double waterBase = input.weight * 60;
    
    // Ajustes por estado fisiológico
    if (input.isLactating) {
      waterBase *= 2.5; // Lactação requer muito mais água
    } else if (input.isPregnant) {
      waterBase *= 1.3;
    } else if (input.isYoung) {
      waterBase *= 1.5; // Filhotes precisam de mais água
    }
    
    // Ajustes por condições médicas
    if (input.medicalCondition == MedicalCondition.kidneyDisease) {
      waterBase *= 1.5;
    } else if (input.medicalCondition == MedicalCondition.diabetes) {
      waterBase *= 1.4;
    }
    
    // Ajustes ambientais
    if (input.environmentalCondition == EnvironmentalCondition.hot) {
      waterBase *= 1.3;
    } else if (input.environmentalCondition == EnvironmentalCondition.cold) {
      waterBase *= 0.9;
    }
    
    return waterBase;
  }

  double _getAgeAdjustmentFactor(CalorieInput input) {
    // Animais muito jovens (< 4 meses)
    if (input.age < 4) return 1.1;
    
    // Filhotes (4-12 meses)
    if (input.age < 12) return 1.05;
    
    // Adultos (1-7 anos para cães, 1-10 para gatos)
    final seniorAge = input.species == AnimalSpecies.dog ? 84 : 120; // meses
    if (input.age < seniorAge) return 1.0;
    
    // Idosos
    return 0.95;
  }

  double _getSpeciesAdjustmentFactor(CalorieInput input) {
    // Gatos têm metabolismo ligeiramente mais alto
    return input.species == AnimalSpecies.cat ? 1.05 : 1.0;
  }

  FeedingRecommendations _generateFeedingRecommendations(double der, CalorieInput input) {
    // Número de refeições baseado na idade
    int mealsPerDay;
    if (input.age < 4) {
      mealsPerDay = 4; // Filhotes muito jovens
    } else if (input.age < 12) {
      mealsPerDay = 3; // Filhotes
    } else if (input.isSenior) {
      mealsPerDay = 3; // Idosos comem mais frequentemente
    } else {
      mealsPerDay = 2; // Adultos
    }
    
    // Gramas por refeição (assumindo ração comercial ~3.5 kcal/g)
    final gramsPerMeal = (der / 3.5) / mealsPerDay;
    
    // Horários de alimentação
    List<String> schedule;
    switch (mealsPerDay) {
      case 4:
        schedule = ['06:00', '10:00', '14:00', '18:00'];
        break;
      case 3:
        schedule = ['07:00', '13:00', '19:00'];
        break;
      default:
        schedule = ['08:00', '18:00'];
    }
    
    // Tipo de alimento recomendado
    String foodType;
    if (input.isYoung) {
      foodType = 'Ração para filhotes (alta energia)';
    } else if (input.isSenior) {
      foodType = 'Ração para seniores (fácil digestão)';
    } else if (input.medicalCondition != MedicalCondition.none) {
      foodType = 'Ração terapêutica específica';
    } else {
      foodType = 'Ração premium para adultos';
    }
    
    // Permissão de petiscos (5-10% das calorias)
    final treatAllowance = input.isYoung ? 5.0 : 10.0;
    
    // Suplementos necessários
    final supplements = <String>[];
    if (input.isYoung) {
      supplements.add('DHA para desenvolvimento cerebral');
    }
    if (input.isSenior) {
      supplements.addAll(['Glucosamina/Condroitina', 'Antioxidantes']);
    }
    if (input.isPregnant || input.isLactating) {
      supplements.addAll(['Ácido fólico', 'Cálcio extra']);
    }
    
    return FeedingRecommendations(
      mealsPerDay: mealsPerDay,
      gramsPerMeal: gramsPerMeal,
      feedingSchedule: schedule,
      foodType: foodType,
      treatAllowance: treatAllowance,
      supplementNeeds: supplements,
    );
  }

  WeightManagementAdvice _generateWeightManagementAdvice(CalorieInput input) {
    final targetWeight = input.idealWeight ?? input.weight;
    final currentWeight = input.weight;
    final weightDifference = targetWeight - currentWeight;
    
    String weightGoal;
    String timeToTarget;
    double weeklyChange;
    String monitoringFreq;
    
    if (weightDifference.abs() < 0.5) {
      // Peso ideal
      weightGoal = 'Manter peso atual';
      timeToTarget = 'N/A - já no peso ideal';
      weeklyChange = 0.0;
      monitoringFreq = 'Mensal';
    } else if (weightDifference > 0) {
      // Ganho de peso necessário
      weightGoal = 'Ganhar peso gradualmente';
      weeklyChange = math.min(currentWeight * 0.02, 0.5); // 1-2% por semana, máx 500g
      final weeksNeeded = (weightDifference / weeklyChange).ceil();
      timeToTarget = '$weeksNeeded semanas';
      monitoringFreq = 'Semanal';
    } else {
      // Perda de peso necessária
      weightGoal = 'Perder peso gradualmente';
      weeklyChange = -math.min(currentWeight * 0.02, 0.5); // 1-2% por semana, máx 500g
      final weeksNeeded = (weightDifference.abs() / weeklyChange.abs()).ceil();
      timeToTarget = '$weeksNeeded semanas';
      monitoringFreq = 'Semanal';
    }
    
    // Recomendações de exercício
    final exerciseRecs = <String>[];
    if (input.species == AnimalSpecies.dog) {
      if (input.bodyConditionScore == BodyConditionScore.overweight ||
          input.bodyConditionScore == BodyConditionScore.obese) {
        exerciseRecs.addAll([
          'Caminhadas de 20-30 min, 2x/dia',
          'Natação (baixo impacto)',
          'Brincadeiras controladas',
        ]);
      } else {
        exerciseRecs.addAll([
          'Caminhadas de 30-45 min, 2x/dia',
          'Corridas leves',
          'Jogos de buscar',
        ]);
      }
    } else { // cat
      exerciseRecs.addAll([
        'Brinquedos interativos 15-20 min/dia',
        'Varinhas com penas',
        'Circuitos de atividade',
        'Laser pointer (com moderação)',
      ]);
    }
    
    return WeightManagementAdvice(
      targetWeight: targetWeight,
      weightGoal: weightGoal,
      timeToTarget: timeToTarget,
      weeklyWeightChange: weeklyChange,
      monitoringFrequency: monitoringFreq,
      exerciseRecommendations: exerciseRecs,
    );
  }

  NutritionalAdjustments _generateNutritionalAdjustments(CalorieInput input) {
    // Proporções base de macronutrientes
    Map<String, double> ratios;
    if (input.species == AnimalSpecies.dog) {
      ratios = {'protein': 25.0, 'fat': 15.0, 'carbohydrate': 50.0, 'fiber': 5.0, 'ash': 5.0};
    } else {
      ratios = {'protein': 45.0, 'fat': 20.0, 'carbohydrate': 5.0, 'fiber': 3.0, 'ash': 7.0};
    }
    
    // Ingredientes restritos
    final restricted = <String>[
      'Chocolate', 'Uvas/passas', 'Cebola/alho', 'Abacate', 'Xilitol'
    ];
    
    // Ingredientes recomendados
    final recommended = <String>[];
    if (input.species == AnimalSpecies.dog) {
      recommended.addAll(['Frango', 'Arroz integral', 'Batata doce', 'Cenoura']);
    } else {
      recommended.addAll(['Peixe', 'Frango', 'Fígado', 'Taurina']);
    }
    
    // Ajustes por condições médicas
    if (input.medicalCondition == MedicalCondition.kidneyDisease) {
      restricted.addAll(['Alimentos ricos em fósforo', 'Excesso de proteína']);
      recommended.addAll(['Proteínas de alta qualidade', 'Alimentos pobres em fósforo']);
    }
    
    if (input.medicalCondition == MedicalCondition.diabetes) {
      restricted.addAll(['Açúcares simples', 'Alimentos de alto índice glicêmico']);
      recommended.addAll(['Fibras solúveis', 'Proteínas magras']);
    }
    
    // Suplementos vitamínicos e minerais
    final vitaminSupp = <String>[];
    final mineralSupp = <String>[];
    
    if (input.isYoung) {
      vitaminSupp.addAll(['Vitamina D', 'Complexo B']);
      mineralSupp.addAll(['Cálcio', 'Fósforo']);
    }
    
    if (input.isSenior) {
      vitaminSupp.addAll(['Vitamina E', 'Vitamina C']);
      mineralSupp.addAll(['Glucosamina', 'Condroitina']);
    }
    
    // Fator de digestibilidade
    double digestibility = 0.85; // Base 85%
    if (input.isSenior || input.medicalCondition != MedicalCondition.none) {
      digestibility = 0.80; // Reduzir para casos especiais
    }
    
    return NutritionalAdjustments(
      macronutrientRatios: ratios,
      restrictedIngredients: restricted,
      recommendedIngredients: recommended,
      vitaminSupplements: vitaminSupp,
      mineralSupplements: mineralSupp,
      digestibilityFactor: digestibility,
    );
  }

  List<String> _generateSpecialConsiderations(CalorieInput input) {
    final considerations = <String>[];
    
    if (input.isPregnant) {
      considerations.add('🤰 GESTAÇÃO: Aumentar calorias gradualmente (+25% no final)');
    }
    
    if (input.isLactating) {
      considerations.add('🤱 LACTAÇÃO: Alimentação livre durante primeiras 3 semanas');
    }
    
    if (input.isYoung) {
      considerations.add('👶 CRESCIMENTO: Monitorar peso semanalmente');
    }
    
    if (input.medicalCondition != MedicalCondition.none) {
      considerations.add('🏥 CONDIÇÃO MÉDICA: Acompanhamento veterinário obrigatório');
    }
    
    if (input.bodyConditionScore != BodyConditionScore.ideal) {
      considerations.add('⚖️ PESO: Reavaliar necessidades a cada 2 semanas');
    }
    
    if (input.activityLevel == ActivityLevel.extreme) {
      considerations.add('🏃 ATIVIDADE EXTREMA: Hidratação extra necessária');
    }
    
    return considerations;
  }

  CalculationDetails _generateCalculationDetails(
    double rer, 
    Map<String, double> factors, 
    CalorieInput input,
  ) {
    final formula = input.weight > 2.0 
        ? '70 × ${input.weight.toStringAsFixed(1)}^0.75 = ${rer.toStringAsFixed(0)} kcal'
        : '(30 × ${input.weight.toStringAsFixed(1)}) + 70 = ${rer.toStringAsFixed(0)} kcal';
    
    final totalMultiplier = factors.values.fold(1.0, (a, b) => a * b);
    
    final adjustments = <String>[];
    if (factors['physiological']! != 1.0) {
      adjustments.add('Estado fisiológico: ${factors['physiological']!.toStringAsFixed(2)}x');
    }
    if (factors['activity']! != 1.0) {
      adjustments.add('Atividade: ${factors['activity']!.toStringAsFixed(2)}x');
    }
    if (factors['body_condition']! != 1.0) {
      adjustments.add('Condição corporal: ${factors['body_condition']!.toStringAsFixed(2)}x');
    }
    if (factors['lactation_bonus']! > 0) {
      adjustments.add('Bônus lactação: +${(factors['lactation_bonus']! * 100).toStringAsFixed(0)}%');
    }
    
    return CalculationDetails(
      rerFormula: formula,
      physiologicalFactor: factors['physiological']!,
      activityFactor: factors['activity']!,
      bodyConditionFactor: factors['body_condition']!,
      environmentalFactor: factors['environmental']!,
      medicalFactor: factors['medical']!,
      totalMultiplier: totalMultiplier,
      adjustmentsApplied: adjustments,
    );
  }

  List<ResultItem> _buildResultItems(
    double rer, 
    double der, 
    Map<String, double> macros, 
    double water, 
    CalorieInput input,
  ) {
    final items = <ResultItem>[];
    
    items.add(ResultItem(
      label: 'RER (Repouso)',
      value: rer.round(),
      unit: 'kcal/dia',
      severity: ResultSeverity.info,
      description: 'Necessidade energética basal',
    ));
    
    items.add(ResultItem(
      label: 'DER (Total)',
      value: der.round(),
      unit: 'kcal/dia',
      severity: der > (rer * 3) ? ResultSeverity.warning : ResultSeverity.success,
      description: 'Necessidade energética diária total',
    ));
    
    items.add(ResultItem(
      label: 'Proteína',
      value: macros['protein']!.round(),
      unit: 'g/dia',
      severity: ResultSeverity.info,
    ));
    
    items.add(ResultItem(
      label: 'Gordura',
      value: macros['fat']!.round(),
      unit: 'g/dia',
      severity: ResultSeverity.info,
    ));
    
    items.add(ResultItem(
      label: 'Carboidrato',
      value: macros['carbohydrate']!.round(),
      unit: 'g/dia',
      severity: ResultSeverity.info,
    ));
    
    items.add(ResultItem(
      label: 'Água',
      value: water.round(),
      unit: 'ml/dia',
      severity: water > (input.weight * 100) ? ResultSeverity.warning : ResultSeverity.info,
      description: 'Necessidade hídrica mínima',
    ));
    
    return items;
  }

  List<Recommendation> _generateRecommendations(CalorieInput input, double der, double rer) {
    final recommendations = <Recommendation>[];
    
    // Alertas críticos
    if (der > (rer * 4)) {
      recommendations.add(const Recommendation(
        title: 'Necessidades Calóricas Extremas',
        message: 'Animal requer monitoramento veterinário constante devido às altas necessidades energéticas',
        severity: ResultSeverity.danger,
        actionLabel: 'Consultar veterinário',
      ));
    }
    
    // Alertas para condições especiais
    if (input.medicalCondition != MedicalCondition.none) {
      recommendations.add(const Recommendation(
        title: 'Dieta Terapêutica Requerida',
        message: 'Condição médica requer dieta específica e acompanhamento profissional',
        severity: ResultSeverity.warning,
        actionLabel: 'Solicitar dieta veterinária',
      ));
    }
    
    // Alertas para peso
    if (input.bodyConditionScore == BodyConditionScore.obese) {
      recommendations.add(const Recommendation(
        title: 'Programa de Perda de Peso',
        message: 'Obesidade requer intervenção imediata com dieta restritiva e exercícios',
        severity: ResultSeverity.warning,
        actionLabel: 'Iniciar programa de emagrecimento',
      ));
    }
    
    // Informações gerais
    recommendations.add(const Recommendation(
      title: 'Monitoramento Regular',
      message: 'Pesar o animal semanalmente e ajustar porções conforme necessário',
      severity: ResultSeverity.info,
    ));
    
    return recommendations;
  }

  String _generateSummary(double der, FeedingRecommendations feeding) {
    return '${der.round()} kcal/dia • ${feeding.mealsPerDay}x ${feeding.gramsPerMeal.round()}g • ${feeding.foodType}';
  }

  // Implementações dos mixins
  @override
  Map<String, dynamic> getSpeciesParameters(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return {
          'metabolic_rate': 1.0,
          'protein_min': 18.0,
          'fat_min': 5.5,
          'senior_age_months': 84,
        };
      case 'cat':
        return {
          'metabolic_rate': 1.05,
          'protein_min': 26.0,
          'fat_min': 9.0,
          'senior_age_months': 120,
        };
      default:
        return {'metabolic_rate': 1.0};
    }
  }

  @override
  List<String> get supportedSpecies => ['dog', 'cat'];

  @override
  double applyAgeCorrection(double baseValue, int ageInMonths, String species) {
    return baseValue * _getAgeAdjustmentFactor(CalorieInput(
      species: species == 'cat' ? AnimalSpecies.cat : AnimalSpecies.dog,
      weight: 10, // dummy
      age: ageInMonths,
      physiologicalState: PhysiologicalState.normal,
      activityLevel: ActivityLevel.moderate,
      bodyConditionScore: BodyConditionScore.ideal,
    ));
  }

  @override
  Map<String, int> get ageRanges => {
    'puppy': 4,
    'juvenile': 12,
    'adult': 84,
    'senior': 300,
  };

  @override
  double applyWeightCorrection(double baseValue, double weightKg, String species) {
    // Aplicar correções baseadas em peso extremo
    if (weightKg < 2.0) return baseValue * 1.1; // Animais muito pequenos
    if (weightKg > 50.0) return baseValue * 0.95; // Animais muito grandes
    return baseValue;
  }

  @override
  Map<String, Map<String, double>> get weightLimits => {
    'dog': {'min': 0.5, 'max': 100.0},
    'cat': {'min': 0.5, 'max': 15.0},
  };
}