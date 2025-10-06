import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart' as input;

/// Resultado da calculadora de exercícios
class ExerciseResult extends CalculationResult {
  const ExerciseResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

/// Calculadora de Exercícios para Pets
/// Calcula necessidades diárias de exercício baseado na raça, idade, porte e condições de saúde
class ExerciseCalculator extends Calculator {
  const ExerciseCalculator();

  @override
  String get id => 'exercise';

  @override
  String get name => 'Calculadora de Exercícios';

  @override
  String get description => 
      'Calcula as necessidades diárias de exercício do animal baseado na raça, idade, porte, '
      'condição física e objetivos específicos para manter saúde e bem-estar.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'directions_run';

  @override
  String get version => '1.0.0';

  @override
  List<input.InputField> get inputFields => [
    const input.InputField(
      key: 'species',
      label: 'Espécie',
      type: input.InputFieldType.dropdown,
      options: ['Cão', 'Gato'],
      isRequired: true,
      helperText: 'Tipo de animal',
    ),
    const input.InputField(
      key: 'breed_group',
      label: 'Grupo da Raça',
      type: input.InputFieldType.dropdown,
      options: [
        'Cão de Trabalho (Pastor, Border Collie)',
        'Cão Esportivo (Retriever, Pointer)',
        'Cão de Caça (Beagle, Cocker)',
        'Cão Terrier (Jack Russell, Bull Terrier)',
        'Cão de Companhia (Pug, Bulldog)',
        'Cão Toy (Chihuahua, Yorkshire)',
        'Cão Gigante (Mastiff, São Bernardo)',
        'Sem Raça Definida - Ativo',
        'Sem Raça Definida - Moderado',
        'Gato de Apartamento',
        'Gato com Acesso Externo',
      ],
      isRequired: true,
      helperText: 'Grupo ou característica da raça',
    ),
    const input.InputField(
      key: 'age_years',
      label: 'Idade',
      type: input.InputFieldType.number,
      unit: 'anos',
      isRequired: true,
      minValue: 0.1,
      maxValue: 25.0,
      helperText: 'Idade do animal em anos',
    ),
    const input.InputField(
      key: 'weight',
      label: 'Peso',
      type: input.InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.5,
      maxValue: 100.0,
      helperText: 'Peso atual do animal',
    ),
    const input.InputField(
      key: 'current_activity_level',
      label: 'Nível de Atividade Atual',
      type: input.InputFieldType.dropdown,
      options: [
        'Sedentário (pouco ou nenhum exercício)',
        'Levemente Ativo (exercício ocasional)',
        'Moderadamente Ativo (exercício regular)',
        'Muito Ativo (exercício intenso diário)',
        'Atlético (treinamento intensivo)',
      ],
      isRequired: true,
      helperText: 'Nível atual de atividade física',
    ),
    const input.InputField(
      key: 'health_conditions',
      label: 'Condições de Saúde',
      type: input.InputFieldType.dropdown,
      options: [
        'Saudável (sem restrições)',
        'Obesidade/Sobrepeso',
        'Problemas Articulares (artrite, displasia)',
        'Problemas Cardíacos',
        'Problemas Respiratórios',
        'Recuperação de Cirurgia',
        'Idade Avançada (limitações)',
      ],
      isRequired: true,
      helperText: 'Condições que podem afetar o exercício',
    ),
    const input.InputField(
      key: 'exercise_goal',
      label: 'Objetivo do Exercício',
      type: input.InputFieldType.dropdown,
      options: [
        'Manutenção da Saúde',
        'Perda de Peso',
        'Ganho de Condicionamento',
        'Controle de Comportamento',
        'Preparação Esportiva',
        'Reabilitação',
      ],
      isRequired: true,
      helperText: 'Principal objetivo com o exercício',
    ),
    const input.InputField(
      key: 'available_time',
      label: 'Tempo Disponível por Dia',
      type: input.InputFieldType.number,
      unit: 'minutos',
      isRequired: true,
      minValue: 10.0,
      maxValue: 300.0,
      helperText: 'Tempo disponível diariamente para exercício',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final species = inputs['species'] as String;
    final breedGroup = inputs['breed_group'] as String;
    final ageYears = inputs['age_years'] as double;
    final weight = inputs['weight'] as double;
    final currentActivityLevel = inputs['current_activity_level'] as String;
    final healthConditions = inputs['health_conditions'] as String;
    final exerciseGoal = inputs['exercise_goal'] as String;
    final availableTime = inputs['available_time'] as double;

    final calculationData = _calculateExercise(
      species: species,
      breedGroup: breedGroup,
      ageYears: ageYears,
      weight: weight,
      currentActivityLevel: currentActivityLevel,
      healthConditions: healthConditions,
      exerciseGoal: exerciseGoal,
      availableTime: availableTime,
    );

    final results = [
      ResultItem(
        label: 'Exercício Diário Recomendado',
        value: calculationData['recommended_minutes'],
        unit: 'minutos/dia',
        severity: _getExerciseTimeSeverity(
          calculationData['recommended_minutes'] as int,
          availableTime.toInt(),
        ),
      ),
      ResultItem(
        label: 'Caminhadas Diárias',
        value: calculationData['walk_minutes'],
        unit: 'minutos',
        severity: ResultSeverity.info,
        description: '${calculationData['walk_sessions']} sessões de ${calculationData['walk_duration']} min',
      ),
      ResultItem(
        label: 'Atividade Intensa',
        value: calculationData['intense_minutes'],
        unit: 'minutos',
        severity: ResultSeverity.success,
        description: calculationData['intense_description'] as String,
      ),
      ResultItem(
        label: 'Tempo de Brincadeira',
        value: calculationData['play_minutes'],
        unit: 'minutos',
        severity: ResultSeverity.info,
        description: calculationData['play_description'] as String,
      ),
      ResultItem(
        label: 'Classificação da Necessidade',
        value: calculationData['exercise_need_level'],
        severity: _getExerciseNeedSeverity(calculationData['exercise_need_level'] as String),
      ),
    ];
    if (calculationData['calories_burned'] != null) {
      results.add(
        ResultItem(
          label: 'Calorias Queimadas Estimadas',
          value: calculationData['calories_burned'],
          unit: 'kcal/dia',
          severity: ResultSeverity.success,
        ),
      );
    }

    final recommendations = (calculationData['recommendations'] as List<String>)
        .map((rec) => Recommendation(
              title: 'Recomendação de Exercício',
              message: rec,
              severity: ResultSeverity.info,
            ))
        .toList();
    final safetyAlerts = calculationData['safety_alerts'] as List<String>;
    for (final alert in safetyAlerts) {
      recommendations.add(
        Recommendation(
          title: 'Alerta de Segurança',
          message: alert,
          severity: ResultSeverity.warning,
        ),
      );
    }

    return ExerciseResult(
      calculatorId: id,
      results: results,
      recommendations: recommendations,
      summary: 'Exercício diário: ${calculationData['recommended_minutes']} min | '
               'Necessidade: ${calculationData['exercise_need_level']} | '
               'Caminhadas: ${calculationData['walk_minutes']} min',
      calculatedAt: DateTime.now(),
    );
  }

  @override
  bool validateInputs(Map<String, dynamic> inputs) {
    return getValidationErrors(inputs).isEmpty;
  }

  @override
  List<String> getValidationErrors(Map<String, dynamic> inputs) {
    final errors = <String>[];
    for (final field in inputFields) {
      if (field.isRequired && !inputs.containsKey(field.key)) {
        errors.add('${field.label} é obrigatório');
      }
    }
    if (inputs.containsKey('age_years')) {
      final age = inputs['age_years'];
      if (age is! double && age is! int) {
        errors.add('Idade deve ser um número');
      } else {
        final ageValue = age is int ? age.toDouble() : age as double;
        if (ageValue <= 0 || ageValue > 25) {
          errors.add('Idade deve estar entre 0.1 e 25 anos');
        }
      }
    }
    if (inputs.containsKey('weight')) {
      final weight = inputs['weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0 || weightValue > 100) {
          errors.add('Peso deve estar entre 0.5 e 100 kg');
        }
      }
    }
    if (inputs.containsKey('available_time')) {
      final time = inputs['available_time'];
      if (time is! double && time is! int) {
        errors.add('Tempo disponível deve ser um número');
      } else {
        final timeValue = time is int ? time.toDouble() : time as double;
        if (timeValue < 10 || timeValue > 300) {
          errors.add('Tempo disponível deve estar entre 10 e 300 minutos');
        }
      }
    }

    return errors;
  }

