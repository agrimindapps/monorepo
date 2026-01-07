import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/brick_calculation.dart';
import '../../domain/usecases/calculate_brick_usecase.dart';

part 'brick_calculator_provider.g.dart';

/// Provider for CalculateBrickUseCase
@riverpod
CalculateBrickUseCase calculateBrickUseCase(Ref ref) {
  return const CalculateBrickUseCase();
}

/// State notifier for brick calculator
@riverpod
class BrickCalculator extends _$BrickCalculator {
  @override
  BrickCalculation build() {
    return BrickCalculation.empty();
  }

  /// Calculate bricks/blocks for wall construction
  Future<void> calculate({
    required double wallLength,
    required double wallHeight,
    double openingsArea = 0,
    BrickType brickType = BrickType.ceramic6Holes,
    double wastePercentage = 5,
  }) async {
    final useCase = ref.read(calculateBrickUseCaseProvider);

    final params = CalculateBrickParams(
      wallLength: wallLength,
      wallHeight: wallHeight,
      openingsArea: openingsArea,
      brickType: brickType,
      wastePercentage: wastePercentage,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = BrickCalculation.empty();
  }
}
