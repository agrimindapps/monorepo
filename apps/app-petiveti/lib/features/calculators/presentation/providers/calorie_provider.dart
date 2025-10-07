import 'package:core/core.dart';

import '../../domain/entities/calorie_input.dart';
import '../../domain/entities/calorie_output.dart';
import '../../domain/strategies/calculator_strategy.dart';
import '../../domain/strategies/calorie_calculator_strategy.dart';

/// Estados para o provider de cálculo calórico
enum CalorieCalculatorStatus { initial, loading, success, error }

/// Estado da calculadora de necessidades calóricas
class CalorieState {
  const CalorieState({
    this.status = CalorieCalculatorStatus.initial,
    this.input = const CalorieInput(
      species: AnimalSpecies.dog,
      weight: 0,
      age: 12,
      physiologicalState: PhysiologicalState.normal,
      activityLevel: ActivityLevel.moderate,
      bodyConditionScore: BodyConditionScore.ideal,
    ),
    this.output,
    this.error,
    this.validationErrors = const [],
    this.history = const [],
    this.currentStep = 0,
    this.isTransitionLoading = false,
  });

  final CalorieCalculatorStatus status;
  final CalorieInput input;
  final CalorieOutput? output;
  final String? error;
  final List<String> validationErrors;
  final List<CalorieOutput> history;
  final int currentStep; // Para navegação step-by-step no formulário
  final bool isTransitionLoading; // Para loading states durante transições

  /// Getters de conveniência
  bool get isLoading => status == CalorieCalculatorStatus.loading;
  bool get hasResult =>
      status == CalorieCalculatorStatus.success && output != null;
  bool get hasError => status == CalorieCalculatorStatus.error && error != null;
  bool get hasValidationErrors => validationErrors.isNotEmpty;
  bool get canCalculate => _isInputValid() && validationErrors.isEmpty;

  /// Verifica se todos os campos obrigatórios estão preenchidos
  bool _isInputValid() {
    return input.weight > 0 &&
        input.age >= 0 &&
        (!input.isLactating || input.numberOfOffspring != null);
  }

  /// Total de steps no formulário
  int get totalSteps => 5;

  /// Indica se é o último step
  bool get isLastStep => currentStep >= totalSteps - 1;

  /// Indica se é o primeiro step
  bool get isFirstStep => currentStep <= 0;

  CalorieState copyWith({
    CalorieCalculatorStatus? status,
    CalorieInput? input,
    CalorieOutput? output,
    String? error,
    List<String>? validationErrors,
    List<CalorieOutput>? history,
    int? currentStep,
    bool? isTransitionLoading,
  }) {
    return CalorieState(
      status: status ?? this.status,
      input: input ?? this.input,
      output: output ?? this.output,
      error: error,
      validationErrors: validationErrors ?? this.validationErrors,
      history: history ?? this.history,
      currentStep: currentStep ?? this.currentStep,
      isTransitionLoading: isTransitionLoading ?? this.isTransitionLoading,
    );
  }
}

/// Notifier para gerenciar estado da calculadora calórica
class CalorieNotifier extends StateNotifier<CalorieState> {
  CalorieNotifier(this._strategy) : super(const CalorieState());

  final CalorieCalculatorStrategy _strategy;

  /// Atualiza entrada da calculadora
  void updateInput(CalorieInput input) {
    final validationErrors = _strategy.validateInput(input);

    state = state.copyWith(
      input: input,
      validationErrors: validationErrors,
      status: CalorieCalculatorStatus.initial,
      error: null,
    );
  }

  void updateSpecies(AnimalSpecies species) {
    final newInput = state.input.copyWith(species: species);
    updateInput(newInput);
  }

  void updateWeight(double weight) {
    final newInput = state.input.copyWith(weight: weight);
    updateInput(newInput);
  }

  void updateIdealWeight(double? idealWeight) {
    final newInput = state.input.copyWith(idealWeight: idealWeight);
    updateInput(newInput);
  }

  void updateAge(int age) {
    final newInput = state.input.copyWith(age: age);
    updateInput(newInput);
  }

