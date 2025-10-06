import 'package:core/core.dart';

import '../entities/calculation_history.dart';
import '../entities/calculation_result.dart';
import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';

abstract class CalculatorRepository {
  /// Obtém todas as calculadoras disponíveis
  Future<Either<Failure, List<CalculatorEntity>>> getAllCalculators();

  /// Obtém calculadoras por categoria
  Future<Either<Failure, List<CalculatorEntity>>> getCalculatorsByCategory(
    CalculatorCategory category,
  );

  /// Obtém uma calculadora específica pelo ID
  Future<Either<Failure, CalculatorEntity>> getCalculatorById(String id);

  /// Executa um cálculo usando uma calculadora específica
  Future<Either<Failure, CalculationResult>> executeCalculation(
    String calculatorId,
    Map<String, dynamic> inputs,
  );

  /// Obtém o histórico de cálculos
  Future<Either<Failure, List<CalculationHistory>>> getCalculationHistory();

  /// Salva o resultado de um cálculo no histórico
  Future<Either<Failure, Unit>> saveCalculationToHistory(
    CalculationHistory historyItem,
  );

  /// Remove um item do histórico
  Future<Either<Failure, Unit>> removeFromHistory(String historyId);

  Future<Either<Failure, Unit>> clearHistory();

  /// Busca calculadoras por termo
  Future<Either<Failure, List<CalculatorEntity>>> searchCalculators(
    String searchTerm,
  );

  /// Obtém IDs das calculadoras favoritas
  Future<Either<Failure, List<String>>> getFavoriteCalculators();

  /// Adiciona calculadora aos favoritos
  Future<Either<Failure, Unit>> addToFavorites(String calculatorId);

  /// Remove calculadora dos favoritos
  Future<Either<Failure, Unit>> removeFromFavorites(String calculatorId);
}
