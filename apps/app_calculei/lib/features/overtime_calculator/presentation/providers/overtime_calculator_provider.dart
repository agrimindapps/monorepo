// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:app_calculei/core/di/injection.dart';
import '../../domain/entities/overtime_calculation.dart';
import '../../domain/usecases/calculate_overtime_usecase.dart';
import '../../domain/usecases/get_overtime_calculation_history_usecase.dart';
import '../../domain/usecases/save_overtime_calculation_usecase.dart';

part 'overtime_calculator_provider.g.dart';

class OvertimeCalculatorState {
  final OvertimeCalculation? calculation;
  final List<OvertimeCalculation> history;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? errorMessage;

  const OvertimeCalculatorState({
    this.calculation,
    this.history = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  OvertimeCalculatorState copyWith({
    OvertimeCalculation? calculation,
    List<OvertimeCalculation>? history,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return OvertimeCalculatorState(
      calculation: calculation ?? this.calculation,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class OvertimeCalculatorNotifier extends _$OvertimeCalculatorNotifier {
  @override
  OvertimeCalculatorState build() {
    return const OvertimeCalculatorState();
  }

  Future<void> calculate(CalculateOvertimeParams params) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final useCase = ref.read(calculateOvertimeUseCaseProvider);
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
        _saveCalculation(calculation);
      },
    );
  }

  Future<void> _saveCalculation(OvertimeCalculation calculation) async {
    final saveUseCase = ref.read(saveOvertimeCalculationUseCaseProvider);
    await saveUseCase(calculation);
    await loadHistory();
  }

  Future<void> loadHistory({int limit = 10}) async {
    state = state.copyWith(isLoadingHistory: true);

    final useCase = ref.read(getOvertimeCalculationHistoryUseCaseProvider);
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

  void clearCalculation() {
    state = const OvertimeCalculatorState();
  }

  void setCalculation(OvertimeCalculation calculation) {
    state = state.copyWith(calculation: calculation);
  }
}

@riverpod
CalculateOvertimeUseCase calculateOvertimeUseCase(
  CalculateOvertimeUseCaseRef ref,
) {
  return getIt<CalculateOvertimeUseCase>();
}

@riverpod
SaveOvertimeCalculationUseCase saveOvertimeCalculationUseCase(
  SaveOvertimeCalculationUseCaseRef ref,
) {
  return getIt<SaveOvertimeCalculationUseCase>();
}

@riverpod
GetOvertimeCalculationHistoryUseCase getOvertimeCalculationHistoryUseCase(
  GetOvertimeCalculationHistoryUseCaseRef ref,
) {
  return getIt<GetOvertimeCalculationHistoryUseCase>();
}
