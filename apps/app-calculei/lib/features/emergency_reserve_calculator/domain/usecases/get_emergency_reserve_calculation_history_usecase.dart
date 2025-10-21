import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/emergency_reserve_calculation.dart';
import '../repositories/emergency_reserve_repository.dart';

@injectable
class GetEmergencyReserveCalculationHistoryUseCase {
  final EmergencyReserveRepository _repository;

  GetEmergencyReserveCalculationHistoryUseCase(this._repository);

  Future<Either<Failure, List<EmergencyReserveCalculation>>> call({int limit = 10}) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
