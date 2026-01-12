import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tractor_ballast_calculation.dart';
import '../../domain/usecases/calculate_tractor_ballast_usecase.dart';

part 'tractor_ballast_calculator_provider.g.dart';

/// Provider for CalculateTractorBallastUseCase
@riverpod
CalculateTractorBallastUseCase calculateTractorBallastUseCase(Ref ref) {
  return const CalculateTractorBallastUseCase();
}

/// State notifier for tractor ballast calculator
@riverpod
class TractorBallastCalculator extends _$TractorBallastCalculator {
  @override
  TractorBallastCalculation build() {
    return TractorBallastCalculation.empty();
  }

  /// Calculate tractor ballast and weight distribution
  Future<void> calculate({
    required double tractorWeight,
    required String tractorType,
    required double implementWeight,
    required String operationType,
  }) async {
    final useCase = ref.read(calculateTractorBallastUseCaseProvider);

    final params = CalculateTractorBallastParams(
      tractorWeight: tractorWeight,
      tractorType: tractorType,
      implementWeight: implementWeight,
      operationType: operationType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = TractorBallastCalculation.empty();
  }
}
