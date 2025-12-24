import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/state/calculator_state.dart';
import '../../domain/entities/emergency_reserve_calculation.dart';
import '../../domain/usecases/calculate_emergency_reserve_usecase.dart';

part 'emergency_reserve_calculator_provider.g.dart';

@riverpod
CalculateEmergencyReserveUseCase calculateEmergencyReserveUseCase(Ref ref) {
  return CalculateEmergencyReserveUseCase();
}

@riverpod
class EmergencyReserveCalculatorNotifier extends _$EmergencyReserveCalculatorNotifier {
  @override
  CalculatorState<EmergencyReserveCalculation> build() {
    return CalculatorState.empty();
  }

  Future<void> calculate(CalculateEmergencyReserveParams params) async {
    state = state.toLoading();
    
    final useCase = ref.read(calculateEmergencyReserveUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
      (failure) => state.toError(failure.message),
      (calculation) => state.toSuccess(calculation),
    );
  }

  void clearCalculation() {
    state = CalculatorState.empty();
  }
}
