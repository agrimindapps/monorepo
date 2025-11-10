import 'package:core/core.dart' hide Column;

/// Datasource local para gerenciamento de cache de dispositivos
/// Usa Hive para persistência offline
class DeviceLocalDataSource {
  static const String _boxName = 'device_cache';
  static const String _devicesKey = 'user_devices';

  Box<dynamic>? _box;

  /// Inicializa o box do Hive (chamado pelo DI)
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<dynamic>(_boxName);
    }
  }

  /// Retorna o box, inicializando se necessário
  Future<Box<dynamic>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  /// Armazena a lista de dispositivos do usuário em cache
  Future<void> cacheUserDevices(
    String userId,
    List<DeviceEntity> devices,
  ) async {
    try {
      final box = await _getBox();
      final key = _getUserDevicesKey(userId);

      // Converte devices para JSON serializável
      final devicesJson = devices.map((d) => d.toJson()).toList();

      await box.put(key, {
        'devices': devicesJson,
        'cachedAt': DateTime.now().toIso8601String(),
      });
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
      final box = await _getBox();
      final key = _getUserDevicesKey(userId);

      final cached = box.get(key) as Map<dynamic, dynamic>?;

      if (cached == null) {
        return [];
      }

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
      final box = await _getBox();
      final key = _getUserDevicesKey(userId);

      final cached = box.get(key) as Map<dynamic, dynamic>?;

      if (cached == null) return;

      final devicesList = cached['devices'] as List<dynamic>?;

      if (devicesList == null || devicesList.isEmpty) return;

      // Remove o dispositivo da lista
      final updatedDevices = devicesList
          .map((json) => DeviceEntity.fromJson(Map<String, dynamic>.from(json as Map)))
          .where((device) => device.uuid != deviceUuid)
          .toList();

      // Atualiza cache
      await box.put(key, {
        'devices': updatedDevices.map((d) => d.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      });
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
      final box = await _getBox();
      await box.clear();
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
      final box = await _getBox();
      final key = _getUserDevicesKey(userId);

      final cached = box.get(key) as Map<dynamic, dynamic>?;

      if (cached == null) return false;

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
  String _getUserDevicesKey(String userId) => '${_devicesKey}_$userId';

  /// Fecha o box (chamado no dispose do app)
  Future<void> dispose() async {
    await _box?.close();
  }
}
