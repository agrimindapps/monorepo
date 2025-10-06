import 'package:core/core.dart' show Equatable;
import 'calculation_result.dart';
import 'calorie_input.dart';

/// Resultado detalhado do cálculo de necessidades calóricas
class CalorieOutput extends CalculationResult {
  const CalorieOutput({
    required this.input,
    required this.restingEnergyRequirement,
    required this.dailyEnergyRequirement,
    required this.proteinRequirement,
    required this.fatRequirement,
    required this.carbohydrateRequirement,
    required this.waterRequirement,
    required this.feedingRecommendations,
    required this.weightManagementAdvice,
    required this.nutritionalAdjustments,
    required this.specialConsiderations,
    required this.calculationDetails,
    required super.calculatorId,
    required super.results,
    super.recommendations = const [],
    super.summary,
    super.calculatedAt,
  });

  /// Entrada utilizada para o cálculo
  final CalorieInput input;

  /// Necessidade Energética de Repouso (RER) em kcal/dia
  final double restingEnergyRequirement;

  /// Necessidade Energética Diária (DER) em kcal/dia
  final double dailyEnergyRequirement;

  /// Necessidade de proteína em gramas/dia
  final double proteinRequirement;

  /// Necessidade de gordura em gramas/dia
  final double fatRequirement;

  /// Necessidade de carboidratos em gramas/dia
  final double carbohydrateRequirement;

  /// Necessidade de água em ml/dia
  final double waterRequirement;

  /// Recomendações específicas de alimentação
  final FeedingRecommendations feedingRecommendations;

  /// Conselhos para manejo de peso
  final WeightManagementAdvice weightManagementAdvice;

  /// Ajustes nutricionais baseados em condições especiais
  final NutritionalAdjustments nutritionalAdjustments;

  /// Considerações especiais baseadas no perfil do animal
  final List<String> specialConsiderations;

  /// Detalhes do cálculo realizado
  final CalculationDetails calculationDetails;

  /// Verifica se as necessidades calóricas estão elevadas
  bool get hasElevatedCalorieNeeds =>
      dailyEnergyRequirement > (restingEnergyRequirement * 2.5);

  /// Verifica se é necessário monitoramento especializado
  bool get requiresSpecializedMonitoring =>
      input.medicalCondition != MedicalCondition.none ||
      input.isPregnant ||
      input.isLactating ||
      input.bodyConditionScore != BodyConditionScore.ideal;

  /// Obtém a classificação do nível calórico
  String get calorieNeedsClassification {
    final ratio = dailyEnergyRequirement / restingEnergyRequirement;

    if (ratio < 1.2) return 'Baixo';
    if (ratio < 1.6) return 'Moderado';
    if (ratio < 2.5) return 'Alto';
    return 'Muito Alto';
  }

  @override
  List<Object?> get props => [
    input,
    restingEnergyRequirement,
    dailyEnergyRequirement,
    proteinRequirement,
    fatRequirement,
    carbohydrateRequirement,
    waterRequirement,
    feedingRecommendations,
    weightManagementAdvice,
    nutritionalAdjustments,
    specialConsiderations,
    calculationDetails,
    ...super.props,
  ];

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'restingEnergyRequirement': restingEnergyRequirement,
      'dailyEnergyRequirement': dailyEnergyRequirement,
      'proteinRequirement': proteinRequirement,
      'fatRequirement': fatRequirement,
      'carbohydrateRequirement': carbohydrateRequirement,
      'waterRequirement': waterRequirement,
      'feedingRecommendations': feedingRecommendations.toJson(),
      'weightManagementAdvice': weightManagementAdvice.toJson(),
      'nutritionalAdjustments': nutritionalAdjustments.toJson(),
      'specialConsiderations': specialConsiderations,
      'calculationDetails': calculationDetails.toJson(),
      'calculatorId': calculatorId,
      'results':
          results
              .map(
                (r) => {
                  'label': r.label,
                  'value': r.value,
                  'unit': r.unit,
                  'severity': r.severity.code,
                  'description': r.description,
                },
              )
              .toList(),
      'recommendations':
          recommendations
              .map(
                (r) => {
                  'title': r.title,
                  'message': r.message,
                  'severity': r.severity.code,
                  'actionLabel': r.actionLabel,
                  'actionUrl': r.actionUrl,
                },
              )
              .toList(),
      'summary': summary,
      'calculatedAt': calculatedAt?.toIso8601String(),
    };
  }
}

/// Recomendações específicas de alimentação
class FeedingRecommendations extends Equatable {
  const FeedingRecommendations({
    required this.mealsPerDay,
    required this.gramsPerMeal,
    required this.feedingSchedule,
    required this.foodType,
    required this.treatAllowance,
    required this.supplementNeeds,
  });

  /// Número recomendado de refeições por dia
  final int mealsPerDay;

  /// Quantidade em gramas por refeição
  final double gramsPerMeal;

  /// Horários sugeridos para alimentação
  final List<String> feedingSchedule;

  /// Tipo de alimento recomendado
  final String foodType;

  /// Permissão de petiscos (% das calorias diárias)
  final double treatAllowance;

