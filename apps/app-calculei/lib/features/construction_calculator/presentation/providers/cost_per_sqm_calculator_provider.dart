import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'cost_per_sqm_calculator_provider.g.dart';

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
  CostPerSquareMeterCalculation? build() {
    return null; // Initial empty state
  }

  /// Calculate cost per square meter
  Future<void> calculate(CalculateCostPerSqmParams params) async {
    state = null;

    final useCase = ref.read(calculateCostPerSqmUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        throw failure;
      },
      (calculation) {
        state = calculation;
      },
    );
  }

  /// Clear calculation
  void clearCalculation() {
    state = null;
  }
}
