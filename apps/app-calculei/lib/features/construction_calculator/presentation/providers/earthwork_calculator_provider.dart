import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/earthwork_calculation.dart';
import '../../domain/usecases/calculate_earthwork_usecase.dart';

part 'earthwork_calculator_provider.g.dart';

/// Provider for CalculateEarthworkUseCase
@riverpod
CalculateEarthworkUseCase calculateEarthworkUseCase(Ref ref) {
  return const CalculateEarthworkUseCase();
}

/// State notifier for earthwork calculator
@riverpod
class EarthworkCalculator extends _$EarthworkCalculator {
  @override
  EarthworkCalculation build() {
    return EarthworkCalculation.empty();
  }

  /// Calculate earthwork volume and logistics
  Future<void> calculate({
    required double length,
    required double width,
    required double depth,
    String operationType = 'Escavação',
    String soilType = 'Areia',
  }) async {
    final useCase = ref.read(calculateEarthworkUseCaseProvider);

    final params = CalculateEarthworkParams(
      length: length,
      width: width,
      depth: depth,
      operationType: operationType,
      soilType: soilType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = EarthworkCalculation.empty();
  }
}
