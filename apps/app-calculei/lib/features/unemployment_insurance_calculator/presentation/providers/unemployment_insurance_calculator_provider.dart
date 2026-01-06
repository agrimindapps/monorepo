import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/unemployment_insurance_calculation.dart';
import '../../domain/usecases/calculate_unemployment_insurance_usecase.dart';

part 'unemployment_insurance_calculator_provider.g.dart';

@riverpod
CalculateUnemploymentInsuranceUseCase calculateUnemploymentInsuranceUseCase(Ref ref) {
  return CalculateUnemploymentInsuranceUseCase();
}

@riverpod
class UnemploymentInsuranceCalculatorNotifier extends _$UnemploymentInsuranceCalculatorNotifier {
  @override
  CalculatorState<UnemploymentInsuranceCalculation> build() {
    return CalculatorState.empty<UnemploymentInsuranceCalculation>();
  }

  Future<void> calculate(CalculateUnemploymentInsuranceParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateUnemploymentInsuranceUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<UnemploymentInsuranceCalculation>();
  }
}
