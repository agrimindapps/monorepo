import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/overtime_calculation.dart';
import '../repositories/overtime_repository.dart';

class SaveOvertimeCalculationUseCase {
  final OvertimeRepository _repository;
  SaveOvertimeCalculationUseCase(this._repository);
  Future<Either<Failure, OvertimeCalculation>> call(
      OvertimeCalculation calculation) async {
    return _repository.saveCalculation(calculation);
  }
}
