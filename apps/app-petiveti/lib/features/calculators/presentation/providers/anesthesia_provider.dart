import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/calculators/anesthesia_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import 'calculators_providers.dart';

part 'anesthesia_provider.g.dart';


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
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class AnesthesiaNotifier extends _$AnesthesiaNotifier {
  final _calculator = const AnesthesiaCalculator();

  @override
  AnesthesiaState build() => const AnesthesiaState();

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

/// Provider para obter informações sobre a calculadora de anestesia
@riverpod
AnesthesiaCalculator anesthesiaCalculatorInfo(Ref ref) => const AnesthesiaCalculator();
