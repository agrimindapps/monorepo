import 'package:core/core.dart';

import '../../domain/calculators/anesthesia_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';
import 'calculators_providers.dart';

/// Estado da calculadora de anestesia
class AnesthesiaState {
  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  const AnesthesiaState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  AnesthesiaState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return AnesthesiaState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar estado da calculadora de anestesia
class AnesthesiaNotifier extends StateNotifier<AnesthesiaState> {
  AnesthesiaNotifier(this._performCalculation) : super(const AnesthesiaState());

  final _calculator = const AnesthesiaCalculator();
  final PerformCalculation _performCalculation;

  /// Realiza o cálculo de anestesia
  Future<void> calculate(Map<String, dynamic> inputs) async {
    if (state.isLoading) return;

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
      final result = _calculator.calculate(inputs);
      try {
        await _performCalculation(
          calculatorId: _calculator.id,
          inputs: inputs,
        );
      } catch (e) {
        print('Aviso: Não foi possível salvar no histórico: $e');
      }

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao calcular: ${e.toString()}',
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

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider para a calculadora de anestesia
final anesthesiaProvider = StateNotifierProvider<AnesthesiaNotifier, AnesthesiaState>((ref) {
  return AnesthesiaNotifier(ref.watch(performCalculationProvider));
});

/// Provider para obter informações sobre a calculadora de anestesia
final anesthesiaCalculatorInfoProvider = Provider((ref) => const AnesthesiaCalculator());
