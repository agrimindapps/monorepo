import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/cash_vs_installment_calculation.dart';
import '../../domain/usecases/calculate_cash_vs_installment_usecase.dart';

part 'cash_vs_installment_calculator_provider.g.dart';

@riverpod
CalculateCashVsInstallmentUseCase calculateCashVsInstallmentUseCase(Ref ref) {
  return CalculateCashVsInstallmentUseCase();
}

@riverpod
class CashVsInstallmentCalculatorNotifier extends _$CashVsInstallmentCalculatorNotifier {
  @override
  CalculatorState<CashVsInstallmentCalculation> build() {
    return CalculatorState.empty<CashVsInstallmentCalculation>();
  }

  Future<void> calculate(CalculateCashVsInstallmentParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateCashVsInstallmentUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<CashVsInstallmentCalculation>();
  }
}
