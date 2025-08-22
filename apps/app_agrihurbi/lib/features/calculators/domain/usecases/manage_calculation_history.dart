import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

class GetCalculationHistory {
  final CalculatorRepository repository;

  GetCalculationHistory(this.repository);

  Future<Either<Failure, List<CalculationHistory>>> call() async {
    return await repository.getCalculationHistory();
  }
}

class DeleteCalculationHistory {
  final CalculatorRepository repository;

  DeleteCalculationHistory(this.repository);

  Future<Either<Failure, Unit>> call(String historyId) async {
    return await repository.removeFromHistory(historyId);
  }
}

// Use case removido - não implementado no repository atual
// class GetCalculatorUsageStats {
//   final CalculatorRepository repository;

//   GetCalculatorUsageStats(this.repository);

//   Future<Either<Failure, Map<String, int>>> call(String userId) async {
//     return await repository.getCalculatorUsageStats(userId);
//   }
// }