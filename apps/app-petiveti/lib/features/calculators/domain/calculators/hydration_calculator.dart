import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator_input.dart';
import 'base_calculator.dart';

enum DehydrationLevel {
  none, // 0-3%
  mild, // 3-5%
  moderate, // 5-8%
  severe, // 8-12%
  critical, // >12%
}

enum BodyCondition {
  underweight,
  ideal,
  overweight,
  obese,
}

enum ActivityLevel {
  sedentary,
  moderate,
  active,
  veryActive,
}

enum EnvironmentTemp {
  cool, // <20°C
  normal, // 20-25°C
  warm, // 25-30°C
  hot, // >30°C
}

class HydrationInput extends CalculatorInput {
  final double weight;
  final DehydrationLevel dehydrationLevel;
  final BodyCondition bodyCondition;
  final ActivityLevel activityLevel;
  final EnvironmentTemp environmentTemp;
  final bool isLactating;
  final bool hasKidneyDisease;
  final bool hasHeartDisease;
  final bool hasVomiting;
  final bool hasDiarrhea;
  final double? currentIntake; // mL nas últimas 24h
  final int? hoursWithoutWater;

  const HydrationInput({
    required this.weight,
    required this.dehydrationLevel,
    required this.bodyCondition,
    required this.activityLevel,
    required this.environmentTemp,
    this.isLactating = false,
    this.hasKidneyDisease = false,
    this.hasHeartDisease = false,
    this.hasVomiting = false,
    this.hasDiarrhea = false,
    this.currentIntake,
    this.hoursWithoutWater,
  });

  @override
  List<Object?> get props => [
        weight,
        dehydrationLevel,
        bodyCondition,
        activityLevel,
        environmentTemp,
        isLactating,
        hasKidneyDisease,
        hasHeartDisease,
        hasVomiting,
        hasDiarrhea,
        currentIntake,
        hoursWithoutWater,
      ];
}

class HydrationResult extends CalculationResult {
  final double dailyWaterNeeds; // mL/dia
  final double maintenanceVolume; // mL/dia
  final double replacementVolume; // mL para repor deficit
  final double ongoingLossVolume; // mL/dia para perdas contínuas
  final double totalDailyVolume; // mL/dia total
  final double hourlyIntakeRecommendation; // mL/hora
  final List<String> hydrationMethods;
  final List<String> monitoringInstructions;
  final List<String> warnings;
  final bool requiresIVTherapy;
  final String urgencyLevel;

  const HydrationResult({
    required this.dailyWaterNeeds,
    required this.maintenanceVolume,
    required this.replacementVolume,
    required this.ongoingLossVolume,
    required this.totalDailyVolume,
    required this.hourlyIntakeRecommendation,
    required this.hydrationMethods,
    required this.monitoringInstructions,
    required this.warnings,
    required this.requiresIVTherapy,
    required this.urgencyLevel,
    required super.timestamp,
    required super.calculatorType,
    super.notes,
  });

  @override
  String get primaryResult => '${totalDailyVolume.round()} mL/dia';

  @override
  String get summary => 'Hidratação: $primaryResult (${urgencyLevel})';

  @override
  List<Object?> get props => [
        dailyWaterNeeds,
        maintenanceVolume,
        replacementVolume,
        ongoingLossVolume,
        totalDailyVolume,
        hourlyIntakeRecommendation,
        hydrationMethods,
        monitoringInstructions,
        warnings,
        requiresIVTherapy,
        urgencyLevel,
        ...super.props,
      ];
}

class HydrationCalculator extends BaseCalculator<HydrationInput, HydrationResult> {
  @override
  String get name => 'Calculadora de Hidratação';

  @override
  String get description => 'Calcula necessidades hídricas e reposição de fluidos para animais';