  Map<String, dynamic> _calculateExercise({
    required String species,
    required String breedGroup,
    required double ageYears,
    required double weight,
    required String currentActivityLevel,
    required String healthConditions,
    required String exerciseGoal,
    required double availableTime,
  }) {
    int baseExerciseMinutes = _getBaseExerciseMinutes(species, breedGroup);
    double ageMultiplier = _getAgeMultiplier(ageYears, species);
    double healthMultiplier = _getHealthMultiplier(healthConditions);
    double goalMultiplier = _getGoalMultiplier(exerciseGoal);
    int recommendedMinutes = (baseExerciseMinutes * ageMultiplier * healthMultiplier * goalMultiplier).round();
    recommendedMinutes = math.max(15, math.min(recommendedMinutes, 180)); // Entre 15 e 180 min
    final distribution = _distributeExercise(recommendedMinutes, breedGroup, species);
    final caloriesBurned = _calculateCalories(weight, recommendedMinutes, currentActivityLevel);
    final recommendations = _generateRecommendations(
      species: species,
      breedGroup: breedGroup,
      ageYears: ageYears,
      healthConditions: healthConditions,
      exerciseGoal: exerciseGoal,
      recommendedMinutes: recommendedMinutes,
      availableTime: availableTime.toInt(),
    );
    final safetyAlerts = _generateSafetyAlerts(
      ageYears: ageYears,
      healthConditions: healthConditions,
      recommendedMinutes: recommendedMinutes,
      species: species,
    );
    String exerciseNeedLevel;
    if (recommendedMinutes >= 120) {
      exerciseNeedLevel = 'Muito Alto';
    } else if (recommendedMinutes >= 90) {
      exerciseNeedLevel = 'Alto';
    } else if (recommendedMinutes >= 60) {
      exerciseNeedLevel = 'Moderado';
    } else if (recommendedMinutes >= 30) {
      exerciseNeedLevel = 'Baixo';
    } else {
      exerciseNeedLevel = 'Muito Baixo';
    }

    return {
      'recommended_minutes': recommendedMinutes,
      'walk_minutes': distribution['walk_minutes'],
      'walk_sessions': distribution['walk_sessions'],
      'walk_duration': distribution['walk_duration'],
      'intense_minutes': distribution['intense_minutes'],
      'intense_description': distribution['intense_description'],
      'play_minutes': distribution['play_minutes'],
      'play_description': distribution['play_description'],
      'exercise_need_level': exerciseNeedLevel,
      'calories_burned': caloriesBurned,
      'recommendations': recommendations,
      'safety_alerts': safetyAlerts,
    };
  }

