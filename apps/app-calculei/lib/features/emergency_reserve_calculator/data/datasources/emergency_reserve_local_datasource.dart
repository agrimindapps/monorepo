import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/emergency_reserve_calculation_model.dart';

abstract class EmergencyReserveLocalDataSource {
  Future<EmergencyReserveCalculationModel> save(
    EmergencyReserveCalculationModel model,
  );
  Future<List<EmergencyReserveCalculationModel>> getAll({int limit = 10});
  Future<EmergencyReserveCalculationModel?> getById(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

class EmergencyReserveLocalDataSourceImpl
    implements EmergencyReserveLocalDataSource {
  static const String _storagePrefix = 'emergency_reserve_calculations';
  static const String _idsKey = '${_storagePrefix}_ids';
  final SharedPreferences _prefs;

  EmergencyReserveLocalDataSourceImpl(this._prefs);

  String _getKey(String id) => '$_storagePrefix:$id';

  Future<List<String>> _getStoredIds() async {
    return _prefs.getStringList(_idsKey) ?? [];
  }

  Future<void> _saveIds(List<String> ids) async {
    await _prefs.setStringList(_idsKey, ids);
  }

  @override
  Future<EmergencyReserveCalculationModel> save(
    EmergencyReserveCalculationModel model,
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
  Future<List<EmergencyReserveCalculationModel>> getAll({
    int limit = 10,
  }) async {
    try {
      final ids = await _getStoredIds();
      final values = <EmergencyReserveCalculationModel>[];

      for (final id in ids) {
        final jsonString = _prefs.getString(_getKey(id));
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          values.add(EmergencyReserveCalculationModel.fromJson(json));
        }
      }

      values.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
      return values.length > limit ? values.sublist(0, limit) : values;
    } catch (e) {
      throw CacheException('Erro ao recuperar histórico: $e');
    }
  }

  @override
  Future<EmergencyReserveCalculationModel?> getById(String id) async {
    try {
      final jsonString = _prefs.getString(_getKey(id));
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return EmergencyReserveCalculationModel.fromJson(json);
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
