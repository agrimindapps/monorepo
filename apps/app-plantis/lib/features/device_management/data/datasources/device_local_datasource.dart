import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../models/device_model.dart';

/// Interface para datasource local de dispositivos
abstract class DeviceLocalDataSource {
  /// Obtém todos os dispositivos do usuário do cache local
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);

  /// Obtém dispositivo específico do cache local
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);

  /// Salva dispositivos do usuário no cache local
  Future<Either<Failure, void>> saveUserDevices(
    String userId,
    List<DeviceModel> devices,
  );

  /// Salva um dispositivo específico no cache local
  Future<Either<Failure, void>> saveDevice(DeviceModel device);

  /// Remove dispositivo do cache local
  Future<Either<Failure, void>> removeDevice(String deviceUuid);

  /// Remove todos os dispositivos do usuário do cache local
  Future<Either<Failure, void>> removeUserDevices(String userId);

  /// Obtém estatísticas dos dispositivos do cache
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(
    String userId,
  );

  Future<Either<Failure, void>> clearAll();

  /// Verifica se há dados em cache para o usuário
  Future<bool> hasDevicesCache(String userId);
}

/// Implementação com cache persistente usando Hive
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final ILocalStorageRepository _storageService;
  static const String _devicesBoxKey = 'devices_cache';
  static const String _userDevicesBoxKey = 'user_devices_cache';
  static const String _statisticsBoxKey = 'device_statistics_cache';
  final Map<String, List<DeviceModel>> _memoryUserDevicesCache = {};
  final Map<String, DeviceModel> _memoryDevicesCache = {};
  bool _isMemoryCacheInitialized = false;

  DeviceLocalDataSourceImpl({required ILocalStorageRepository storageService})
    : _storageService = storageService;

  /// Inicializa cache em memória do Hive se necessário
  Future<void> _ensureMemoryCacheInitialized() async {
    if (_isMemoryCacheInitialized) return;

    try {
      final deviceKeysResult = await _storageService.getKeys(
        box: _devicesBoxKey,
      );
      deviceKeysResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '📱 DeviceLocal: Could not load device keys from Hive: ${failure.message}',
            );
          }
        },
        (deviceKeys) {
          for (final deviceUuid in deviceKeys) {
            _storageService
                .get<Map<String, dynamic>>(key: deviceUuid, box: _devicesBoxKey)
                .then((result) {
                  result.fold(
                    (failure) {
                      if (kDebugMode) {
                        debugPrint(
                          '📱 DeviceLocal: Error loading device $deviceUuid: ${failure.message}',
                        );
                      }
                    },
                    (deviceData) {
                      if (deviceData != null) {
                        try {
                          final device = DeviceModel.fromJson(deviceData);
                          _memoryDevicesCache[deviceUuid] = device;
                        } catch (e) {
                          if (kDebugMode) {
                            debugPrint(
                              '📱 DeviceLocal: Error parsing device $deviceUuid: $e',
                            );
                          }
                        }
                      }
                    },
                  );
                });
          }
        },
      );

      final userKeysResult = await _storageService.getKeys(
        box: _userDevicesBoxKey,
      );
      userKeysResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '📱 DeviceLocal: Could not load user keys from Hive: ${failure.message}',
            );
          }
        },
        (userKeys) {
          for (final userId in userKeys) {
            _storageService
                .get<List<String>>(key: userId, box: _userDevicesBoxKey)
                .then((result) {
                  result.fold(
                    (failure) {
                      if (kDebugMode) {
                        debugPrint(
                          '📱 DeviceLocal: Error loading user devices $userId: ${failure.message}',
                        );
                      }
                    },
                    (deviceUuids) {
                      if (deviceUuids != null) {
                        try {
                          final devices =
                              deviceUuids
                                  .map((uuid) => _memoryDevicesCache[uuid])
                                  .where((device) => device != null)
                                  .cast<DeviceModel>()
                                  .toList();
                          _memoryUserDevicesCache[userId] = devices;
                        } catch (e) {
                          if (kDebugMode) {
                            debugPrint(
                              '📱 DeviceLocal: Error parsing user devices $userId: $e',
                            );
                          }
                        }
                      }
                    },
                  );
                });
          }
        },
      );

      _isMemoryCacheInitialized = true;
      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Memory cache initialized - ${_memoryDevicesCache.length} devices, ${_memoryUserDevicesCache.length} user caches',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Error initializing memory cache: $e');
      }
      _isMemoryCacheInitialized =
          true; // Mark as initialized to avoid retry loops
    }
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(
    String userId,
  ) async {
    try {
      await _ensureMemoryCacheInitialized();

      final devices = _memoryUserDevicesCache[userId] ?? [];
      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Getting ${devices.length} devices for user $userId from cache',
        );
      }
      return Right(devices);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dispositivos do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(
    String deviceUuid,
  ) async {
    try {
      await _ensureMemoryCacheInitialized();

      final device = _memoryDevicesCache[deviceUuid];
      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Getting device $deviceUuid - ${device != null ? 'found' : 'not found'}',
        );
      }
      return Right(device);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dispositivo do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserDevices(
    String userId,
    List<DeviceModel> devices,
  ) async {
    try {
      await _ensureMemoryCacheInitialized();
      _memoryUserDevicesCache[userId] = devices;
      for (final device in devices) {
        _memoryDevicesCache[device.uuid] = device;
        await _storageService.save(
          key: device.uuid,
          data: device.toJson(),
          box: _devicesBoxKey,
        );
      }
      final deviceUuids = devices.map((d) => d.uuid).toList();
      await _storageService.save(
        key: userId,
        data: deviceUuids,
        box: _userDevicesBoxKey,
      );

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Saved ${devices.length} devices for user $userId to Hive',
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dispositivos no cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDevice(DeviceModel device) async {
    try {
      await _ensureMemoryCacheInitialized();
      _memoryDevicesCache[device.uuid] = device;
      await _storageService.save(
        key: device.uuid,
        data: device.toJson(),
        box: _devicesBoxKey,
      );

      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Saved device ${device.uuid} to Hive');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dispositivo no cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDevice(String deviceUuid) async {
    try {
      await _ensureMemoryCacheInitialized();
      _memoryDevicesCache.remove(deviceUuid);
      await _storageService.remove(key: deviceUuid, box: _devicesBoxKey);
      for (final userId in _memoryUserDevicesCache.keys.toList()) {
        final devices = _memoryUserDevicesCache[userId] ?? [];
        final originalLength = devices.length;
        devices.removeWhere((device) => device.uuid == deviceUuid);

        if (devices.length != originalLength) {
          if (devices.isEmpty) {
            _memoryUserDevicesCache.remove(userId);
            await _storageService.remove(key: userId, box: _userDevicesBoxKey);
          } else {
            _memoryUserDevicesCache[userId] = devices;
            final deviceUuids = devices.map((d) => d.uuid).toList();
            await _storageService.save(
              key: userId,
              data: deviceUuids,
              box: _userDevicesBoxKey,
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Removed device $deviceUuid from Hive');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dispositivo do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeUserDevices(String userId) async {
    try {
      await _ensureMemoryCacheInitialized();

      final devices = _memoryUserDevicesCache[userId] ?? [];
      for (final device in devices) {
        _memoryDevicesCache.remove(device.uuid);
        await _storageService.remove(key: device.uuid, box: _devicesBoxKey);
      }
      _memoryUserDevicesCache.remove(userId);
      await _storageService.remove(key: userId, box: _userDevicesBoxKey);

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Removed all devices for user $userId from Hive',
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao remover dispositivos do usuário do cache: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(
    String userId,
  ) async {
    try {
      await _ensureMemoryCacheInitialized();
      final cachedStatsResult = await _storageService.get<Map<String, dynamic>>(
        key: userId,
        box: _statisticsBoxKey,
      );
      final hasCachedStats = cachedStatsResult.fold(
        (failure) => false,
        (data) => data != null,
      );
      if (hasCachedStats) {
        final cachedStats = cachedStatsResult.getOrElse(() => null);
        if (cachedStats != null) {
          final timestamp = cachedStats['timestamp'] as int?;
          if (timestamp != null) {
            final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
            const oneHourInMs = 60 * 60 * 1000;

            if (cacheAge < oneHourInMs) {
              if (kDebugMode) {
                debugPrint(
                  '📱 DeviceLocal: Using cached statistics for user $userId',
                );
              }
              return Right(
                Map<String, dynamic>.from(cachedStats)..remove('timestamp'),
              );
            }
          }
        }
      }
      final devices = _memoryUserDevicesCache[userId] ?? [];
      final activeDevices = devices.where((d) => d.isActive).length;
      final totalDevices = devices.length;

      final stats = {
        'total_devices': totalDevices,
        'active_devices': activeDevices,
        'inactive_devices': totalDevices - activeDevices,
        'last_updated': DateTime.now().toIso8601String(),
      };
      final statsToCache = Map<String, dynamic>.from(stats);
      statsToCache['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      await _storageService.save(
        key: userId,
        data: statsToCache,
        box: _statisticsBoxKey,
      );

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocal: Generated and cached statistics for user $userId: $stats',
        );
      }
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      _memoryUserDevicesCache.clear();
      _memoryDevicesCache.clear();
      await _storageService.clear(box: _devicesBoxKey);
      await _storageService.clear(box: _userDevicesBoxKey);
      await _storageService.clear(box: _statisticsBoxKey);

      _isMemoryCacheInitialized = false; // Força reinicialização

      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Cleared all cache from memory and Hive');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  @override
  Future<bool> hasDevicesCache(String userId) async {
    await _ensureMemoryCacheInitialized();

    final hasCache =
        _memoryUserDevicesCache.containsKey(userId) &&
        _memoryUserDevicesCache[userId]!.isNotEmpty;
    if (kDebugMode) {
      debugPrint('📱 DeviceLocal: Has cache for user $userId: $hasCache');
    }
    return hasCache;
  }
}
