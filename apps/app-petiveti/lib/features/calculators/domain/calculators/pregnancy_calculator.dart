import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/calculator_input.dart';
import 'base_calculator.dart';

enum AnimalSpecies {
  dog,
  cat,
}

enum PregnancyStage {
  early, // 0-30 dias
  middle, // 31-45 dias
  late, // 46+ dias
}

class PregnancyInput extends CalculatorInput {
  final AnimalSpecies species;
  final DateTime matingDate;
  final double motherWeight;
  final int? expectedLitterSize;
  final bool isFirstPregnancy;
  final DateTime? lastUltrasoundDate;
  final int? confirmedPuppies;

  const PregnancyInput({
    required this.species,
    required this.matingDate,
    required this.motherWeight,
    this.expectedLitterSize,
    this.isFirstPregnancy = false,
    this.lastUltrasoundDate,
    this.confirmedPuppies,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'species': species.name,
      'matingDate': matingDate.millisecondsSinceEpoch,
      'motherWeight': motherWeight,
      'expectedLitterSize': expectedLitterSize,
      'isFirstPregnancy': isFirstPregnancy,
      'lastUltrasoundDate': lastUltrasoundDate?.millisecondsSinceEpoch,
      'confirmedPuppies': confirmedPuppies,
    };
  }

  factory PregnancyInput.fromMap(Map<String, dynamic> map) {
    return PregnancyInput(
      species: AnimalSpecies.values.firstWhere((e) => e.name == map['species']),
      matingDate: DateTime.fromMillisecondsSinceEpoch(map['matingDate'] as int),
      motherWeight: (map['motherWeight'] as num?)?.toDouble() ?? 0.0,
      expectedLitterSize: (map['expectedLitterSize'] as num?)?.toInt(),
      isFirstPregnancy: map['isFirstPregnancy'] as bool? ?? false,
      lastUltrasoundDate: map['lastUltrasoundDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUltrasoundDate'] as int)
          : null,
      confirmedPuppies: (map['confirmedPuppies'] as num?)?.toInt(),
    );
  }

  @override
  List<String> validate() {
    final errors = <String>[];
    
    if (motherWeight <= 0) {
      errors.add('Peso da mãe deve ser maior que zero');
    }
    if (matingDate.isAfter(DateTime.now())) {
      errors.add('Data do acasalamento não pode ser futura');
    }
    
    final daysSinceMating = DateTime.now().difference(matingDate).inDays;
    if (daysSinceMating < 0) {
      errors.add('Data do acasalamento inválida');
    }
    
    if (expectedLitterSize != null && expectedLitterSize! <= 0) {
      errors.add('Tamanho esperado da ninhada deve ser maior que zero');
    }
    
    return errors;
  }

  @override
  PregnancyInput copyWith({
    AnimalSpecies? species,
    DateTime? matingDate,
    double? motherWeight,
    int? expectedLitterSize,
    bool? isFirstPregnancy,
    DateTime? lastUltrasoundDate,
    int? confirmedPuppies,
  }) {
    return PregnancyInput(
      species: species ?? this.species,
      matingDate: matingDate ?? this.matingDate,
      motherWeight: motherWeight ?? this.motherWeight,
      expectedLitterSize: expectedLitterSize ?? this.expectedLitterSize,
      isFirstPregnancy: isFirstPregnancy ?? this.isFirstPregnancy,
      lastUltrasoundDate: lastUltrasoundDate ?? this.lastUltrasoundDate,
      confirmedPuppies: confirmedPuppies ?? this.confirmedPuppies,
    );
  }

  @override
  List<Object?> get props => [
        species,
        matingDate,
        motherWeight,
        expectedLitterSize,
        isFirstPregnancy,
        lastUltrasoundDate,
        confirmedPuppies,
      ];
}

class PregnancyResult extends CalculationResult {
  final int gestationDays;
  final DateTime estimatedDueDate;
  final DateTime earliestDueDate;
  final DateTime latestDueDate;
  final PregnancyStage currentStage;
  final int daysRemaining;
  final double recommendedDailyCalories;
  final double recommendedWeight;
  final List<String> nutritionalRecommendations;
  final List<String> careInstructions;
  final List<PregnancyMilestone> upcomingMilestones;
  final bool isOverdue;

