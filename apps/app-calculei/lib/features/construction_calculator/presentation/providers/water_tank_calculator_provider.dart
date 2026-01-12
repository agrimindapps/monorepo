import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/water_tank_calculation.dart';
import '../../domain/usecases/calculate_water_tank_usecase.dart';

part 'water_tank_calculator_provider.g.dart';

/// Provider for CalculateWaterTankUseCase
@riverpod
CalculateWaterTankUseCase calculateWaterTankUseCase(Ref ref) {
  return const CalculateWaterTankUseCase();
}

/// State notifier for water tank calculator
@riverpod
class WaterTankCalculator extends _$WaterTankCalculator {
  @override
  WaterTankCalculation build() {
    return WaterTankCalculation.empty();
  }

  /// Calculate water tank capacity
  Future<void> calculate({
    required int numberOfPeople,
    double dailyConsumption = 150.0,
    int reserveDays = 2,
    String tankType = 'Polietileno',
  }) async {
    final useCase = ref.read(calculateWaterTankUseCaseProvider);

    final params = CalculateWaterTankParams(
      numberOfPeople: numberOfPeople,
      dailyConsumption: dailyConsumption,
      reserveDays: reserveDays,
      tankType: tankType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = WaterTankCalculation.empty();
  }
}
