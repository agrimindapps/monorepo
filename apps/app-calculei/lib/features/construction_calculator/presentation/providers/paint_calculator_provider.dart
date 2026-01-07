import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/paint_calculation.dart';
import '../../domain/usecases/calculate_paint_usecase.dart';

part 'paint_calculator_provider.g.dart';

/// Provider for CalculatePaintUseCase
@riverpod
CalculatePaintUseCase calculatePaintUseCase(Ref ref) {
  return const CalculatePaintUseCase();
}

/// State notifier for paint calculator
@riverpod
class PaintCalculator extends _$PaintCalculator {
  @override
  PaintCalculation build() {
    return PaintCalculation.empty();
  }

  /// Calculate paint consumption
  Future<void> calculate({
    required double wallArea,
    double openingsArea = 0,
    int coats = 2,
    String paintType = 'Acrílica',
    double? customYield,
  }) async {
    final useCase = ref.read(calculatePaintUseCaseProvider);

    final params = CalculatePaintParams(
      wallArea: wallArea,
      openingsArea: openingsArea,
      coats: coats,
      paintType: paintType,
      customYield: customYield,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = PaintCalculation.empty();
  }
}
