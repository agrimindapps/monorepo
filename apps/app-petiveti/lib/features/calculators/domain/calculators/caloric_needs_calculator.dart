import 'dart:math';

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart';

/// Calculadora de Necessidades Calóricas
/// Calcula as necessidades energéticas diárias do animal
class CaloricNeedsCalculator extends Calculator {
  const CaloricNeedsCalculator();

  @override
  String get id => 'caloric_needs';

  @override
  String get name => 'Necessidades Calóricas';

  @override
  String get description => 
      'Calcula as necessidades energéticas diárias baseadas no peso, '
      'idade, atividade e condição fisiológica do animal.';

  @override
  CalculatorCategory get category => CalculatorCategory.nutrition;

  @override
  String get iconName => 'restaurant';

  @override
  String get version => '1.0.0';

  @override
  List<InputField> get inputFields => [
    const InputField(
      key: 'weight',
      label: 'Peso do Animal',
      helperText: 'Peso atual do animal em quilogramas',
      type: InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.5,
      maxValue: 100.0,
    ),
    const InputField(
      key: 'species',
      label: 'Espécie',
      helperText: 'Tipo de animal',
      type: InputFieldType.dropdown,
      options: ['Cão', 'Gato'],
      isRequired: true,
    ),
    const InputField(
      key: 'life_stage',
      label: 'Fase da Vida',
      helperText: 'Estágio de desenvolvimento',
      type: InputFieldType.dropdown,
      options: [
        'Filhote (até 4 meses)',
        'Jovem (4-12 meses)',
        'Adulto (1-7 anos)',
        'Senior (7+ anos)'
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'activity_level',
      label: 'Nível de Atividade',
      helperText: 'Quantidade de exercício diário',
      type: InputFieldType.dropdown,
      options: [
        'Sedentário',
        'Atividade leve',
        'Atividade moderada',
        'Atividade intensa',
        'Atlético'
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'physiological_state',
      label: 'Estado Fisiológico',
      helperText: 'Condição especial atual',
      type: InputFieldType.dropdown,
      options: [
        'Normal',
        'Gestante',
        'Lactante',
        'Castrado/Esterilizado',
        'Convalescente',
        'Obeso'
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'body_condition',
      label: 'Condição Corporal',
      helperText: 'Escala de 1-9 (5 = ideal)',
      type: InputFieldType.slider,
      minValue: 1.0,
      maxValue: 9.0,
      defaultValue: 5.0,
      isRequired: true,
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final weight = inputs['weight'] as double;
    final species = inputs['species'] as String;
    final lifeStage = inputs['life_stage'] as String;
    final activityLevel = inputs['activity_level'] as String;
    final physiologicalState = inputs['physiological_state'] as String;
    final bodyCondition = inputs['body_condition'] as double;
    final rer = _calculateRER(weight);
    final der = _calculateDER(rer, species, lifeStage, activityLevel, physiologicalState);
    final adjustedDER = _adjustForBodyCondition(der, bodyCondition);
    final foodAmountGrams = (adjustedDER / 3.5).round();
    final recommendations = _generateRecommendations(
      adjustedDER, species, lifeStage, activityLevel, physiologicalState, bodyCondition
    );
    final resultItems = [
      ResultItem(
        label: 'Necessidade Energética de Repouso (RER)',
        value: rer.round(),
        unit: 'kcal/dia',
      ),
      ResultItem(
        label: 'Necessidade Energética Diária (DER)',
        value: adjustedDER.round(),
        unit: 'kcal/dia',
      ),
      ResultItem(
        label: 'Quantidade de Ração',
        value: foodAmountGrams,
        unit: 'gramas/dia',
      ),
      ResultItem(
        label: 'Quantidade de Ração (xícaras)',
        value: (foodAmountGrams / 80).toStringAsFixed(1),
        unit: 'xícaras/dia',
      ),
    ];
    
    final recommendationItems = recommendations.map((rec) => 
      Recommendation(title: 'Recomendação', message: rec)
    ).toList();
    
    return _CaloricNeedsResult(
      calculatorId: id,
      results: resultItems,
      recommendations: recommendationItems,
      summary: 'Necessidade energética: ${adjustedDER.round()} kcal/dia (~${foodAmountGrams}g de ração)',
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

    if (inputs.containsKey('weight')) {
      final weight = inputs['weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0) {
          errors.add('Peso deve ser maior que zero');
        }
      }
    }

    return errors;
  }

  double _calculateRER(double weight) {
    return (70 * pow(weight, 0.75)).toDouble();
  }

  double _calculateDER(double rer, String species, String lifeStage, 
                      String activityLevel, String physiologicalState) {
    double multiplier = 1.0;
    final rerValue = rer;
    switch (lifeStage) {
      case 'Filhote (até 4 meses)':
        multiplier = species == 'Cão' ? 3.0 : 2.5;
        break;
      case 'Jovem (4-12 meses)':
        multiplier = species == 'Cão' ? 2.0 : 2.0;
        break;
      case 'Adulto (1-7 anos)':
        multiplier = 1.6;
        break;
      case 'Senior (7+ anos)':
        multiplier = 1.4;
        break;
    }
    switch (activityLevel) {
      case 'Sedentário':
        multiplier *= 0.8;
        break;
      case 'Atividade leve':
        multiplier *= 1.0;
        break;
      case 'Atividade moderada':
        multiplier *= 1.2;
        break;
      case 'Atividade intensa':
        multiplier *= 1.4;
        break;
      case 'Atlético':
        multiplier *= 1.6;
        break;
    }
    switch (physiologicalState) {
      case 'Gestante':
        multiplier *= species == 'Cão' ? 1.5 : 1.4;
        break;
      case 'Lactante':
        multiplier *= species == 'Cão' ? 3.0 : 2.5;
        break;
      case 'Castrado/Esterilizado':
        multiplier *= 0.9;
        break;
      case 'Convalescente':
        multiplier *= 1.2;
        break;
      case 'Obeso':
        multiplier *= 0.8;
        break;
    }

    return rerValue * multiplier;
  }

  double _adjustForBodyCondition(double der, double bodyCondition) {
    if (bodyCondition < 4) {
      return der * 1.15;
    } else if (bodyCondition > 6) {
      return der * 0.85;
    }
    return der;
  }

  List<String> _generateRecommendations(double calories, String species, 
                                       String lifeStage, String activityLevel, 
                                       String physiologicalState, double bodyCondition) {
    final recommendations = <String>[];
    recommendations.add('Divida a alimentação em 2-3 refeições por dia');
    recommendations.add('Forneça água fresca sempre disponível');
    if (lifeStage.contains('Filhote')) {
      recommendations.add('Use ração específica para filhotes com alta densidade energética');
      recommendations.add('Alimente 3-4 vezes por dia até 6 meses de idade');
    } else if (lifeStage.contains('Senior')) {
      recommendations.add('Use ração específica para animais seniores');
      recommendations.add('Monitore peso regularmente para prevenir obesidade');
    }
    if (bodyCondition < 4) {
      recommendations.add('Aumente gradualmente a quantidade de ração');
      recommendations.add('Considere alimentos com maior densidade calórica');
    } else if (bodyCondition > 6) {
      recommendations.add('Implemente plano de redução de peso supervisionado');
      recommendations.add('Aumente a atividade física gradualmente');
    }
    if (physiologicalState == 'Gestante') {
      recommendations.add('Aumente gradualmente a alimentação durante a gestação');
      recommendations.add('Use ração para filhotes no terço final da gestação');
    } else if (physiologicalState == 'Lactante') {
      recommendations.add('Forneça alimentação ad libitum durante a lactação');
      recommendations.add('Mantenha ração para filhotes durante todo período');
    }

    return recommendations;
  }
}

/// Implementação concreta do resultado da calculadora de necessidades calóricas
class _CaloricNeedsResult extends CalculationResult {
  const _CaloricNeedsResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}
