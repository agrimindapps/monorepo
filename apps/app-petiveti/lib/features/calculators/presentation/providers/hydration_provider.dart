import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/calculators/hydration_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import 'calculators_providers.dart';

part 'hydration_provider.g.dart';


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
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class HydrationNotifier extends _$HydrationNotifier {
  final _calculator = const HydrationCalculator();

  @override
  HydrationState build() => const HydrationState();

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
        final performCalculation = ref.read(performCalculationProvider);
        await performCalculation(
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

/// Provider para obter informações sobre a calculadora de hidratação
@riverpod
HydrationCalculator hydrationCalculatorInfo(Ref ref) => const HydrationCalculator();
