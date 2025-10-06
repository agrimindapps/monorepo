import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/calculators/fluid_therapy_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';

/// Estado da calculadora de fluidoterapia
class FluidTherapyState {
  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  const FluidTherapyState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  FluidTherapyState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return FluidTherapyState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar estado da calculadora de fluidoterapia
class FluidTherapyNotifier extends StateNotifier<FluidTherapyState> {
  FluidTherapyNotifier() : super(const FluidTherapyState());

  final _calculator = const FluidTherapyCalculator();
  late final PerformCalculation _performCalculation;

  /// Inicializa o provider com dependências
  void initialize() {
    try {
      _performCalculation = di.getIt<PerformCalculation>();
    } catch (e) {
      _performCalculation = PerformCalculation(di.getIt());
    }
  }

  /// Realiza o cálculo de fluidoterapia
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

/// Provider para a calculadora de fluidoterapia
final fluidTherapyProvider = StateNotifierProvider<FluidTherapyNotifier, FluidTherapyState>((ref) {
  final notifier = FluidTherapyNotifier();
  notifier.initialize();
  return notifier;
});

/// Provider para obter informações sobre a calculadora de fluidoterapia
final fluidTherapyCalculatorInfoProvider = Provider((ref) => const FluidTherapyCalculator());
