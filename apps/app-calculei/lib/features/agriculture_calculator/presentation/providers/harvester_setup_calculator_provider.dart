import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/harvester_setup_calculation.dart';
import '../../domain/usecases/calculate_harvester_setup_usecase.dart';

part 'harvester_setup_calculator_provider.g.dart';

/// Provider for CalculateHarvesterSetupUseCase
@riverpod
CalculateHarvesterSetupUseCase calculateHarvesterSetupUseCase(Ref ref) {
  return const CalculateHarvesterSetupUseCase();
}

/// State notifier for harvester setup calculator
@riverpod
class HarvesterSetupCalculator extends _$HarvesterSetupCalculator {
  @override
  HarvesterSetupCalculation build() {
    return HarvesterSetupCalculation.empty();
  }

  /// Calculate harvester setup and regulation
  Future<void> calculate({
    required String cropType,
    required double productivity,
    required double moisture,
    double harvestSpeed = 5.0,
    double platformWidth = 6.0,
  }) async {
    final useCase = ref.read(calculateHarvesterSetupUseCaseProvider);

    final params = CalculateHarvesterSetupParams(
      cropType: cropType,
      productivity: productivity,
      moisture: moisture,
      harvestSpeed: harvestSpeed,
      platformWidth: platformWidth,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = HarvesterSetupCalculation.empty();
  }
}