  @override
  HydrationResult calculate(HydrationInput input) {
    _validateInput(input);

    // Calcular necessidade base de água
    final dailyWaterNeeds = _calculateDailyWaterNeeds(input);
    
    // Calcular volume de manutenção
    final maintenanceVolume = _calculateMaintenanceVolume(input);
    
    // Calcular volume de reposição (para déficit)
    final replacementVolume = _calculateReplacementVolume(input);
    
    // Calcular volume para perdas contínuas
    final ongoingLossVolume = _calculateOngoingLossVolume(input);
    
    // Volume total diário
    final totalDailyVolume = maintenanceVolume + replacementVolume + ongoingLossVolume;
    
    // Recomendação por hora
    final hourlyIntakeRecommendation = totalDailyVolume / 24;
    
    // Métodos de hidratação recomendados
    final hydrationMethods = _getHydrationMethods(input);
    
    // Instruções de monitoramento
    final monitoringInstructions = _getMonitoringInstructions(input);
    
    // Avisos de segurança
    final warnings = _generateWarnings(input);
    
    // Verificar se precisa de terapia IV
    final requiresIVTherapy = _requiresIVTherapy(input);
    
    // Nível de urgência
    final urgencyLevel = _getUrgencyLevel(input);

    return HydrationResult(
      dailyWaterNeeds: dailyWaterNeeds,
      maintenanceVolume: maintenanceVolume,
      replacementVolume: replacementVolume,
      ongoingLossVolume: ongoingLossVolume,
      totalDailyVolume: totalDailyVolume,
      hourlyIntakeRecommendation: hourlyIntakeRecommendation,
      hydrationMethods: hydrationMethods,
      monitoringInstructions: monitoringInstructions,
      warnings: warnings,
      requiresIVTherapy: requiresIVTherapy,
      urgencyLevel: urgencyLevel,
      timestamp: DateTime.now(),
      calculatorType: CalculatorType.hydration,
    );
  }

  void _validateInput(HydrationInput input) {
    if (input.weight <= 0) {
      throw ArgumentError('Peso deve ser maior que zero');
    }
    if (input.weight > 100) {
      throw ArgumentError('Peso muito alto (>100kg)');
    }
    if (input.currentIntake != null && input.currentIntake! < 0) {
      throw ArgumentError('Ingestão atual não pode ser negativa');
    }
    if (input.hoursWithoutWater != null && input.hoursWithoutWater! < 0) {
      throw ArgumentError('Horas sem água não pode ser negativo');
    }
  }

  double _calculateDailyWaterNeeds(HydrationInput input) {
    // Necessidade base: 50-60 mL/kg/dia para cães e gatos
    double baseNeeds = input.weight * 55; // mL/dia
    
    // Ajustar por condição corporal
    switch (input.bodyCondition) {
      case BodyCondition.underweight:
        baseNeeds *= 1.1; // +10%
        break;
      case BodyCondition.ideal:
        // Sem ajuste
        break;
      case BodyCondition.overweight:
        baseNeeds *= 0.9; // -10%
        break;
      case BodyCondition.obese:
        baseNeeds *= 0.8; // -20%
        break;
    }
    
    // Ajustar por nível de atividade
    switch (input.activityLevel) {
      case ActivityLevel.sedentary:
        baseNeeds *= 0.9; // -10%
        break;
      case ActivityLevel.moderate:
        // Sem ajuste
        break;
      case ActivityLevel.active:
        baseNeeds *= 1.2; // +20%
        break;
      case ActivityLevel.veryActive:
        baseNeeds *= 1.4; // +40%
        break;
    }
    
    // Ajustar por temperatura ambiente
    switch (input.environmentTemp) {
      case EnvironmentTemp.cool:
        baseNeeds *= 0.9; // -10%
        break;
      case EnvironmentTemp.normal:
        // Sem ajuste
        break;
      case EnvironmentTemp.warm:
        baseNeeds *= 1.2; // +20%
        break;
      case EnvironmentTemp.hot:
        baseNeeds *= 1.5; // +50%
        break;
    }
    
    // Ajustes por condições especiais
    if (input.isLactating) {
      baseNeeds *= 1.5; // +50% para lactação
    }
    
    if (input.hasKidneyDisease) {
      baseNeeds *= 1.3; // +30% para doença renal
    }
    
    return baseNeeds;
  }

