import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/flooring_calculation.dart';
import '../../domain/usecases/calculate_flooring_usecase.dart';

part 'flooring_calculator_provider.g.dart';

/// Provider for CalculateFlooringUseCase
@riverpod
CalculateFlooringUseCase calculateFlooringUseCase(Ref ref) {
  return const CalculateFlooringUseCase();
}

/// State notifier for flooring calculator
@riverpod
class FlooringCalculator extends _$FlooringCalculator {
  @override
  FlooringCalculation build() {
    return FlooringCalculation.empty();
  }

  /// Calculate flooring materials
  Future<void> calculate({
    required double roomLength,
    required double roomWidth,
    double tileLength = 60,
    double tileWidth = 60,
    int tilesPerBox = 6,
    double wastePercentage = 10,
    String flooringType = 'Porcelanato',
  }) async {
    final useCase = ref.read(calculateFlooringUseCaseProvider);

    final params = CalculateFlooringParams(
      roomLength: roomLength,
      roomWidth: roomWidth,
      tileLength: tileLength,
      tileWidth: tileWidth,
      tilesPerBox: tilesPerBox,
      wastePercentage: wastePercentage,
      flooringType: flooringType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = FlooringCalculation.empty();
  }
}
