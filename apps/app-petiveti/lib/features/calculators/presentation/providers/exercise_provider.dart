import 'package:core/core.dart';

import '../../domain/calculators/exercise_calculator.dart';
import '../../domain/entities/calculation_result.dart';
import '../../domain/usecases/perform_calculation.dart';
import 'calculators_providers.dart';

/// Estado da calculadora de exercícios
class ExerciseState {
  const ExerciseState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final CalculationResult? result;
  final String? errorMessage;

  ExerciseState copyWith({
    bool? isLoading,
    CalculationResult? result,
    String? errorMessage,
  }) {
    return ExerciseState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar o estado da calculadora de exercícios
class ExerciseNotifier extends StateNotifier<ExerciseState> {
  ExerciseNotifier(this._performCalculation) : super(const ExerciseState());

  final _calculator = const ExerciseCalculator();
  final PerformCalculation _performCalculation;

  /// Calcula o plano de exercícios baseado nos inputs
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
    state = const ExerciseState();
  }

  /// Recalcula com novo objetivo de exercício
  Future<void> updateExerciseGoal(String newGoal, Map<String, dynamic> currentInputs) async {
    final updatedInputs = Map<String, dynamic>.from(currentInputs);
    updatedInputs['exercise_goal'] = newGoal;
    await calculate(updatedInputs);
  }

  /// Recalcula com novo tempo disponível
  Future<void> updateAvailableTime(double newTime, Map<String, dynamic> currentInputs) async {
    final updatedInputs = Map<String, dynamic>.from(currentInputs);
    updatedInputs['available_time'] = newTime;
    await calculate(updatedInputs);
  }

  /// Recalcula com nova condição de saúde
  Future<void> updateHealthCondition(String newCondition, Map<String, dynamic> currentInputs) async {
    final updatedInputs = Map<String, dynamic>.from(currentInputs);
    updatedInputs['health_conditions'] = newCondition;
    await calculate(updatedInputs);
  }
}

/// Provider para a calculadora de exercícios
final exerciseProvider = StateNotifierProvider<ExerciseNotifier, ExerciseState>(
  (ref) => ExerciseNotifier(ref.watch(performCalculationProvider)),
);

/// Provider para obter histórico de cálculos de exercício
final exerciseHistoryProvider = FutureProvider<List<CalculationResult>>((ref) async {
  return <CalculationResult>[];
});

/// Provider para verificar se a calculadora é favorita
final exerciseIsFavoriteProvider = FutureProvider<bool>((ref) async {
  return false;
});

/// Provider para cálculos rápidos de exercício (sem persistir histórico)
final quickExerciseCalculationProvider = FutureProvider.family<CalculationResult, Map<String, dynamic>>((ref, inputs) async {
  const calculator = ExerciseCalculator();
  return calculator.calculate(inputs);
});

/// Provider para sugestões de exercício baseadas na raça
final exerciseSuggestionsByBreedProvider = Provider.family<List<String>, String>((ref, breedGroup) {
  final suggestions = <String>[];

  if (breedGroup.contains('Trabalho')) {
    suggestions.addAll([
      'Agility e obstáculos',
      'Treinamento de obediência',
      'Corrida em trilhas',
      'Atividades de pastoreio simulado',
    ]);
  } else if (breedGroup.contains('Esportivo')) {
    suggestions.addAll([
      'Natação',
      'Busca e resgate de objetos',
      'Corrida ao lado da bicicleta',
      'Jogos de busca na água',
    ]);
  } else if (breedGroup.contains('Terrier')) {
    suggestions.addAll([
      'Caça ao tesouro',
      'Tug-of-war (cabo de guerra)',
      'Corridas curtas e intensas',
      'Jogos de perseguição',
    ]);
  } else if (breedGroup.contains('Toy')) {
    suggestions.addAll([
      'Caminhadas curtas',
      'Brincadeiras indoor',
      'Jogos mentais com petiscos',
      'Socialização em parques',
    ]);
  } else if (breedGroup.contains('Gato')) {
    suggestions.addAll([
      'Brinquedos com penas',
      'Laser pointer (termine com recompensa física)',
      'Arranhadores e torres de escalada',
      'Caça simulada com brinquedos',
    ]);
  } else {
    suggestions.addAll([
      'Caminhadas variadas',
      'Jogos de busca',
      'Socialização com outros animais',
      'Exploração de novos ambientes',
    ]);
  }

  return suggestions;
});
