import 'package:core/core.dart';

import '../entities/vacation_calculation.dart';
import '../repositories/vacation_repository.dart';

/// Use case for saving vacation calculation to history
@injectable
class SaveCalculationUseCase {
  final VacationRepository repository;

  const SaveCalculationUseCase(this.repository);

  Future<Either<Failure, VacationCalculation>> call(
    VacationCalculation calculation,
  ) async {
    return repository.saveCalculation(calculation);
  }
}
