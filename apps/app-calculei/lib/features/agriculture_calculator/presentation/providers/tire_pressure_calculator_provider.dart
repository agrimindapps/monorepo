import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tire_pressure_calculation.dart';
import '../../domain/usecases/calculate_tire_pressure_usecase.dart';

part 'tire_pressure_calculator_provider.g.dart';

/// Provider for CalculateTirePressureUseCase
@riverpod
CalculateTirePressureUseCase calculateTirePressureUseCase(Ref ref) {
  return const CalculateTirePressureUseCase();
}

/// State notifier for tire pressure calculator
@riverpod
class TirePressureCalculator extends _$TirePressureCalculator {
  @override
  TirePressureCalculation build() {
    return TirePressureCalculation.empty();
  }

  /// Calculate tire pressure
  Future<void> calculate({
    required String tireType,
    required double axleLoad,
    required String tireSize,
    String operationType = 'Campo',
  }) async {
    final useCase = ref.read(calculateTirePressureUseCaseProvider);

    final params = CalculateTirePressureParams(
      tireType: tireType,
      axleLoad: axleLoad,
      tireSize: tireSize,
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
    state = TirePressureCalculation.empty();
  }
}
