import '../entities/calculation_history.dart';
import '../entities/calculator.dart';

/// Interface do repositório para calculadoras
/// Define contratos para persistência de dados das calculadoras
abstract class CalculatorRepository {
  /// Obtém todas as calculadoras disponíveis
  Future<List<Calculator>> getCalculators();

  /// Obtém calculadora por ID
  Future<Calculator?> getCalculatorById(String id);

  /// Obtém calculadoras por categoria
  Future<List<Calculator>> getCalculatorsByCategory(
    CalculatorCategory category,
  );

  /// Salva um resultado de cálculo no histórico
  Future<void> saveCalculationHistory(CalculationHistory history);

  /// Obtém histórico de cálculos
  Future<List<CalculationHistory>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Obtém histórico por ID
  Future<CalculationHistory?> getCalculationHistoryById(String id);

  /// Remove item do histórico
  Future<void> deleteCalculationHistory(String id);

  Future<void> clearCalculationHistory();

  /// Obtém calculadoras favoritas
  Future<List<String>> getFavoriteCalculatorIds();

  /// Adiciona calculadora aos favoritos
  Future<void> addFavoriteCalculator(String calculatorId);

  /// Remove calculadora dos favoritos
  Future<void> removeFavoriteCalculator(String calculatorId);

  /// Verifica se calculadora é favorita
  Future<bool> isFavoriteCalculator(String calculatorId);

  /// Obtém estatísticas de uso das calculadoras
  Future<Map<String, int>> getCalculatorUsageStats();
}