  PregnancyResult({
    required this.gestationDays,
    required this.estimatedDueDate,
    required this.earliestDueDate,
    required this.latestDueDate,
    required this.currentStage,
    required this.daysRemaining,
    required this.recommendedDailyCalories,
    required this.recommendedWeight,
    required this.nutritionalRecommendations,
    required this.careInstructions,
    required this.upcomingMilestones,
    required this.isOverdue,
  }) : super(
         calculatorId: CalculatorType.pregnancy.id,
         results: [
           ResultItem(
             label: 'Dias restantes',
             value: daysRemaining,
             unit: 'dias',
             severity: daysRemaining <= 7 ? ResultSeverity.warning : ResultSeverity.info,
           ),
           ResultItem(
             label: 'Dias de gestação',
             value: gestationDays,
             unit: 'dias',
           ),
           ResultItem(
             label: 'Calorias diárias recomendadas',
             value: recommendedDailyCalories.toStringAsFixed(0),
             unit: 'kcal',
           ),
           ResultItem(
             label: 'Peso recomendado',
             value: recommendedWeight.toStringAsFixed(1),
             unit: 'kg',
           ),
         ],
         recommendations: const [],
         summary: 'Gestação: $gestationDays dias - $daysRemaining dias restantes',
         calculatedAt: DateTime.now(),
       );


  @override
  List<Object?> get props => [
        gestationDays,
        estimatedDueDate,
        earliestDueDate,
        latestDueDate,
        currentStage,
        daysRemaining,
        recommendedDailyCalories,
        recommendedWeight,
        nutritionalRecommendations,
        careInstructions,
        upcomingMilestones,
        isOverdue,
        ...super.props,
      ];
}

class PregnancyMilestone {
  final int day;
  final String title;
  final String description;
  final bool isImportant;

  const PregnancyMilestone({
    required this.day,
    required this.title,
    required this.description,
    this.isImportant = false,
  });
}

class PregnancyCalculator extends BaseCalculator<PregnancyInput, PregnancyResult> {
  const PregnancyCalculator();
  @override
  String get id => CalculatorType.pregnancy.id;

  @override
  String get name => 'Calculadora de Gestação';

  @override
  String get description => 'Calcula período gestacional, data do parto e recomendações nutricionais';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'pregnant_woman';

  @override
  PregnancyResult performCalculation(PregnancyInput input) {
    final validationErrors = getInputValidationErrors(input);
    if (validationErrors.isNotEmpty) {
      return createErrorResult(validationErrors.first, input);
    }

    final now = DateTime.now();
    final gestationDays = now.difference(input.matingDate).inDays;
    final totalGestationDays = _getTotalGestationDays(input.species);
    final variationDays = _getGestationVariation(input.species);
    final estimatedDueDate = input.matingDate.add(Duration(days: totalGestationDays));
    final earliestDueDate = estimatedDueDate.subtract(Duration(days: variationDays));
    final latestDueDate = estimatedDueDate.add(Duration(days: variationDays));
    final currentStage = _getCurrentStage(gestationDays, input.species);
    final daysRemaining = totalGestationDays - gestationDays;
    final isOverdue = now.isAfter(latestDueDate);
    final recommendedCalories = _calculateDailyCalories(input, currentStage);
    final recommendedWeight = _calculateRecommendedWeight(input, currentStage);
    final nutritionalRecs = _getNutritionalRecommendations(input, currentStage);
    final careInstructions = _getCareInstructions(input, currentStage, daysRemaining);
    final upcomingMilestones = _getUpcomingMilestones(input.species, gestationDays);

    return PregnancyResult(
      gestationDays: gestationDays,
      estimatedDueDate: estimatedDueDate,
      earliestDueDate: earliestDueDate,
      latestDueDate: latestDueDate,
      currentStage: currentStage,
      daysRemaining: daysRemaining,
      recommendedDailyCalories: recommendedCalories,
      recommendedWeight: recommendedWeight,
      nutritionalRecommendations: nutritionalRecs,
      careInstructions: careInstructions,
      upcomingMilestones: upcomingMilestones,
      isOverdue: isOverdue,
    );
  }

  @override
  List<String> getInputValidationErrors(PregnancyInput input) {
    return input.validate();
  }

