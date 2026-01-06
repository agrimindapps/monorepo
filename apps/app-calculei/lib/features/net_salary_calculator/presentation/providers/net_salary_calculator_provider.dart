import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/net_salary_calculation.dart';
import '../../domain/usecases/calculate_net_salary_usecase.dart';

part 'net_salary_calculator_provider.g.dart';

@riverpod
CalculateNetSalaryUseCase calculateNetSalaryUseCase(Ref ref) {
  return CalculateNetSalaryUseCase();
}

@riverpod
class NetSalaryCalculatorNotifier extends _$NetSalaryCalculatorNotifier {
  @override
  CalculatorState<NetSalaryCalculation> build() {
    return CalculatorState.empty<NetSalaryCalculation>();
  }

  Future<void> calculate(CalculateNetSalaryParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateNetSalaryUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<NetSalaryCalculation>();
  }
}