  int _getBaseExerciseMinutes(String species, String breedGroup) {
    if (species == 'Gato') {
      return breedGroup.contains('Apartamento') ? 30 : 45;
    }
    final breedExerciseNeeds = {
      'Cão de Trabalho (Pastor, Border Collie)': 120,
      'Cão Esportivo (Retriever, Pointer)': 90,
      'Cão de Caça (Beagle, Cocker)': 75,
      'Cão Terrier (Jack Russell, Bull Terrier)': 75,
      'Cão de Companhia (Pug, Bulldog)': 30,
      'Cão Toy (Chihuahua, Yorkshire)': 20,
      'Cão Gigante (Mastiff, São Bernardo)': 60,
      'Sem Raça Definida - Ativo': 75,
      'Sem Raça Definida - Moderado': 60,
    };

    return breedExerciseNeeds[breedGroup] ?? 60;
  }

  double _getAgeMultiplier(double ageYears, String species) {
    if (species == 'Gato') {
      if (ageYears < 1) return 1.2; // Filhotes
      if (ageYears < 2) return 1.1; // Jovens
      if (ageYears < 8) return 1.0; // Adultos
      if (ageYears < 12) return 0.8; // Sênior
      return 0.6; // Geriátrico
    } else {
      if (ageYears < 1) return 0.8; // Filhotes - limitado
      if (ageYears < 2) return 1.2; // Jovens - muita energia
      if (ageYears < 7) return 1.0; // Adultos
      if (ageYears < 10) return 0.8; // Sênior
      return 0.6; // Geriátrico
    }
  }

