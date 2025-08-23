import '../models/calculation_history_model.dart';
import '../../../../core/storage/hive_service.dart';

/// Data source local para calculadoras usando HiveService
class CalculatorLocalDatasource {
  final HiveService _hiveService;
  
  CalculatorLocalDatasource(this._hiveService);
  
  static const String _historyBoxName = 'calculation_history';
  static const String _favoritesBoxName = 'favorite_calculators';
  static const String _statsBoxName = 'calculator_usage_stats';

  /// Salva item no histórico
  Future<void> saveCalculationHistory(CalculationHistoryModel history) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(_historyBoxName);
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
    final box = await _hiveService.getBox<CalculationHistoryModel>(_historyBoxName);
    var histories = box.values.toList();

    // Aplicar filtros
    if (calculatorId != null) {
      histories = histories.where((CalculationHistoryModel h) => h.calculatorId == calculatorId).toList();
    }
    
    if (animalId != null) {
      histories = histories.where((CalculationHistoryModel h) => h.animalId == animalId).toList();
    }
    
    if (fromDate != null) {
      histories = histories.where((CalculationHistoryModel h) => h.createdAt.isAfter(fromDate)).toList();
    }
    
    if (toDate != null) {
      histories = histories.where((CalculationHistoryModel h) => h.createdAt.isBefore(toDate)).toList();
    }

    // Ordenar por data (mais recente primeiro)
    histories.sort((CalculationHistoryModel a, CalculationHistoryModel b) => b.createdAt.compareTo(a.createdAt));

    // Aplicar limite
    if (limit != null && limit > 0) {
      histories = histories.take(limit).toList();
    }

    return histories;
  }

  /// Remove item do histórico
  Future<void> removeCalculationHistory(String historyId) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(_historyBoxName);
    await box.delete(historyId);
  }

  /// Limpa todo o histórico
  Future<void> clearCalculationHistory() async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(_historyBoxName);
    await box.clear();
  }

  /// Adiciona calculadora aos favoritos
  Future<void> addToFavorites(String calculatorId) async {
    final box = await _hiveService.getBox<String>(_favoritesBoxName);
    if (!box.values.contains(calculatorId)) {
      await box.add(calculatorId);
    }
  }

  /// Remove calculadora dos favoritos
  Future<void> removeFromFavorites(String calculatorId) async {
    final box = await _hiveService.getBox<String>(_favoritesBoxName);
    final key = box.keys.firstWhere(
      (key) => box.get(key) == calculatorId,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  /// Obtém lista de calculadoras favoritas
  Future<List<String>> getFavoriteCalculators() async {
    final box = await _hiveService.getBox<String>(_favoritesBoxName);
    return box.values.toList();
  }

  /// Registra uso de calculadora para estatísticas
  Future<void> recordCalculatorUsage(String calculatorId) async {
    final box = await _hiveService.getBox<Map>(_statsBoxName);
    final existingStats = box.get(calculatorId, defaultValue: <String, dynamic>{});
    final stats = Map<String, dynamic>.from(existingStats ?? <String, dynamic>{});
    
    final now = DateTime.now();
    stats['lastUsed'] = now.millisecondsSinceEpoch;
    stats['usageCount'] = (stats['usageCount'] ?? 0) + 1;
    
    await box.put(calculatorId, stats);
  }

  /// Obtém estatísticas de uso
  Future<Map<String, dynamic>> getCalculatorStats(String calculatorId) async {
    final box = await _hiveService.getBox<Map>(_statsBoxName);
    final stats = box.get(calculatorId, defaultValue: <String, dynamic>{});
    return Map<String, dynamic>.from(stats ?? <String, dynamic>{});
  }
}