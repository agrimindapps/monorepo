import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/calculators/diabetes_insulin_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import 'calculators_providers.dart';

part 'diabetes_insulin_provider.g.dart';


/// Estado da calculadora de diabetes insulina
class DiabetesInsulinState {
  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  const DiabetesInsulinState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  DiabetesInsulinState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return DiabetesInsulinState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar estado da calculadora de diabetes insulina
/// Migrated to Riverpod 3.0 Notifier pattern
@riverpod
class DiabetesInsulinNotifier extends _$DiabetesInsulinNotifier {
  final _calculator = const DiabetesInsulinCalculator();

  @override
  DiabetesInsulinState build() => const DiabetesInsulinState();

  /// Realiza o cálculo de insulina para diabetes
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
      final glucoseLevel = inputs['glucoseLevel'] as double;
      if (glucoseLevel < 80) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ATENÇÃO: Hipoglicemia detectada (${glucoseLevel.toInt()} mg/dL). '
                       'Não administre insulina. Trate a hipoglicemia primeiro com glicose.',
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

/// Provider para obter informações sobre a calculadora de diabetes insulina
@riverpod
DiabetesInsulinCalculator diabetesInsulinCalculatorInfo(Ref ref) => const DiabetesInsulinCalculator();
