import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/net_salary_calculation.dart';
import '../repositories/net_salary_repository.dart';

@injectable
class SaveNetSalaryCalculationUseCase {
  final NetSalaryRepository _repository;

  SaveNetSalaryCalculationUseCase(this._repository);

  Future<Either<Failure, NetSalaryCalculation>> call(NetSalaryCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
