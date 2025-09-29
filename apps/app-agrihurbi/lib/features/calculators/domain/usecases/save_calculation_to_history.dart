import 'package:core/core.dart';

import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

/// Use case para salvar resultado de cálculo no histórico
/// 
/// Segue padrão Clean Architecture com Either para error handling
/// Utilizado pelo CalculatorProvider para persistir resultados
class SaveCalculationToHistory {
  final CalculatorRepository repository;

  SaveCalculationToHistory(repository);

  Future<Either<Failure, Unit>> call(CalculationHistory historyItem) async {
    return await repository.saveCalculationToHistory(historyItem);
  }
}

/// Use case para remover item do histórico
class RemoveFromHistory {
  final CalculatorRepository repository;

  RemoveFromHistory(repository);

  Future<Either<Failure, Unit>> call(String historyId) async {
    return await repository.removeFromHistory(historyId);
  }
}

/// Use case para limpar todo o histórico
class ClearHistory {
  final CalculatorRepository repository;

  ClearHistory(repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.clearHistory();
  }
}