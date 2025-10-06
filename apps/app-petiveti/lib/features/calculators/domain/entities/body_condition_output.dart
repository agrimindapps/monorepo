import 'calculation_result.dart';

/// Enum para classificação da condição corporal
enum BcsClassification {
  severelyUnderweight('severely_underweight', 'Extremamente Magro', ResultSeverity.danger),
  underweight('underweight', 'Abaixo do Peso', ResultSeverity.warning),
  slightlyUnderweight('slightly_underweight', 'Ligeiramente Magro', ResultSeverity.warning),
  ideal('ideal', 'Peso Ideal', ResultSeverity.success),
  slightlyOverweight('slightly_overweight', 'Ligeiramente Acima do Peso', ResultSeverity.warning),
  overweight('overweight', 'Sobrepeso', ResultSeverity.warning),
  obese('obese', 'Obeso', ResultSeverity.danger);

  const BcsClassification(this.code, this.displayName, this.severity);
  final String code;
  final String displayName;
  final ResultSeverity severity;
}

/// Enum para urgência de ação veterinária
enum ActionUrgency {
  routine('routine', 'Monitoramento de Rotina'),
  monitor('monitor', 'Monitoramento Próximo'),
  veterinary('veterinary', 'Consulta Veterinária'),
  urgent('urgent', 'Consulta Urgente');

