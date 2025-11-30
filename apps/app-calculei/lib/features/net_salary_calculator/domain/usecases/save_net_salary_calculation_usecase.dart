import 'package:core/core.dart';
import '../entities/net_salary_calculation.dart';
import '../repositories/net_salary_repository.dart';

class SaveNetSalaryCalculationUseCase {
  final NetSalaryRepository _repository;

  SaveNetSalaryCalculationUseCase(this._repository);

  Future<Either<Failure, NetSalaryCalculation>> call(
      NetSalaryCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
