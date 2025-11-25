import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:core/core.dart';


import '../../../../core/error/exceptions.dart';

import '../../domain/entities/body_condition_input.dart';

import '../../domain/entities/body_condition_output.dart';

import '../../domain/entities/calculation_result.dart';

import '../../domain/strategies/body_condition_strategy.dart';

import '../../domain/strategies/calculator_strategy.dart';

part 'body_condition_provider.g.dart';


/// Estados para o provider de condição corporal
enum BodyConditionCalculatorStatus { initial, loading, success, error }

/// Estado do calculator de condição corporal
class BodyConditionState {
  const BodyConditionState({
    this.status = BodyConditionCalculatorStatus.initial,
    this.input = const BodyConditionInput(
      species: AnimalSpecies.dog,
      currentWeight: 0,
      ribPalpation: RibPalpation.moderatePressure,
      waistVisibility: WaistVisibility.moderatelyVisible,
      abdominalProfile: AbdominalProfile.straight,
    ),
    this.output,
    this.error,
    this.validationErrors = const [],
    this.history = const [],
  });

  final BodyConditionCalculatorStatus status;
  final BodyConditionInput input;
  final BodyConditionOutput? output;
  final String? error;
  final List<String> validationErrors;
  final List<BodyConditionOutput> history;

  /// Getters de conveniência
  bool get isLoading => status == BodyConditionCalculatorStatus.loading;
  bool get hasResult =>
      status == BodyConditionCalculatorStatus.success && output != null;
  bool get hasError =>
      status == BodyConditionCalculatorStatus.error && error != null;
  bool get hasValidationErrors => validationErrors.isNotEmpty;
  bool get canCalculate => input.isValid && validationErrors.isEmpty;

  BodyConditionState copyWith({
    BodyConditionCalculatorStatus? status,
    BodyConditionInput? input,
    BodyConditionOutput? output,
    String? error,
    List<String>? validationErrors,
    List<BodyConditionOutput>? history,
  }) {
    return BodyConditionState(
      status: status ?? this.status,
      input: input ?? this.input,
      output: output ?? this.output,
      error: error,
      validationErrors: validationErrors ?? this.validationErrors,
      history: history ?? this.history,
    );
  }
}

/// Notifier para gerenciar estado da calculadora BCS
@riverpod
class BodyConditionNotifier extends _$BodyConditionNotifier {
  late final BodyConditionStrategy _strategy;

  @override
  BodyConditionState build() {
    _strategy = ref.watch(bodyConditionStrategyProvider);
    return const BodyConditionState();
  }

  /// Atualiza entrada da calculadora
  void updateInput(BodyConditionInput input) {
    final validationErrors = _strategy.validateInput(input);

    state = state.copyWith(
      input: input,
      validationErrors: validationErrors,
      status: BodyConditionCalculatorStatus.initial,
      error: null,
    );
  }

  /// Atualiza campo específico da entrada
  void updateSpecies(AnimalSpecies species) {
    final newInput = state.input.copyWith(species: species);
    updateInput(newInput);
  }

  void updateCurrentWeight(double weight) {
    if (weight <= 0.0 || weight > 150.0) {
      throw VeterinaryInputException(
        message: 'Peso deve estar entre 0.1kg e 150kg',
        fieldName: 'currentWeight',
        providedValue: weight,
        minValue: 0.1,
        maxValue: 150.0,
      );
    }
    final species = state.input.species;
    if (species == AnimalSpecies.cat) {
      if (weight < 1.0 || weight > 12.0) {
        throw VeterinaryInputException(
          message: 'Peso para gatos deve estar entre 1kg e 12kg',
          fieldName: 'currentWeight',
          providedValue: weight,
          minValue: 1.0,
          maxValue: 12.0,
        );
      }
    } else if (species == AnimalSpecies.dog) {
      if (weight < 1.0 || weight > 90.0) {
        throw VeterinaryInputException(
          message: 'Peso para cães deve estar entre 1kg e 90kg',
          fieldName: 'currentWeight',
          providedValue: weight,
          minValue: 1.0,
          maxValue: 90.0,
        );
      }
    }

    final newInput = state.input.copyWith(currentWeight: weight);
    updateInput(newInput);
  }

  void updateIdealWeight(double? weight) {
    final newInput = state.input.copyWith(idealWeight: weight);
    updateInput(newInput);
  }

  void updateRibPalpation(RibPalpation ribPalpation) {
    final newInput = state.input.copyWith(ribPalpation: ribPalpation);
    updateInput(newInput);
  }

  void updateWaistVisibility(WaistVisibility waistVisibility) {
    final newInput = state.input.copyWith(waistVisibility: waistVisibility);
    updateInput(newInput);
  }

  void updateAbdominalProfile(AbdominalProfile abdominalProfile) {
    final newInput = state.input.copyWith(abdominalProfile: abdominalProfile);
    updateInput(newInput);
  }

  void updateObservations(String? observations) {
    final newInput = state.input.copyWith(observations: observations);
    updateInput(newInput);
  }

  void updateAnimalAge(int? age) {
    final newInput = state.input.copyWith(animalAge: age);
    updateInput(newInput);
  }

  void updateAnimalBreed(String? breed) {
    final newInput = state.input.copyWith(animalBreed: breed);
    updateInput(newInput);
  }

  void updateIsNeutered(bool isNeutered) {
    final newInput = state.input.copyWith(isNeutered: isNeutered);
    updateInput(newInput);
  }

  void updateHasMetabolicConditions(bool hasConditions) {
    final newInput = state.input.copyWith(
      hasMetabolicConditions: hasConditions,
    );
    updateInput(newInput);
  }

