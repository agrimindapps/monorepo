import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../database/petiveti_database.dart';
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

/// Drift-based implementation of CalculatorLocalDatasource
@LazySingleton(as: CalculatorLocalDatasource)
class CalculatorLocalDatasourceImpl implements CalculatorLocalDatasource {
  final PetivetiDatabase _database;
  final SharedPreferences _prefs;

  CalculatorLocalDatasourceImpl(this._database, this._prefs);

  static const String _favoritesKey = 'favorite_calculators';
  static const String _statsPrefix = 'calculator_stats_';

  @override
  Future<void> saveCalculationHistory(CalculationHistoryModel history) async {
    final inputsJson = jsonEncode(history.inputs);
    final resultJson = jsonEncode(history.resultData);
    
    if (history.id != null) {
      final existingEntry = await _database.calculatorDao.getHistoryById(history.id!);
      if (existingEntry != null) {
        await _database.calculatorDao.updateHistoryEntry(
          history.id!,
          calculatorType: history.calculatorId,
          inputData: inputsJson,
          result: resultJson,
        );
        return;
      }
    }
    
    await _database.calculatorDao.createHistoryEntry(
      calculatorType: history.calculatorId,
      inputData: inputsJson,
      result: resultJson,
      userId: history.userId ?? '',
      date: history.createdAt,
    );
  }

  @override
  Future<List<CalculationHistoryModel>> getCalculationHistory({
    String? calculatorId,
    String? animalId,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final allHistory = await _database.calculatorDao.getAllHistory('');
    
    var filtered = allHistory.where((h) => !h.isDeleted).toList();
    
    if (calculatorId != null) {
      filtered = filtered.where((h) => h.calculatorType == calculatorId).toList();
    }
    
    if (fromDate != null) {
      filtered = filtered.where((h) => h.date.isAfter(fromDate)).toList();
    }
    
    if (toDate != null) {
      filtered = filtered.where((h) => h.date.isBefore(toDate)).toList();
    }
    
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    if (limit != null && limit > 0) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered.map(_toModel).toList();
  }

  @override
  Future<CalculationHistoryModel?> getCalculationHistoryById(String id) async {
    try {
      final entry = await _database.calculatorDao.getHistoryById(int.parse(id));
      return entry != null ? _toModel(entry) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteCalculationHistory(String id) async {
    await _database.calculatorDao.deleteHistoryEntry(int.parse(id));
  }

  @override
  Future<void> clearCalculationHistory() async {
    await _database.calculatorDao.clearAllHistory('');
  }

  @override
  Future<void> addFavoriteCalculator(String calculatorId) async {
    final favorites = await getFavoriteCalculatorIds();
    if (!favorites.contains(calculatorId)) {
      favorites.add(calculatorId);
      await _prefs.setStringList(_favoritesKey, favorites);
    }
  }

  @override
  Future<void> removeFavoriteCalculator(String calculatorId) async {
    final favorites = await getFavoriteCalculatorIds();
    favorites.remove(calculatorId);
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  @override
  Future<List<String>> getFavoriteCalculatorIds() async {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  @override
  Future<bool> isFavoriteCalculator(String calculatorId) async {
    final favorites = await getFavoriteCalculatorIds();
    return favorites.contains(calculatorId);
  }

  @override
  Future<void> incrementCalculatorUsage(String calculatorId) async {
    final statsKey = '$_statsPrefix$calculatorId';
    final statsJson = _prefs.getString(statsKey);
    
    Map<String, dynamic> stats = {};
    if (statsJson != null) {
      stats = jsonDecode(statsJson) as Map<String, dynamic>;
    }
    
    stats['lastUsed'] = DateTime.now().millisecondsSinceEpoch;
    stats['usageCount'] = (stats['usageCount'] ?? 0) + 1;
    
    await _prefs.setString(statsKey, jsonEncode(stats));
  }

  @override
  Future<Map<String, int>> getCalculatorUsageStats() async {
    final allKeys = _prefs.getKeys();
    final statsKeys = allKeys.where((k) => k.startsWith(_statsPrefix));
    
    final stats = <String, int>{};
    for (final key in statsKeys) {
      final calculatorId = key.replaceFirst(_statsPrefix, '');
      final statsJson = _prefs.getString(key);
      if (statsJson != null) {
        final data = jsonDecode(statsJson) as Map<String, dynamic>;
        stats[calculatorId] = data['usageCount'] ?? 0;
      }
    }
    
    return stats;
  }

  CalculationHistoryModel _toModel(CalculationHistoryEntry entry) {
    final inputs = jsonDecode(entry.inputData) as Map<String, dynamic>;
    final resultData = jsonDecode(entry.result) as Map<String, dynamic>;
    
    return CalculationHistoryModel(
      id: entry.id,
      calculatorId: entry.calculatorType,
      calculatorName: entry.calculatorType,
      inputs: inputs,
      resultData: resultData,
      createdAt: entry.date,
      userId: entry.userId,
    );
  }
}
