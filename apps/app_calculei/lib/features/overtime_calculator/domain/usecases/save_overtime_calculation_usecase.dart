// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import '../entities/overtime_calculation.dart';
import '../repositories/overtime_repository.dart';

/// Use case for saving an overtime calculation to local storage
@injectable
class SaveOvertimeCalculationUseCase {
  final OvertimeRepository _repository;

  SaveOvertimeCalculationUseCase(this._repository);

  Future<Either<Failure, OvertimeCalculation>> call(
    OvertimeCalculation calculation,
  ) async {
    return _repository.saveCalculation(calculation);
  }
}
