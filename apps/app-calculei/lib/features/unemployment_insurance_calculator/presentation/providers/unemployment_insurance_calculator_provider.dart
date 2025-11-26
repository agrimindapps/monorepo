import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/unemployment_insurance_local_datasource.dart';
import '../../data/repositories/unemployment_insurance_repository_impl.dart';
import '../../domain/entities/unemployment_insurance_calculation.dart';
import '../../domain/repositories/unemployment_insurance_repository.dart';
import '../../domain/usecases/calculate_unemployment_insurance_usecase.dart';
import '../../domain/usecases/get_unemployment_insurance_calculation_history_usecase.dart';
import '../../domain/usecases/save_unemployment_insurance_calculation_usecase.dart';

part 'unemployment_insurance_calculator_provider.g.dart';

/// State for unemployment insurance calculator
///
/// Immutable state following Clean Architecture principles
class UnemploymentInsuranceCalculatorState {
  final UnemploymentInsuranceCalculation? calculation;
  final List<UnemploymentInsuranceCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const UnemploymentInsuranceCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  UnemploymentInsuranceCalculatorState copyWith({
    UnemploymentInsuranceCalculation? calculation,
    List<UnemploymentInsuranceCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return UnemploymentInsuranceCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing unemployment insurance calculator state
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for state management
/// - Delegates business logic to use cases
@riverpod
class UnemploymentInsuranceCalculatorNotifier
    extends _$UnemploymentInsuranceCalculatorNotifier {
  @override
  UnemploymentInsuranceCalculatorState build() {
    // Initialize with empty state
    return const UnemploymentInsuranceCalculatorState();
  }

  /// Calculates unemployment insurance based on parameters
  Future<void> calculate(CalculateUnemploymentInsuranceParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateUnemploymentInsuranceUseCaseProvider);
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
  Future<void> _saveCalculation(
      UnemploymentInsuranceCalculation calculation) async {
    final saveUseCase =
        ref.read(saveUnemploymentInsuranceCalculationUseCaseProvider);
    await saveUseCase(calculation);

    // Refresh history after saving
    await loadHistory();
  }

  /// Loads calculation history
  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase =
        ref.read(getUnemploymentInsuranceCalculationHistoryUseCaseProvider);
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
    state = const UnemploymentInsuranceCalculatorState();
  }

  /// Sets a specific calculation from history as current
  void setCalculation(UnemploymentInsuranceCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

// ========== DATA LAYER PROVIDERS ==========

/// Provider for UnemploymentInsuranceLocalDataSource
@riverpod
UnemploymentInsuranceLocalDataSource unemploymentInsuranceLocalDataSource(
  Ref ref,
) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).requireValue;
  return UnemploymentInsuranceLocalDataSourceImpl(sharedPrefs);
}

/// Provider for UnemploymentInsuranceRepository
@riverpod
UnemploymentInsuranceRepository unemploymentInsuranceRepository(
  Ref ref,
) {
  final localDataSource =
      ref.watch(unemploymentInsuranceLocalDataSourceProvider);
  return UnemploymentInsuranceRepositoryImpl(localDataSource);
}

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateUnemploymentInsuranceUseCase
@riverpod
CalculateUnemploymentInsuranceUseCase calculateUnemploymentInsuranceUseCase(
  Ref ref,
) {
  return CalculateUnemploymentInsuranceUseCase();
}

/// Provider for SaveUnemploymentInsuranceCalculationUseCase
@riverpod
SaveUnemploymentInsuranceCalculationUseCase
    saveUnemploymentInsuranceCalculationUseCase(
  Ref ref,
) {
  final repository = ref.watch(unemploymentInsuranceRepositoryProvider);
  return SaveUnemploymentInsuranceCalculationUseCase(repository);
}

/// Provider for GetUnemploymentInsuranceCalculationHistoryUseCase
@riverpod
GetUnemploymentInsuranceCalculationHistoryUseCase
    getUnemploymentInsuranceCalculationHistoryUseCase(
  Ref ref,
) {
  final repository = ref.watch(unemploymentInsuranceRepositoryProvider);
  return GetUnemploymentInsuranceCalculationHistoryUseCase(repository);
}
