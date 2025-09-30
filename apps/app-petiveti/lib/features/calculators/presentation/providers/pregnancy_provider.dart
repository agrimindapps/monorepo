import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/calculators/pregnancy_gestacao_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';

/// Estado da calculadora de gestação
class PregnancyState {
  const PregnancyState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  PregnancyState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return PregnancyState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar o estado da calculadora de gestação
class PregnancyNotifier extends StateNotifier<PregnancyState> {
  PregnancyNotifier() : super(const PregnancyState());

  final _calculator = const PregnancyGestacaoCalculator();
  final _performCalculation = di.getIt<PerformCalculation>();

  /// Calcula a gestação baseado nos inputs
  Future<void> calculate(Map<String, dynamic> inputs) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Validar inputs
      final validationErrors = _calculator.getValidationErrors(inputs);
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validationErrors.first,
        );
        return;
      }

      // Realizar cálculo
      final result = await _performCalculation(
        calculatorId: _calculator.id,
        inputs: inputs,
      );
      
      state = state.copyWith(
        isLoading: false,
        result: result,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
      );
    }
  }

  /// Limpa o resultado atual
  void clearResult() {
    state = state.copyWith(
      result: null,
      errorMessage: null,
    );
  }

  /// Reseta o estado para o inicial
  void reset() {
    state = const PregnancyState();
  }

  /// Atualiza os dados da gestação com nova data de acasalamento
  Future<void> updateMatingDate(DateTime newDate, Map<String, dynamic> currentInputs) async {
    final updatedInputs = Map<String, dynamic>.from(currentInputs);
    updatedInputs['mating_date'] = newDate.toIso8601String().split('T')[0];
    await calculate(updatedInputs);
  }

  /// Recalcula com novo peso da mãe
  Future<void> updateMotherWeight(double newWeight, Map<String, dynamic> currentInputs) async {
    final updatedInputs = Map<String, dynamic>.from(currentInputs);
    updatedInputs['mother_weight'] = newWeight;
    await calculate(updatedInputs);
  }
}

/// Provider para a calculadora de gestação
final pregnancyProvider = StateNotifierProvider<PregnancyNotifier, PregnancyState>(
  (ref) => PregnancyNotifier(),
);

/// Provider para obter histórico de cálculos de gestação
final pregnancyHistoryProvider = FutureProvider<List<CalculationResult>>((ref) async {
  // TODO: Implementar busca do histórico no repositório
  // final repository = di.getIt<CalculatorRepository>();
  // final history = await repository.getCalculationHistory(calculatorId: 'pregnancy_gestacao');
  // return history.map((h) => h.result).toList();
  return <CalculationResult>[];
});

/// Provider para verificar se a calculadora é favorita
final pregnancyIsFavoriteProvider = FutureProvider<bool>((ref) async {
  // TODO: Implementar verificação de favorito
  // final repository = di.getIt<CalculatorRepository>();
  // return await repository.isFavoriteCalculator('pregnancy_gestacao');
  return false;
});

/// Provider para cálculos rápidos de gestação (sem persistir histórico)
final quickPregnancyCalculationProvider = FutureProvider.family<CalculationResult, Map<String, dynamic>>((ref, inputs) async {
  const calculator = PregnancyGestacaoCalculator();
  return calculator.calculate(inputs);
});