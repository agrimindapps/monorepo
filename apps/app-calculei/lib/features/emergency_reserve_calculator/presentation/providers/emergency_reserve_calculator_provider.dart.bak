// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:app_calculei/core/di/injection.dart';
import '../../domain/entities/emergency_reserve_calculation.dart';
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

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateEmergencyReserveUseCase
@riverpod
CalculateEmergencyReserveUseCase calculateEmergencyReserveUseCase(
  CalculateEmergencyReserveUseCaseRef ref,
) {
  return getIt<CalculateEmergencyReserveUseCase>();
}

/// Provider for SaveEmergencyReserveCalculationUseCase
@riverpod
SaveEmergencyReserveCalculationUseCase saveEmergencyReserveCalculationUseCase(
  SaveEmergencyReserveCalculationUseCaseRef ref,
) {
  return getIt<SaveEmergencyReserveCalculationUseCase>();
}

/// Provider for GetEmergencyReserveCalculationHistoryUseCase
@riverpod
GetEmergencyReserveCalculationHistoryUseCase
    getEmergencyReserveCalculationHistoryUseCase(
  GetEmergencyReserveCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetEmergencyReserveCalculationHistoryUseCase>();
}
