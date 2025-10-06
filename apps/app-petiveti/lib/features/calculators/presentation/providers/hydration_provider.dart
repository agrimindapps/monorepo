import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/calculators/hydration_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';

/// Estado da calculadora de hidratação
class HydrationState {
  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  const HydrationState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  HydrationState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return HydrationState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar estado da calculadora de hidratação
class HydrationNotifier extends StateNotifier<HydrationState> {
  HydrationNotifier() : super(const HydrationState());

  final _calculator = const HydrationCalculator();
  late final PerformCalculation _performCalculation;

  /// Inicializa o provider com dependências
  void initialize() {
    try {
      _performCalculation = di.getIt<PerformCalculation>();
    } catch (e) {
      _performCalculation = PerformCalculation(di.getIt());
    }
  }

  /// Realiza o cálculo de hidratação
  Future<void> calculate(Map<String, dynamic> inputs) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final hydrationInput = HydrationInput.fromMap(inputs);
      final validationErrors = hydrationInput.validate();
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validationErrors.first,
        );
        return;
      }
      final result = _calculator.performCalculation(hydrationInput);
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

/// Provider para a calculadora de hidratação
final hydrationProvider = StateNotifierProvider<HydrationNotifier, HydrationState>((ref) {
  final notifier = HydrationNotifier();
  notifier.initialize();
  return notifier;
});

/// Provider para obter informações sobre a calculadora de hidratação
final hydrationCalculatorInfoProvider = Provider((ref) => const HydrationCalculator());
