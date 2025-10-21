import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/vacation_calculation.dart';
import '../../domain/usecases/calculate_vacation_usecase.dart';
import '../../domain/usecases/save_calculation_usecase.dart';
import '../../domain/usecases/get_calculation_history_usecase.dart';

part 'vacation_calculator_provider.g.dart';

/// Provider for CalculateVacationUseCase
@riverpod
CalculateVacationUseCase calculateVacationUseCase(
  CalculateVacationUseCaseRef ref,
) {
  return getIt<CalculateVacationUseCase>();
}

/// Provider for SaveCalculationUseCase
@riverpod
SaveCalculationUseCase saveCalculationUseCase(SaveCalculationUseCaseRef ref) {
  return getIt<SaveCalculationUseCase>();
}

/// Provider for GetCalculationHistoryUseCase
@riverpod
GetCalculationHistoryUseCase getCalculationHistoryUseCase(
  GetCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetCalculationHistoryUseCase>();
}

/// State notifier for vacation calculator
@riverpod
class VacationCalculator extends _$VacationCalculator {
  @override
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
      (failure) {
        // Keep current state on error (UI will handle error display)
        throw failure;
      },
      (calculation) {
        state = calculation;

        // Auto-save to history
        _saveToHistory(calculation);
      },
    );
  }

  /// Save calculation to history
  Future<void> _saveToHistory(VacationCalculation calculation) async {
    final useCase = ref.read(saveCalculationUseCaseProvider);
    await useCase(calculation);

    // Invalidate history to trigger reload
    ref.invalidate(vacationHistoryProvider);
  }

  /// Reset calculation
  void reset() {
    state = VacationCalculation.empty();
  }
}

/// Provider for calculation history
@riverpod
class VacationHistory extends _$VacationHistory {
  @override
  Future<List<VacationCalculation>> build() async {
    final useCase = ref.watch(getCalculationHistoryUseCaseProvider);

    final result = await useCase(limit: 20);

    return result.fold(
      (failure) => throw failure,
      (history) => history,
    );
  }

  /// Refresh history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getCalculationHistoryUseCaseProvider);
      final result = await useCase(limit: 20);

      return result.fold(
        (failure) => throw failure,
        (history) => history,
      );
    });
  }
}
