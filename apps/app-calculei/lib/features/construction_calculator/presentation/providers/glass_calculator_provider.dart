import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/glass_calculation.dart';
import '../../domain/usecases/calculate_glass_usecase.dart';

part 'glass_calculator_provider.g.dart';

/// Provider for CalculateGlassUseCase
@riverpod
CalculateGlassUseCase calculateGlassUseCase(Ref ref) {
  return const CalculateGlassUseCase();
}

/// State notifier for glass calculator
@riverpod
class GlassCalculator extends _$GlassCalculator {
  @override
  GlassCalculation build() {
    return GlassCalculation.empty();
  }

  /// Calculate glass area and weight
  Future<void> calculate({
    required double width,
    required double height,
    String glassType = 'Comum',
    int glassThickness = 6,
    int numberOfPanels = 1,
  }) async {
    final useCase = ref.read(calculateGlassUseCaseProvider);

    final params = CalculateGlassParams(
      width: width,
      height: height,
      glassType: glassType,
      glassThickness: glassThickness,
      numberOfPanels: numberOfPanels,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = GlassCalculation.empty();
  }
}