  void updateMetabolicConditions(List<String>? conditions) {
    final newInput = state.input.copyWith(metabolicConditions: conditions);
    updateInput(newInput);
  }

  /// Executa o cálculo de condição corporal
  Future<void> calculate() async {
    if (!state.canCalculate) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.error,
        error: 'Dados de entrada inválidos',
      );
      return;
    }

    state = state.copyWith(
      status: BodyConditionCalculatorStatus.loading,
      error: null,
    );

    try {
      final result = _strategy.calculate(state.input);
      final newHistory = [...state.history, result];

      state = state.copyWith(
        status: BodyConditionCalculatorStatus.success,
        output: result,
        history: newHistory,
      );
    } on VeterinaryInputException catch (e) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.error,
        error: e.message,
        validationErrors: [e.message],
      );
    } on InvalidInputException catch (e) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.error,
        error: e.message,
        validationErrors: e.validationErrors,
      );
    } on CalculationException catch (e) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.error,
        error: 'Erro inesperado durante o cálculo: ${e.toString()}',
      );
    }
  }

  /// Limpa erro atual
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: BodyConditionCalculatorStatus.initial,
        error: null,
      );
    }
  }

  /// Limpa resultado atual
  void clearResult() {
    state = state.copyWith(
      status: BodyConditionCalculatorStatus.initial,
      output: null,
      error: null,
    );
  }

  /// Reseta calculadora para estado inicial
  void reset() {
    state = const BodyConditionState();
  }

  /// Remove item do histórico
  void removeFromHistory(int index) {
    if (index >= 0 && index < state.history.length) {
      final newHistory = [...state.history];
      newHistory.removeAt(index);
      state = state.copyWith(history: newHistory);
    }
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  /// Carrega entrada de resultado anterior
  void loadFromHistory(int index) {
    if (index >= 0 && index < state.history.length) {
      final historicalResult = state.history[index];
      final reconstructedInput = state.input.copyWith(
        currentWeight:
            (historicalResult.results
                        .firstWhere(
                          (r) => r.label == 'Peso Atual',
                          orElse: () => const ResultItem(label: '', value: 0.0),
                        )
                        .value
                    as num?)
                ?.toDouble(),
      );

      updateInput(reconstructedInput);
      state = state.copyWith(output: historicalResult);
    }
  }
}

/// Provider da estratégia BCS
@riverpod
BodyConditionStrategy bodyConditionStrategy(Ref ref) {
  return const BodyConditionStrategy();
}

/// Providers de conveniência para componentes específicos

/// Provider do estado de entrada
@riverpod
BodyConditionInput bodyConditionInput(Ref ref) {
  return ref.watch(bodyConditionProvider).input;
}

/// Provider do resultado
@riverpod
BodyConditionOutput? bodyConditionOutput(Ref ref) {
  return ref.watch(bodyConditionProvider).output;
}

/// Provider do status de loading
@riverpod
bool bodyConditionLoading(Ref ref) {
  return ref.watch(bodyConditionProvider).isLoading;
}

/// Provider de erros
@riverpod
String? bodyConditionError(Ref ref) {
  final state = ref.watch(bodyConditionProvider);
  return state.hasError ? state.error : null;
}

/// Provider de erros de validação
@riverpod
List<String> bodyConditionValidationErrors(Ref ref) {
  return ref.watch(bodyConditionProvider).validationErrors;
}

/// Provider indicando se pode calcular
@riverpod
bool bodyConditionCanCalculate(Ref ref) {
  return ref.watch(bodyConditionProvider).canCalculate;
}

/// Provider do histórico
@riverpod
List<BodyConditionOutput> bodyConditionHistory(Ref ref) {
  return ref.watch(bodyConditionProvider).history;
}

/// Provider de sugestões baseadas na entrada atual
@riverpod
List<String> bodyConditionSuggestions(Ref ref) {
  final input = ref.watch(bodyConditionInputProvider);
  final suggestions = <String>[];
  if (input.currentWeight > 0) {
    if (input.idealWeight == null) {
      suggestions.add('💡 Informe o peso ideal para cálculos mais precisos');
    }

    if (input.animalBreed == null || input.animalBreed!.isEmpty) {
      suggestions.add('🐕 Informe a raça para recomendações mais específicas');
    }

    if (input.animalAge == null) {
      suggestions.add('📅 Informe a idade para ajustes metabólicos');
    }
    if (input.species == AnimalSpecies.cat && input.currentWeight > 6) {
      suggestions.add(
        '⚠️ Peso elevado para gatos - considere avaliação veterinária',
      );
    } else if (input.species == AnimalSpecies.dog && input.currentWeight < 2) {
      suggestions.add(
        '⚠️ Peso muito baixo - verifique se é filhote ou raça toy',
      );
    }
    if (input.observations == null || input.observations!.isEmpty) {
      suggestions.add('📝 Adicione observações sobre comportamento alimentar');
    }
  }

  return suggestions;
}

/// Provider com estatísticas do histórico
@riverpod
Map<String, dynamic> bodyConditionHistoryStats(Ref ref) {
  final history = ref.watch(bodyConditionHistoryProvider);

  if (history.isEmpty) {
    return {'count': 0};
  }

  final scores = history.map((result) => result.bcsScore).toList();
  final avgScore = scores.reduce((a, b) => a + b) / scores.length;

  final classifications =
      history.map((result) => result.classification).toList();
  final idealCount =
      classifications.where((c) => c == BcsClassification.ideal).length;

  return {
    'count': history.length,
    'averageScore': avgScore,
    'idealPercentage': idealCount / history.length * 100,
    'latestScore': scores.last,
    'trend': scores.length > 1 ? scores.last - scores[scores.length - 2] : 0,
  };
}
