import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/mortar_calculation.dart';
import '../../domain/usecases/calculate_mortar_usecase.dart';

part 'mortar_calculator_provider.g.dart';

/// Provider for CalculateMortarUseCase
@riverpod
CalculateMortarUseCase calculateMortarUseCase(Ref ref) {
  return const CalculateMortarUseCase();
}

/// State notifier for mortar calculator
@riverpod
class MortarCalculator extends _$MortarCalculator {
  @override
  MortarCalculation build() {
    return MortarCalculation.empty();
  }

  /// Calculate mortar volume and materials
  Future<void> calculate({
    required double area,
    required double thickness,
    String mortarType = 'Assentamento',
  }) async {
    final useCase = ref.read(calculateMortarUseCaseProvider);

    final params = CalculateMortarParams(
      area: area,
      thickness: thickness,
      mortarType: mortarType,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = MortarCalculation.empty();
  }
}