  double _getHealthMultiplier(String healthConditions) {
    switch (healthConditions) {
      case 'Saudável (sem restrições)':
        return 1.0;
      case 'Obesidade/Sobrepeso':
        return 1.3; // Mais exercício necessário
      case 'Problemas Articulares (artrite, displasia)':
        return 0.7; // Exercício de baixo impacto
      case 'Problemas Cardíacos':
        return 0.6; // Exercício moderado controlado
      case 'Problemas Respiratórios':
        return 0.5; // Exercício leve
      case 'Recuperação de Cirurgia':
        return 0.3; // Muito limitado
      case 'Idade Avançada (limitações)':
        return 0.7; // Exercício suave
      default:
        return 1.0;
    }
  }

  double _getGoalMultiplier(String exerciseGoal) {
    switch (exerciseGoal) {
      case 'Manutenção da Saúde':
        return 1.0;
      case 'Perda de Peso':
        return 1.4; // Mais exercício para queimar calorias
      case 'Ganho de Condicionamento':
        return 1.3; // Exercício progressivo
      case 'Controle de Comportamento':
        return 1.2; // Exercício para gastar energia
      case 'Preparação Esportiva':
        return 1.5; // Treinamento intensivo
      case 'Reabilitação':
        return 0.8; // Exercício controlado
      default:
        return 1.0;
    }
  }

  Map<String, dynamic> _distributeExercise(int totalMinutes, String breedGroup, String species) {
    if (species == 'Gato') {
      return {
        'walk_minutes': 0,
        'walk_sessions': 0,
        'walk_duration': 0,
        'intense_minutes': (totalMinutes * 0.3).round(),
        'intense_description': 'Caça simulada, brinquedos interativos',
        'play_minutes': (totalMinutes * 0.7).round(),
        'play_description': 'Brincadeiras com brinquedos, exploração',
      };
    }
    final walkMinutes = (totalMinutes * 0.6).round();
    final intenseMinutes = (totalMinutes * 0.25).round();
    final playMinutes = totalMinutes - walkMinutes - intenseMinutes;

    int walkSessions;
    int walkDuration;
    
    if (walkMinutes <= 30) {
      walkSessions = 2;
      walkDuration = (walkMinutes / 2).round();
    } else {
      walkSessions = 3;
      walkDuration = (walkMinutes / 3).round();
    }

    String intenseDescription;
    if (breedGroup.contains('Trabalho') || breedGroup.contains('Esportivo')) {
      intenseDescription = 'Corrida, busca, agility';
    } else if (breedGroup.contains('Terrier')) {
      intenseDescription = 'Brincadeiras vigorosas, cabo de guerra';
    } else {
      intenseDescription = 'Caminhada rápida, brincadeiras ativas';
    }

    return {
      'walk_minutes': walkMinutes,
      'walk_sessions': walkSessions,
      'walk_duration': walkDuration,
      'intense_minutes': intenseMinutes,
      'intense_description': intenseDescription,
      'play_minutes': playMinutes,
      'play_description': 'Brincadeiras livres, socialização',
    };
  }

  int? _calculateCalories(double weight, int exerciseMinutes, String activityLevel) {
    double baseCaloriesPerKgPerMinute = 0.8; // Valor médio
    double intensityMultiplier;
    switch (activityLevel) {
      case 'Sedentário (pouco ou nenhum exercício)':
        intensityMultiplier = 0.7;
        break;
      case 'Levemente Ativo (exercício ocasional)':
        intensityMultiplier = 0.85;
        break;
      case 'Moderadamente Ativo (exercício regular)':
        intensityMultiplier = 1.0;
        break;
      case 'Muito Ativo (exercício intenso diário)':
        intensityMultiplier = 1.2;
        break;
      case 'Atlético (treinamento intensivo)':
        intensityMultiplier = 1.4;
        break;
      default:
        intensityMultiplier = 1.0;
    }

    return (weight * exerciseMinutes * baseCaloriesPerKgPerMinute * intensityMultiplier).round();
  }

