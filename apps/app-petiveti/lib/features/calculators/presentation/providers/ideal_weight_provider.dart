import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';


import '../../domain/calculators/ideal_weight_calculator.dart';

import '../../domain/entities/calculation_result.dart';

import '../../domain/usecases/perform_calculation.dart';

import 'calculators_providers.dart';

part 'ideal_weight_provider.g.dart';


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
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class IdealWeightNotifier extends _$IdealWeightNotifier {
  final _calculator = const IdealWeightCalculator();

  @override
  IdealWeightState build() => const IdealWeightState();

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
      final performCalculation = ref.read(performCalculationProvider);
      final result = await performCalculation(
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

/// Provider para obter histórico de cálculos de peso ideal
@riverpod
Future<List<CalculationResult>> idealWeightHistory(Ref ref) async {
  return <CalculationResult>[];
}

/// Provider para verificar se a calculadora é favorita
@riverpod
Future<bool> idealWeightIsFavorite(Ref ref) async {
  return false;
}
