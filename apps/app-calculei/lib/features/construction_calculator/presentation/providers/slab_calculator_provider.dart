import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/slab_calculation.dart';
import '../../domain/usecases/calculate_slab_usecase.dart';

part 'slab_calculator_provider.g.dart';

/// Provider for CalculateSlabUseCase
@riverpod
CalculateSlabUseCase calculateSlabUseCase(Ref ref) {
  return const CalculateSlabUseCase();
}

/// State notifier for slab calculator
@riverpod
class SlabCalculator extends _$SlabCalculator {
  @override
  SlabCalculation build() {
    return SlabCalculation.empty();
  }

  /// Calculate slab volume and materials
  Future<void> calculate({
    required double length,
    required double width,
    required double thickness,
    String slabType = 'Maciça',
  }) async {
    final useCase = ref.read(calculateSlabUseCaseProvider);

    final params = CalculateSlabParams(
      length: length,
      width: width,
      thickness: thickness,
      slabType: slabType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = SlabCalculation.empty();
  }
}
