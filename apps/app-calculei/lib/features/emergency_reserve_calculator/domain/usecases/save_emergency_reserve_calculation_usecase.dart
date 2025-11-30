import 'package:core/core.dart';
import '../entities/emergency_reserve_calculation.dart';
import '../repositories/emergency_reserve_repository.dart';

class SaveEmergencyReserveCalculationUseCase {
  final EmergencyReserveRepository _repository;

  SaveEmergencyReserveCalculationUseCase(this._repository);

  Future<Either<Failure, EmergencyReserveCalculation>> call(
      EmergencyReserveCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
