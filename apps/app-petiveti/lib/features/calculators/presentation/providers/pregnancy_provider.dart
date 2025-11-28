import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/calculators/pregnancy_gestacao_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import 'calculators_providers.dart';

part 'pregnancy_provider.g.dart';


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
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class PregnancyNotifier extends _$PregnancyNotifier {
  final _calculator = const PregnancyGestacaoCalculator();

  @override
  PregnancyState build() => const PregnancyState();

  /// Calcula a gestação baseado nos inputs
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

/// Provider para obter histórico de cálculos de gestação
@riverpod
Future<List<CalculationResult>> pregnancyHistory(Ref ref) async {
  return <CalculationResult>[];
}

/// Provider para verificar se a calculadora é favorita
@riverpod
Future<bool> pregnancyIsFavorite(Ref ref) async {
  return false;
}

/// Provider para cálculos rápidos de gestação (sem persistir histórico)
@riverpod
Future<CalculationResult> quickPregnancyCalculation(Ref ref, Map<String, dynamic> inputs) async {
  const calculator = PregnancyGestacaoCalculator();
  return calculator.calculate(inputs);
}
