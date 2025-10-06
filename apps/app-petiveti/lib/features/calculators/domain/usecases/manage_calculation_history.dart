import '../entities/calculation_history.dart';
import '../repositories/calculator_repository.dart';

/// Use case para gerenciar histórico de cálculos
class ManageCalculationHistory {
  const ManageCalculationHistory(this._repository);

  final CalculatorRepository _repository;

  /// Obtém histórico de cálculos com filtros opcionais
  ///
  /// [calculatorId] - Filtrar por calculadora específica
  /// [animalId] - Filtrar por animal específico
  /// [limit] - Limitar número de resultados
  /// [fromDate] - Data inicial do período
  /// [toDate] - Data final do período
  Future<List<CalculationHistory>> getHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.getCalculationHistory(
      calculatorId: calculatorId,
      animalId: animalId,
      limit: limit,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Obtém item específico do histórico
  ///
  /// [id] - ID do item no histórico
  Future<CalculationHistory?> getHistoryById(String id) async {
    return await _repository.getCalculationHistoryById(id);
  }

  /// Remove item do histórico
  ///
  /// [id] - ID do item a ser removido
  Future<void> deleteHistoryItem(String id) async {
    await _repository.deleteCalculationHistory(id);
  }

  Future<void> clearAllHistory() async {
    await _repository.clearCalculationHistory();
  }

  /// Obtém histórico recente (últimos N itens)
  ///
  /// [limit] - Número de itens a retornar (default: 10)
  Future<List<CalculationHistory>> getRecentHistory({int limit = 10}) async {
    return await _repository.getCalculationHistory(limit: limit);
  }

  /// Obtém histórico de um animal específico
  ///
  /// [animalId] - ID do animal
  /// [limit] - Número máximo de itens
  Future<List<CalculationHistory>> getAnimalHistory(
    String animalId, {
    int? limit,
  }) async {
    return await _repository.getCalculationHistory(
      animalId: animalId,
      limit: limit,
    );
  }

  /// Obtém histórico de uma calculadora específica
  ///
  /// [calculatorId] - ID da calculadora
  /// [limit] - Número máximo de itens
  Future<List<CalculationHistory>> getCalculatorHistory(
    String calculatorId, {
    int? limit,
  }) async {
    return await _repository.getCalculationHistory(
      calculatorId: calculatorId,
      limit: limit,
    );
  }

  /// Obtém estatísticas de uso das calculadoras
  Future<Map<String, int>> getUsageStats() async {
    return await _repository.getCalculatorUsageStats();
  }

  /// Salva resultado de cálculo no histórico
  ///
  /// [history] - Item de histórico a ser salvo
  Future<void> saveToHistory(CalculationHistory history) async {
    await _repository.saveCalculationHistory(history);
  }
}
