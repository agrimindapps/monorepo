import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/planter_setup_calculation.dart';
import '../../domain/usecases/calculate_planter_setup_usecase.dart';

part 'planter_setup_calculator_provider.g.dart';

/// Provider for CalculatePlanterSetupUseCase
@riverpod
CalculatePlanterSetupUseCase calculatePlanterSetupUseCase(Ref ref) {
  return const CalculatePlanterSetupUseCase();
}

/// State notifier for planter setup calculator
@riverpod
class PlanterSetupCalculator extends _$PlanterSetupCalculator {
  @override
  PlanterSetupCalculation build() {
    return PlanterSetupCalculation.empty();
  }

  /// Calculate planter setup and calibration
  Future<void> calculate({
    required String cropType,
    required double targetPopulation,
    required double rowSpacing,
    required double germination,
    int discHoles = 28,
  }) async {
    final useCase = ref.read(calculatePlanterSetupUseCaseProvider);

    final params = CalculatePlanterSetupParams(
      cropType: cropType,
      targetPopulation: targetPopulation,
      rowSpacing: rowSpacing,
      germination: germination,
      discHoles: discHoles,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = PlanterSetupCalculation.empty();
  }
}
