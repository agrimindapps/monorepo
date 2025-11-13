import '../../../../core/storage/hive_service.dart';
import '../models/calculation_history_model.dart';

/// Interface abstrata para data source local de calculadoras
abstract class CalculatorLocalDatasource {
  Future<void> saveCalculationHistory(CalculationHistoryModel history);
  Future<List<CalculationHistoryModel>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<void> deleteCalculationHistory(String id);
  Future<void> addFavoriteCalculator(String calculatorId);
  Future<void> removeFavoriteCalculator(String calculatorId);
  Future<List<String>> getFavoriteCalculatorIds();
  Future<void> incrementCalculatorUsage(String calculatorId);
  Future<Map<String, int>> getCalculatorUsageStats();
  Future<CalculationHistoryModel?> getCalculationHistoryById(String id);
  Future<void> clearCalculationHistory();
  Future<bool> isFavoriteCalculator(String calculatorId);
}

/// Implementação do data source local para calculadoras usando HiveService
class CalculatorLocalDatasourceImpl implements CalculatorLocalDatasource {
  final HiveService _hiveService;

  CalculatorLocalDatasourceImpl(this._hiveService);

  static const String _historyBoxName = 'calculation_history';
  static const String _favoritesBoxName = 'favorite_calculators';
  static const String _statsBoxName = 'calculator_usage_stats';

  /// Salva item no histórico
  @override
  Future<void> saveCalculationHistory(CalculationHistoryModel history) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(
      _historyBoxName,
    );
    await box.put(history.id, history);
  }

  /// Obtém histórico com filtros
  @override
  Future<List<CalculationHistoryModel>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(
      _historyBoxName,
    );
    var histories = box.values.toList();
    if (calculatorId != null) {
      histories =
          histories
              .where(
                (CalculationHistoryModel h) => h.calculatorId == calculatorId,
              )
              .toList();
    }

    if (animalId != null) {
      histories =
          histories
              .where((CalculationHistoryModel h) => h.animalId == animalId)
              .toList();
    }

    if (fromDate != null) {
      histories =
          histories
              .where(
                (CalculationHistoryModel h) => h.createdAt.isAfter(fromDate),
              )
              .toList();
    }

    if (toDate != null) {
      histories =
          histories
              .where(
                (CalculationHistoryModel h) => h.createdAt.isBefore(toDate),
              )
              .toList();
    }
    histories.sort(
      (CalculationHistoryModel a, CalculationHistoryModel b) =>
          b.createdAt.compareTo(a.createdAt),
    );
    if (limit != null && limit > 0) {
      histories = histories.take(limit).toList();
    }

    return histories;
  }

  /// Remove item do histórico
  Future<void> removeCalculationHistory(String historyId) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(
      _historyBoxName,
    );
    await box.delete(historyId);
  }

  @override
  Future<void> clearCalculationHistory() async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(
      _historyBoxName,
    );
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
    final box = await _hiveService.getBox<Map<dynamic, dynamic>>(_statsBoxName);
    final existingStats = box.get(
      calculatorId,
      defaultValue: <String, dynamic>{},
    );
    final stats = Map<String, dynamic>.from(
      existingStats ?? <String, dynamic>{},
    );

    final now = DateTime.now();
    stats['lastUsed'] = now.millisecondsSinceEpoch;
    stats['usageCount'] = (stats['usageCount'] ?? 0) + 1;

    await box.put(calculatorId, stats);
  }

  /// Obtém estatísticas de uso
  Future<Map<String, dynamic>> getCalculatorStats(String calculatorId) async {
    final box = await _hiveService.getBox<Map<dynamic, dynamic>>(_statsBoxName);
    final stats = box.get(calculatorId, defaultValue: <String, dynamic>{});
    return Map<String, dynamic>.from(stats ?? <String, dynamic>{});
  }

  /// Incrementa contador de uso da calculadora
  @override
  Future<void> incrementCalculatorUsage(String calculatorId) async {
    await recordCalculatorUsage(calculatorId);
  }

  /// Obtém item específico do histórico por ID
  @override
  Future<CalculationHistoryModel?> getCalculationHistoryById(String id) async {
    final box = await _hiveService.getBox<CalculationHistoryModel>(
      _historyBoxName,
    );
    return box.get(id);
  }

  /// Remove item do histórico (alias para compatibilidade)
  @override
  Future<void> deleteCalculationHistory(String id) async {
    await removeCalculationHistory(id);
  }

  /// Obtém lista de IDs das calculadoras favoritas
  @override
  Future<List<String>> getFavoriteCalculatorIds() async {
    return await getFavoriteCalculators();
  }

  /// Adiciona calculadora aos favoritos (alias para compatibilidade)
  @override
  Future<void> addFavoriteCalculator(String calculatorId) async {
    await addToFavorites(calculatorId);
  }

  /// Remove calculadora dos favoritos (alias para compatibilidade)
  @override
  Future<void> removeFavoriteCalculator(String calculatorId) async {
    await removeFromFavorites(calculatorId);
  }

  /// Verifica se calculadora é favorita
  @override
  Future<bool> isFavoriteCalculator(String calculatorId) async {
    final favorites = await getFavoriteCalculators();
    return favorites.contains(calculatorId);
  }

  /// Obtém estatísticas de uso de todas as calculadoras
  @override
  Future<Map<String, int>> getCalculatorUsageStats() async {
    final box = await _hiveService.getBox<Map<dynamic, dynamic>>(_statsBoxName);
    final stats = <String, int>{};

    for (final key in box.keys) {
      final calculatorStats = box.get(key);
      if (calculatorStats != null) {
        final usageCount = calculatorStats['usageCount'] ?? 0;
        stats[key.toString()] = usageCount as int;
      }
    }

    return stats;
  }
}
