import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'cost_per_sqm_calculator_provider.g.dart';

/// State for cost per sqm calculator
class CostPerSqmCalculatorState {
  final CostPerSquareMeterCalculation? calculation;
  final bool isLoading;
  final String? errorMessage;

  const CostPerSqmCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.errorMessage,
  });

  CostPerSqmCalculatorState copyWith({
    CostPerSquareMeterCalculation? calculation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CostPerSqmCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for calculate cost per sqm use case
@riverpod
CalculateCostPerSqmUseCase calculateCostPerSqmUseCase(
  CalculateCostPerSqmUseCaseRef ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateCostPerSqmUseCase(repository: repository);
}

/// State notifier for cost per square meter calculator
@riverpod
class CostPerSqmCalculator extends _$CostPerSqmCalculator {
  @override
  CostPerSqmCalculatorState build() {
    return const CostPerSqmCalculatorState(); // Initial empty state
  }

  /// Calculate cost per square meter
  Future<void> calculate(CalculateCostPerSqmParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateCostPerSqmUseCaseProvider);
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
    state = const CostPerSqmCalculatorState();
  }
}
