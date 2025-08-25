import 'dart:math' as math;

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart' as input;

/// Resultado da calculadora de peso ideal
class IdealWeightResult extends CalculationResult {
  const IdealWeightResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

/// Calculadora de Peso Ideal por Condição Corporal
/// Calcula peso ideal baseado no ECC (Escore de Condição Corporal) e características do animal
class IdealWeightCalculator extends Calculator {
  const IdealWeightCalculator();

  @override
  String get id => 'ideal_weight';

  @override
  String get name => 'Peso Ideal por ECC';

  @override
  String get description => 
      'Calcula o peso ideal do animal baseado no Escore de Condição Corporal (ECC), '
      'considerando espécie, raça, sexo e idade para recomendações nutricionais precisas.';

  @override
  CalculatorCategory get category => CalculatorCategory.nutrition;

  @override
  String get iconName => 'monitor_weight';

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
      key: 'breed',
      label: 'Raça/Porte',
      type: input.InputFieldType.dropdown,
      options: [
        'Sem raça definida',
        'Pequeno (até 10kg)',
        'Médio (10-25kg)',
        'Grande (25-40kg)',
        'Gigante (acima de 40kg)',
        'Gato doméstico',
        'Maine Coon',
        'Persa',
        'Siamês',
      ],
      isRequired: true,
      helperText: 'Raça ou porte do animal',
    ),
    const input.InputField(
      key: 'sex',
      label: 'Sexo',
      type: input.InputFieldType.dropdown,
      options: ['Macho', 'Fêmea'],
      isRequired: true,
      helperText: 'Sexo do animal',
    ),
    const input.InputField(
      key: 'neutered',
      label: 'Castrado',
      type: input.InputFieldType.switch_,
      isRequired: true,
      helperText: 'Animal castrado/esterilizado',
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
      key: 'current_weight',
      label: 'Peso Atual',
      type: input.InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.1,
      maxValue: 100.0,
      helperText: 'Peso atual do animal',
    ),
    const input.InputField(
      key: 'bcs_score',
      label: 'Escore de Condição Corporal (ECC)',
      type: input.InputFieldType.slider,
      isRequired: true,
      minValue: 1.0,
      maxValue: 9.0,
      defaultValue: 5.0,
      helperText: 'ECC de 1 (caquético) a 9 (obeso mórbido)',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final species = inputs['species'] as String;
    final breed = inputs['breed'] as String;
    final sex = inputs['sex'] as String;
    final neutered = inputs['neutered'] as bool;
    final ageYears = inputs['age_years'] as double;
    final currentWeight = inputs['current_weight'] as double;
    final bcsScore = inputs['bcs_score'] as double;

    final calculationData = _calculateIdealWeight(
      species: species,
      breed: breed,
      sex: sex,
      neutered: neutered,
      ageYears: ageYears,
      currentWeight: currentWeight,
      bcsScore: bcsScore,
    );

    final results = [
      ResultItem(
        label: 'Peso Ideal',
        value: calculationData['ideal_weight'],
        unit: 'kg',
        severity: ResultSeverity.success,
      ),
      ResultItem(
        label: 'Diferença de Peso',
        value: calculationData['weight_difference'] as double,
        unit: 'kg',
        severity: _getWeightDifferenceSeverity(calculationData['weight_difference'] as double),
        description: (calculationData['weight_difference'] as double) > 0 
            ? 'Animal precisa ganhar peso'
            : (calculationData['weight_difference'] as double) < 0 
                ? 'Animal precisa perder peso'
                : 'Peso adequado',
      ),
      ResultItem(
        label: 'Calorias Diárias Recomendadas',
        value: calculationData['daily_calories'],
        unit: 'kcal/dia',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Classificação ECC',
        value: calculationData['bcs_classification'],
        severity: _getBcsSeverity(bcsScore),
      ),
    ];

    if (calculationData['estimated_weeks'] != null && (calculationData['estimated_weeks'] as num) > 0) {
      results.add(
        ResultItem(
          label: 'Tempo Estimado para Meta',
          value: calculationData['estimated_weeks'],
          unit: 'semanas',
          severity: ResultSeverity.warning,
        ),
      );
    }

    final recommendations = (calculationData['recommendations'] as List<String>)
        .map((rec) => Recommendation(
              title: 'Recomendação Nutricional',
              message: rec,
              severity: ResultSeverity.info,
            ))
        .toList();

    return IdealWeightResult(
      calculatorId: id,
      results: results,
      recommendations: recommendations,
      summary: 'Peso ideal: ${calculationData['ideal_weight']}kg | '
               'Diferença: ${(calculationData['weight_difference'] as double) >= 0 ? '+' : ''}${calculationData['weight_difference']}kg',
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

    // Validar campos obrigatórios
    for (final field in inputFields) {
      if (field.isRequired && !inputs.containsKey(field.key)) {
        errors.add('${field.label} é obrigatório');
      }
    }

    // Validação específica para campos numéricos
    if (inputs.containsKey('current_weight')) {
      final weight = inputs['current_weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso atual deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0) {
          errors.add('Peso atual deve ser maior que zero');
        }
      }
    }

    if (inputs.containsKey('age_years')) {
      final age = inputs['age_years'];
      if (age is! double && age is! int) {
        errors.add('Idade deve ser um número');
      } else {
        final ageValue = age is int ? age.toDouble() : age as double;
        if (ageValue <= 0) {
          errors.add('Idade deve ser maior que zero');
        }
      }
    }

    return errors;
  }

