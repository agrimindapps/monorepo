import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart' as input;

/// Resultado da calculadora de idade animal
class AnimalAgeResult extends CalculationResult {
  const AnimalAgeResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

/// Calculadora de Idade Animal 
/// Converte idade de animais para equivalente em anos humanos
class AnimalAgeCalculator extends Calculator {
  const AnimalAgeCalculator();

  @override
  String get id => 'animal_age';

  @override
  String get name => 'Idade Animal';

  @override
  String get description => 
      'Converte a idade de cães e gatos para idade equivalente em anos humanos, '
      'considerando o porte do animal e suas fases de vida.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'cake';

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
      key: 'age_years',
      label: 'Idade do Animal',
      type: input.InputFieldType.number,
      unit: 'anos',
      isRequired: true,
      minValue: 0.1,
      maxValue: 30.0,
      helperText: 'Idade atual do animal em anos',
    ),
    const input.InputField(
      key: 'dog_size',
      label: 'Porte do Cão',
      type: input.InputFieldType.dropdown,
      options: [
        'Pequeno (até 9kg)',
        'Médio (10kg a 22kg)', 
        'Grande (23kg a 40kg)',
        'Gigante (acima de 40kg)'
      ],
      isRequired: false,
      helperText: 'Porte do cão (apenas para cães)',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final species = inputs['species'] as String;
    final ageYears = inputs['age_years'] as double;
    final dogSize = inputs['dog_size'] as String?;

    final calculationData = species == 'Cão' 
        ? _calculateDogAge(ageYears, dogSize!)
        : _calculateCatAge(ageYears);

    final results = [
      ResultItem(
        label: 'Idade Humana Equivalente',
        value: calculationData['human_age'],
        unit: 'anos',
        severity: ResultSeverity.success,
      ),
      ResultItem(
        label: 'Fase da Vida',
        value: calculationData['life_stage'],
        severity: ResultSeverity.info,
      ),
    ];

    final recommendations = (calculationData['care_recommendations'] as List<String>)
        .map((care) => Recommendation(
              title: 'Cuidados Recomendados',
              message: care,
              severity: ResultSeverity.info,
            ))
        .toList();

    return AnimalAgeResult(
      calculatorId: id,
      results: results,
      recommendations: recommendations,
      summary: calculationData['age_comparison']?.toString(),
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

    // Validar idade
    if (inputs.containsKey('age_years')) {
      final age = inputs['age_years'];
      if (age is! double && age is! int) {
        errors.add('Idade deve ser um número');
      } else {
        final ageValue = age is int ? age.toDouble() : age as double;
        if (ageValue <= 0) {
          errors.add('Idade deve ser maior que zero');
        }
        if (ageValue > 30) {
          errors.add('Idade muito alta - verifique o valor');
        }
      }
    }

    // Validar porte para cães
    if (inputs['species'] == 'Cão' && !inputs.containsKey('dog_size')) {
      errors.add('Porte do cão é obrigatório');
    }

    return errors;
  }

  Map<String, dynamic> _calculateDogAge(double ageYears, String dogSize) {
    final age = ageYears.round();
    int humanAge;
    String lifeStage;

    if (age == 1) {
      humanAge = _getFirstYearAge(dogSize);
      lifeStage = 'Adolescente';
    } else if (age == 2) {
      humanAge = _getSecondYearAge(dogSize);
      lifeStage = 'Jovem adulto';
    } else {
      final baseAge = _getSecondYearAge(dogSize);
      final yearlyFactor = _getYearlyFactor(dogSize);
      humanAge = baseAge + (age - 2) * yearlyFactor;
      lifeStage = _getDogLifeStage(age, dogSize);
    }

    final care = _getDogCareRecommendations(lifeStage);
    final comparison = _generateAgeComparison(age, humanAge, 'cão', dogSize);

    return {
      'human_age': humanAge,
      'life_stage': lifeStage,
      'care_recommendations': care,
      'age_comparison': comparison,
      'dog_size': dogSize,
    };
  }

  Map<String, dynamic> _calculateCatAge(double ageYears) {
    final age = ageYears.round();
    int humanAge;
    String lifeStage;

    if (age == 1) {
      humanAge = 15;
      lifeStage = 'Adolescente';
    } else if (age == 2) {
      humanAge = 24;
      lifeStage = 'Jovem adulto';
    } else {
      humanAge = 24 + (age - 2) * 4;
      lifeStage = _getCatLifeStage(age);
    }

    final care = _getCatCareRecommendations(lifeStage);
    final comparison = _generateAgeComparison(age, humanAge, 'gato', null);

    return {
      'human_age': humanAge,
      'life_stage': lifeStage,
      'care_recommendations': care,
      'age_comparison': comparison,
    };
  }

  int _getFirstYearAge(String dogSize) {
    switch (dogSize) {
      case 'Pequeno (até 9kg)':
      case 'Médio (10kg a 22kg)':
        return 15;
      case 'Grande (23kg a 40kg)':
        return 14;
      case 'Gigante (acima de 40kg)':
        return 12;
      default:
        return 15;
    }
  }

  int _getSecondYearAge(String dogSize) {
    switch (dogSize) {
      case 'Pequeno (até 9kg)':
      case 'Médio (10kg a 22kg)':
        return 24;
      case 'Grande (23kg a 40kg)':
        return 22;
      case 'Gigante (acima de 40kg)':
        return 19;
      default:
        return 24;
    }
  }

  int _getYearlyFactor(String dogSize) {
    switch (dogSize) {
      case 'Pequeno (até 9kg)':
        return 4;
      case 'Médio (10kg a 22kg)':
        return 5;
      case 'Grande (23kg a 40kg)':
        return 6;
      case 'Gigante (acima de 40kg)':
        return 7;
      default:
        return 5;
    }
  }

  String _getDogLifeStage(int age, String dogSize) {
    switch (dogSize) {
      case 'Pequeno (até 9kg)':
        if (age < 7) return 'Adulto';
        if (age < 12) return 'Adulto maduro';
        return 'Idoso';
      case 'Médio (10kg a 22kg)':
        if (age < 6) return 'Adulto';
        if (age < 10) return 'Adulto maduro';
        return 'Idoso';
      case 'Grande (23kg a 40kg)':
      case 'Gigante (acima de 40kg)':
        if (age < 5) return 'Adulto';
        if (age < 8) return 'Adulto maduro';
        return 'Idoso';
      default:
        return 'Adulto';
    }
  }

  String _getCatLifeStage(int age) {
    if (age < 7) return 'Adulto';
    if (age < 10) return 'Adulto maduro';
    if (age < 15) return 'Idoso';
    return 'Idoso avançado';
  }

  List<String> _getDogCareRecommendations(String lifeStage) {
    switch (lifeStage) {
      case 'Adolescente':
      case 'Jovem adulto':
        return [
          'Check-ups veterinários anuais',
          'Exercícios regulares',
          'Treinamento contínuo',
          'Alimentação balanceada',
          'Socialização adequada'
        ];
      case 'Adulto':
        return [
          'Check-ups veterinários anuais',
          'Manter peso adequado',
          'Exercícios regulares',
          'Cuidados dentários',
          'Alimentação de qualidade'
        ];
      case 'Adulto maduro':
        return [
          'Check-ups veterinários a cada 6 meses',
          'Atenção à dieta e peso',
          'Exercícios moderados',
          'Monitoramento de problemas de saúde',
          'Cuidados dentários intensivos'
        ];
      case 'Idoso':
        return [
          'Check-ups veterinários frequentes (3-4 meses)',
          'Dieta específica para idosos',
          'Exercícios leves e adaptados',
          'Atenção especial ao conforto',
          'Monitoramento cardíaco e renal'
        ];
      default:
        return ['Consulte um veterinário para orientações específicas'];
    }
  }

  List<String> _getCatCareRecommendations(String lifeStage) {
    switch (lifeStage) {
      case 'Adolescente':
      case 'Jovem adulto':
        return [
          'Check-ups veterinários anuais',
          'Vacinação e vermifugação em dia',
          'Alimentação adequada à idade',
          'Estímulos ambientais',
          'Cuidados dentários'
        ];
      case 'Adulto':
        return [
          'Check-ups veterinários anuais',
          'Controle de peso',
          'Alimentação balanceada',
          'Atividades estimulantes',
          'Higiene dental regular'
        ];
      case 'Adulto maduro':
        return [
          'Check-ups veterinários a cada 6 meses',
          'Dieta controlada',
          'Monitoramento renal',
          'Ambiente confortável',
          'Atenção a mudanças comportamentais'
        ];
      case 'Idoso':
      case 'Idoso avançado':
        return [
          'Check-ups veterinários frequentes',
          'Dieta específica para idosos',
          'Ambiente aquecido e confortável',
          'Cuidados especiais com mobilidade',
          'Monitoramento constante da saúde'
        ];
      default:
        return ['Consulte um veterinário para orientações específicas'];
    }
  }

  String _generateAgeComparison(int animalAge, int humanAge, String species, String? dogSize) {
    final sizeText = dogSize != null ? ' de porte ${dogSize.toLowerCase()}' : '';
    return 'A idade de $animalAge anos para um $species$sizeText '
           'equivale aproximadamente a $humanAge anos humanos.';
  }
}