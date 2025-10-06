import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart' as input;

/// Resultado da calculadora de gestação
class PregnancyGestacaoResult extends CalculationResult {
  const PregnancyGestacaoResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

/// Calculadora de Gestação
/// Calcula período gestacional, datas importantes e cuidados necessários
class PregnancyGestacaoCalculator extends Calculator {
  const PregnancyGestacaoCalculator();

  @override
  String get id => 'pregnancy_gestacao';

  @override
  String get name => 'Calculadora de Gestação';

  @override
  String get description => 
      'Monitora o período gestacional, calcula datas importantes, necessidades nutricionais '
      'e fornece orientações de cuidados para cada fase da gestação.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'pregnant_woman';

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
      key: 'mating_date',
      label: 'Data do Acasalamento',
      type: input.InputFieldType.text,
      isRequired: true,
      helperText: 'Data aproximada do acasalamento ou inseminação (YYYY-MM-DD)',
    ),
    const input.InputField(
      key: 'mother_weight',
      label: 'Peso da Mãe',
      type: input.InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.5,
      maxValue: 100.0,
      helperText: 'Peso atual da fêmea gestante',
    ),
    const input.InputField(
      key: 'breed_size',
      label: 'Porte da Raça',
      type: input.InputFieldType.dropdown,
      options: [
        'Pequeno (até 10kg)',
        'Médio (10-25kg)', 
        'Grande (25-40kg)',
        'Gigante (acima de 40kg)',
        'Gato'
      ],
      isRequired: true,
      helperText: 'Porte da raça para cálculos específicos',
    ),
    const input.InputField(
      key: 'expected_litter_size',
      label: 'Tamanho Esperado da Ninhada',
      type: input.InputFieldType.number,
      unit: 'filhotes',
      isRequired: false,
      minValue: 1.0,
      maxValue: 15.0,
      helperText: 'Quantidade estimada de filhotes (opcional)',
    ),
    const input.InputField(
      key: 'is_first_pregnancy',
      label: 'Primeira Gestação',
      type: input.InputFieldType.switch_,
      isRequired: true,
      helperText: 'Esta é a primeira gestação da fêmea?',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final species = inputs['species'] as String;
    final matingDate = DateTime.parse(inputs['mating_date'] as String);
    final motherWeight = inputs['mother_weight'] as double;
    final breedSize = inputs['breed_size'] as String;
    final expectedLitterSize = inputs['expected_litter_size'] as double?;
    final isFirstPregnancy = inputs['is_first_pregnancy'] as bool;

    final calculationData = _calculateGestacao(
      species: species,
      matingDate: matingDate,
      motherWeight: motherWeight,
      breedSize: breedSize,
      expectedLitterSize: expectedLitterSize?.toInt(),
      isFirstPregnancy: isFirstPregnancy,
    );

    final results = [
      ResultItem(
        label: 'Dias de Gestação',
        value: calculationData['current_gestation_days'],
        unit: 'dias',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Data Prevista do Parto',
        value: calculationData['due_date_formatted'],
        severity: _getDueDateSeverity(calculationData['days_remaining'] as int),
        description: calculationData['due_date_range'] as String,
      ),
      ResultItem(
        label: 'Dias Restantes',
        value: calculationData['days_remaining'],
        unit: 'dias',
        severity: _getDaysRemainingSeverity(calculationData['days_remaining'] as int),
      ),
      ResultItem(
        label: 'Fase Atual da Gestação',
        value: calculationData['current_stage'],
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Calorias Diárias Recomendadas',
        value: calculationData['recommended_calories'],
        unit: 'kcal/dia',
        severity: ResultSeverity.success,
      ),
      ResultItem(
        label: 'Ganho de Peso Esperado',
        value: calculationData['expected_weight_gain'],
        unit: 'kg',
        severity: ResultSeverity.info,
      ),
    ];

    final recommendations = (calculationData['recommendations'] as List<String>)
        .map((rec) => Recommendation(
              title: 'Cuidados da Gestação',
              message: rec,
              severity: ResultSeverity.info,
            ))
        .toList();
    final alerts = calculationData['alerts'] as List<String>;
    for (final alert in alerts) {
      recommendations.add(
        Recommendation(
          title: 'Alerta Importante',
          message: alert,
          severity: ResultSeverity.warning,
        ),
      );
    }

    return PregnancyGestacaoResult(
      calculatorId: id,
      results: results,
      recommendations: recommendations,
      summary: 'Gestação: ${calculationData['current_gestation_days']} dias | '
               'Restam: ${calculationData['days_remaining']} dias | '
               'Parto: ${calculationData['due_date_formatted']}',
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
    if (inputs.containsKey('mating_date')) {
      try {
        final matingDate = DateTime.parse(inputs['mating_date'] as String);
        final now = DateTime.now();
        final daysSinceMating = now.difference(matingDate).inDays;
        
        if (matingDate.isAfter(now)) {
          errors.add('Data do acasalamento não pode ser futura');
        } else if (daysSinceMating > 90) {
          errors.add('Data do acasalamento muito antiga (mais de 90 dias)');
        }
      } catch (e) {
        errors.add('Data de acasalamento inválida');
      }
    }
    if (inputs.containsKey('mother_weight')) {
      final weight = inputs['mother_weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso da mãe deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0) {
          errors.add('Peso da mãe deve ser maior que zero');
        }
      }
    }

    return errors;
  }

