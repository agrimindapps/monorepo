import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/index.dart';
import '../../domain/entities/index.dart';
import 'construction_calculator_providers.dart';

part 'paint_consumption_calculator_provider.g.dart';

/// Provider for calculate paint consumption use case
@riverpod
CalculatePaintConsumptionUseCase calculatePaintConsumptionUseCase(
  CalculatePaintConsumptionUseCaseRef ref,
) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculatePaintConsumptionUseCase(repository: repository);
}

/// State notifier for paint consumption calculator
@riverpod
class PaintConsumptionCalculator extends _$PaintConsumptionCalculator {
  @override
  PaintConsumptionCalculation? build() {
    return null; // Initial empty state
  }

  /// Calculate paint consumption
  Future<void> calculate(CalculatePaintConsumptionParams params) async {
    state = null;

    final useCase = ref.read(calculatePaintConsumptionUseCaseProvider);
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
