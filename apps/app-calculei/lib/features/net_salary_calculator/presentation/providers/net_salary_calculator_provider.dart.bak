// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:app_calculei/core/di/injection.dart';
import '../../domain/entities/net_salary_calculation.dart';
import '../../domain/usecases/calculate_net_salary_usecase.dart';
import '../../domain/usecases/get_net_salary_calculation_history_usecase.dart';
import '../../domain/usecases/save_net_salary_calculation_usecase.dart';

part 'net_salary_calculator_provider.g.dart';

/// State for net salary calculator
///
/// Immutable state following Clean Architecture principles
class NetSalaryCalculatorState {
  final NetSalaryCalculation? calculation;
  final List<NetSalaryCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const NetSalaryCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  NetSalaryCalculatorState copyWith({
    NetSalaryCalculation? calculation,
    List<NetSalaryCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return NetSalaryCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing net salary calculator state
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for state management
/// - Delegates business logic to use cases
@riverpod
class NetSalaryCalculatorNotifier extends _$NetSalaryCalculatorNotifier {
  @override
  NetSalaryCalculatorState build() {
    // Initialize with empty state
    return const NetSalaryCalculatorState();
  }

  /// Calculates net salary based on parameters
  Future<void> calculate(CalculateNetSalaryParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateNetSalaryUseCaseProvider);
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
  Future<void> _saveCalculation(NetSalaryCalculation calculation) async {
    final saveUseCase = ref.read(saveNetSalaryCalculationUseCaseProvider);
    await saveUseCase(calculation);

    // Refresh history after saving
    await loadHistory();
  }

  /// Loads calculation history
  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase = ref.read(getNetSalaryCalculationHistoryUseCaseProvider);
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
    state = const NetSalaryCalculatorState();
  }

  /// Sets a specific calculation from history as current
  void setCalculation(NetSalaryCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateNetSalaryUseCase
@riverpod
CalculateNetSalaryUseCase calculateNetSalaryUseCase(
  CalculateNetSalaryUseCaseRef ref,
) {
  return getIt<CalculateNetSalaryUseCase>();
}

/// Provider for SaveNetSalaryCalculationUseCase
@riverpod
SaveNetSalaryCalculationUseCase saveNetSalaryCalculationUseCase(
  SaveNetSalaryCalculationUseCaseRef ref,
) {
  return getIt<SaveNetSalaryCalculationUseCase>();
}

/// Provider for GetNetSalaryCalculationHistoryUseCase
@riverpod
GetNetSalaryCalculationHistoryUseCase getNetSalaryCalculationHistoryUseCase(
  GetNetSalaryCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetNetSalaryCalculationHistoryUseCase>();
}
