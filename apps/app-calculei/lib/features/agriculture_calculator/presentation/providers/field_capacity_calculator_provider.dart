import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/field_capacity_calculation.dart';
import '../../domain/usecases/calculate_field_capacity_usecase.dart';

part 'field_capacity_calculator_provider.g.dart';

/// Provider for CalculateFieldCapacityUseCase
@riverpod
CalculateFieldCapacityUseCase calculateFieldCapacityUseCase(Ref ref) {
  return const CalculateFieldCapacityUseCase();
}

/// State notifier for field capacity calculator
@riverpod
class FieldCapacityCalculator extends _$FieldCapacityCalculator {
  @override
  FieldCapacityCalculation build() {
    return FieldCapacityCalculation.empty();
  }

  /// Calculate field capacity
  Future<void> calculate({
    required double workingWidth,
    required double workingSpeed,
    double? fieldEfficiency,
    String operationType = 'Preparo',
  }) async {
    final useCase = ref.read(calculateFieldCapacityUseCaseProvider);

    final params = CalculateFieldCapacityParams(
      workingWidth: workingWidth,
      workingSpeed: workingSpeed,
      fieldEfficiency: fieldEfficiency,
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
    state = FieldCapacityCalculation.empty();
  }
}