  const ActionUrgency(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// Tipo de recomendação nutricional
enum NutritionalRecommendationType {
  maintain('maintain', 'Manter Dieta Atual'),
  increaseFood('increase_food', 'Aumentar Alimentação'),
  decreaseFood('decrease_food', 'Reduzir Alimentação'),
  dietaryChange('dietary_change', 'Mudança na Dieta'),
  specializedDiet('specialized_diet', 'Dieta Especializada');

  const NutritionalRecommendationType(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// Recomendação específica com detalhes
class BcsRecommendation extends Recommendation {
  const BcsRecommendation({
    required this.type,
    required super.title,
    required this.description,
    required this.actionSteps,
    this.targetWeightRange,
    this.expectedTimeframe,
    this.monitoringFrequency,
    this.additionalNotes,
    super.severity,
  }) : super(
    message: description,
  );

  final NutritionalRecommendationType type;
  final String description;
  final List<String> actionSteps;
  final String? targetWeightRange; // ex: "18-22 kg"
  final String? expectedTimeframe; // ex: "2-3 meses"
  final String? monitoringFrequency; // ex: "semanal"
  final String? additionalNotes;

  @override
  List<Object?> get props => [
    type,
    title,
    description,
    actionSteps,
    targetWeightRange,
    expectedTimeframe,
    monitoringFrequency,
    additionalNotes,
  ];
}

/// Output completo do cálculo de condição corporal
/// Contém toda informação necessária para decisões clínicas
class BodyConditionOutput extends CalculationResult {
  const BodyConditionOutput({
    required this.bcsScore,
    required this.classification,
    required this.interpretation,
    required this.idealWeightEstimate,
    required this.weightAdjustmentNeeded,
    required this.bcsRecommendations,
    required this.actionUrgency,
    required this.veterinaryNotes,
    required this.metabolicRisk,
    required super.calculatorId,
    required super.results,
    super.summary,
    super.calculatedAt,
  });

  /// Resultados principais
  final int bcsScore; // 1-9 ou 1-5 dependendo da escala
  final BcsClassification classification;
  final String interpretation; // texto detalhado da interpretação
  
  /// Recomendações de peso
  final double? idealWeightEstimate; // kg estimado baseado na raça/espécie
  final double weightAdjustmentNeeded; // kg a ganhar/perder (positivo = ganhar, negativo = perder)
  
  /// Recomendações e ações
  final List<BcsRecommendation> bcsRecommendations;
  final ActionUrgency actionUrgency;

  /// Override the base recommendations getter to return BcsRecommendations cast as Recommendations
  @override
  List<Recommendation> get recommendations => bcsRecommendations;
  final List<String> veterinaryNotes; // notas específicas para o veterinário
  
  /// Avaliação de risco
  final String metabolicRisk; // baixo, moderado, alto
  
  /// Getters de conveniência
  bool get isIdealWeight => classification == BcsClassification.ideal;
  bool get needsWeightLoss => weightAdjustmentNeeded < 0;
  bool get needsWeightGain => weightAdjustmentNeeded > 0;
  bool get requiresVeterinaryAttention => 
      actionUrgency == ActionUrgency.veterinary || 
      actionUrgency == ActionUrgency.urgent;
  
  /// Percentual de ajuste de peso necessário
  double getWeightAdjustmentPercentage(double currentWeight) {
    if (currentWeight <= 0) return 0;
    return (weightAdjustmentNeeded / currentWeight) * 100;
  }
  
  /// Texto descritivo do status geral
  String get statusDescription {
    switch (classification) {
      case BcsClassification.severelyUnderweight:
        return 'Animal com desnutrição severa. Intervenção veterinária urgente necessária.';
      case BcsClassification.underweight:
        return 'Animal abaixo do peso ideal. Requer ajuste nutricional supervisionado.';
      case BcsClassification.slightlyUnderweight:
        return 'Animal ligeiramente abaixo do peso. Monitoramento e ajuste gradual recomendados.';
      case BcsClassification.ideal:
        return 'Animal em condição corporal ideal. Manter dieta atual e monitoramento regular.';
      case BcsClassification.slightlyOverweight:
        return 'Animal ligeiramente acima do peso. Ajuste nutricional preventivo recomendado.';
      case BcsClassification.overweight:
        return 'Animal com sobrepeso. Programa de emagrecimento supervisionado necessário.';
      case BcsClassification.obese:
        return 'Animal obeso. Intervenção veterinária imediata para plano de emagrecimento.';
    }
  }
  
  /// Cor associada ao status (para UI)
  String get statusColor {
    switch (classification.severity) {
      case ResultSeverity.success:
        return '#4CAF50'; // Verde
      case ResultSeverity.warning:
        return '#FF9800'; // Laranja  
      case ResultSeverity.danger:
        return '#F44336'; // Vermelho
      case ResultSeverity.info:
        return '#2196F3'; // Azul
    }
  }

  @override
  List<Object?> get props => [
    bcsScore,
    classification,
    interpretation,
    idealWeightEstimate,
    weightAdjustmentNeeded,
    recommendations,
    actionUrgency,
    veterinaryNotes,
    metabolicRisk,
    ...super.props,
  ];
}

/// Factory para criar outputs baseado no score BCS
class BodyConditionOutputFactory {
  /// Cria output baseado no score e dados do animal
  static BodyConditionOutput fromBcsScore({
    required int bcsScore,
    required double currentWeight,
    required String species,
    double? idealWeight,
    bool isNeutered = false,
    int? animalAge,
    String? breed,
    bool hasMetabolicConditions = false,
  }) {
    final classification = _getClassificationFromScore(bcsScore);
    final weightEstimate = idealWeight ?? _estimateIdealWeight(
      species: species,
      currentWeight: currentWeight,
      bcsScore: bcsScore,
      breed: breed,
    );
    final weightAdjustment = _calculateWeightAdjustment(
      currentWeight: currentWeight,
      idealWeight: weightEstimate,
      bcsScore: bcsScore,
    );
    final interpretation = _generateInterpretation(bcsScore, classification);
    final recommendations = _generateRecommendations(
      bcsScore: bcsScore,
      currentWeight: currentWeight,
      weightAdjustment: weightAdjustment,
      species: species,
      isNeutered: isNeutered,
      hasMetabolicConditions: hasMetabolicConditions,
    );
    
    final actionUrgency = _determineActionUrgency(bcsScore);
    final veterinaryNotes = _generateVeterinaryNotes(bcsScore, hasMetabolicConditions);
    final metabolicRisk = _assessMetabolicRisk(bcsScore, isNeutered, animalAge);

    return BodyConditionOutput(
      bcsScore: bcsScore,
      classification: classification,
      interpretation: interpretation,
      idealWeightEstimate: weightEstimate,
      weightAdjustmentNeeded: weightAdjustment,
      bcsRecommendations: recommendations,
      actionUrgency: actionUrgency,
      veterinaryNotes: veterinaryNotes,
      metabolicRisk: metabolicRisk,
      calculatorId: 'body_condition_calculator',
      results: [
        ResultItem(
          label: 'Score BCS',
          value: '$bcsScore/9',
          severity: classification.severity,
          description: classification.displayName,
        ),
        ResultItem(
          label: 'Peso Atual',
          value: currentWeight.toStringAsFixed(1),
          unit: 'kg',
        ),
        ResultItem(
        label: 'Peso Ideal Estimado',
        value: weightEstimate.toStringAsFixed(1),
        unit: 'kg',
      ),
        if (weightAdjustment != 0) ResultItem(
          label: weightAdjustment > 0 ? 'Peso a Ganhar' : 'Peso a Perder',
          value: weightAdjustment.abs().toStringAsFixed(1),
          unit: 'kg',
          severity: weightAdjustment.abs() > 2 ? ResultSeverity.warning : ResultSeverity.info,
        ),
      ],
      summary: 'BCS $bcsScore/9 - ${classification.displayName}',
      calculatedAt: DateTime.now(),
    );
  }

  static BcsClassification _getClassificationFromScore(int score) {
    switch (score) {
      case 1:
        return BcsClassification.severelyUnderweight;
      case 2:
      case 3:
        return BcsClassification.underweight;
      case 4:
        return BcsClassification.slightlyUnderweight;
      case 5:
        return BcsClassification.ideal;
      case 6:
        return BcsClassification.slightlyOverweight;
      case 7:
        return BcsClassification.overweight;
      case 8:
      case 9:
        return BcsClassification.obese;
      default:
        return BcsClassification.ideal;
    }
  }

  static double _estimateIdealWeight({
    required String species,
    required double currentWeight,
    required int bcsScore,
    String? breed,
  }) {
    final adjustmentFactor = (5 - bcsScore) * 0.125; // 12.5% por ponto
    return currentWeight * (1 + adjustmentFactor);
  }

  static double _calculateWeightAdjustment({
    required double currentWeight,
    required double idealWeight,
    required int bcsScore,
  }) {
    return idealWeight - currentWeight;
  }

  static String _generateInterpretation(int bcsScore, BcsClassification classification) {
    final Map<int, String> interpretations = {
      1: 'Costelas, vértebras lombares e ossos pélvicos facilmente visíveis. Perda óbvia de massa muscular. Desnutrição severa.',
      2: 'Costelas facilmente palpáveis com pressão mínima. Vértebras lombares óbvias. Cintura e dobra abdominal evidentes.',
      3: 'Costelas facilmente palpáveis. Vértebras lombares visíveis. Cintura óbvia quando vista de cima. Dobra abdominal evidente.',
      4: 'Costelas facilmente palpáveis com cobertura adiposa mínima. Cintura facilmente observável. Dobra abdominal óbvia.',
      5: 'Costelas palpáveis sem excesso de cobertura adiposa. Cintura observável. Dobra abdominal presente.',
      6: 'Costelas palpáveis com ligeira cobertura adiposa. Cintura visível mas não proeminente. Dobra abdominal presente.',
      7: 'Costelas difíceis de palpar devido à cobertura adiposa. Cintura pouco visível. Dobra abdominal pode estar presente.',
      8: 'Costelas não palpáveis ou palpáveis apenas com pressão significativa. Depósitos adiposos visíveis. Cintura ausente.',
      9: 'Depósitos adiposos massivos. Costelas não palpáveis. Depósitos adiposos evidentes na região lombar e base da cauda.',
    };

    return interpretations[bcsScore] ?? 'Score de condição corporal não reconhecido.';
  }

  static List<BcsRecommendation> _generateRecommendations({
    required int bcsScore,
    required double currentWeight,
    required double weightAdjustment,
    required String species,
    bool isNeutered = false,
    bool hasMetabolicConditions = false,
  }) {
    final recommendations = <BcsRecommendation>[];

    if (bcsScore <= 3) {
      recommendations.add(BcsRecommendation(
        type: NutritionalRecommendationType.increaseFood,
        title: 'Programa de Ganho de Peso',
        description: 'Animal abaixo do peso ideal necessita aumento controlado da alimentação.',
        actionSteps: const [
          'Aumentar porção diária em 20-30%',
          'Dividir em 3-4 refeições menores',
          'Considerar ração hipercalórica de qualidade',
          'Monitorar ganho de peso semanal (meta: 1-2% do peso corporal/semana)',
          'Descartar causas médicas para baixo peso',
        ],
        targetWeightRange: '${(currentWeight + weightAdjustment.abs() * 0.9).toStringAsFixed(1)}-${(currentWeight + weightAdjustment.abs() * 1.1).toStringAsFixed(1)} kg',
        expectedTimeframe: '8-12 semanas',
        monitoringFrequency: 'Semanal',
        additionalNotes: bcsScore == 1 ? 'URGENTE: Desnutrição severa requer supervisão veterinária imediata.' : null,
      ));
    } else if (bcsScore >= 7) {
      recommendations.add(BcsRecommendation(
        type: NutritionalRecommendationType.decreaseFood,
        title: 'Programa de Emagrecimento',
        description: 'Animal acima do peso ideal necessita redução controlada da alimentação.',
        actionSteps: const [
          'Reduzir porção diária em 20-25%',
          'Aumentar frequência de refeições (menor quantidade)',
          'Trocar por ração light/dietética se necessário',
          'Incrementar atividade física gradualmente',
          'Monitorar perda de peso semanal (meta: 1-2% do peso corporal/semana)',
          'Evitar petiscos e alimentos extras',
        ],
        targetWeightRange: '${(currentWeight + weightAdjustment * 0.9).toStringAsFixed(1)}-${(currentWeight + weightAdjustment * 1.1).toStringAsFixed(1)} kg',
        expectedTimeframe: bcsScore >= 8 ? '12-20 semanas' : '8-16 semanas',
        monitoringFrequency: 'Quinzenal',
        additionalNotes: bcsScore >= 8 ? 'Obesidade requer acompanhamento veterinário para evitar complicações.' : null,
      ));
    } else {
      recommendations.add(const BcsRecommendation(
        type: NutritionalRecommendationType.maintain,
        title: 'Manutenção da Condição Ideal',
        description: 'Animal em peso ideal. Manter rotina atual de alimentação e exercícios.',
        actionSteps: [
          'Manter porções atuais de alimentação',
          'Continuar rotina de exercícios',
          'Monitorar peso mensalmente',
          'Ajustar porções conforme idade e atividade',
        ],
        expectedTimeframe: 'Manutenção contínua',
        monitoringFrequency: 'Mensal',
      ));
    }
    if (isNeutered) {
      recommendations.add(const BcsRecommendation(
        type: NutritionalRecommendationType.specializedDiet,
        title: 'Considerações para Animal Castrado',
        description: 'Animais castrados tendem a ter metabolismo mais lento.',
        actionSteps: [
          'Considerar ração específica para castrados',
          'Monitorar peso mais frequentemente',
          'Aumentar atividade física',
          'Controlar petiscos rigorosamente',
        ],
      ));
    }
    if (hasMetabolicConditions) {
      recommendations.add(const BcsRecommendation(
        type: NutritionalRecommendationType.specializedDiet,
        title: 'Manejo de Condições Metabólicas',
        description: 'Condições metabólicas requerem abordagem nutricional específica.',
        actionSteps: [
          'Consultar veterinário para dieta terapêutica',
          'Monitoramento mais frequente',
          'Considerar suplementação específica',
          'Acompanhar parâmetros laboratoriais',
        ],
        additionalNotes: 'Essencial supervisão veterinária continuada.',
      ));
    }

    return recommendations;
  }

  static ActionUrgency _determineActionUrgency(int bcsScore) {
    if (bcsScore == 1 || bcsScore >= 8) {
      return ActionUrgency.urgent;
    } else if (bcsScore <= 3 || bcsScore == 7) {
      return ActionUrgency.veterinary;
    } else if (bcsScore == 4 || bcsScore == 6) {
      return ActionUrgency.monitor;
    } else {
      return ActionUrgency.routine;
    }
  }

  static List<String> _generateVeterinaryNotes(int bcsScore, bool hasMetabolicConditions) {
    final notes = <String>[];

    if (bcsScore == 1) {
      notes.addAll([
        'CRÍTICO: Desnutrição severa - investigar causas médicas subjacentes',
        'Avaliar função hepática, renal e tireoidiana',
        'Considerar hospitalização se condição geral comprometida',
        'Realimentação gradual para evitar síndrome de realimentação',
      ]);
    } else if (bcsScore <= 3) {
      notes.addAll([
        'Investigar causas de perda de peso (parasitas, doenças sistêmicas)',
        'Exames laboratoriais recomendados',
        'Monitorar resposta ao aumento alimentar',
      ]);
    } else if (bcsScore >= 8) {
      notes.addAll([
        'Obesidade - avaliar comorbidades associadas',
        'Investigar disfunções endócrinas (hipotireoidismo, hiperadrenocorticismo)',
        'Avaliar função cardiovascular',
        'Programa de emagrecimento supervisionado obrigatório',
      ]);
    } else if (bcsScore == 7) {
      notes.addAll([
        'Sobrepeso - intervenção precoce para prevenir obesidade',
        'Avaliar fatores contributórios',
        'Ajustar dieta e exercícios',
      ]);
    }

    if (hasMetabolicConditions) {
      notes.add('Ajustar manejo nutricional conforme condições metabólicas existentes');
    }

    return notes;
  }

  static String _assessMetabolicRisk(int bcsScore, bool isNeutered, int? animalAge) {
    var riskLevel = 'Baixo';

    if (bcsScore >= 7) {
      riskLevel = 'Alto';
    } else if (bcsScore == 6 || bcsScore <= 3) {
      riskLevel = 'Moderado';
    }
    if (isNeutered && bcsScore >= 6) {
      riskLevel = 'Alto';
    }

    if (animalAge != null && animalAge > 84 && bcsScore != 5) { // > 7 anos
      riskLevel = riskLevel == 'Baixo' ? 'Moderado' : 'Alto';
    }

    return riskLevel;
  }
}