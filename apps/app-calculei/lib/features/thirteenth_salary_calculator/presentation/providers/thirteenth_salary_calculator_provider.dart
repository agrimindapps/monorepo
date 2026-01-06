import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/thirteenth_salary_calculation.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';

part 'thirteenth_salary_calculator_provider.g.dart';

@riverpod
CalculateThirteenthSalaryUseCase calculateThirteenthSalaryUseCase(Ref ref) {
  return CalculateThirteenthSalaryUseCase();
}

@riverpod
class ThirteenthSalaryCalculatorNotifier extends _$ThirteenthSalaryCalculatorNotifier {
  @override
  CalculatorState<ThirteenthSalaryCalculation> build() {
    return CalculatorState.empty<ThirteenthSalaryCalculation>();
  }

  Future<void> calculate(CalculateThirteenthSalaryParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateThirteenthSalaryUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<ThirteenthSalaryCalculation>();
  }
}
