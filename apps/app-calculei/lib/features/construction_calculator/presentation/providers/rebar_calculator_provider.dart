import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/rebar_calculation.dart';
import '../../domain/usecases/calculate_rebar_usecase.dart';

part 'rebar_calculator_provider.g.dart';

/// Provider for CalculateRebarUseCase
@riverpod
CalculateRebarUseCase calculateRebarUseCase(Ref ref) {
  return const CalculateRebarUseCase();
}

/// State notifier for rebar calculator
@riverpod
class RebarCalculator extends _$RebarCalculator {
  @override
  RebarCalculation build() {
    return RebarCalculation.empty();
  }

  /// Calculate rebar (steel reinforcement) quantities
  Future<void> calculate({
    required String structureType,
    required double concreteVolume,
    String rebarDiameter = '8mm',
  }) async {
    final useCase = ref.read(calculateRebarUseCaseProvider);

    final params = CalculateRebarParams(
      structureType: structureType,
      concreteVolume: concreteVolume,
      rebarDiameter: rebarDiameter,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = RebarCalculation.empty();
  }
}
