import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/electrical_calculation.dart';
import '../../domain/usecases/calculate_electrical_usecase.dart';

part 'electrical_calculator_provider.g.dart';

/// Provider for CalculateElectricalUseCase
@riverpod
CalculateElectricalUseCase calculateElectricalUseCase(Ref ref) {
  return const CalculateElectricalUseCase();
}

/// State notifier for electrical calculator
@riverpod
class ElectricalCalculator extends _$ElectricalCalculator {
  @override
  ElectricalCalculation build() {
    return ElectricalCalculation.empty();
  }

  /// Calculate electrical installation requirements
  Future<void> calculate({
    required double totalPower,
    required double voltage,
    String circuitType = 'Monofásico',
    double cableLength = 10.0,
    int numberOfCircuits = 1,
  }) async {
    final useCase = ref.read(calculateElectricalUseCaseProvider);

    final params = CalculateElectricalParams(
      totalPower: totalPower,
      voltage: voltage,
      circuitType: circuitType,
      cableLength: cableLength,
      numberOfCircuits: numberOfCircuits,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = ElectricalCalculation.empty();
  }
}
