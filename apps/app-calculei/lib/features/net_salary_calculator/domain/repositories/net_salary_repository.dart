import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/net_salary_calculation.dart';

abstract class NetSalaryRepository {
  Future<Either<Failure, NetSalaryCalculation>> saveCalculation(NetSalaryCalculation calculation);
  Future<Either<Failure, List<NetSalaryCalculation>>> getCalculationHistory({int limit = 10});
  Future<Either<Failure, NetSalaryCalculation>> getCalculationById(String id);
  Future<Either<Failure, void>> deleteCalculation(String id);
  Future<Either<Failure, void>> clearHistory();
}