  Map<String, dynamic> _calculateGestacao({
    required String species,
    required DateTime matingDate,
    required double motherWeight,
    required String breedSize,
    required int? expectedLitterSize,
    required bool isFirstPregnancy,
  }) {
    final now = DateTime.now();
    final currentGestationDays = now.difference(matingDate).inDays;
    final gestationPeriods = {
      'Cão': {'min': 58, 'average': 63, 'max': 68},
      'Gato': {'min': 64, 'average': 67, 'max': 70},
    };

    final period = gestationPeriods[species]!;
    final averageGestationDays = period['average']!;
    final minGestationDays = period['min']!;
    final maxGestationDays = period['max']!;
    final estimatedDueDate = matingDate.add(Duration(days: averageGestationDays));
    final earliestDueDate = matingDate.add(Duration(days: minGestationDays));
    final latestDueDate = matingDate.add(Duration(days: maxGestationDays));

    final daysRemaining = averageGestationDays - currentGestationDays;
    String currentStage;
    if (currentGestationDays < 21) {
      currentStage = 'Início (Implantação)';
    } else if (currentGestationDays < 35) {
      currentStage = 'Desenvolvimento Inicial';
    } else if (currentGestationDays < 50) {
      currentStage = 'Desenvolvimento Médio';
    } else if (currentGestationDays < averageGestationDays) {
      currentStage = 'Desenvolvimento Final';
    } else if (currentGestationDays <= maxGestationDays) {
      currentStage = 'Termo (Pronto para nascer)';
    } else {
      currentStage = 'Atrasado';
    }
    double calorieMultiplier = 1.0;
    if (currentGestationDays > 30) {
      final weeksAfter30 = (currentGestationDays - 30) / 7;
      calorieMultiplier = 1.0 + (weeksAfter30 * 0.25);
      calorieMultiplier = math.min(calorieMultiplier, 2.0); // Máximo 2x
    }
    if (expectedLitterSize != null) {
      final litterFactor = 1.0 + (expectedLitterSize * 0.1);
      calorieMultiplier *= litterFactor;
    }
    final metabolicWeight = math.pow(motherWeight, 0.75).toDouble();
    final baseCalories = species == 'Cão' ? 132.0 : 100.0;
    final recommendedCalories = (metabolicWeight * baseCalories * calorieMultiplier).round();
    double expectedWeightGainPercent = 0.15; // 15% por padrão
    if (species == 'Cão') {
      if (breedSize.contains('Pequeno')) {
        expectedWeightGainPercent = 0.20; // Raças pequenas ganham mais proporcionalmente
      } else if (breedSize.contains('Grande') || breedSize.contains('Gigante')) {
        expectedWeightGainPercent = 0.12; // Raças grandes ganham menos proporcionalmente
      }
    }

    if (expectedLitterSize != null) {
      expectedWeightGainPercent += (expectedLitterSize * 0.02); // 2% a mais por filhote
    }

    final expectedWeightGain = double.parse((motherWeight * expectedWeightGainPercent).toStringAsFixed(1));
    final recommendations = _generateRecommendations(
      currentGestationDays: currentGestationDays,
      daysRemaining: daysRemaining,
      species: species,
      isFirstPregnancy: isFirstPregnancy,
      currentStage: currentStage,
    );
    final alerts = <String>[];
    if (daysRemaining <= 7 && daysRemaining > 0) {
      alerts.add('Parto iminente! Prepare o local de parto e mantenha contato veterinário.');
    } else if (daysRemaining <= 0) {
      alerts.add('Gestação prolongada. Consulte o veterinário imediatamente.');
    }

    if (isFirstPregnancy) {
      alerts.add('Primeira gestação requer monitoramento veterinário mais frequente.');
    }

    return {
      'current_gestation_days': currentGestationDays,
      'days_remaining': daysRemaining,
      'due_date_formatted': _formatDate(estimatedDueDate),
      'due_date_range': '${_formatDate(earliestDueDate)} a ${_formatDate(latestDueDate)}',
      'current_stage': currentStage,
      'recommended_calories': recommendedCalories,
      'expected_weight_gain': expectedWeightGain,
      'recommendations': recommendations,
      'alerts': alerts,
    };
  }

