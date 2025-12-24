import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/vacation_calculation.dart';
import '../../domain/usecases/calculate_vacation_usecase.dart';

part 'vacation_calculator_provider.g.dart';

/// Provider for CalculateVacationUseCase
@riverpod
CalculateVacationUseCase calculateVacationUseCase(
  Ref ref,
) {
  return CalculateVacationUseCase();
}

/// State notifier for vacation calculator
@riverpod
class VacationCalculator extends _$VacationCalculator {
  
  VacationCalculation build() {
    return VacationCalculation.empty();
  }

  /// Calculate vacation pay
  Future<void> calculate({
    required double grossSalary,
    required int vacationDays,
    required bool sellVacationDays,
  }) async {
    final useCase = ref.read(calculateVacationUseCaseProvider);

    final params = CalculateVacationParams(
      grossSalary: grossSalary,
      vacationDays: vacationDays,
      sellVacationDays: sellVacationDays,
    );

    final result = await useCase(params);

    result.fold(
      (failure) => throw failure,
      (calculation) => state = calculation,
    );
  }

  /// Reset calculation
  void reset() {
    state = VacationCalculation.empty();
  }
}
