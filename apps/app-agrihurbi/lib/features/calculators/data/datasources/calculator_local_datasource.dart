import 'package:injectable/injectable.dart';

import '../../domain/calculators/irrigation/evapotranspiration_calculator.dart';
import '../../domain/calculators/irrigation/field_capacity_calculator.dart';
import '../../domain/calculators/irrigation/irrigation_sizing_calculator.dart';
import '../../domain/calculators/irrigation/irrigation_time_calculator.dart';
import '../../domain/calculators/irrigation/water_need_calculator.dart';
import '../../domain/calculators/nutrition/organic_fertilizer_calculator.dart';
import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';

/// Interface para datasource local de calculadoras
abstract class CalculatorLocalDataSource {
  Future<List<CalculatorEntity>> getAllCalculators();
  Future<List<CalculatorEntity>> getCalculatorsByCategory(CalculatorCategory category);
  Future<CalculatorEntity?> getCalculatorById(String id);
  Future<List<CalculatorEntity>> searchCalculators(String searchTerm);
  Future<List<CalculationHistory>> getCalculationHistory();
  Future<void> saveCalculationToHistory(CalculationHistory historyItem);
  Future<void> removeFromHistory(String historyId);
  Future<void> clearHistory();
  Future<List<String>> getFavoriteCalculators();
  Future<void> addToFavorites(String calculatorId);
  Future<void> removeFromFavorites(String calculatorId);
}

/// Implementação do datasource local com Hive
/// 
/// Gerencia calculadoras hardcoded e armazenamento local de histórico/favoritos
@LazySingleton(as: CalculatorLocalDataSource)
class CalculatorLocalDataSourceImpl implements CalculatorLocalDataSource {
  static final List<CalculatorEntity> _availableCalculators = [
    const WaterNeedCalculator(),
    const IrrigationSizingCalculator(),
    const EvapotranspirationCalculator(),
    const FieldCapacityCalculator(),
    const IrrigationTimeCalculator(),
    const OrganicFertilizerCalculator(),
  ];
  static final List<CalculationHistory> _historyCache = [];
  static final Set<String> _favoritesCache = {};

  @override
  Future<List<CalculatorEntity>> getAllCalculators() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    return List<CalculatorEntity>.from(_availableCalculators);
  }

  @override
  Future<List<CalculatorEntity>> getCalculatorsByCategory(
    CalculatorCategory category,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    
    return _availableCalculators
        .where((calculator) => calculator.category == category)
        .toList();
  }

  @override
  Future<CalculatorEntity?> getCalculatorById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    try {
      return _availableCalculators.firstWhere((calc) => calc.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CalculatorEntity>> searchCalculators(String searchTerm) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    
    if (searchTerm.isEmpty) {
      return getAllCalculators();
    }

    final query = searchTerm.toLowerCase();
    return _availableCalculators
        .where((calculator) =>
            calculator.name.toLowerCase().contains(query) ||
            calculator.description.toLowerCase().contains(query))
        .toList();
  }

  @override
  Future<List<CalculationHistory>> getCalculationHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final history = List<CalculationHistory>.from(_historyCache);
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return history;
  }

  @override
  Future<void> saveCalculationToHistory(CalculationHistory historyItem) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _historyCache.removeWhere((item) => 
      item.calculatorId == historyItem.calculatorId &&
      _inputsAreEqual(item.result.inputs, historyItem.result.inputs)
    );
    _historyCache.add(historyItem);
    if (_historyCache.length > 50) {
      _historyCache.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _historyCache.removeRange(50, _historyCache.length);
    }
  }

  @override
  Future<void> removeFromHistory(String historyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    _historyCache.removeWhere((item) => item.id == historyId);
  }

  @override
  Future<void> clearHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    _historyCache.clear();
  }

  @override
  Future<List<String>> getFavoriteCalculators() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    
    return _favoritesCache.toList();
  }

  @override
  Future<void> addToFavorites(String calculatorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    _favoritesCache.add(calculatorId);
  }

  @override
  Future<void> removeFromFavorites(String calculatorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    _favoritesCache.remove(calculatorId);
  }

  /// Compara dois mapas de inputs para detectar duplicatas
  bool _inputsAreEqual(Map<String, dynamic> inputs1, Map<String, dynamic> inputs2) {
    if (inputs1.length != inputs2.length) return false;
    
    for (final key in inputs1.keys) {
      if (!inputs2.containsKey(key)) return false;
      if (inputs1[key]?.toString() != inputs2[key]?.toString()) return false;
    }
    
    return true;
  }
}