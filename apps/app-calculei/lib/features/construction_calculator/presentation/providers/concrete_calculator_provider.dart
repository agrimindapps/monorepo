import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/index.dart';
import '../../domain/usecases/index.dart';
import 'construction_calculator_providers.dart';

part 'concrete_calculator_provider.g.dart';

/// State for concrete calculator
class ConcreteCalculatorState {
  final ConcreteCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  const ConcreteCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  ConcreteCalculatorState copyWith({
    ConcreteCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConcreteCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for calculate concrete use case
@riverpod
CalculateConcreteUseCase calculateConcreteUseCase(
  Ref ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateConcreteUseCase(repository: repository);
}

/// State notifier for concrete calculator
@riverpod
class ConcreteCalculator extends _$ConcreteCalculator {
  @override
  ConcreteCalculatorState build() {
    return const ConcreteCalculatorState(); // Initial empty state
  }

  /// Calculate concrete
  Future<void> calculate(CalculateConcreteParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateConcreteUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (calculation) {
        state = state.copyWith(
          isLoading: false,
          calculation: calculation,
          errorMessage: null,
        );
      },
    );
  }

  /// Clear calculation
  void clearCalculation() {
    state = const ConcreteCalculatorState();
  }
}
