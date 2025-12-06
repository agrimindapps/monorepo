import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculation_result.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/execute_calculation.dart';
import 'calculators_di_providers.dart';

part 'calculator_execution_provider.g.dart';

/// ValidationResult class for inputs
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

/// State class for CalculatorExecution
class CalculatorExecutionState {
  final bool isCalculating;
  final CalculationResult? currentResult;
  final Map<String, dynamic> currentInputs;
  final String? errorMessage;
  final CalculatorEntity? activeCalculator;

  const CalculatorExecutionState({
    this.isCalculating = false,
    this.currentResult,
    this.currentInputs = const {},
    this.errorMessage,
    this.activeCalculator,
  });

  CalculatorExecutionState copyWith({
    bool? isCalculating,
    CalculationResult? currentResult,
    Map<String, dynamic>? currentInputs,
    String? errorMessage,
    CalculatorEntity? activeCalculator,
    bool clearResult = false,
    bool clearInputs = false,
    bool clearError = false,
    bool clearActiveCalculator = false,
  }) {
    return CalculatorExecutionState(
      isCalculating: isCalculating ?? this.isCalculating,
      currentResult: clearResult ? null : (currentResult ?? this.currentResult),
      currentInputs: clearInputs ? const {} : (currentInputs ?? this.currentInputs),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeCalculator: clearActiveCalculator ? null : (activeCalculator ?? this.activeCalculator),
    );
  }

  bool get hasResult => currentResult != null;
  bool get hasInputs => currentInputs.isNotEmpty;
  bool get canExecute => activeCalculator != null && currentInputs.isNotEmpty;
}

/// Provider especializado para execução de cálculos
///
/// Responsabilidade única: Gerenciar execução de cálculos e inputs
/// Seguindo Single Responsibility Principle
@riverpod
class CalculatorExecutionNotifier extends _$CalculatorExecutionNotifier {
  ExecuteCalculation get _executeCalculation => ref.read(executeCalculationUseCaseProvider);

  @override
  CalculatorExecutionState build() {
    return const CalculatorExecutionState();
  }

  // Convenience getters for backward compatibility
  bool get isCalculating => state.isCalculating;
  CalculationResult? get currentResult => state.currentResult;
  Map<String, dynamic> get currentInputs => state.currentInputs;
  String? get errorMessage => state.errorMessage;
  CalculatorEntity? get activeCalculator => state.activeCalculator;
  bool get hasResult => state.hasResult;
  bool get hasInputs => state.hasInputs;
  bool get canExecute => state.canExecute;

  /// Verifica se um input específico foi definido
  bool hasInput(String parameterId) => state.currentInputs.containsKey(parameterId);

  /// Obtém valor de um input específico
  T? getInput<T>(String parameterId) => state.currentInputs[parameterId] as T?;

  /// Define calculadora ativa
  void setActiveCalculator(CalculatorEntity? calculator) {
    if (calculator == null || state.activeCalculator?.id != calculator.id) {
      state = state.copyWith(
        activeCalculator: calculator,
        clearActiveCalculator: calculator == null,
        clearInputs: true,
        clearResult: true,
      );
    } else {
      state = state.copyWith(activeCalculator: calculator);
    }
    debugPrint(
        'CalculatorExecutionNotifier: Calculadora ativa definida - ${calculator?.id ?? 'nenhuma'}');
  }

  /// Atualiza input de cálculo
  void updateInput(String parameterId, dynamic value) {
    final updatedInputs = Map<String, dynamic>.from(state.currentInputs);
    updatedInputs[parameterId] = value;
    state = state.copyWith(
      currentInputs: updatedInputs,
      clearResult: true,
    );
    debugPrint(
        'CalculatorExecutionNotifier: Input atualizado - $parameterId: $value');
  }

  /// Atualiza múltiplos inputs
  void updateInputs(Map<String, dynamic> inputs) {
    final updatedInputs = Map<String, dynamic>.from(state.currentInputs);
    updatedInputs.addAll(inputs);
    state = state.copyWith(
      currentInputs: updatedInputs,
      clearResult: true,
    );
    debugPrint(
        'CalculatorExecutionNotifier: Múltiplos inputs atualizados - ${inputs.keys.toList()}');
  }

  /// Remove um input específico
  void removeInput(String parameterId) {
    final updatedInputs = Map<String, dynamic>.from(state.currentInputs);
    if (updatedInputs.remove(parameterId) != null) {
      state = state.copyWith(
        currentInputs: updatedInputs,
        clearResult: true,
      );
      debugPrint('CalculatorExecutionNotifier: Input removido - $parameterId');
    }
  }

  /// Limpa todos os inputs
  void clearInputs() {
    state = state.copyWith(clearInputs: true, clearResult: true);
    debugPrint('CalculatorExecutionNotifier: Todos os inputs limpos');
  }

  /// Limpa resultado atual
  void clearResult() {
    state = state.copyWith(clearResult: true);
    debugPrint('CalculatorExecutionNotifier: Resultado limpo');
  }

  /// Executa cálculo com a calculadora ativa
  Future<bool> executeCalculation() async {
    if (state.activeCalculator == null) {
      state = state.copyWith(errorMessage: 'Nenhuma calculadora ativa definida');
      return false;
    }

    return await executeCalculationWithCalculator(state.activeCalculator!);
  }

  /// Executa cálculo com calculadora específica
  Future<bool> executeCalculationWithCalculator(
      CalculatorEntity calculator) async {
    state = state.copyWith(
      isCalculating: true,
      activeCalculator: calculator,
      clearError: true,
    );

    final result = await _executeCalculation.execute(
      ExecuteCalculationParams(
        calculatorId: calculator.id,
        inputs: state.currentInputs,
      ),
    );

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isCalculating: false,
        );
        debugPrint(
            'CalculatorExecutionNotifier: Erro no cálculo - ${failure.message}');
      },
      (calculationResult) {
        state = state.copyWith(
          currentResult: calculationResult,
          isCalculating: false,
        );
        success = true;
        debugPrint(
            'CalculatorExecutionNotifier: Cálculo executado com sucesso - ${calculator.id}');
      },
    );

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
            'CalculatorExecutionNotifier: Erro no cálculo rápido - ${failure.message}');
        return null;
      },
      (calculationResult) {
        debugPrint(
            'CalculatorExecutionNotifier: Cálculo rápido executado - ${calculator.id}');
        return calculationResult;
      },
    );
  }

  /// Valida inputs obrigatórios
  ValidationResult validateRequiredInputs() {
    if (state.activeCalculator == null) {
      return const ValidationResult(
        isValid: false,
        errors: ['Nenhuma calculadora ativa'],
        missingInputs: [],
      );
    }

    final errors = <String>[];
    final missingInputs = <String>[];
    if (state.currentInputs.isEmpty) {
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
    state = state.copyWith(
      currentResult: result,
      currentInputs: Map<String, dynamic>.from(result.inputs),
    );
    debugPrint('CalculatorExecutionNotifier: Resultado anterior aplicado');
  }

  /// Obtém resumo do resultado atual
  String? getResultSummary() {
    if (state.currentResult == null) return null;
    return 'Cálculo realizado com ${state.currentInputs.length} parâmetros';
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorExecutionState();
  }
}
