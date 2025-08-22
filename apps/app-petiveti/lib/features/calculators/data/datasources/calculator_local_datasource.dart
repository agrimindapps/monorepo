import '../models/calculation_history_model.dart';
import '../../../../shared/data/box_manager.dart';

/// Data source local para calculadoras usando Hive
class CalculatorLocalDatasource {
  static const String _historyBoxName = 'calculation_history';
  static const String _favoritesBoxName = 'favorite_calculators';
  static const String _statsBoxName = 'calculator_usage_stats';

  /// Salva item no histórico
  Future<void> saveCalculationHistory(CalculationHistoryModel history) async {
    final box = await BoxManager.openBox<CalculationHistoryModel>(_historyBoxName);
    await box.put(history.id, history);
  }

  /// Obtém histórico com filtros
  Future<List<CalculationHistoryModel>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final box = await BoxManager.openBox<CalculationHistoryModel>(_historyBoxName);
    var histories = box.values.toList();

    // Aplicar filtros
    if (calculatorId != null) {
      histories = histories.where((h) => h.calculatorId == calculatorId).toList();
    }

    if (animalId != null) {
      histories = histories.where((h) => h.animalId == animalId).toList();
    }

    if (fromDate != null) {
      histories = histories.where((h) => h.createdAt.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      histories = histories.where((h) => h.createdAt.isBefore(toDate)).toList();
    }

    // Ordenar por data (mais recentes primeiro)
    histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Aplicar limite
    if (limit != null && limit > 0) {
      histories = histories.take(limit).toList();
    }

    return histories;
  }

  /// Obtém item específico do histórico
  Future<CalculationHistoryModel?> getCalculationHistoryById(String id) async {
    final box = await BoxManager.openBox<CalculationHistoryModel>(_historyBoxName);
    return box.get(id);
  }

  /// Remove item do histórico
  Future<void> deleteCalculationHistory(String id) async {
    final box = await BoxManager.openBox<CalculationHistoryModel>(_historyBoxName);
    await box.delete(id);
  }

  /// Limpa todo o histórico
  Future<void> clearCalculationHistory() async {
    final box = await BoxManager.openBox<CalculationHistoryModel>(_historyBoxName);
    await box.clear();
  }

  /// Obtém IDs das calculadoras favoritas
  Future<List<String>> getFavoriteCalculatorIds() async {
    final box = await BoxManager.openBox<String>(_favoritesBoxName);
    return box.values.toList();
  }

  /// Adiciona calculadora aos favoritos
  Future<void> addFavoriteCalculator(String calculatorId) async {
    final box = await BoxManager.openBox<String>(_favoritesBoxName);
    if (!box.values.contains(calculatorId)) {
      await box.add(calculatorId);
    }
  }

  /// Remove calculadora dos favoritos
  Future<void> removeFavoriteCalculator(String calculatorId) async {
    final box = await BoxManager.openBox<String>(_favoritesBoxName);
    final keys = box.keys.toList();
    
    for (final key in keys) {
      if (box.get(key) == calculatorId) {
        await box.delete(key);
        break;
      }
    }
  }

  /// Verifica se calculadora é favorita
  Future<bool> isFavoriteCalculator(String calculatorId) async {
    final favoriteIds = await getFavoriteCalculatorIds();
    return favoriteIds.contains(calculatorId);
  }

  /// Incrementa contador de uso de uma calculadora
  Future<void> incrementCalculatorUsage(String calculatorId) async {
    final box = await BoxManager.openBox<int>(_statsBoxName);
    final currentCount = box.get(calculatorId) ?? 0;
    await box.put(calculatorId, currentCount + 1);
  }

  /// Obtém estatísticas de uso das calculadoras
  Future<Map<String, int>> getCalculatorUsageStats() async {
    final box = await BoxManager.openBox<int>(_statsBoxName);
    final stats = <String, int>{};
    
    for (final key in box.keys) {
      if (key is String) {
        stats[key] = box.get(key) ?? 0;
      }
    }
    
    return stats;
  }

  /// Reseta estatísticas de uso
  Future<void> resetCalculatorUsageStats() async {
    final box = await BoxManager.openBox<int>(_statsBoxName);
    await box.clear();
  }
}