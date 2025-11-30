import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/thirteenth_salary_calculation_model.dart';

/// Abstract interface for 13th salary local data source
///
/// Follows Interface Segregation Principle (ISP):
/// - Specific interface for local storage operations
abstract class ThirteenthSalaryLocalDataSource {
  /// Saves a calculation to local storage
  Future<ThirteenthSalaryCalculationModel> save(
    ThirteenthSalaryCalculationModel model,
  );

  /// Retrieves all calculations from local storage
  ///
  /// Parameters:
  /// - [limit]: Maximum number of calculations to retrieve
  Future<List<ThirteenthSalaryCalculationModel>> getAll({int limit = 10});

  /// Retrieves a specific calculation by ID
  Future<ThirteenthSalaryCalculationModel?> getById(String id);

  /// Deletes a specific calculation
  Future<void> delete(String id);

  /// Clears all calculations
  Future<void> clearAll();
}

/// Implementation of 13th salary local data source
///
/// Follows Dependency Inversion Principle (DIP):
/// - Depends on SharedPreferences abstraction
class ThirteenthSalaryLocalDataSourceImpl
    implements ThirteenthSalaryLocalDataSource {
  static const String _storagePrefix = 'thirteenth_salary_calculations';
  static const String _idsKey = '${_storagePrefix}_ids';
  final SharedPreferences _prefs;

  ThirteenthSalaryLocalDataSourceImpl(this._prefs);

  String _getKey(String id) => '$_storagePrefix:$id';

  Future<List<String>> _getStoredIds() async {
    return _prefs.getStringList(_idsKey) ?? [];
  }

  Future<void> _saveIds(List<String> ids) async {
    await _prefs.setStringList(_idsKey, ids);
  }

  @override
  Future<ThirteenthSalaryCalculationModel> save(
    ThirteenthSalaryCalculationModel model,
  ) async {
    try {
      final jsonString = jsonEncode(model.toJson());
      await _prefs.setString(_getKey(model.id), jsonString);

      final ids = await _getStoredIds();
      if (!ids.contains(model.id)) {
        ids.add(model.id);
        await _saveIds(ids);
      }

      return model;
    } catch (e) {
      throw CacheException('Erro ao salvar cálculo: $e');
    }
  }

  @override
  Future<List<ThirteenthSalaryCalculationModel>> getAll({
    int limit = 10,
  }) async {
    try {
      final ids = await _getStoredIds();
      final values = <ThirteenthSalaryCalculationModel>[];

      for (final id in ids) {
        final jsonString = _prefs.getString(_getKey(id));
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          values.add(ThirteenthSalaryCalculationModel.fromJson(json));
        }
      }

      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

      if (values.length > limit) {
        return values.sublist(0, limit);
      }

      return values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<ThirteenthSalaryCalculationModel?> getById(String id) async {
    try {
      final jsonString = _prefs.getString(_getKey(id));
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ThirteenthSalaryCalculationModel.fromJson(json);
    } catch (e) {
      throw CacheException('Erro ao recuperar cálculo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _prefs.remove(_getKey(id));

      final ids = await _getStoredIds();
      ids.remove(id);
      await _saveIds(ids);
    } catch (e) {
      throw CacheException('Erro ao deletar cálculo: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final ids = await _getStoredIds();
      for (final id in ids) {
        await _prefs.remove(_getKey(id));
      }
      await _prefs.remove(_idsKey);
    } catch (e) {
      throw CacheException('Erro ao limpar histórico: $e');
    }
  }
}

/// Extension to add initialization method for backwards compatibility
extension ThirteenthSalaryLocalDataSourceImplExtension
    on ThirteenthSalaryLocalDataSourceImpl {
  static Future<void> initialize() async {
    // No initialization needed for SharedPreferences
  }
}
