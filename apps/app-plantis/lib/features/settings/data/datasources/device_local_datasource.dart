import 'dart:convert';

import 'package:core/core.dart' hide Column;

/// Datasource local para gerenciamento de cache de dispositivos
/// Usa SharedPreferences para persistência offline
class DeviceLocalDataSource {
  static const String _keyPrefix = 'device_cache_';
  static const String _devicesKey = 'user_devices';

  final SharedPreferences _prefs;

  DeviceLocalDataSource(this._prefs);

  /// Inicializa o datasource (compatibilidade com versão anterior)
  Future<void> init() async {
    // No initialization needed for SharedPreferences
  }

  /// Armazena a lista de dispositivos do usuário em cache
  Future<void> cacheUserDevices(
    String userId,
    List<DeviceEntity> devices,
  ) async {
    try {
      final key = _getUserDevicesKey(userId);

      // Converte devices para JSON serializável
      final devicesJson = devices.map((d) => d.toJson()).toList();

      final cacheData = {
        'devices': devicesJson,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _prefs.setString(key, jsonEncode(cacheData));
    } catch (e) {
      throw CacheFailure(
        'Erro ao armazenar dispositivos em cache',
        code: 'CACHE_DEVICES_ERROR',
        details: e,
      );
    }
  }

  /// Recupera dispositivos do cache
  Future<List<DeviceEntity>> getCachedDevices(String userId) async {
    try {
      final key = _getUserDevicesKey(userId);
      final cachedString = _prefs.getString(key);

      if (cachedString == null) {
        return [];
      }

      final cached = jsonDecode(cachedString) as Map<String, dynamic>;
      final devicesList = cached['devices'] as List<dynamic>?;

      if (devicesList == null || devicesList.isEmpty) {
        return [];
      }

      // Converte JSON para DeviceEntity
      return devicesList
          .map((json) => DeviceEntity.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao recuperar dispositivos do cache',
        code: 'GET_CACHED_DEVICES_ERROR',
        details: e,
      );
    }
  }

  /// Remove um dispositivo específico do cache
  Future<void> removeDevice(String userId, String deviceUuid) async {
    try {
      final key = _getUserDevicesKey(userId);
      final cachedString = _prefs.getString(key);

      if (cachedString == null) return;

      final cached = jsonDecode(cachedString) as Map<String, dynamic>;
      final devicesList = cached['devices'] as List<dynamic>?;

      if (devicesList == null || devicesList.isEmpty) return;

      // Remove o dispositivo da lista
      final updatedDevices = devicesList
          .map((json) => DeviceEntity.fromJson(Map<String, dynamic>.from(json as Map)))
          .where((device) => device.uuid != deviceUuid)
          .toList();

      // Atualiza cache
      final updatedCache = {
        'devices': updatedDevices.map((d) => d.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _prefs.setString(key, jsonEncode(updatedCache));
    } catch (e) {
      throw CacheFailure(
        'Erro ao remover dispositivo do cache',
        code: 'REMOVE_DEVICE_ERROR',
        details: e,
      );
    }
  }

  /// Limpa todo o cache de dispositivos
  Future<void> clearCache() async {
    try {
      // Remove all keys with the device cache prefix
      final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao limpar cache',
        code: 'CLEAR_CACHE_ERROR',
        details: e,
      );
    }
  }

  /// Verifica se existe cache válido (menos de 24h)
  Future<bool> hasFreshCache(String userId) async {
    try {
      final key = _getUserDevicesKey(userId);
      final cachedString = _prefs.getString(key);

      if (cachedString == null) return false;

      final cached = jsonDecode(cachedString) as Map<String, dynamic>;
      final cachedAtStr = cached['cachedAt'] as String?;
      
      if (cachedAtStr == null) return false;

      final cachedAt = DateTime.parse(cachedAtStr);
      final now = DateTime.now();

      // Cache válido por 24 horas
      return now.difference(cachedAt).inHours < 24;
    } catch (e) {
      return false;
    }
  }

  /// Gera chave única por usuário
  String _getUserDevicesKey(String userId) => '$_keyPrefix${_devicesKey}_$userId';

  /// Fecha o datasource (compatibilidade com versão anterior)
  Future<void> dispose() async {
    // No cleanup needed for SharedPreferences
  }
}
