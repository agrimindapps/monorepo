import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

@lazySingleton
class GetCalculationHistory {
  final CalculatorRepository repository;

  GetCalculationHistory(this.repository);

  Future<Either<Failure, List<CalculationHistory>>> call() async {
    return repository.getCalculationHistory();
  }
}

@lazySingleton
class DeleteCalculationHistory {
  final CalculatorRepository repository;

  DeleteCalculationHistory(this.repository);

  Future<Either<Failure, Unit>> call(String historyId) async {
    return repository.removeFromHistory(historyId);
  }
}

// }