  double _calculateMaintenanceVolume(HydrationInput input) {
    // Volume de manutenção baseado no peso
    // Fórmula: 70 * peso^0.75 (para energia) convertido para água
    return 70 * math.pow(input.weight, 0.75) * 2; // Aproximadamente 2mL por kcal
  }

  double _calculateReplacementVolume(HydrationInput input) {
    double deficitPercent;
    
    switch (input.dehydrationLevel) {
      case DehydrationLevel.none:
        deficitPercent = 0.0;
        break;
      case DehydrationLevel.mild:
        deficitPercent = 0.04; // 4%
        break;
      case DehydrationLevel.moderate:
        deficitPercent = 0.065; // 6.5%
        break;
      case DehydrationLevel.severe:
        deficitPercent = 0.10; // 10%
        break;
      case DehydrationLevel.critical:
        deficitPercent = 0.12; // 12%
        break;
    }
    
    // Peso em kg * % desidratação * 1000 (para converter kg para mL)
    double deficitVolume = input.weight * deficitPercent * 1000;
    
    // Dividir em 24h para reposição gradual (exceto emergências)
    if (input.dehydrationLevel == DehydrationLevel.critical) {
      return deficitVolume; // Repor em 6-12h
    } else {
      return deficitVolume; // Repor em 24h
    }
  }

  double _calculateOngoingLossVolume(HydrationInput input) {
    double ongoingLoss = 0.0;
    
    if (input.hasVomiting) {
      ongoingLoss += input.weight * 20; // 20mL/kg/dia adicional
    }
    
    if (input.hasDiarrhea) {
      ongoingLoss += input.weight * 30; // 30mL/kg/dia adicional
    }
    
    return ongoingLoss;
  }

  List<String> _getHydrationMethods(HydrationInput input) {
    final methods = <String>[];
    
    if (input.dehydrationLevel == DehydrationLevel.none || 
        input.dehydrationLevel == DehydrationLevel.mild) {
      methods.addAll([
        '💧 Água fresca sempre disponível',
        '🥄 Oferecer água com seringa (se necessário)',
        '🍲 Ração úmida para aumentar ingestão',
        '🧊 Cubos de gelo como petisco',
      ]);
    }
    
    if (input.dehydrationLevel == DehydrationLevel.moderate) {
      methods.addAll([
        '💉 Fluidos subcutâneos',
        '🏥 Supervisão veterinária',
        '⏰ Administração fracionada (6-8x/dia)',
        '📊 Monitoramento de resposta',
      ]);
    }
    
    if (input.dehydrationLevel == DehydrationLevel.severe || 
        input.dehydrationLevel == DehydrationLevel.critical) {
      methods.addAll([
        '🏥 HOSPITALIZAÇÃO IMEDIATA',
        '💉 Fluidoterapia intravenosa',
        '⚡ Reposição rápida inicial',
        '🔍 Monitoramento contínuo',
        '📈 Ajuste baseado em resposta',
      ]);
    }
    
    if (input.hasHeartDisease) {
      methods.add('⚠️ Fluidoterapia cautelosa (risco de sobrecarga)');
    }
    
    return methods;
  }

  List<String> _getMonitoringInstructions(HydrationInput input) {
    final instructions = <String>[];
    
    instructions.addAll([
      '👁️ Verificar elasticidade da pele (teste da prega)',
      '👄 Observar umidade das mucosas',
      '⚖️ Monitorar peso corporal',
      '🚰 Medir consumo de água diário',
    ]);
    
    if (input.dehydrationLevel != DehydrationLevel.none) {
      instructions.addAll([
        '⏱️ Reavaliar hidratação a cada 4-6h',
        '🌡️ Monitorar temperatura corporal',
        '💓 Verificar frequência cardíaca',
        '🩺 Pulso e perfusão capilar',
      ]);
    }
    
    if (input.dehydrationLevel == DehydrationLevel.severe || 
        input.dehydrationLevel == DehydrationLevel.critical) {
      instructions.addAll([
        '📊 Exames laboratoriais (ureia, creatinina)',
        '💉 Verificar acesso venoso',
        '📋 Balanço hídrico rigoroso',
        '🚨 Sinais de sobrecarga hídrica',
      ]);
    }
    
    return instructions;
  }

