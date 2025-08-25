import '../entities/calculation_history.dart';
import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../repositories/calculator_repository.dart';

/// Use case para executar cálculos
class PerformCalculation {
  const PerformCalculation(this._repository);
  
  final CalculatorRepository _repository;

  /// Executa um cálculo com os inputs fornecidos
  /// 
  /// [calculatorId] - ID da calculadora a ser usada
  /// [inputs] - Map com os inputs para o cálculo
  /// [animalId] - ID do animal associado (opcional)
  /// [saveToHistory] - Se deve salvar no histórico (default: true)
  /// 
  /// Retorna o resultado do cálculo
  /// Lança [ArgumentError] se os inputs forem inválidos
  /// Lança [Exception] se a calculadora não for encontrada
  Future<CalculationResult> call({
    required String calculatorId,
    required Map<String, dynamic> inputs,
    String? animalId,
    bool saveToHistory = true,
  }) async {
    // 1. Buscar a calculadora
    final calculator = await _repository.getCalculatorById(calculatorId);
    if (calculator == null) {
      throw Exception('Calculadora não encontrada: $calculatorId');
    }

    // 2. Validar inputs
    if (!calculator.validateInputs(inputs)) {
      final errors = calculator.getValidationErrors(inputs);
      throw ArgumentError('Inputs inválidos: ${errors.join(', ')}');
    }

    // 3. Executar cálculo
    final result = calculator.calculate(inputs);

    // 4. Salvar no histórico se solicitado
    if (saveToHistory) {
      await _saveCalculationToHistory(
        calculator: calculator,
        inputs: inputs,
        result: result,
        animalId: animalId,
      );
    }

    return result;
  }

  /// Salva o resultado no histórico
  Future<void> _saveCalculationToHistory({
    required Calculator calculator,
    required Map<String, dynamic> inputs,
    required CalculationResult result,
    String? animalId,
  }) async {
    final history = CalculationHistory(
      id: _generateHistoryId(),
      calculatorId: calculator.id,
      calculatorName: calculator.name,
      inputs: inputs,
      result: result,
      createdAt: DateTime.now(),
      animalId: animalId,
    );

    await _repository.saveCalculationHistory(history);
  }

  /// Gera um ID único para o histórico
  String _generateHistoryId() {
    return 'calc_${DateTime.now().millisecondsSinceEpoch}';
  }
}