import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/calculators/ideal_weight_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';

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
  IdealWeightNotifier() : super(const IdealWeightState());

  final _calculator = const IdealWeightCalculator();
  final _performCalculation = di.getIt<PerformCalculation>();

  /// Calcula o peso ideal baseado nos inputs
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
    state = const IdealWeightState();
  }
}

/// Provider para a calculadora de peso ideal
final idealWeightProvider = StateNotifierProvider<IdealWeightNotifier, IdealWeightState>(
  (ref) => IdealWeightNotifier(),
);

/// Provider para obter histórico de cálculos de peso ideal
final idealWeightHistoryProvider = FutureProvider<List<CalculationResult>>((ref) async {
  // TODO: Implementar busca do histórico no repositório
  // final repository = di.getIt<CalculatorRepository>();
  // final history = await repository.getCalculationHistory(calculatorId: 'ideal_weight');
  // return history.map((h) => h.result).toList();
  return <CalculationResult>[];
});

/// Provider para verificar se a calculadora é favorita
final idealWeightIsFavoriteProvider = FutureProvider<bool>((ref) async {
  // TODO: Implementar verificação de favorito
  // final repository = di.getIt<CalculatorRepository>();
  // return await repository.isFavoriteCalculator('ideal_weight');
  return false;
});