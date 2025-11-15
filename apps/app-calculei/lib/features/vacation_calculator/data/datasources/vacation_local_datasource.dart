import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vacation_calculation_model.dart';

/// Local data source for vacation calculations
abstract class VacationLocalDataSource {
  /// Save calculation to local storage
  Future<void> saveCalculation(VacationCalculationModel calculation);

  /// Get all calculations from local storage
  Future<List<VacationCalculationModel>> getCalculations({int? limit});

  /// Get calculation by ID
  Future<VacationCalculationModel?> getCalculationById(String id);

  /// Delete calculation
  Future<void> deleteCalculation(String id);

  /// Clear all calculations
  Future<void> clearAll();
}

@Injectable(as: VacationLocalDataSource)
class VacationLocalDataSourceImpl implements VacationLocalDataSource {
  static const String _storagePrefix = 'vacation_calculations';
  static const String _idsKey = '${_storagePrefix}_ids';
  final SharedPreferences _prefs;

  VacationLocalDataSourceImpl(this._prefs);

  String _getKey(String id) => '${_storagePrefix}:$id';

  Future<List<String>> _getStoredIds() async {
    return _prefs.getStringList(_idsKey) ?? [];
  }

  Future<void> _saveIds(List<String> ids) async {
    await _prefs.setStringList(_idsKey, ids);
  }

  @override
  Future<void> saveCalculation(VacationCalculationModel calculation) async {
    final jsonString = jsonEncode(calculation.toJson());
    await _prefs.setString(_getKey(calculation.id), jsonString);

    final ids = await _getStoredIds();
    if (!ids.contains(calculation.id)) {
      ids.add(calculation.id);
      await _saveIds(ids);
    }
  }

  @override
  Future<List<VacationCalculationModel>> getCalculations({int? limit}) async {
    final ids = await _getStoredIds();
    final calculations = <VacationCalculationModel>[];

    for (final id in ids) {
      final jsonString = _prefs.getString(_getKey(id));
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        calculations.add(VacationCalculationModel.fromJson(json));
      }
    }

    calculations.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

    if (limit != null && limit > 0) {
      return calculations.take(limit).toList();
    }

    return calculations;
  }

  @override
  Future<VacationCalculationModel?> getCalculationById(String id) async {
    final jsonString = _prefs.getString(_getKey(id));
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return VacationCalculationModel.fromJson(json);
  }

  @override
  Future<void> deleteCalculation(String id) async {
    await _prefs.remove(_getKey(id));

    final ids = await _getStoredIds();
    ids.remove(id);
    await _saveIds(ids);
  }

  @override
  Future<void> clearAll() async {
    final ids = await _getStoredIds();
    for (final id in ids) {
      await _prefs.remove(_getKey(id));
    }
    await _prefs.remove(_idsKey);
  }
}

/// Initialize method for backwards compatibility
extension VacationLocalDataSourceImplExtension on VacationLocalDataSourceImpl {
  static Future<void> initialize() async {
    // No initialization needed for SharedPreferences
  }
}
