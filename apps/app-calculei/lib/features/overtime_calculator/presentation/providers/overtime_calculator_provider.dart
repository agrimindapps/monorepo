import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/overtime_calculation.dart';
import '../../domain/usecases/calculate_overtime_usecase.dart';

part 'overtime_calculator_provider.g.dart';

@riverpod
CalculateOvertimeUseCase calculateOvertimeUseCase(Ref ref) {
  return CalculateOvertimeUseCase();
}

@riverpod
class OvertimeCalculatorNotifier extends _$OvertimeCalculatorNotifier {
  @override
  CalculatorState<OvertimeCalculation> build() {
    return CalculatorState.empty<OvertimeCalculation>();
  }

  Future<void> calculate(CalculateOvertimeParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateOvertimeUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<OvertimeCalculation>();
  }
}