  Map<String, dynamic> _calculateIdealWeight({
    required String species,
    required String breed,
    required String sex,
    required bool neutered,
    required double ageYears,
    required double currentWeight,
    required double bcsScore,
  }) {
    // Fatores de conversão por ECC
    final bcsConversionFactors = {
      1.0: 1.43, 2.0: 1.25, 3.0: 1.15, 4.0: 1.05, 5.0: 1.00,
      6.0: 0.90, 7.0: 0.80, 8.0: 0.70, 9.0: 0.60,
    };

    // Calcular peso ideal baseado no ECC
    final conversionFactor = bcsConversionFactors[bcsScore] ?? 1.0;
    double idealWeight = currentWeight * conversionFactor;

    // Ajustar baseado na raça/porte (peso de referência)
    final referenceWeight = _getReferenceWeight(species, breed, sex);
    if (referenceWeight > 0) {
      final ratio = idealWeight / referenceWeight;
      if (ratio < 0.7 || ratio > 1.3) {
        idealWeight = (idealWeight + referenceWeight) / 2;
      }
    }

    idealWeight = double.parse(idealWeight.toStringAsFixed(1));
    final weightDifference = double.parse((idealWeight - currentWeight).toStringAsFixed(1));

    // Calcular necessidades calóricas
    final metabolicWeight = math.pow(idealWeight, 0.75).toDouble();
    final baseCalories = species == 'Cão' ? 132.0 : 100.0;
    double dailyCalories = metabolicWeight * baseCalories;

    // Ajustar por idade
    if (ageYears < 1) {
      dailyCalories *= 1.8; // Filhotes
    } else if (ageYears >= 7) {
      final ageFactor = species == 'Cão' 
          ? math.max(0.8, 1.0 - ((ageYears - 7) * 0.02))
          : math.max(0.8, 1.0 - ((ageYears - 7) * 0.01));
      dailyCalories *= ageFactor;
    }

    // Ajustar por castração
    if (neutered) {
      dailyCalories *= 0.8;
    }

    // Ajustar por necessidade de ganho/perda de peso
    int? estimatedWeeks;
    if (weightDifference.abs() > 0.1) {
      if (weightDifference < 0) {
        // Precisa perder peso
        dailyCalories *= 0.8;
        estimatedWeeks = (weightDifference.abs() / 0.5 * 4).ceil();
      } else {
        // Precisa ganhar peso
        dailyCalories *= 1.2;
        estimatedWeeks = (weightDifference.abs() / 0.25 * 4).ceil();
      }
    }

    final recommendations = _generateRecommendations(weightDifference, bcsScore);
    final bcsClassification = _getBcsClassification(bcsScore);

    return {
      'ideal_weight': idealWeight,
      'weight_difference': weightDifference,
      'daily_calories': dailyCalories.round(),
      'bcs_classification': bcsClassification,
      'estimated_weeks': estimatedWeeks,
      'recommendations': recommendations,
    };
  }

