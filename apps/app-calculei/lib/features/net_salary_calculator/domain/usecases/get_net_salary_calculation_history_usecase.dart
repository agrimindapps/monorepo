import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/net_salary_calculation.dart';
import '../repositories/net_salary_repository.dart';

class GetNetSalaryCalculationHistoryUseCase {
  final NetSalaryRepository _repository;

  GetNetSalaryCalculationHistoryUseCase(this._repository);

  Future<Either<Failure, List<NetSalaryCalculation>>> call(
      {int limit = 10}) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
