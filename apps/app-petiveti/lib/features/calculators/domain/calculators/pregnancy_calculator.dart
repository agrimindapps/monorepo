import '../entities/calculation_result.dart';
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

  const PregnancyResult({
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
    required super.timestamp,
    required super.calculatorType,
    super.notes,
  });

  @override
  String get primaryResult => '$daysRemaining dias restantes';

  @override
  String get summary => 'Gestação: $gestationDays dias (${currentStage.name}) - $primaryResult';

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
  @override
  String get name => 'Calculadora de Gestação';

  @override
  String get description => 'Calcula período gestacional, data do parto e recomendações nutricionais';

  @override
  PregnancyResult calculate(PregnancyInput input) {
    _validateInput(input);

    final now = DateTime.now();
    final gestationDays = now.difference(input.matingDate).inDays;
    
    // Período gestacional por espécie
    final totalGestationDays = _getTotalGestationDays(input.species);
    final variationDays = _getGestationVariation(input.species);
    
    // Calcular datas
    final estimatedDueDate = input.matingDate.add(Duration(days: totalGestationDays));
    final earliestDueDate = estimatedDueDate.subtract(Duration(days: variationDays));
    final latestDueDate = estimatedDueDate.add(Duration(days: variationDays));
    
    // Estágio atual
    final currentStage = _getCurrentStage(gestationDays, input.species);
    
    // Dias restantes
    final daysRemaining = totalGestationDays - gestationDays;
    
    // Verificar se está atrasado
    final isOverdue = now.isAfter(latestDueDate);
    
    // Cálculos nutricionais
    final recommendedCalories = _calculateDailyCalories(input, currentStage);
    final recommendedWeight = _calculateRecommendedWeight(input, currentStage);
    
    // Recomendações
    final nutritionalRecs = _getNutritionalRecommendations(input, currentStage);
    final careInstructions = _getCareInstructions(input, currentStage, daysRemaining);
    
    // Marcos importantes
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
      timestamp: DateTime.now(),
      calculatorType: CalculatorType.pregnancy,
    );
  }

  void _validateInput(PregnancyInput input) {
    if (input.motherWeight <= 0) {
      throw ArgumentError('Peso da mãe deve ser maior que zero');
    }
    if (input.matingDate.isAfter(DateTime.now())) {
      throw ArgumentError('Data do acasalamento não pode ser futura');
    }
    
    final maxGestationDays = _getTotalGestationDays(input.species) + 14;
    final daysSinceMating = DateTime.now().difference(input.matingDate).inDays;
    
    if (daysSinceMating > maxGestationDays) {
      throw ArgumentError('Data do acasalamento muito antiga para gestação ativa');
    }
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
    // Calorias base: ~70 * peso^0.75 para manutenção
    double baseCalories = 70 * Math.pow(input.motherWeight, 0.75);
    
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
    // Ganho de peso recomendado durante a gestação
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
    
    // Filtrar apenas marcos futuros ou próximos
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
        PregnancyMilestone(
          day: 14,
          title: 'Implantação',
          description: 'Embriões se implantam no útero',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 25,
          title: 'Primeiro Ultrassom',
          description: 'Confirmação da gestação por ultrassom',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 30,
          title: 'Desenvolvimento Fetal',
          description: 'Órgãos começam a se formar',
        ),
        PregnancyMilestone(
          day: 40,
          title: 'Segundo Ultrassom',
          description: 'Contagem de filhotes',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 50,
          title: 'Preparação do Parto',
          description: 'Instinto de nidificação aumenta',
        ),
        PregnancyMilestone(
          day: 58,
          title: 'Monitoramento Intensivo',
          description: 'Verificar temperatura 2x/dia',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 63,
          title: 'Data Prevista do Parto',
          description: 'Parto esperado',
          isImportant: true,
        ),
      ]);
    } else {
      // Gatos
      milestones.addAll([
        PregnancyMilestone(
          day: 15,
          title: 'Implantação',
          description: 'Embriões se implantam no útero',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 21,
          title: 'Primeiro Ultrassom',
          description: 'Confirmação da gestação',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 35,
          title: 'Desenvolvimento Fetal',
          description: 'Estruturas corporais se formam',
        ),
        PregnancyMilestone(
          day: 45,
          title: 'Segundo Ultrassom',
          description: 'Contagem de filhotes',
          isImportant: true,
        ),
        PregnancyMilestone(
          day: 55,
          title: 'Preparação do Parto',
          description: 'Comportamento de nidificação',
        ),
        PregnancyMilestone(
          day: 62,
          title: 'Monitoramento Final',
          description: 'Verificar sinais de parto',
          isImportant: true,
        ),
        PregnancyMilestone(
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
        'options': AnimalSpecies.values,
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

// Import do Math para usar pow
import 'dart:math' as Math;