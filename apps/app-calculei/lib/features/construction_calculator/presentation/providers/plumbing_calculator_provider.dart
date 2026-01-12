import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/plumbing_calculation.dart';
import '../../domain/usecases/calculate_plumbing_usecase.dart';

part 'plumbing_calculator_provider.g.dart';

/// Provider for CalculatePlumbingUseCase
@riverpod
CalculatePlumbingUseCase calculatePlumbingUseCase(Ref ref) {
  return const CalculatePlumbingUseCase();
}

/// State notifier for plumbing calculator
@riverpod
class PlumbingCalculator extends _$PlumbingCalculator {
  @override
  PlumbingCalculation build() {
    return PlumbingCalculation.empty();
  }

  /// Calculate plumbing pipes and materials
  Future<void> calculate({
    required String systemType,
    required String pipeDiameter,
    required double totalLength,
    int numberOfElbows = 0,
    int numberOfTees = 0,
    int numberOfCouplings = 0,
  }) async {
    final useCase = ref.read(calculatePlumbingUseCaseProvider);

    final params = CalculatePlumbingParams(
      systemType: systemType,
      pipeDiameter: pipeDiameter,
      totalLength: totalLength,
      numberOfElbows: numberOfElbows,
      numberOfTees: numberOfTees,
      numberOfCouplings: numberOfCouplings,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = PlumbingCalculation.empty();
  }
}
