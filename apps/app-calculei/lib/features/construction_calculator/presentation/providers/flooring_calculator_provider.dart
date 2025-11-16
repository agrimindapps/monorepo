import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'flooring_calculator_provider.g.dart';

/// Provider for calculate flooring use case
@riverpod
CalculateFlooringUseCase calculateFlooringUseCase(
  CalculateFlooringUseCaseRef ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateFlooringUseCase(repository: repository);
}

/// State notifier for flooring calculator
@riverpod
class FlooringCalculator extends _$FlooringCalculator {
  @override
  FlooringCalculation? build() {
    return null; // Initial empty state
  }

  /// Calculate flooring
  Future<void> calculate(CalculateFlooringParams params) async {
    state = null;

    final useCase = ref.read(calculateFlooringUseCaseProvider);
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
