import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/roof_calculation.dart';
import '../../domain/usecases/calculate_roof_usecase.dart';

part 'roof_calculator_provider.g.dart';

/// Provider for CalculateRoofUseCase
@riverpod
CalculateRoofUseCase calculateRoofUseCase(Ref ref) {
  return const CalculateRoofUseCase();
}

/// State notifier for roof calculator
@riverpod
class RoofCalculator extends _$RoofCalculator {
  @override
  RoofCalculation build() {
    return RoofCalculation.empty();
  }

  /// Calculate roof area, tiles and materials
  Future<void> calculate({
    required double length,
    required double width,
    double roofSlope = 30.0,
    String roofType = 'Colonial',
  }) async {
    final useCase = ref.read(calculateRoofUseCaseProvider);

    final params = CalculateRoofParams(
      length: length,
      width: width,
      roofSlope: roofSlope,
      roofType: roofType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = RoofCalculation.empty();
  }
}
