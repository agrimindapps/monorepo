// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:app_calculei/core/di/injection.dart';
import '../../domain/entities/cash_vs_installment_calculation.dart';
import '../../domain/usecases/calculate_cash_vs_installment_usecase.dart';
import '../../domain/usecases/get_cash_vs_installment_calculation_history_usecase.dart';
import '../../domain/usecases/save_cash_vs_installment_calculation_usecase.dart';

part 'cash_vs_installment_calculator_provider.g.dart';

/// State for cash vs installment calculator
///
/// Immutable state following Clean Architecture principles
class CashVsInstallmentCalculatorState {
  final CashVsInstallmentCalculation? calculation;
  final List<CashVsInstallmentCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const CashVsInstallmentCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  CashVsInstallmentCalculatorState copyWith({
    CashVsInstallmentCalculation? calculation,
    List<CashVsInstallmentCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return CashVsInstallmentCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing cash vs installment calculator state
///
/// Follows Single Responsibility Principle (SRP):
/// - Only responsible for state management
/// - Delegates business logic to use cases
@riverpod
class CashVsInstallmentCalculatorNotifier
    extends _$CashVsInstallmentCalculatorNotifier {
  @override
  CashVsInstallmentCalculatorState build() {
    // Initialize with empty state
    return const CashVsInstallmentCalculatorState();
  }

  /// Calculates cash vs installment based on parameters
  Future<void> calculate(CalculateCashVsInstallmentParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateCashVsInstallmentUseCaseProvider);
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
      CashVsInstallmentCalculation calculation) async {
    final saveUseCase =
        ref.read(saveCashVsInstallmentCalculationUseCaseProvider);
    await saveUseCase(calculation);

    // Refresh history after saving
    await loadHistory();
  }

  /// Loads calculation history
  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase =
        ref.read(getCashVsInstallmentCalculationHistoryUseCaseProvider);
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
    state = const CashVsInstallmentCalculatorState();
  }

  /// Sets a specific calculation from history as current
  void setCalculation(CashVsInstallmentCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

// ========== USE CASE PROVIDERS ==========

/// Provider for CalculateCashVsInstallmentUseCase
@riverpod
CalculateCashVsInstallmentUseCase calculateCashVsInstallmentUseCase(
  CalculateCashVsInstallmentUseCaseRef ref,
) {
  return getIt<CalculateCashVsInstallmentUseCase>();
}

/// Provider for SaveCashVsInstallmentCalculationUseCase
@riverpod
SaveCashVsInstallmentCalculationUseCase
    saveCashVsInstallmentCalculationUseCase(
  SaveCashVsInstallmentCalculationUseCaseRef ref,
) {
  return getIt<SaveCashVsInstallmentCalculationUseCase>();
}

/// Provider for GetCashVsInstallmentCalculationHistoryUseCase
@riverpod
GetCashVsInstallmentCalculationHistoryUseCase
    getCashVsInstallmentCalculationHistoryUseCase(
  GetCashVsInstallmentCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetCashVsInstallmentCalculationHistoryUseCase>();
}
