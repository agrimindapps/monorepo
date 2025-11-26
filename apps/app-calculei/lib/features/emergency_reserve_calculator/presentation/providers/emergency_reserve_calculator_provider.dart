import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/emergency_reserve_local_datasource.dart';
import '../../data/repositories/emergency_reserve_repository_impl.dart';
import '../../domain/entities/emergency_reserve_calculation.dart';
import '../../domain/repositories/emergency_reserve_repository.dart';
import '../../domain/usecases/calculate_emergency_reserve_usecase.dart';
import '../../domain/usecases/get_emergency_reserve_calculation_history_usecase.dart';
import '../../domain/usecases/save_emergency_reserve_calculation_usecase.dart';

part 'emergency_reserve_calculator_provider.g.dart';

/// State for emergency reserve calculator
///
/// Immutable state following Clean Architecture principles
class EmergencyReserveCalculatorState {
  final EmergencyReserveCalculation? calculation;
  final List<EmergencyReserveCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const EmergencyReserveCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  EmergencyReserveCalculatorState copyWith({
    EmergencyReserveCalculation? calculation,
    List<EmergencyReserveCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return EmergencyReserveCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing emergency reserve calculator state
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for state management
/// - Delegates business logic to use cases
@riverpod
class EmergencyReserveCalculatorNotifier
    extends _$EmergencyReserveCalculatorNotifier {
  @override
  EmergencyReserveCalculatorState build() {
    // Initialize with empty state
    return const EmergencyReserveCalculatorState();
  }

  /// Calculates emergency reserve based on parameters
  Future<void> calculate(CalculateEmergencyReserveParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateEmergencyReserveUseCaseProvider);
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
      EmergencyReserveCalculation calculation) async {
    final saveUseCase = ref.read(saveEmergencyReserveCalculationUseCaseProvider);
    await saveUseCase(calculation);

    // Refresh history after saving
    await loadHistory();
  }

  /// Loads calculation history
  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase =
        ref.read(getEmergencyReserveCalculationHistoryUseCaseProvider);
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
    state = const EmergencyReserveCalculatorState();
  }

  /// Sets a specific calculation from history as current
  void setCalculation(EmergencyReserveCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

// ========== DATA LAYER PROVIDERS ==========

/// Provider for EmergencyReserveLocalDataSource
@riverpod
EmergencyReserveLocalDataSource emergencyReserveLocalDataSource(
  Ref ref,
) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider).requireValue;
  return EmergencyReserveLocalDataSourceImpl(sharedPrefs);
}

/// Provider for EmergencyReserveRepository
@riverpod
EmergencyReserveRepository emergencyReserveRepository(
  Ref ref,
) {
  final localDataSource = ref.watch(emergencyReserveLocalDataSourceProvider);
  return EmergencyReserveRepositoryImpl(localDataSource);
}

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateEmergencyReserveUseCase
@riverpod
CalculateEmergencyReserveUseCase calculateEmergencyReserveUseCase(
  Ref ref,
) {
  return CalculateEmergencyReserveUseCase();
}

/// Provider for SaveEmergencyReserveCalculationUseCase
@riverpod
SaveEmergencyReserveCalculationUseCase saveEmergencyReserveCalculationUseCase(
  Ref ref,
) {
  final repository = ref.watch(emergencyReserveRepositoryProvider);
  return SaveEmergencyReserveCalculationUseCase(repository);
}

/// Provider for GetEmergencyReserveCalculationHistoryUseCase
@riverpod
GetEmergencyReserveCalculationHistoryUseCase
    getEmergencyReserveCalculationHistoryUseCase(
  Ref ref,
) {
  final repository = ref.watch(emergencyReserveRepositoryProvider);
  return GetEmergencyReserveCalculationHistoryUseCase(repository);
}
