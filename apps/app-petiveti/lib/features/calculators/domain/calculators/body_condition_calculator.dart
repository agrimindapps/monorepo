import '../entities/calculator.dart';
import '../entities/calculation_result.dart';
import '../entities/input_field.dart';

/// Calculadora de Condição Corporal
/// Avalia o estado nutricional do animal com base em parâmetros físicos
class BodyConditionCalculator extends Calculator {
  const BodyConditionCalculator();

  @override
  String get id => 'body_condition';

  @override
  String get name => 'Condição Corporal';

  @override
  String get description => 
      'Avalia o estado nutricional do animal baseado na palpação '
      'e observação visual, utilizando escala de 1 a 9.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'fitness_center';

  @override
  String get version => '1.0.0';

  @override
  List<InputField> get inputFields => [
    const InputField(
      id: 'species',
      label: 'Espécie',
      description: 'Tipo de animal',
      type: InputFieldType.dropdown,
      options: ['Cão', 'Gato'],
      isRequired: true,
    ),
    const InputField(
      id: 'ribs_palpation',
      label: 'Palpação das Costelas',
      description: 'Facilidade para palpar as costelas',
      type: InputFieldType.dropdown,
      options: [
        'Muito difícil de palpar',
        'Difícil de palpar',
        'Palpável com pressão moderada',
        'Facilmente palpável',
        'Muito facilmente palpável'
      ],
      isRequired: true,
    ),
    const InputField(
      id: 'waist_visibility',
      label: 'Cintura Vista de Cima',
      description: 'Visibilidade da cintura quando visto de cima',
      type: InputFieldType.dropdown,
      options: [
        'Não visível',
        'Pouco visível',
        'Moderadamente visível',
        'Bem visível',
        'Muito pronunciada'
      ],
      isRequired: true,
    ),
    const InputField(
      id: 'abdomen_profile',
      label: 'Perfil Abdominal',
      description: 'Formato do abdome visto de perfil',
      type: InputFieldType.dropdown,
      options: [
        'Pendular/Caído',
        'Ligeiramente abaulado',
        'Reto',
        'Ligeiramente retraído',
        'Muito retraído'
      ],
      isRequired: true,
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    // Mapear respostas para pontuações
    final ribsScore = _mapRibsScore(inputs['ribs_palpation'] as String);
    final waistScore = _mapWaistScore(inputs['waist_visibility'] as String);
    final abdomenScore = _mapAbdomenScore(inputs['abdomen_profile'] as String);

    // Calcular média das pontuações
    final score = ((ribsScore + waistScore + abdomenScore) / 3).round();
    
    final interpretation = _getInterpretation(score);
    final recommendation = _getRecommendation(score);

    return CalculationResult(
      calculatorId: id,
      timestamp: DateTime.now(),
      inputs: inputs,
      results: {
        'score': score,
        'interpretation': interpretation,
        'recommendation': recommendation,
      },
      summary: 'Condição Corporal: $score/9 - $interpretation',
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
      if (field.isRequired && !inputs.containsKey(field.id)) {
        errors.add('${field.label} é obrigatório');
      }
    }

    return errors;
  }

  int _mapRibsScore(String value) {
    switch (value) {
      case 'Muito difícil de palpar': return 1;
      case 'Difícil de palpar': return 3;
      case 'Palpável com pressão moderada': return 5;
      case 'Facilmente palpável': return 7;
      case 'Muito facilmente palpável': return 9;
      default: return 5;
    }
  }

  int _mapWaistScore(String value) {
    switch (value) {
      case 'Não visível': return 1;
      case 'Pouco visível': return 3;
      case 'Moderadamente visível': return 5;
      case 'Bem visível': return 7;
      case 'Muito pronunciada': return 9;
      default: return 5;
    }
  }

  int _mapAbdomenScore(String value) {
    switch (value) {
      case 'Pendular/Caído': return 1;
      case 'Ligeiramente abaulado': return 3;
      case 'Reto': return 5;
      case 'Ligeiramente retraído': return 7;
      case 'Muito retraído': return 9;
      default: return 5;
    }
  }

  String _getInterpretation(int score) {
    switch (score) {
      case 1:
        return 'Extremamente magro - Desnutrição severa';
      case 2:
        return 'Muito magro - Desnutrição moderada';
      case 3:
        return 'Magro - Abaixo do peso ideal';
      case 4:
        return 'Ligeiramente abaixo do peso';
      case 5:
        return 'Peso ideal - Condição corporal ótima';
      case 6:
        return 'Ligeiramente acima do peso';
      case 7:
        return 'Sobrepeso - Acima do peso ideal';
      case 8:
        return 'Obeso - Excesso de peso significativo';
      case 9:
        return 'Extremamente obeso - Obesidade severa';
      default:
        return 'Peso ideal';
    }
  }

  String _getRecommendation(int score) {
    switch (score) {
      case 1:
      case 2:
        return 'Consulte um veterinário imediatamente. Necessária avaliação médica e plano nutricional específico.';
      case 3:
        return 'Aumente a quantidade de ração e monitore semanalmente. Consulte veterinário.';
      case 4:
        return 'Aumente ligeiramente a alimentação e monitore quinzenalmente.';
      case 5:
        return 'Mantenha a dieta atual. Monitoramento mensal é suficiente.';
      case 6:
        return 'Reduza ligeiramente a alimentação e aumente exercícios.';
      case 7:
        return 'Reduza 10-15% da alimentação e intensifique atividade física.';
      case 8:
      case 9:
        return 'Consulte veterinário para plano de emagrecimento supervisionado.';
      default:
        return 'Mantenha a dieta atual e monitore regularmente.';
    }
  }
}