  List<String> _generateRecommendations({
    required int currentGestationDays,
    required int daysRemaining,
    required String species,
    required bool isFirstPregnancy,
    required String currentStage,
  }) {
    final recommendations = <String>[];
    if (currentGestationDays < 21) {
      recommendations.addAll([
        'Mantenha alimentação normal de alta qualidade',
        'Evite exercícios extenuantes',
        'Confirme gestação com veterinário (ultrassom aos 25-30 dias)',
        'Inicie suplementação de ácido fólico se recomendado',
      ]);
    } else if (currentGestationDays < 35) {
      recommendations.addAll([
        'Aumente gradualmente a quantidade de ração (10-15%)',
        'Divida a alimentação em porções menores e mais frequentes',
        'Continue exercícios leves e regulares',
        'Agende ultrassom para contagem de filhotes',
      ]);
    } else if (currentGestationDays < 50) {
      recommendations.addAll([
        'Aumente a alimentação em 25-50% da quantidade normal',
        'Use ração para filhotes ou gestantes de alta qualidade',
        'Prepare o local de parto (caixa de parto)',
        'Monitore ganho de peso semanalmente',
      ]);
    } else {
      recommendations.addAll([
        'Alimentação à vontade com ração para filhotes',
        'Mantenha a fêmea próxima ao local de parto',
        'Monitore sinais de trabalho de parto',
        'Tenha contato veterinário de emergência disponível',
      ]);
    }
    if (species == 'Cão') {
      recommendations.add('Temperatura retal normal: 38.0-39.2°C (queda indica trabalho de parto)');
    } else {
      recommendations.add('Temperatura retal normal: 38.1-39.2°C (monitorar nas últimas semanas)');
    }
    if (isFirstPregnancy) {
      recommendations.addAll([
        'Consultas veterinárias mais frequentes (quinzenais no final)',
        'Considere parto assistido por veterinário',
        'Monitore mais de perto sinais de complicações',
      ]);
    }
    if (daysRemaining <= 14) {
      recommendations.addAll([
        'Meça temperatura retal diariamente (manhã e noite)',
        'Observe mudanças comportamentais (inquietação, busca por local)',
        'Tenha kit de parto preparado (toalhas, tesoura esterilizada, fio dental)',
      ]);
    }

    return recommendations;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day}/${months[date.month - 1]}/${date.year}';
  }

  ResultSeverity _getDueDateSeverity(int daysRemaining) {
    if (daysRemaining <= 0) return ResultSeverity.danger;
    if (daysRemaining <= 7) return ResultSeverity.warning;
    if (daysRemaining <= 14) return ResultSeverity.info;
    return ResultSeverity.success;
  }

  ResultSeverity _getDaysRemainingSeverity(int daysRemaining) {
    if (daysRemaining <= 0) return ResultSeverity.danger;
    if (daysRemaining <= 7) return ResultSeverity.warning;
    return ResultSeverity.info;
  }
}