  /// Necessidades de suplementação
  final List<String> supplementNeeds;

  @override
  List<Object?> get props => [
    mealsPerDay,
    gramsPerMeal,
    feedingSchedule,
    foodType,
    treatAllowance,
    supplementNeeds,
  ];

  Map<String, dynamic> toJson() {
    return {
      'mealsPerDay': mealsPerDay,
      'gramsPerMeal': gramsPerMeal,
      'feedingSchedule': feedingSchedule,
      'foodType': foodType,
      'treatAllowance': treatAllowance,
      'supplementNeeds': supplementNeeds,
    };
  }
}

/// Conselhos para manejo de peso
class WeightManagementAdvice extends Equatable {
  const WeightManagementAdvice({
    required this.targetWeight,
    required this.weightGoal,
    required this.timeToTarget,
    required this.weeklyWeightChange,
    required this.monitoringFrequency,
    required this.exerciseRecommendations,
  });

  /// Peso alvo em kg
  final double targetWeight;

  /// Objetivo de peso (manter, ganhar, perder)
  final String weightGoal;

  /// Tempo estimado para atingir o peso alvo
  final String timeToTarget;

  /// Mudança de peso semanal recomendada
  final double weeklyWeightChange;

  /// Frequência de monitoramento do peso
  final String monitoringFrequency;

  /// Recomendações de exercício
  final List<String> exerciseRecommendations;

  @override
  List<Object?> get props => [
    targetWeight,
    weightGoal,
    timeToTarget,
    weeklyWeightChange,
    monitoringFrequency,
    exerciseRecommendations,
  ];

  Map<String, dynamic> toJson() {
    return {
      'targetWeight': targetWeight,
      'weightGoal': weightGoal,
      'timeToTarget': timeToTarget,
      'weeklyWeightChange': weeklyWeightChange,
      'monitoringFrequency': monitoringFrequency,
      'exerciseRecommendations': exerciseRecommendations,
    };
  }
}

/// Ajustes nutricionais para condições especiais
class NutritionalAdjustments extends Equatable {
  const NutritionalAdjustments({
    required this.macronutrientRatios,
    required this.restrictedIngredients,
    required this.recommendedIngredients,
    required this.vitaminSupplements,
    required this.mineralSupplements,
    required this.digestibilityFactor,
  });

  /// Proporções ideais de macronutrientes (proteína:gordura:carboidrato)
  final Map<String, double> macronutrientRatios;

  /// Ingredientes que devem ser evitados
  final List<String> restrictedIngredients;

  /// Ingredientes especialmente recomendados
  final List<String> recommendedIngredients;

  /// Suplementos vitamínicos recomendados
  final List<String> vitaminSupplements;

  /// Suplementos minerais recomendados
  final List<String> mineralSupplements;

  /// Fator de digestibilidade considerado
  final double digestibilityFactor;

  @override
  List<Object?> get props => [
    macronutrientRatios,
    restrictedIngredients,
    recommendedIngredients,
    vitaminSupplements,
    mineralSupplements,
    digestibilityFactor,
  ];

  Map<String, dynamic> toJson() {
    return {
      'macronutrientRatios': macronutrientRatios,
      'restrictedIngredients': restrictedIngredients,
      'recommendedIngredients': recommendedIngredients,
      'vitaminSupplements': vitaminSupplements,
      'mineralSupplements': mineralSupplements,
      'digestibilityFactor': digestibilityFactor,
    };
  }
}

/// Detalhes do cálculo realizado para transparência
class CalculationDetails extends Equatable {
  const CalculationDetails({
    required this.rerFormula,
    required this.physiologicalFactor,
    required this.activityFactor,
    required this.bodyConditionFactor,
    required this.environmentalFactor,
    required this.medicalFactor,
    required this.totalMultiplier,
    required this.adjustmentsApplied,
  });

  /// Fórmula utilizada para RER
  final String rerFormula;

  /// Fator aplicado para estado fisiológico
  final double physiologicalFactor;

  /// Fator aplicado para atividade
  final double activityFactor;

  /// Fator aplicado para condição corporal
  final double bodyConditionFactor;

  /// Fator aplicado para condição ambiental
  final double environmentalFactor;

  /// Fator aplicado para condição médica
  final double medicalFactor;

  /// Multiplicador total aplicado ao RER
  final double totalMultiplier;

  /// Lista de ajustes aplicados
  final List<String> adjustmentsApplied;

  @override
  List<Object?> get props => [
    rerFormula,
    physiologicalFactor,
    activityFactor,
    bodyConditionFactor,
    environmentalFactor,
    medicalFactor,
    totalMultiplier,
    adjustmentsApplied,
  ];

  Map<String, dynamic> toJson() {
    return {
      'rerFormula': rerFormula,
      'physiologicalFactor': physiologicalFactor,
      'activityFactor': activityFactor,
      'bodyConditionFactor': bodyConditionFactor,
      'environmentalFactor': environmentalFactor,
      'medicalFactor': medicalFactor,
      'totalMultiplier': totalMultiplier,
      'adjustmentsApplied': adjustmentsApplied,
    };
  }
}
