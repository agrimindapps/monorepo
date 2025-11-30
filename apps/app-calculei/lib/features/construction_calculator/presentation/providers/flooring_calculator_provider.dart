import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/index.dart';
import '../../domain/usecases/index.dart';
import 'construction_calculator_providers.dart';

part 'flooring_calculator_provider.g.dart';

/// State for flooring calculator
class FlooringCalculatorState {
  final FlooringCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  const FlooringCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  FlooringCalculatorState copyWith({
    FlooringCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FlooringCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for calculate flooring use case
@riverpod
CalculateFlooringUseCase calculateFlooringUseCase(
  Ref ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateFlooringUseCase(repository: repository);
}

/// State notifier for flooring calculator
@riverpod
class FlooringCalculator extends _$FlooringCalculator {
  @override
  FlooringCalculatorState build() {
    return const FlooringCalculatorState(); // Initial empty state
  }

  /// Calculate flooring
  Future<void> calculate(CalculateFlooringParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateFlooringUseCaseProvider);
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
    state = const FlooringCalculatorState();
  }
}
