import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Helper function to safely convert any Map to Map<String, dynamic>
/// Handles LinkedMap, IdentityMap, and other Hive internal map types
Map<String, dynamic> _safeConvertToMap(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Failed to convert map of type ${value.runtimeType}: $e',
        );
      }
      // Return empty map as fallback
      return {};
    }
  }
  return {};
}

/// Serviço responsável por gerenciar dados locais
/// Usado especialmente para o modo anônimo onde os dados não são sincronizados com o Firebase
@singleton
class LocalDataService {
  static const String _vehiclesBoxName = 'vehicles_local';
  static const String _fuelRecordsBoxName = 'fuel_records_local';
  static const String _maintenanceBoxName = 'maintenance_local';
  static const String _userPreferencesKey = 'user_preferences';

  late Box<dynamic> _vehiclesBox;
  late Box<dynamic> _fuelRecordsBox;
  late Box<dynamic> _maintenanceBox;
  SharedPreferences? _prefs;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de dados locais
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _vehiclesBox = await Hive.openBox(_vehiclesBoxName);
      _fuelRecordsBox = await Hive.openBox(_fuelRecordsBoxName);
      _maintenanceBox = await Hive.openBox(_maintenanceBoxName);
      _prefs = await SharedPreferences.getInstance();

      _isInitialized = true;
      debugPrint('LocalDataService inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar LocalDataService: $e');
      rethrow;
    }
  }

  /// Limpa todos os dados locais
  Future<void> clearAllData() async {
    await _ensureInitialized();

    try {
      await Future.wait([
        _vehiclesBox.clear(),
        _fuelRecordsBox.clear(),
        _maintenanceBox.clear(),
        _prefs!.clear(),
      ]);
      debugPrint('Todos os dados locais foram limpos');
    } catch (e) {
      debugPrint('Erro ao limpar dados locais: $e');
      rethrow;
    }
  }

  /// Salva um veículo localmente
  Future<void> saveVehicle(String id, Map<String, dynamic> vehicleData) async {
    await _ensureInitialized();
    await _vehiclesBox.put(id, vehicleData);
  }

  /// Obtém um veículo pelo ID
  Map<String, dynamic>? getVehicle(String id) {
    _ensureInitialized();
    final data = _vehiclesBox.get(id);
    return data != null ? _safeConvertToMap(data) : null;
  }

  /// Obtém todos os veículos
  List<Map<String, dynamic>> getAllVehicles() {
    _ensureInitialized();
    return _vehiclesBox.values.map(_safeConvertToMap).toList();
  }

  /// Remove um veículo
  Future<void> deleteVehicle(String id) async {
    await _ensureInitialized();
    await _vehiclesBox.delete(id);
  }

  /// Salva um registro de combustível
  Future<void> saveFuelRecord(String id, Map<String, dynamic> fuelData) async {
    await _ensureInitialized();
    await _fuelRecordsBox.put(id, fuelData);
  }

  /// Obtém um registro de combustível pelo ID
  Map<String, dynamic>? getFuelRecord(String id) {
    _ensureInitialized();
    final data = _fuelRecordsBox.get(id);
    return data != null ? _safeConvertToMap(data) : null;
  }

  /// Obtém todos os registros de combustível
  List<Map<String, dynamic>> getAllFuelRecords() {
    _ensureInitialized();
    return _fuelRecordsBox.values.map(_safeConvertToMap).toList();
  }

  /// Obtém registros de combustível por veículo
  List<Map<String, dynamic>> getFuelRecordsByVehicle(String vehicleId) {
    _ensureInitialized();
    return _fuelRecordsBox.values
        .where(
          (record) => _safeConvertToMap(record)['vehicleId'] == vehicleId,
        )
        .map(_safeConvertToMap)
        .toList();
  }

  /// Remove um registro de combustível
  Future<void> deleteFuelRecord(String id) async {
    await _ensureInitialized();
    await _fuelRecordsBox.delete(id);
  }

  /// Salva um registro de manutenção
  Future<void> saveMaintenanceRecord(
    String id,
    Map<String, dynamic> maintenanceData,
  ) async {
    await _ensureInitialized();
    await _maintenanceBox.put(id, maintenanceData);
  }

  /// Obtém um registro de manutenção pelo ID
  Map<String, dynamic>? getMaintenanceRecord(String id) {
    _ensureInitialized();
    final data = _maintenanceBox.get(id);
    return data != null ? _safeConvertToMap(data) : null;
  }

  /// Obtém todos os registros de manutenção
  List<Map<String, dynamic>> getAllMaintenanceRecords() {
    _ensureInitialized();
    return _maintenanceBox.values.map(_safeConvertToMap).toList();
  }

  /// Obtém registros de manutenção por veículo
  List<Map<String, dynamic>> getMaintenanceRecordsByVehicle(String vehicleId) {
    _ensureInitialized();
    return _maintenanceBox.values
        .where(
          (record) => _safeConvertToMap(record)['vehicleId'] == vehicleId,
        )
        .map(_safeConvertToMap)
        .toList();
  }

  /// Remove um registro de manutenção
  Future<void> deleteMaintenanceRecord(String id) async {
    await _ensureInitialized();
    await _maintenanceBox.delete(id);
  }

  /// Salva preferências do usuário
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _ensureInitialized();

    for (final entry in preferences.entries) {
      final value = entry.value;

      if (value is String) {
        await _prefs!.setString('${_userPreferencesKey}_${entry.key}', value);
      } else if (value is int) {
        await _prefs!.setInt('${_userPreferencesKey}_${entry.key}', value);
      } else if (value is double) {
        await _prefs!.setDouble('${_userPreferencesKey}_${entry.key}', value);
      } else if (value is bool) {
        await _prefs!.setBool('${_userPreferencesKey}_${entry.key}', value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(
          '${_userPreferencesKey}_${entry.key}',
          value,
        );
      }
    }
  }

  /// Obtém preferências do usuário
  Map<String, dynamic> getUserPreferences() {
    _ensureInitialized();

    final preferences = <String, dynamic>{};
    final keys =
        _prefs!
            .getKeys()
            .where((key) => key.startsWith(_userPreferencesKey))
            .toList();

    for (final key in keys) {
      final actualKey = key.replaceFirst('${_userPreferencesKey}_', '');
      preferences[actualKey] = _prefs!.get(key);
    }

    return preferences;
  }

  /// Remove uma preferência específica
  Future<void> removeUserPreference(String key) async {
    await _ensureInitialized();
    await _prefs!.remove('${_userPreferencesKey}_$key');
  }

  /// Obtém estatísticas de consumo
  Map<String, dynamic> getConsumptionStats(String vehicleId) {
    _ensureInitialized();

    final fuelRecords = getFuelRecordsByVehicle(vehicleId);

    if (fuelRecords.isEmpty) {
      return {
        'totalFuelConsumed': 0.0,
        'totalDistance': 0.0,
        'averageConsumption': 0.0,
        'totalSpent': 0.0,
        'recordsCount': 0,
      };
    }

    double totalFuel = 0;
    double totalSpent = 0;
    double totalDistance = 0;

    for (final record in fuelRecords) {
      totalFuel += (record['liters'] as num?)?.toDouble() ?? 0.0;
      totalSpent += (record['totalCost'] as num?)?.toDouble() ?? 0.0;
      totalDistance += (record['distance'] as num?)?.toDouble() ?? 0.0;
    }

    final averageConsumption =
        totalDistance > 0 ? totalDistance / totalFuel : 0.0;

    return {
      'totalFuelConsumed': totalFuel,
      'totalDistance': totalDistance,
      'averageConsumption': averageConsumption,
      'totalSpent': totalSpent,
      'recordsCount': fuelRecords.length,
    };
  }

  /// Verifica se existe dados locais
  bool hasLocalData() {
    if (!_isInitialized) return false;

    return _vehiclesBox.isNotEmpty ||
        _fuelRecordsBox.isNotEmpty ||
        _maintenanceBox.isNotEmpty;
  }

  /// Obtém resumo dos dados locais
  Map<String, int> getLocalDataSummary() {
    if (!_isInitialized) {
      return {'vehicles': 0, 'fuelRecords': 0, 'maintenanceRecords': 0};
    }

    return {
      'vehicles': _vehiclesBox.length,
      'fuelRecords': _fuelRecordsBox.length,
      'maintenanceRecords': _maintenanceBox.length,
    };
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose e limpeza de recursos
  Future<void> dispose() async {
    if (_isInitialized) {
      await _vehiclesBox.close();
      await _fuelRecordsBox.close();
      await _maintenanceBox.close();
      _isInitialized = false;
    }
  }
}