  void updatePhysiologicalState(PhysiologicalState physiologicalState) {
    final newInput = state.input.copyWith(
      physiologicalState: physiologicalState,
    );
    updateInput(newInput);
  }

  void updateActivityLevel(ActivityLevel activityLevel) {
    final newInput = state.input.copyWith(activityLevel: activityLevel);
    updateInput(newInput);
  }

  void updateBodyConditionScore(BodyConditionScore bodyConditionScore) {
    final newInput = state.input.copyWith(
      bodyConditionScore: bodyConditionScore,
    );
    updateInput(newInput);
  }

  void updateEnvironmentalCondition(
    EnvironmentalCondition environmentalCondition,
  ) {
    final newInput = state.input.copyWith(
      environmentalCondition: environmentalCondition,
    );
    updateInput(newInput);
  }

  void updateMedicalCondition(MedicalCondition medicalCondition) {
    final newInput = state.input.copyWith(medicalCondition: medicalCondition);
    updateInput(newInput);
  }

  void updateNumberOfOffspring(int? numberOfOffspring) {
    final newInput = state.input.copyWith(numberOfOffspring: numberOfOffspring);
    updateInput(newInput);
  }

  void updateBreed(String? breed) {
    final newInput = state.input.copyWith(breed: breed);
    updateInput(newInput);
  }

  void updateNotes(String? notes) {
    final newInput = state.input.copyWith(notes: notes);
    updateInput(newInput);
  }

  void nextStep() {
    if (!state.isLastStep) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (!state.isFirstStep) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  void resetSteps() {
    state = state.copyWith(currentStep: 0);
  }

  /// Set transition loading state for better UX during step changes
  void setTransitionLoading(bool isLoading) {
    state = state.copyWith(isTransitionLoading: isLoading);
  }

  /// Valida step atual antes de avançar
  bool canProceedToNextStep() {
    switch (state.currentStep) {
      case 0: // Informações básicas
        return state.input.weight > 0 && state.input.age >= 0;
      case 1: // Estado fisiológico
        return !state.input.isLactating ||
            state.input.numberOfOffspring != null;
      case 2: // Atividade e condição corporal
        return true;
      case 3: // Condições especiais
        return true; // Sempre pode prosseguir (campos opcionais)
      case 4: // Revisão
        return state.canCalculate;
      default:
        return false;
    }
  }

  /// Executa o cálculo de necessidades calóricas
  Future<void> calculate() async {
    if (!state.canCalculate) {
      state = state.copyWith(
        status: CalorieCalculatorStatus.error,
        error: 'Dados de entrada inválidos ou incompletos',
      );
      return;
    }

    state = state.copyWith(
      status: CalorieCalculatorStatus.loading,
      error: null,
    );

    try {
      final result = _strategy.calculate(state.input);
      final newHistory = [...state.history, result];

      state = state.copyWith(
        status: CalorieCalculatorStatus.success,
        output: result,
        history: newHistory,
      );
    } on InvalidInputException catch (e) {
      state = state.copyWith(
        status: CalorieCalculatorStatus.error,
        error: e.message,
        validationErrors: e.validationErrors,
      );
    } on CalculationException catch (e) {
      state = state.copyWith(
        status: CalorieCalculatorStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: CalorieCalculatorStatus.error,
        error: 'Erro inesperado durante o cálculo: ${e.toString()}',
      );
    }
  }

  /// Calcula automaticamente quando campos obrigatórios são preenchidos
  Future<void> autoCalculateIfReady() async {
    if (state.canCalculate && !state.isLoading) {
      await calculate();
    }
  }

  /// Limpa erro atual
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: CalorieCalculatorStatus.initial,
        error: null,
      );
    }
  }

  /// Limpa resultado atual
  void clearResult() {
    state = state.copyWith(
      status: CalorieCalculatorStatus.initial,
      output: null,
      error: null,
    );
  }

  /// Reseta calculadora para estado inicial
  void reset() {
    state = const CalorieState();
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
      updateInput(historicalResult.input);
      state = state.copyWith(output: historicalResult);
    }
  }

  /// Cria input pré-configurado para diferentes cenários
  void loadPreset(CaloriePreset preset) {
    CalorieInput presetInput;

    switch (preset) {
      case CaloriePreset.adultDogNormal:
        presetInput = const CalorieInput(
          species: AnimalSpecies.dog,
          weight: 25.0,
          age: 36, // 3 anos
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
        );
        break;
      case CaloriePreset.adultCatNormal:
        presetInput = const CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.5,
          age: 36, // 3 anos
          physiologicalState: PhysiologicalState.normal,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.ideal,
        );
        break;
      case CaloriePreset.puppyGrowth:
        presetInput = const CalorieInput(
          species: AnimalSpecies.dog,
          weight: 8.0,
          age: 6, // 6 meses
          physiologicalState: PhysiologicalState.juvenile,
          activityLevel: ActivityLevel.active,
          bodyConditionScore: BodyConditionScore.ideal,
        );
        break;
      case CaloriePreset.seniorDog:
        presetInput = const CalorieInput(
          species: AnimalSpecies.dog,
          weight: 20.0,
          age: 96, // 8 anos
          physiologicalState: PhysiologicalState.senior,
          activityLevel: ActivityLevel.light,
          bodyConditionScore: BodyConditionScore.ideal,
        );
        break;
      case CaloriePreset.lactatingQueen:
        presetInput = const CalorieInput(
          species: AnimalSpecies.cat,
          weight: 4.0,
          age: 24, // 2 anos
          physiologicalState: PhysiologicalState.lactating,
          activityLevel: ActivityLevel.moderate,
          bodyConditionScore: BodyConditionScore.ideal,
          numberOfOffspring: 4,
        );
        break;
    }

    updateInput(presetInput);
  }

  /// Salva cálculo atual como favorito (em implementação futura)
  void saveAsFavorite() {
    if (state.hasResult) {}
  }
}

