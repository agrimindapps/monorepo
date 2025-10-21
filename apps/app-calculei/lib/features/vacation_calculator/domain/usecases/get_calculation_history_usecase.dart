import 'package:core/core.dart';

import '../entities/vacation_calculation.dart';
import '../repositories/vacation_repository.dart';

/// Use case for retrieving vacation calculation history
@injectable
class GetCalculationHistoryUseCase {
  final VacationRepository repository;

  const GetCalculationHistoryUseCase(this.repository);

  Future<Either<Failure, List<VacationCalculation>>> call({
    int limit = 10,
  }) async {
    return repository.getCalculationHistory(limit: limit);
  }
}