  @override
  PregnancyResult createErrorResult(String message, [PregnancyInput? input]) {
    return PregnancyResult(
      gestationDays: 0,
      estimatedDueDate: DateTime.now(),
      earliestDueDate: DateTime.now(),
      latestDueDate: DateTime.now(),
      currentStage: PregnancyStage.early,
      daysRemaining: 0,
      recommendedDailyCalories: 0,
      recommendedWeight: 0,
      nutritionalRecommendations: const [],
      careInstructions: ['ERRO: $message'],
      upcomingMilestones: const [],
      isOverdue: false,
    );
  }

  @override
  PregnancyInput createInputFromMap(Map<String, dynamic> inputs) {
    return PregnancyInput.fromMap(inputs);
  }


  int _getTotalGestationDays(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return 63; // 9 semanas
      case AnimalSpecies.cat:
        return 65; // ~9.3 semanas
    }
  }

  int _getGestationVariation(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.dog:
        return 3; // ±3 dias
      case AnimalSpecies.cat:
        return 2; // ±2 dias
    }
  }

  PregnancyStage _getCurrentStage(int gestationDays, AnimalSpecies species) {
    if (gestationDays <= 30) {
      return PregnancyStage.early;
    } else if (gestationDays <= 45) {
      return PregnancyStage.middle;
    } else {
      return PregnancyStage.late;
    }
  }

  double _calculateDailyCalories(PregnancyInput input, PregnancyStage stage) {
    double baseCalories = 70 * math.pow(input.motherWeight, 0.75).toDouble();
    
    switch (stage) {
      case PregnancyStage.early:
        return baseCalories * 1.1; // Aumento de 10%
      case PregnancyStage.middle:
        return baseCalories * 1.3; // Aumento de 30%
      case PregnancyStage.late:
        return baseCalories * 1.5; // Aumento de 50%
    }
  }

  double _calculateRecommendedWeight(PregnancyInput input, PregnancyStage stage) {
    double weightGainPercent;
    
    switch (stage) {
      case PregnancyStage.early:
        weightGainPercent = 0.05; // 5%
        break;
      case PregnancyStage.middle:
        weightGainPercent = 0.15; // 15%
        break;
      case PregnancyStage.late:
        weightGainPercent = 0.25; // 25%
        break;
    }
    
    return input.motherWeight * (1 + weightGainPercent);
  }

  List<String> _getNutritionalRecommendations(PregnancyInput input, PregnancyStage stage) {
    final recommendations = <String>[];
    
    switch (stage) {
      case PregnancyStage.early:
        recommendations.addAll([
          '🥗 Ração de alta qualidade para filhotes',
          '💊 Suplementação com ácido fólico',
          '🚫 Evitar medicamentos desnecessários',
          '💧 Água fresca sempre disponível',
        ]);
        break;
        
      case PregnancyStage.middle:
        recommendations.addAll([
          '📈 Aumentar porção em 30%',
          '🍖 Proteína de alta qualidade (mín. 25%)',
          '🥛 Suplementação de cálcio (sob orientação)',
          '🕐 Dividir em 3-4 refeições/dia',
        ]);
        break;
        
      case PregnancyStage.late:
        recommendations.addAll([
          '📊 Aumentar porção em 50%',
          '🍗 Ração específica para gestantes',
          '⚖️ Monitorar peso semanalmente',
          '🕑 Pequenas refeições frequentes',
          '🧂 Controlar sal e aditivos',
        ]);
        break;
    }
    
    if (input.expectedLitterSize != null && input.expectedLitterSize! > 5) {
      recommendations.add('👥 Ninhada grande: aumentar calorias em 10% adicional');
    }
    
    return recommendations;
  }

  List<String> _getCareInstructions(PregnancyInput input, PregnancyStage stage, int daysRemaining) {
    final instructions = <String>[];
    
    switch (stage) {
      case PregnancyStage.early:
        instructions.addAll([
          '🔬 Ultrassom entre 25-30 dias',
          '🏃‍♀️ Exercício moderado permitido',
          '💉 Evitar vacinas vivas',
          '🩺 Check-up veterinário',
        ]);
        break;
        
      case PregnancyStage.middle:
        instructions.addAll([
          '📸 Ultrassom para contar filhotes',
          '🚶‍♀️ Reduzir intensidade dos exercícios',
          '🏠 Preparar local do parto',
          '📚 Educação sobre parto',
        ]);
        break;
        
      case PregnancyStage.late:
        instructions.addAll([
          '🏥 Materiais de parto prontos',
          '📞 Veterinário em standby',
          '🌡️ Monitorar temperatura retal',
          '👀 Observar sinais de trabalho de parto',
          '🚫 Evitar estresse e mudanças',
        ]);
        break;
    }
    
    if (daysRemaining <= 7) {
      instructions.addAll([
        '🚨 ALERTA: Parto iminente!',
        '📱 Manter veterinário contactável 24h',
        '🏠 Caixa de parto preparada',
        '🌡️ Temperatura pode cair 1-2°C antes do parto',
      ]);
    }
    
    if (input.isFirstPregnancy) {
      instructions.add('👶 PRIMEIRA GESTAÇÃO: Monitoramento mais rigoroso');
    }
    
    return instructions;
  }

  List<PregnancyMilestone> _getUpcomingMilestones(AnimalSpecies species, int currentDay) {
    final milestones = <PregnancyMilestone>[];
    
    final allMilestones = _getAllMilestones(species);
    for (final milestone in allMilestones) {
      if (milestone.day >= currentDay - 2) {
        milestones.add(milestone);
      }
    }
    
    return milestones.take(5).toList(); // Próximos 5 marcos
  }

  List<PregnancyMilestone> _getAllMilestones(AnimalSpecies species) {
    final milestones = <PregnancyMilestone>[];
    
    if (species == AnimalSpecies.dog) {
      milestones.addAll([
        const PregnancyMilestone(
          day: 14,
          title: 'Implantação',
          description: 'Embriões se implantam no útero',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 25,
          title: 'Primeiro Ultrassom',
          description: 'Confirmação da gestação por ultrassom',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 30,
          title: 'Desenvolvimento Fetal',
          description: 'Órgãos começam a se formar',
        ),
        const PregnancyMilestone(
          day: 40,
          title: 'Segundo Ultrassom',
          description: 'Contagem de filhotes',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 50,
          title: 'Preparação do Parto',
          description: 'Instinto de nidificação aumenta',
        ),
        const PregnancyMilestone(
          day: 58,
          title: 'Monitoramento Intensivo',
          description: 'Verificar temperatura 2x/dia',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 63,
          title: 'Data Prevista do Parto',
          description: 'Parto esperado',
          isImportant: true,
        ),
      ]);
    } else {
      milestones.addAll([
        const PregnancyMilestone(
          day: 15,
          title: 'Implantação',
          description: 'Embriões se implantam no útero',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 21,
          title: 'Primeiro Ultrassom',
          description: 'Confirmação da gestação',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 35,
          title: 'Desenvolvimento Fetal',
          description: 'Estruturas corporais se formam',
        ),
        const PregnancyMilestone(
          day: 45,
          title: 'Segundo Ultrassom',
          description: 'Contagem de filhotes',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 55,
          title: 'Preparação do Parto',
          description: 'Comportamento de nidificação',
        ),
        const PregnancyMilestone(
          day: 62,
          title: 'Monitoramento Final',
          description: 'Verificar sinais de parto',
          isImportant: true,
        ),
        const PregnancyMilestone(
          day: 65,
          title: 'Data Prevista do Parto',
          description: 'Parto esperado',
          isImportant: true,
        ),
      ]);
    }
    
    return milestones;
  }

  @override
  Map<String, dynamic> getInputParameters() {
    return {
      'species': {
        'type': 'enum',
        'label': 'Espécie',
        'options': AnimalSpecies.values.map((e) => e.name).toList(),
        'required': true,
      },
      'matingDate': {
        'type': 'date',
        'label': 'Data do acasalamento',
        'required': true,
      },
      'motherWeight': {
        'type': 'double',
        'label': 'Peso da mãe (kg)',
        'min': 0.5,
        'max': 100.0,
        'step': 0.1,
        'required': true,
      },
      'expectedLitterSize': {
        'type': 'int',
        'label': 'Tamanho esperado da ninhada',
        'min': 1,
        'max': 15,
        'step': 1,
        'required': false,
      },
      'isFirstPregnancy': {
        'type': 'bool',
        'label': 'É a primeira gestação?',
        'required': true,
      },
      'lastUltrasoundDate': {
        'type': 'date',
        'label': 'Data do último ultrassom',
        'required': false,
      },
      'confirmedPuppies': {
        'type': 'int',
        'label': 'Filhotes confirmados por ultrassom',
        'min': 1,
        'max': 15,
        'step': 1,
        'required': false,
      },
    };
  }
}

