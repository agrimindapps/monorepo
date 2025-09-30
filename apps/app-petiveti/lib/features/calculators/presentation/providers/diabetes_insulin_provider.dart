import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/calculators/diabetes_insulin_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';

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
class DiabetesInsulinNotifier extends StateNotifier<DiabetesInsulinState> {
  DiabetesInsulinNotifier() : super(const DiabetesInsulinState());

  final _calculator = const DiabetesInsulinCalculator();
  late final PerformCalculation _performCalculation;

  /// Inicializa o provider com dependências
  void initialize() {
    try {
      _performCalculation = di.getIt<PerformCalculation>();
    } catch (e) {
      // Se não conseguir obter do DI, usar instância direta
      _performCalculation = PerformCalculation(di.getIt());
    }
  }

  /// Realiza o cálculo de insulina para diabetes
  Future<void> calculate(Map<String, dynamic> inputs) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Validar inputs primeiro
      final validationErrors = _calculator.getValidationErrors(inputs);
      if (validationErrors.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: validationErrors.first,
        );
        return;
      }

      // Verificar condições críticas
      final glucoseLevel = inputs['glucoseLevel'] as double;
      if (glucoseLevel < 80) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ATENÇÃO: Hipoglicemia detectada (${glucoseLevel.toInt()} mg/dL). '
                       'Não administre insulina. Trate a hipoglicemia primeiro com glicose.',
        );
        return;
      }

      // Realizar cálculo
      final result = _calculator.calculate(inputs);

      // Salvar no histórico se o use case estiver disponível
      try {
        await _performCalculation(
          calculatorId: _calculator.id,
          inputs: inputs,
        );
      } catch (e) {
        // Continuar mesmo se não conseguir salvar no histórico
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

/// Provider para a calculadora de diabetes insulina
final diabetesInsulinProvider = StateNotifierProvider<DiabetesInsulinNotifier, DiabetesInsulinState>((ref) {
  final notifier = DiabetesInsulinNotifier();
  notifier.initialize();
  return notifier;
});

/// Provider para obter informações sobre a calculadora de diabetes insulina
final diabetesInsulinCalculatorInfoProvider = Provider((ref) => const DiabetesInsulinCalculator());