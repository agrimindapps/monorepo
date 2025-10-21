import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/emergency_reserve_calculation.dart';

abstract class EmergencyReserveRepository {
  Future<Either<Failure, EmergencyReserveCalculation>> saveCalculation(EmergencyReserveCalculation calculation);
  Future<Either<Failure, List<EmergencyReserveCalculation>>> getCalculationHistory({int limit = 10});
  Future<Either<Failure, EmergencyReserveCalculation>> getCalculationById(String id);
  Future<Either<Failure, void>> deleteCalculation(String id);
  Future<Either<Failure, void>> clearHistory();
}
