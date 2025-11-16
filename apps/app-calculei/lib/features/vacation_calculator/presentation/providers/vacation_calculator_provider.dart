import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/vacation_local_datasource.dart';
import '../../data/repositories/vacation_repository_impl.dart';
import '../../domain/entities/vacation_calculation.dart';
import '../../domain/repositories/vacation_repository.dart';
import '../../domain/usecases/calculate_vacation_usecase.dart';
import '../../domain/usecases/save_calculation_usecase.dart';
import '../../domain/usecases/get_calculation_history_usecase.dart';

part 'vacation_calculator_provider.g.dart';

/// Provider for VacationLocalDataSource
@riverpod
VacationLocalDataSource vacationLocalDataSource(
  VacationLocalDataSourceRef ref,
) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).requireValue;
  return VacationLocalDataSourceImpl(sharedPrefs);
}

/// Provider for VacationRepository
@riverpod
VacationRepository vacationRepository(VacationRepositoryRef ref) {
  final localDataSource = ref.watch(vacationLocalDataSourceProvider);
  return VacationRepositoryImpl(localDataSource);
}

/// Provider for CalculateVacationUseCase
@riverpod
CalculateVacationUseCase calculateVacationUseCase(
  CalculateVacationUseCaseRef ref,
) {
  return const CalculateVacationUseCase();
}

/// Provider for SaveCalculationUseCase
@riverpod
SaveCalculationUseCase saveCalculationUseCase(SaveCalculationUseCaseRef ref) {
  final repository = ref.watch(vacationRepositoryProvider);
  return SaveCalculationUseCase(repository);
}

/// Provider for GetCalculationHistoryUseCase
@riverpod
GetCalculationHistoryUseCase getCalculationHistoryUseCase(
  GetCalculationHistoryUseCaseRef ref,
) {
  final repository = ref.watch(vacationRepositoryProvider);
  return GetCalculationHistoryUseCase(repository);
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
