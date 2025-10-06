import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/calculator_input.dart';
import '../entities/input_field.dart';

/// Enum que define os tipos de calculadoras disponíveis
enum CalculatorType {
  bodyCondition('body_condition', 'Escore Corporal'),
  calorie('calorie', 'Cálculo Calórico'),
  medicationDosage('medication_dosage', 'Dosagem de Medicamentos'),
  anesthesia('anesthesia', 'Anestesia'),
  animalAge('animal_age', 'Idade Animal'),
  caloricNeeds('caloric_needs', 'Necessidades Calóricas'),
  pregnancy('pregnancy', 'Gestação'),
  pregnancyBirth('pregnancy_birth', 'Parto'),
  diabetesInsulin('diabetes_insulin', 'Insulina Diabetes'),
  fluidTherapy('fluid_therapy', 'Fluidoterapia'),
  hydration('hydration', 'Hidratação'),
  idealWeight('ideal_weight', 'Peso Ideal'),
  unitConversion('unit_conversion', 'Conversão de Unidades'),
  advancedDiet('advanced_diet', 'Dieta Avançada');

  const CalculatorType(this.id, this.displayName);
  
  final String id;
  final String displayName;
}

/// Classe abstrata base para todas as calculadoras
/// Implementa Strategy Pattern para diferentes tipos de cálculos
abstract class BaseCalculator<TInput extends CalculatorInput, TResult extends CalculationResult> extends Calculator {
  const BaseCalculator();

  /// Executa o cálculo baseado no input fornecido
  /// 
  /// [input] - Input tipado específico da calculadora
  /// Retorna o resultado tipado específico da calculadora
  TResult performCalculation(TInput input);
  
  /// Valida se o input fornecido é válido para o cálculo
  /// 
  /// [input] - Input tipado específico da calculadora
  /// Retorna true se o input é válido, false caso contrário
  bool validateInput(TInput input) {
    try {
      final errors = getInputValidationErrors(input);
      return errors.isEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Obtém mensagens de erro para inputs inválidos
  /// 
  /// [input] - Input tipado específico da calculadora
  /// Retorna lista de mensagens de erro, vazia se o input é válido
  List<String> getInputValidationErrors(TInput input);

  /// Cria um resultado de erro padronizado
  /// 
  /// [message] - Mensagem de erro
  /// [input] - Input que causou o erro (opcional)
  TResult createErrorResult(String message, [TInput? input]);

  /// Obtém os parâmetros de entrada necessários para esta calculadora
  /// Usado para construir formulários dinâmicos
  Map<String, dynamic> getInputParameters();
  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    final typedInput = createInputFromMap(inputs);
    return performCalculation(typedInput);
  }
  
  @override
  bool validateInputs(Map<String, dynamic> inputs) {
    try {
      final typedInput = createInputFromMap(inputs);
      return validateInput(typedInput);
    } catch (e) {
      return false;
    }
  }
  
  @override
  List<String> getValidationErrors(Map<String, dynamic> inputs) {
    try {
      final typedInput = createInputFromMap(inputs);
      return getInputValidationErrors(typedInput);
    } catch (e) {
      return ['Erro ao processar entrada: ${e.toString()}'];
    }
  }

  /// Cria uma instância de input tipado a partir de um mapa genérico
  /// 
  /// [inputs] - Mapa com os valores dos campos de entrada
  /// Retorna instância tipada do input
  TInput createInputFromMap(Map<String, dynamic> inputs);

  /// Versão padrão para todas as calculadoras
  @override
  String get version => '1.0.0';

  /// Lista de campos de entrada padrão
  /// As calculadoras específicas devem sobrescrever se necessário
  @override
  List<InputField> get inputFields => [];

  /// Categoria padrão
  @override
  CalculatorCategory get category => CalculatorCategory.health;

  /// Ícone padrão
  @override
  String get iconName => 'calculate';
}