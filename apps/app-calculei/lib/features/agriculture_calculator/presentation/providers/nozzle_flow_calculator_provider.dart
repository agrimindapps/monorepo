import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/nozzle_flow_calculation.dart';
import '../../domain/usecases/calculate_nozzle_flow_usecase.dart';

part 'nozzle_flow_calculator_provider.g.dart';

@riverpod
CalculateNozzleFlowUseCase calculateNozzleFlowUseCase(Ref ref) {
  return CalculateNozzleFlowUseCase();
}

@riverpod
class NozzleFlowCalculatorNotifier extends _$NozzleFlowCalculatorNotifier {
  @override
  CalculatorState<NozzleFlowCalculation> build() {
    return CalculatorState.empty<NozzleFlowCalculation>();
  }

  Future<void> calculate(CalculateNozzleFlowParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateNozzleFlowUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty<NozzleFlowCalculation>();
  }
}