  List<String> _generateWarnings(HydrationInput input) {
    final warnings = <String>[];
    
    if (input.dehydrationLevel == DehydrationLevel.critical) {
      warnings.add('🚨 EMERGÊNCIA: Desidratação crítica - procurar veterinário IMEDIATAMENTE');
    }
    
    if (input.dehydrationLevel == DehydrationLevel.severe) {
      warnings.add('⚠️ URGENTE: Desidratação severa - hospitalização recomendada');
    }
    
    if (input.hasHeartDisease) {
      warnings.add('❤️ ATENÇÃO: Cardiopata - fluidoterapia cautelosa');
    }
    
    if (input.hasKidneyDisease) {
      warnings.add('🔴 CUIDADO: Doença renal - monitorar função renal');
    }
    
    if (input.hoursWithoutWater != null && input.hoursWithoutWater! > 24) {
      warnings.add('⏰ ALERTA: Mais de 24h sem água - risco aumentado');
    }
    
    if (input.isLactating && input.dehydrationLevel != DehydrationLevel.none) {
      warnings.add('🤱 LACTAÇÃO: Desidratação pode afetar produção de leite');
    }
    
    warnings.add('📞 Sempre consultar veterinário para casos de desidratação moderada ou superior');
    
    return warnings;
  }

  bool _requiresIVTherapy(HydrationInput input) {
    return input.dehydrationLevel == DehydrationLevel.severe ||
           input.dehydrationLevel == DehydrationLevel.critical ||
           (input.hasVomiting && input.dehydrationLevel == DehydrationLevel.moderate);
  }

  String _getUrgencyLevel(HydrationInput input) {
    switch (input.dehydrationLevel) {
      case DehydrationLevel.none:
        return 'Normal';
      case DehydrationLevel.mild:
        return 'Baixa';
      case DehydrationLevel.moderate:
        return 'Moderada';
      case DehydrationLevel.severe:
        return 'Alta';
      case DehydrationLevel.critical:
        return 'CRÍTICA';
    }
  }

  @override
  Map<String, dynamic> getInputParameters() {
    return {
      'weight': {
        'type': 'double',
        'label': 'Peso do animal (kg)',
        'min': 0.1,
        'max': 100.0,
        'step': 0.1,
        'required': true,
      },
      'dehydrationLevel': {
        'type': 'enum',
        'label': 'Nível de desidratação',
        'options': DehydrationLevel.values,
        'required': true,
      },
      'bodyCondition': {
        'type': 'enum',
        'label': 'Condição corporal',
        'options': BodyCondition.values,
        'required': true,
      },
      'activityLevel': {
        'type': 'enum',
        'label': 'Nível de atividade',
        'options': ActivityLevel.values,
        'required': true,
      },
      'environmentTemp': {
        'type': 'enum',
        'label': 'Temperatura ambiente',
        'options': EnvironmentTemp.values,
        'required': true,
      },
      'isLactating': {
        'type': 'bool',
        'label': 'Está lactando?',
        'required': true,
      },
      'hasKidneyDisease': {
        'type': 'bool',
        'label': 'Tem doença renal?',
        'required': true,
      },
      'hasHeartDisease': {
        'type': 'bool',
        'label': 'Tem doença cardíaca?',
        'required': true,
      },
      'hasVomiting': {
        'type': 'bool',
        'label': 'Está vomitando?',
        'required': true,
      },
      'hasDiarrhea': {
        'type': 'bool',
        'label': 'Tem diarreia?',
        'required': true,
      },
      'currentIntake': {
        'type': 'double',
        'label': 'Ingestão atual de água (mL/24h)',
        'min': 0.0,
        'max': 5000.0,
        'step': 10.0,
        'required': false,
      },
      'hoursWithoutWater': {
        'type': 'int',
        'label': 'Horas sem água',
        'min': 0,
        'max': 72,
        'step': 1,
        'required': false,
      },
    };
  }
}

