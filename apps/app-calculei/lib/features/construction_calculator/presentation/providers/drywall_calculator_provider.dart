import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/drywall_calculation.dart';
import '../../domain/usecases/calculate_drywall_usecase.dart';

part 'drywall_calculator_provider.g.dart';

/// Provider for CalculateDrywallUseCase
@riverpod
CalculateDrywallUseCase calculateDrywallUseCase(Ref ref) {
  return const CalculateDrywallUseCase();
}

/// State notifier for drywall calculator
@riverpod
class DrywallCalculator extends _$DrywallCalculator {
  @override
  DrywallCalculation build() {
    return DrywallCalculation.empty();
  }

  /// Calculate drywall materials
  Future<void> calculate({
    required double length,
    required double height,
    String wallType = 'Simples',
  }) async {
    final useCase = ref.read(calculateDrywallUseCaseProvider);

    final params = CalculateDrywallParams(
      length: length,
      height: height,
      wallType: wallType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = DrywallCalculation.empty();
  }
}