  List<String> _generateRecommendations({
    required String species,
    required String breedGroup,
    required double ageYears,
    required String healthConditions,
    required String exerciseGoal,
    required int recommendedMinutes,
    required int availableTime,
  }) {
    final recommendations = <String>[];
    if (species == 'Cão') {
      recommendations.addAll([
        'Varie os tipos de exercício para manter o interesse',
        'Use caminhadas para socialização e exploração sensorial',
        'Ajuste a intensidade baseado na resposta do animal',
      ]);
    } else {
      recommendations.addAll([
        'Estimule o instinto de caça com brinquedos interativos',
        'Crie ambientes verticais para exploração (arranhadores altos)',
        'Alterne períodos de atividade intensa com descanso',
      ]);
    }
    if (breedGroup.contains('Trabalho')) {
      recommendations.add('Forneça atividades que estimulem a mente (puzzles, treinamentos)');
    } else if (breedGroup.contains('Companhia')) {
      recommendations.add('Foque em exercícios de baixo impacto e curta duração');
    }
    if (healthConditions.contains('Articulares')) {
      recommendations.addAll([
        'Prefira natação ou caminhadas em superfícies macias',
        'Evite saltos e movimentos bruscos',
        'Considere fisioterapia veterinária',
      ]);
    } else if (healthConditions.contains('Cardíacos')) {
      recommendations.addAll([
        'Monitore sinais de cansaço excessivo',
        'Exercite em horários frescos do dia',
        'Consulte veterinário antes de aumentar intensidade',
      ]);
    }
    if (exerciseGoal == 'Perda de Peso') {
      recommendations.addAll([
        'Combine exercício com dieta balanceada',
        'Aumente gradualmente a duração e intensidade',
        'Monitore o peso semanalmente',
      ]);
    } else if (exerciseGoal == 'Controle de Comportamento') {
      recommendations.addAll([
        'Exercite antes de períodos prolongados sozinho',
        'Varie os locais de exercício para estimulação mental',
        'Inclua treinamento de obediência durante o exercício',
      ]);
    }
    if (availableTime < recommendedMinutes) {
      recommendations.addAll([
        'Divida o exercício em sessões menores ao longo do dia',
        'Use atividades de alta intensidade para otimizar o tempo',
        'Considere dog walking ou pet sitter para dias ocupados',
      ]);
    }

    return recommendations;
  }

  List<String> _generateSafetyAlerts({
    required double ageYears,
    required String healthConditions,
    required int recommendedMinutes,
    required String species,
  }) {
    final alerts = <String>[];
    if (ageYears < 0.5) {
      alerts.add('Filhotes muito novos: limite exercício forçado, permita brincadeiras naturais');
    } else if (ageYears > 12 && species == 'Cão') {
      alerts.add('Cão sênior: monitore sinais de fadiga, adapte exercício conforme necessário');
    } else if (ageYears > 15 && species == 'Gato') {
      alerts.add('Gato sênior: observe limitações articulares, mantenha atividade suave');
    }
    if (healthConditions.contains('Cardíacos')) {
      alerts.add('ATENÇÃO: Problemas cardíacos requerem supervisão veterinária constante');
    }

    if (healthConditions.contains('Respiratórios')) {
      alerts.add('Evite exercício em dias quentes ou com alta umidade');
    }
    if (recommendedMinutes > 120) {
      alerts.add('Exercício intenso: aumente gradualmente, observe sinais de sobrecarga');
    }
    alerts.addAll([
      'Sempre forneça água fresca disponível durante e após exercício',
      'Evite exercício intenso 1-2 horas após alimentação',
      'Pare imediatamente se observar respiração ofegante excessiva ou claudicação',
    ]);

    return alerts;
  }

  ResultSeverity _getExerciseTimeSeverity(int recommendedMinutes, int availableTime) {
    final difference = (availableTime - recommendedMinutes).abs();
    final percentDifference = difference / recommendedMinutes;

    if (availableTime >= recommendedMinutes) return ResultSeverity.success;
    if (percentDifference <= 0.2) return ResultSeverity.info;
    if (percentDifference <= 0.4) return ResultSeverity.warning;
    return ResultSeverity.danger;
  }

  ResultSeverity _getExerciseNeedSeverity(String needLevel) {
    switch (needLevel) {
      case 'Muito Alto':
        return ResultSeverity.danger;
      case 'Alto':
        return ResultSeverity.warning;
      case 'Moderado':
        return ResultSeverity.info;
      case 'Baixo':
      case 'Muito Baixo':
        return ResultSeverity.success;
      default:
        return ResultSeverity.info;
    }
  }
}