/// Presets comuns para facilitar uso
enum CaloriePreset {
  adultDogNormal,
  adultCatNormal,
  puppyGrowth,
  seniorDog,
  lactatingQueen,
}

/// Provider da estratégia de cálculo calórico
final calorieCalculatorStrategyProvider = Provider<CalorieCalculatorStrategy>((
  ref,
) {
  return CalorieCalculatorStrategy();
});

/// Provider principal da calculadora de necessidades calóricas
final calorieProvider = StateNotifierProvider<CalorieNotifier, CalorieState>((
  ref,
) {
  final strategy = ref.watch(calorieCalculatorStrategyProvider);
  return CalorieNotifier(strategy);
});

/// Providers de conveniência para componentes específicos

/// Provider do estado de entrada
final calorieInputProvider = Provider<CalorieInput>((ref) {
  return ref.watch(calorieProvider).input;
});

/// Provider do resultado
final calorieOutputProvider = Provider<CalorieOutput?>((ref) {
  return ref.watch(calorieProvider).output;
});

/// Provider do status de loading
final calorieLoadingProvider = Provider<bool>((ref) {
  return ref.watch(calorieProvider).isLoading;
});

/// Provider de erros
final calorieErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(calorieProvider);
  return state.hasError ? state.error : null;
});

/// Provider de erros de validação
final calorieValidationErrorsProvider = Provider<List<String>>((ref) {
  return ref.watch(calorieProvider).validationErrors;
});

/// Provider indicando se pode calcular
final calorieCanCalculateProvider = Provider<bool>((ref) {
  return ref.watch(calorieProvider).canCalculate;
});

/// Provider do histórico
final calorieHistoryProvider = Provider<List<CalorieOutput>>((ref) {
  return ref.watch(calorieProvider).history;
});

/// Provider do step atual
final calorieCurrentStepProvider = Provider<int>((ref) {
  return ref.watch(calorieProvider).currentStep;
});

