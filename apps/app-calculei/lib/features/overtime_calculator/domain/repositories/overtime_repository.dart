// Package imports:
import 'package:core/core.dart';

// Project imports:
import '../entities/overtime_calculation.dart';

abstract class OvertimeRepository {
  Future<Either<Failure, OvertimeCalculation>> saveCalculation(
    OvertimeCalculation calculation,
  );
  Future<Either<Failure, List<OvertimeCalculation>>> getCalculationHistory({
    int limit = 10,
  });
  Future<Either<Failure, OvertimeCalculation>> getCalculationById(String id);
  Future<Either<Failure, void>> deleteCalculation(String id);
  Future<Either<Failure, void>> clearHistory();
}