  double _getReferenceWeight(String species, String breed, String sex) {
    // Pesos de referência aproximados por categoria
    final referenceWeights = {
      'Cão': {
        'Macho': {
          'Pequeno (até 10kg)': 7.0,
          'Médio (10-25kg)': 17.5,
          'Grande (25-40kg)': 32.0,
          'Gigante (acima de 40kg)': 50.0,
          'Sem raça definida': 20.0,
        },
        'Fêmea': {
          'Pequeno (até 10kg)': 6.0,
          'Médio (10-25kg)': 15.0,
          'Grande (25-40kg)': 28.0,
          'Gigante (acima de 40kg)': 45.0,
          'Sem raça definida': 17.0,
        },
      },
      'Gato': {
        'Macho': {
          'Gato doméstico': 4.5,
          'Maine Coon': 7.0,
          'Persa': 5.0,
          'Siamês': 4.0,
          'Sem raça definida': 4.5,
        },
        'Fêmea': {
          'Gato doméstico': 3.5,
          'Maine Coon': 5.5,
          'Persa': 4.0,
          'Siamês': 3.5,
          'Sem raça definida': 3.5,
        },
      },
    };

    return referenceWeights[species]?[sex]?[breed] ?? 0.0;
  }

  String _getBcsClassification(double bcsScore) {
    final classifications = {
      1.0: 'Caquético',
      2.0: 'Muito Magro',
      3.0: 'Magro',
      4.0: 'Levemente Magro',
      5.0: 'Ideal',
      6.0: 'Levemente Sobrepeso',
      7.0: 'Sobrepeso',
      8.0: 'Obeso',
      9.0: 'Obeso Mórbido',
    };

    return classifications[bcsScore] ?? 'Não Classificado';
  }

  ResultSeverity _getBcsSeverity(double bcsScore) {
    if (bcsScore <= 2 || bcsScore >= 8) return ResultSeverity.danger;
    if (bcsScore <= 3 || bcsScore >= 7) return ResultSeverity.warning;
    if (bcsScore == 5) return ResultSeverity.success;
    return ResultSeverity.info;
  }

  ResultSeverity _getWeightDifferenceSeverity(double difference) {
    if (difference.abs() <= 0.5) return ResultSeverity.success;
    if (difference.abs() <= 2.0) return ResultSeverity.warning;
    return ResultSeverity.danger;
  }

  List<String> _generateRecommendations(double weightDifference, double bcsScore) {
    final recommendations = <String>[];

    if (weightDifference < -0.5) {
      recommendations.addAll([
        'Ofereça dieta com baixo teor calórico e alta saciedade',
        'Divida a alimentação em pequenas porções ao longo do dia',
        'Aumente gradualmente a atividade física',
        'Evite petiscos calóricos, substitua por vegetais',
        'Monitore o peso semanalmente',
      ]);
    } else if (weightDifference > 0.5) {
      recommendations.addAll([
        'Ofereça alimentos com maior densidade calórica',
        'Aumente a frequência de alimentação para 3-4 vezes ao dia',
        'Considere suplementar a dieta com alimentos de alta qualidade',
        'Monitore o peso semanalmente',
        'Consulte o veterinário para descartar problemas médicos',
      ]);
    } else {
      recommendations.addAll([
        'Mantenha o plano alimentar atual',
        'Ofereça exercícios regulares para manter o tônus muscular',
        'Monitore o peso mensalmente',
      ]);
    }

    if (bcsScore <= 2 || bcsScore >= 8) {
      recommendations.add('Consulte um veterinário imediatamente');
    }

    return recommendations;
  }
}