/// Provider indicando se pode avançar para próximo step
/// Optimized to watch state instead of calling method repeatedly
final calorieCanProceedProvider = Provider<bool>((ref) {
  final state = ref.watch(calorieProvider);

  switch (state.currentStep) {
    case 0: // Informações básicas
      return state.input.weight > 0 && state.input.age >= 0;
    case 1: // Estado fisiológico
      return (!state.input.isLactating ||
          state.input.numberOfOffspring != null);
    case 2: // Atividade e condição corporal
      return true; // BodyConditionScore is non-nullable enum
    case 3: // Condições especiais
      return true; // Sempre pode prosseguir (campos opcionais)
    case 4: // Revisão
      return state.canCalculate;
    default:
      return false;
  }
});

/// Provider de sugestões baseadas na entrada atual
final calorieSuggestionsProvider = Provider<List<String>>((ref) {
  final input = ref.watch(calorieInputProvider);
  final suggestions = <String>[];
  if (input.species == AnimalSpecies.cat && input.weight > 6) {
    suggestions.add(
      '⚠️ Peso elevado para gatos - considere avaliação veterinária',
    );
  } else if (input.species == AnimalSpecies.dog && input.weight < 2) {
    suggestions.add(
      '💡 Para cães pequenos, monitore alimentação mais frequentemente',
    );
  }
  if (input.age < 6) {
    suggestions.add(
      '🍼 Filhotes necessitam alimentação mais frequente (3-4x/dia)',
    );
  } else if (input.age > 84) {
    suggestions.add('👴 Animais idosos podem precisar de dieta especial');
  }
  if (input.isPregnant) {
    suggestions.add('🤰 Aumente calorias gradualmente durante gestação');
  } else if (input.isLactating) {
    suggestions.add('🤱 Ofereça alimentação livre durante lactação');
  }
  if (input.bodyConditionScore == BodyConditionScore.overweight) {
    suggestions.add('⚖️ Considere programa de perda de peso supervisionado');
  } else if (input.bodyConditionScore == BodyConditionScore.underweight) {
    suggestions.add(
      '🍽️ Aumente frequência de refeições e monitorar ganho de peso',
    );
  }
  if (input.medicalCondition != MedicalCondition.none) {
    suggestions.add(
      '🏥 Consulte veterinário para dieta terapêutica específica',
    );
  }
  if (input.idealWeight == null &&
      input.bodyConditionScore != BodyConditionScore.ideal) {
    suggestions.add('🎯 Informe peso ideal para cálculos mais precisos');
  }

  if (input.breed == null || input.breed!.isEmpty) {
    suggestions.add('🐕 Informe raça para recomendações mais específicas');
  }

  return suggestions;
});

/// Provider com estatísticas do histórico
final calorieHistoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final history = ref.watch(calorieHistoryProvider);

  if (history.isEmpty) {
    return {'count': 0};
  }

  final derValues =
      history.map((result) => result.dailyEnergyRequirement).toList();
  final avgDer = derValues.reduce((a, b) => a + b) / derValues.length;

  final rerValues =
      history.map((result) => result.restingEnergyRequirement).toList();
  final avgRer = rerValues.reduce((a, b) => a + b) / rerValues.length;

  final weights = history.map((result) => result.input.weight).toList();
  final avgWeight = weights.reduce((a, b) => a + b) / weights.length;

  return {
    'count': history.length,
    'averageDer': avgDer,
    'averageRer': avgRer,
    'averageWeight': avgWeight,
    'latestDer': derValues.last,
    'latestRer': rerValues.last,
    'calorieRange':
        '${derValues.reduce((a, b) => a < b ? a : b).round()}-${derValues.reduce((a, b) => a > b ? a : b).round()} kcal/dia',
    'trend':
        derValues.length > 1
            ? derValues.last - derValues[derValues.length - 2]
            : 0,
  };
});

/// Provider de classificação de necessidades calóricas
final calorieNeedsClassificationProvider = Provider<String>((ref) {
  final output = ref.watch(calorieOutputProvider);
  if (output == null) return 'N/A';
  return output.calorieNeedsClassification;
});

/// Provider indicando se há alertas críticos
final calorieCriticalAlertsProvider = Provider<bool>((ref) {
  final output = ref.watch(calorieOutputProvider);
  if (output == null) return false;
  return output.requiresSpecializedMonitoring;
});
