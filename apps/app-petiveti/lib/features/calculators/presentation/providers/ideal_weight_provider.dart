import 'package:core/core.dart';

import '../../domain/calculators/ideal_weight_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';
import 'calculators_providers.dart';

/// Estado da calculadora de peso ideal
class IdealWeightState {
  const IdealWeightState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  IdealWeightState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return IdealWeightState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar o estado da calculadora de peso ideal
class IdealWeightNotifier extends StateNotifier<IdealWeightState> {
  IdealWeightNotifier(this._performCalculation) : super(const IdealWeightState());

  final _calculator = const IdealWeightCalculator();
  final PerformCalculation _performCalculation;

  /// Calcula o peso ideal baseado nos inputs
  Future<void> calculate(Map<String, dynamic> inputs) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final validationErrors = _calculator.getValidationErrors(inputs);
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validationErrors.first,
        );
        return;
      }
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
    state = const IdealWeightState();
  }
}

/// Provider para a calculadora de peso ideal
final idealWeightProvider = StateNotifierProvider<IdealWeightNotifier, IdealWeightState>(
  (ref) => IdealWeightNotifier(ref.watch(performCalculationProvider)),
);

/// Provider para obter histórico de cálculos de peso ideal
final idealWeightHistoryProvider = FutureProvider<List<CalculationResult>>((ref) async {
  return <CalculationResult>[];
});

/// Provider para verificar se a calculadora é favorita
final idealWeightIsFavoriteProvider = FutureProvider<bool>((ref) async {
  return false;
});
