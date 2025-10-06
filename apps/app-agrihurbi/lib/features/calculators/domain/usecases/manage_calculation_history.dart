import 'package:core/core.dart';

import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

class GetCalculationHistory {
  final CalculatorRepository repository;

  GetCalculationHistory(this.repository);

  Future<Either<Failure, List<CalculationHistory>>> call() async {
    return repository.getCalculationHistory();
  }
}

class DeleteCalculationHistory {
  final CalculatorRepository repository;

  DeleteCalculationHistory(this.repository);

  Future<Either<Failure, Unit>> call(String historyId) async {
    return repository.removeFromHistory(historyId);
  }
}
// }