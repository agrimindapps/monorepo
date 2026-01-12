import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/operational_cost_calculation.dart';
import '../../domain/usecases/calculate_operational_cost_usecase.dart';

part 'operational_cost_calculator_provider.g.dart';

/// Provider for CalculateOperationalCostUseCase
@riverpod
CalculateOperationalCostUseCase calculateOperationalCostUseCase(Ref ref) {
  return const CalculateOperationalCostUseCase();
}

/// State notifier for operational cost calculator
@riverpod
class OperationalCostCalculator extends _$OperationalCostCalculator {
  @override
  OperationalCostCalculation build() {
    return OperationalCostCalculation.empty();
  }

  /// Calculate operational cost
  Future<void> calculate({
    String operationType = 'Preparo',
    required double fuelConsumption,
    required double fuelPrice,
    required double laborHours,
    required double laborCost,
    required double machineryValue,
    required double usefulLife,
    required double maintenanceFactor,
    required double areaWorked,
  }) async {
    final useCase = ref.read(calculateOperationalCostUseCaseProvider);

    final params = CalculateOperationalCostParams(
      operationType: operationType,
      fuelConsumption: fuelConsumption,
      fuelPrice: fuelPrice,
      laborHours: laborHours,
      laborCost: laborCost,
      machineryValue: machineryValue,
      usefulLife: usefulLife,
      maintenanceFactor: maintenanceFactor,
      areaWorked: areaWorked,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = OperationalCostCalculation.empty();
  }
}
