import '../entities/body_condition_input.dart';
import '../entities/body_condition_output.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart';
import 'base_calculator.dart';

/// Calculadora de Condição Corporal usando nova arquitetura
/// Avalia o estado nutricional do animal com base em parâmetros físicos
class BodyConditionCalculator extends BaseCalculator<BodyConditionInput, BodyConditionOutput> {
  const BodyConditionCalculator();

  @override
  String get id => CalculatorType.bodyCondition.id;

  @override
  String get name => 'Condição Corporal (BCS)';

  @override
  String get description => 
      'Avalia o estado nutricional do animal baseado na palpação '
      'e observação visual, utilizando escala de 1 a 9.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'fitness_center';

  @override
  List<InputField> get inputFields => [
    const InputField(
      key: 'species',
      label: 'Espécie',
      type: InputFieldType.dropdown,
      options: ['dog', 'cat'],
      isRequired: true,
      helperText: 'Tipo de animal para avaliação',
    ),
    const InputField(
      key: 'currentWeight',
      label: 'Peso Atual',
      type: InputFieldType.number,
      unit: 'kg',
      minValue: 0.1,
      maxValue: 200.0,
      isRequired: true,
      helperText: 'Peso atual do animal em quilogramas',
    ),
    const InputField(
      key: 'ribPalpation',
      label: 'Palpação das Costelas',
      type: InputFieldType.dropdown,
      options: ['1', '2', '3', '4', '5'],
      isRequired: true,
      helperText: 'Facilidade para palpar as costelas (1=muito difícil, 5=muito fácil)',
    ),
    const InputField(
      key: 'waistVisibility',
      label: 'Visibilidade da Cintura',
      type: InputFieldType.dropdown,
      options: ['1', '2', '3', '4', '5'],
      isRequired: true,
      helperText: 'Visibilidade da cintura vista de cima (1=não visível, 5=muito pronunciada)',
    ),
    const InputField(
      key: 'abdominalProfile',
      label: 'Perfil Abdominal',
      type: InputFieldType.dropdown,
      options: ['1', '2', '3', '4', '5'],
      isRequired: true,
      helperText: 'Perfil do abdomen visto de lado (1=pendular, 5=muito retraído)',
    ),
    const InputField(
      key: 'idealWeight',
      label: 'Peso Ideal (opcional)',
      type: InputFieldType.number,
      unit: 'kg',
      minValue: 0.1,
      maxValue: 200.0,
      isRequired: false,
      helperText: 'Peso ideal conhecido do animal',
    ),
    const InputField(
      key: 'isNeutered',
      label: 'Animal Castrado?',
      type: InputFieldType.switch_,
      isRequired: false,
      defaultValue: false,
    ),
    const InputField(
      key: 'animalAge',
      label: 'Idade (opcional)',
      type: InputFieldType.number,
      unit: 'meses',
      minValue: 1,
      maxValue: 300,
      isRequired: false,
      helperText: 'Idade do animal em meses',
    ),
  ];

  @override
  BodyConditionOutput performCalculation(BodyConditionInput input) {
    // Calcular score BCS baseado nos parâmetros de entrada
    final bcsScore = _calculateBcsScore(input);
    
    // Usar factory para criar output completo
    return BodyConditionOutputFactory.fromBcsScore(
      bcsScore: bcsScore,
      currentWeight: input.currentWeight,
      species: input.species.code,
      idealWeight: input.idealWeight,
      isNeutered: input.isNeutered,
      animalAge: input.animalAge,
      breed: input.animalBreed,
      hasMetabolicConditions: input.hasMetabolicConditions,
    );
  }

  @override
  List<String> getInputValidationErrors(BodyConditionInput input) {
    return input.validate();
  }

  @override
  BodyConditionOutput createErrorResult(String message, [BodyConditionInput? input]) {
    return BodyConditionOutputFactory.fromBcsScore(
      bcsScore: 5, // Score neutro em caso de erro
      currentWeight: input?.currentWeight ?? 0.0,
      species: input?.species.code ?? 'dog',
      idealWeight: input?.idealWeight,
      isNeutered: input?.isNeutered ?? false,
      animalAge: input?.animalAge,
      breed: input?.animalBreed,
      hasMetabolicConditions: input?.hasMetabolicConditions ?? false,
    );
  }

  @override
  BodyConditionInput createInputFromMap(Map<String, dynamic> inputs) {
    return BodyConditionInput.fromMap(inputs);
  }

  @override
  Map<String, dynamic> getInputParameters() {
    return {
      'species': {
        'type': 'enum',
        'label': 'Espécie',
        'options': AnimalSpecies.values.map((e) => e.code).toList(),
        'required': true,
      },
      'currentWeight': {
        'type': 'double',
        'label': 'Peso Atual (kg)',
        'min': 0.1,
        'max': 200.0,
        'step': 0.1,
        'required': true,
      },
      'ribPalpation': {
        'type': 'enum',
        'label': 'Palpação das Costelas',
        'options': RibPalpation.values.map((e) => e.score.toString()).toList(),
        'required': true,
      },
      'waistVisibility': {
        'type': 'enum',
        'label': 'Visibilidade da Cintura',
        'options': WaistVisibility.values.map((e) => e.score.toString()).toList(),
        'required': true,
      },
      'abdominalProfile': {
        'type': 'enum',
        'label': 'Perfil Abdominal',
        'options': AbdominalProfile.values.map((e) => e.score.toString()).toList(),
        'required': true,
      },
      'idealWeight': {
        'type': 'double',
        'label': 'Peso Ideal (kg)',
        'min': 0.1,
        'max': 200.0,
        'step': 0.1,
        'required': false,
      },
      'isNeutered': {
        'type': 'bool',
        'label': 'Animal Castrado?',
        'required': false,
      },
      'animalAge': {
        'type': 'int',
        'label': 'Idade (meses)',
        'min': 1,
        'max': 300,
        'step': 1,
        'required': false,
      },
    };
  }

  /// Calcula o score BCS baseado nos parâmetros de entrada
  /// Usa média ponderada dos três parâmetros principais
  int _calculateBcsScore(BodyConditionInput input) {
    // Pesos para cada parâmetro na avaliação final
    const ribWeight = 0.4; // 40% - mais importante
    const waistWeight = 0.35; // 35% 
    const abdominalWeight = 0.25; // 25%
    
    // Calcular score ponderado
    final weightedScore = (input.ribPalpation.score * ribWeight) +
                         (input.waistVisibility.score * waistWeight) +
                         (input.abdominalProfile.score * abdominalWeight);
    
    // Converter para escala 1-9
    // Score 1-5 dos parâmetros -> Score 1-9 BCS
    final bcsScore = ((weightedScore - 1) * 2) + 1;
    
    // Arredondar e limitar entre 1-9
    return bcsScore.round().clamp(1, 9);
  }
}