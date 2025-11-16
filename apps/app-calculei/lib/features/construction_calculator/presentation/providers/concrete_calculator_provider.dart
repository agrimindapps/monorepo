import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'concrete_calculator_provider.g.dart';

/// Provider for calculate concrete use case
@riverpod
CalculateConcreteUseCase calculateConcreteUseCase(
  CalculateConcreteUseCaseRef ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateConcreteUseCase(repository: repository);
}

/// State notifier for concrete calculator
@riverpod
class ConcreteCalculator extends _$ConcreteCalculator {
  @override
  ConcreteCalculation? build() {
    return null; // Initial empty state
  }

  /// Calculate concrete
  Future<void> calculate(CalculateConcreteParams params) async {
    // Set loading state (AsyncValue will handle this automatically)
    state = null;

    final useCase = ref.read(calculateConcreteUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        // On error, throw the failure (AsyncValue will catch it)
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
