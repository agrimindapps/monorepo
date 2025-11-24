import 'package:flutter/foundation.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/execute_calculation.dart';

/// Provider especializado para execução de cálculos
///
/// Responsabilidade única: Gerenciar execução de cálculos e inputs
/// Seguindo Single Responsibility Principle
class CalculatorExecutionProvider extends ChangeNotifier {
  final ExecuteCalculation _executeCalculation;

  CalculatorExecutionProvider({
    required ExecuteCalculation executeCalculation,
  }) : _executeCalculation = executeCalculation;

  bool _isCalculating = false;
  CalculationResult? _currentResult;
  Map<String, dynamic> _currentInputs = {};
  String? _errorMessage;
  CalculatorEntity? _activeCalculator;

  bool get isCalculating => _isCalculating;
  CalculationResult? get currentResult => _currentResult;
  Map<String, dynamic> get currentInputs => _currentInputs;
  String? get errorMessage => _errorMessage;
  CalculatorEntity? get activeCalculator => _activeCalculator;

  bool get hasResult => _currentResult != null;
  bool get hasInputs => _currentInputs.isNotEmpty;
  bool get canExecute => _activeCalculator != null && _currentInputs.isNotEmpty;

  /// Verifica se um input específico foi definido
  bool hasInput(String parameterId) => _currentInputs.containsKey(parameterId);

  /// Obtém valor de um input específico
  T? getInput<T>(String parameterId) => _currentInputs[parameterId] as T?;

  /// Define calculadora ativa
  void setActiveCalculator(CalculatorEntity? calculator) {
    _activeCalculator = calculator;
    if (calculator == null || _activeCalculator?.id != calculator.id) {
      _currentInputs.clear();
      _currentResult = null;
    }

    notifyListeners();
    debugPrint(
        'CalculatorExecutionProvider: Calculadora ativa definida - ${calculator?.id ?? 'nenhuma'}');
  }

  /// Atualiza input de cálculo
  void updateInput(String parameterId, dynamic value) {
    _currentInputs[parameterId] = value;
    _currentResult = null;

    notifyListeners();
    debugPrint(
        'CalculatorExecutionProvider: Input atualizado - $parameterId: $value');
  }

  /// Atualiza múltiplos inputs
  void updateInputs(Map<String, dynamic> inputs) {
    _currentInputs.addAll(inputs);
    _currentResult = null;

    notifyListeners();
    debugPrint(
        'CalculatorExecutionProvider: Múltiplos inputs atualizados - ${inputs.keys.toList()}');
  }

  /// Remove um input específico
  void removeInput(String parameterId) {
    if (_currentInputs.remove(parameterId) != null) {
      _currentResult = null;
      notifyListeners();
      debugPrint('CalculatorExecutionProvider: Input removido - $parameterId');
    }
  }

  /// Limpa todos os inputs
  void clearInputs() {
    _currentInputs.clear();
    _currentResult = null;
    notifyListeners();
    debugPrint('CalculatorExecutionProvider: Todos os inputs limpos');
  }

  /// Limpa resultado atual
  void clearResult() {
    _currentResult = null;
    notifyListeners();
    debugPrint('CalculatorExecutionProvider: Resultado limpo');
  }

  /// Executa cálculo com a calculadora ativa
  Future<bool> executeCalculation() async {
    if (_activeCalculator == null) {
      _errorMessage = 'Nenhuma calculadora ativa definida';
      notifyListeners();
      return false;
    }

    return await executeCalculationWithCalculator(_activeCalculator!);
  }

  /// Executa cálculo com calculadora específica
  Future<bool> executeCalculationWithCalculator(
      CalculatorEntity calculator) async {
    _isCalculating = true;
    _errorMessage = null;
    _activeCalculator = calculator;
    notifyListeners();

    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: calculator.id,
        inputs: _currentInputs,
      ),
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint(
            'CalculatorExecutionProvider: Erro no cálculo - ${failure.message}');
      },
      (calculationResult) {
        _currentResult = calculationResult;
        success = true;
        debugPrint(
            'CalculatorExecutionProvider: Cálculo executado com sucesso - ${calculator.id}');
      },
    );

    _isCalculating = false;
    notifyListeners();
    return success;
  }

  /// Executa cálculo rápido com inputs específicos
  Future<CalculationResult?> quickCalculation(
    CalculatorEntity calculator,
    Map<String, dynamic> inputs,
  ) async {
    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: calculator.id,
        inputs: inputs,
      ),
    );

    return result.fold(
      (failure) {
        debugPrint(
            'CalculatorExecutionProvider: Erro no cálculo rápido - ${failure.message}');
        return null;
      },
      (calculationResult) {
        debugPrint(
            'CalculatorExecutionProvider: Cálculo rápido executado - ${calculator.id}');
        return calculationResult;
      },
    );
  }

  /// Valida inputs obrigatórios
  ValidationResult validateRequiredInputs() {
    if (_activeCalculator == null) {
      return const ValidationResult(
        isValid: false,
        errors: ['Nenhuma calculadora ativa'],
        missingInputs: [],
      );
    }

    final errors = <String>[];
    final missingInputs = <String>[];
    if (_currentInputs.isEmpty) {
      errors.add('Nenhum parâmetro informado');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      missingInputs: missingInputs,
    );
  }

  /// Valida formato dos inputs
  bool validateInputFormat(String parameterId, dynamic value) {
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is num && value.isNaN) return false;

    return true;
  }

  /// Aplica resultado de cálculo anterior
  void applyPreviousResult(CalculationResult result) {
    _currentResult = result;
    _currentInputs = Map<String, dynamic>.from(result.inputs);
    notifyListeners();
    debugPrint('CalculatorExecutionProvider: Resultado anterior aplicado');
  }

  /// Obtém resumo do resultado atual
  String? getResultSummary() {
    if (_currentResult == null) return null;
    return 'Cálculo realizado com ${_currentInputs.length} parâmetros';
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _currentInputs.clear();
    _currentResult = null;
    _activeCalculator = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorExecutionProvider: Disposed');
    super.dispose();
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> missingInputs;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.missingInputs,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasMissingInputs => missingInputs.isNotEmpty;
}
