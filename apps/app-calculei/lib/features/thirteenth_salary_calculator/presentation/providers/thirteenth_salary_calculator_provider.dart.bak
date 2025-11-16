// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:app_calculei/core/di/injection.dart';
import '../../domain/entities/thirteenth_salary_calculation.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';
import '../../domain/usecases/get_thirteenth_salary_calculation_history_usecase.dart';
import '../../domain/usecases/save_thirteenth_salary_calculation_usecase.dart';

part 'thirteenth_salary_calculator_provider.g.dart';

/// State for 13th salary calculator
///
/// Immutable state following Clean Architecture principles
class ThirteenthSalaryCalculatorState {
  final ThirteenthSalaryCalculation? calculation;
  final List<ThirteenthSalaryCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const ThirteenthSalaryCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  ThirteenthSalaryCalculatorState copyWith({
    ThirteenthSalaryCalculation? calculation,
    List<ThirteenthSalaryCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return ThirteenthSalaryCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing 13th salary calculator state
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for state management
/// - Delegates business logic to use cases
@riverpod
class ThirteenthSalaryCalculatorNotifier
    extends _$ThirteenthSalaryCalculatorNotifier {
  @override
  ThirteenthSalaryCalculatorState build() {
    // Initialize with empty state
    return const ThirteenthSalaryCalculatorState();
  }

  /// Calculates 13th salary based on parameters
  Future<void> calculate(CalculateThirteenthSalaryParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateThirteenthSalaryUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (calculation) {
        state = state.copyWith(
          isLoading: false,
          calculation: calculation,
          errorMessage: null,
        );

        // Auto-save calculation
        _saveCalculation(calculation);
      },
    );
  }

  /// Saves current calculation to history
  Future<void> _saveCalculation(ThirteenthSalaryCalculation calculation) async {
    final saveUseCase = ref.read(saveThirteenthSalaryCalculationUseCaseProvider);
    await saveUseCase(calculation);

    // Refresh history after saving
    await loadHistory();
  }

  /// Loads calculation history
  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase = ref.read(getThirteenthSalaryCalculationHistoryUseCaseProvider);
    final result = await useCase(limit: limit);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: failure.message,
      ),
      (history) => state = state.copyWith(
        isLoadingHistory: false,
        history: history,
        errorMessage: null,
      ),
    );
  }

  /// Clears current calculation
  void clearCalculation() {
    state = const ThirteenthSalaryCalculatorState();
  }

  /// Sets a specific calculation from history as current
  void setCalculation(ThirteenthSalaryCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateThirteenthSalaryUseCase
@riverpod
CalculateThirteenthSalaryUseCase calculateThirteenthSalaryUseCase(
  CalculateThirteenthSalaryUseCaseRef ref,
) {
  return getIt<CalculateThirteenthSalaryUseCase>();
}

/// Provider for SaveThirteenthSalaryCalculationUseCase
@riverpod
SaveThirteenthSalaryCalculationUseCase saveThirteenthSalaryCalculationUseCase(
  SaveThirteenthSalaryCalculationUseCaseRef ref,
) {
  return getIt<SaveThirteenthSalaryCalculationUseCase>();
}

/// Provider for GetThirteenthSalaryCalculationHistoryUseCase
@riverpod
GetThirteenthSalaryCalculationHistoryUseCase
    getThirteenthSalaryCalculationHistoryUseCase(
  GetThirteenthSalaryCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetThirteenthSalaryCalculationHistoryUseCase>();
}
