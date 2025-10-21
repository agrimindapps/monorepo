// Package imports:
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import '../entities/overtime_calculation.dart';
import '../repositories/overtime_repository.dart';

/// Use case for retrieving overtime calculation history
@injectable
class GetOvertimeCalculationHistoryUseCase {
  final OvertimeRepository _repository;

  GetOvertimeCalculationHistoryUseCase(this._repository);

  Future<Either<Failure, List<OvertimeCalculation>>> call({
    int limit = 10,
  }) async {
    return _repository.getCalculationHistory(limit: limit);
  }
}
