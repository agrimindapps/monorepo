import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/device_entity.dart';
import '../../../domain/repositories/i_local_storage_repository.dart';
import '../../../shared/utils/failure.dart';

/// Interface para datasource local de dispositivos
/// Define operações de cache para dispositivos
abstract class DeviceLocalDataSource {
  /// Obtém todos os dispositivos do usuário do cache local
  Future<Either<Failure, List<DeviceEntity>>> getCachedDevices(String userId);

  /// Obtém dispositivo específico do cache local
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String deviceUuid);

  /// Salva dispositivos do usuário no cache local
  Future<Either<Failure, void>> cacheDevices(
    String userId,
    List<DeviceEntity> devices,
  );

  /// Atualiza um dispositivo específico no cache local
  Future<Either<Failure, void>> updateDevice(
    String userId,
    DeviceEntity device,
  );

  /// Remove dispositivo do cache local
  Future<Either<Failure, void>> removeDevice(String userId, String deviceUuid);

  /// Limpa todo o cache do usuário
  Future<Either<Failure, void>> clearCache(String userId);

  /// Verifica se há dados em cache para o usuário
  Future<bool> hasDevicesCache(String userId);
}

/// Implementação do datasource local usando ILocalStorageRepository
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final ILocalStorageRepository _localStorage;

  static const String _devicesBox = 'user_devices';
  static const Duration _cacheExpiry = Duration(hours: 1);

  DeviceLocalDataSourceImpl({required ILocalStorageRepository localStorage})
      : _localStorage = localStorage;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getCachedDevices(
    String userId,
  ) async {
    try {
      final cacheKey = '${userId}_devices';
      final timestampKey = '${userId}_devices_timestamp';

      // Verificar timestamp do cache
      final timestampResult = await _localStorage.get<int>(
        key: timestampKey,
        box: _devicesBox,
      );

      return await timestampResult.fold(
        (failure) async => const Right(<DeviceEntity>[]),
        (timestamp) async {
          if (timestamp != null) {
            final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final now = DateTime.now();

            // Cache expirado
            if (now.difference(cachedAt) > _cacheExpiry) {
              await _clearUserCache(userId);
              return const Right(<DeviceEntity>[]);
            }
          }

          // Buscar dispositivos do cache
          final cachedResult = await _localStorage
              .getList<Map<String, dynamic>>(key: cacheKey, box: _devicesBox);

          return cachedResult.fold(
            (failure) => const Right(<DeviceEntity>[]),
            (cached) {
              if (cached.isEmpty) {
                return const Right(<DeviceEntity>[]);
              }

              final devices = cached
                  .map((deviceMap) => DeviceEntity.fromJson(deviceMap))
                  .toList();

              if (kDebugMode) {
                debugPrint(
                  '📱 DeviceLocalDataSource: Loaded ${devices.length} devices from cache',
                );
              }

              return Right(devices);
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error getting cached devices - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao recuperar dispositivos do cache: $e',
          code: 'CACHE_GET_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(
    String deviceUuid,
  ) async {
    try {
      // Buscar em todos os caches de usuário
      final keysResult = await _localStorage.getKeys(box: _devicesBox);

      return await keysResult.fold(
        (failure) async => const Right(null),
        (allKeys) async {
          for (final key in allKeys) {
            if (key.endsWith('_devices')) {
              final devicesResult = await _localStorage
                  .getList<Map<String, dynamic>>(key: key, box: _devicesBox);

              final deviceFound = await devicesResult.fold(
                (failure) async => null,
                (devices) async {
                  for (final deviceMap in devices) {
                    final device = DeviceEntity.fromJson(deviceMap);
                    if (device.uuid == deviceUuid) {
                      return device;
                    }
                  }
                  return null;
                },
              );

              if (deviceFound != null) {
                return Right(deviceFound);
              }
            }
          }

          return const Right(null);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error getting device by UUID - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao buscar dispositivo por UUID: $e',
          code: 'DEVICE_SEARCH_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cacheDevices(
    String userId,
    List<DeviceEntity> devices,
  ) async {
    try {
      final cacheKey = '${userId}_devices';
      final timestampKey = '${userId}_devices_timestamp';

      // Converter dispositivos para JSON
      final deviceMaps = devices.map((device) => device.toJson()).toList();

      // Salvar dispositivos
      final saveDevicesResult = await _localStorage.saveList<Map<String, dynamic>>(
        key: cacheKey,
        data: deviceMaps,
        box: _devicesBox,
      );

      if (saveDevicesResult.isLeft()) {
        return saveDevicesResult;
      }

      // Salvar timestamp
      final saveTimestampResult = await _localStorage.save<int>(
        key: timestampKey,
        data: DateTime.now().millisecondsSinceEpoch,
        box: _devicesBox,
      );

      if (kDebugMode) {
        debugPrint(
          '📱 DeviceLocalDataSource: Cached ${devices.length} devices for user $userId',
        );
      }

      return saveTimestampResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error caching devices - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao armazenar dispositivos no cache: $e',
          code: 'CACHE_PUT_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateDevice(
    String userId,
    DeviceEntity device,
  ) async {
    try {
      final devicesResult = await getCachedDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) async {
          // Atualizar ou adicionar dispositivo
          final updatedDevices = devices.map((existingDevice) {
            return existingDevice.uuid == device.uuid ? device : existingDevice;
          }).toList();

          // Se não existia, adicionar
          if (!devices.any((d) => d.uuid == device.uuid)) {
            updatedDevices.add(device);
          }

          return await cacheDevices(userId, updatedDevices);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error updating device - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao atualizar dispositivo no cache: $e',
          code: 'DEVICE_UPDATE_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeDevice(
    String userId,
    String deviceUuid,
  ) async {
    try {
      final devicesResult = await getCachedDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) async {
          final updatedDevices =
              devices.where((device) => device.uuid != deviceUuid).toList();
          return await cacheDevices(userId, updatedDevices);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error removing device - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao remover dispositivo do cache: $e',
          code: 'DEVICE_REMOVE_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache(String userId) async {
    try {
      await _clearUserCache(userId);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceLocalDataSource: Error clearing cache - $e');
      }
      return Left(
        CacheFailure(
          'Erro ao limpar cache: $e',
          code: 'CACHE_CLEAR_ERROR',
        ),
      );
    }
  }

  @override
  Future<bool> hasDevicesCache(String userId) async {
    final cacheKey = '${userId}_devices';
    final result = await _localStorage.getList<Map<String, dynamic>>(
      key: cacheKey,
      box: _devicesBox,
    );
    
    return result.fold(
      (failure) => false,
      (devices) => devices.isNotEmpty,
    );
  }

  /// Limpa cache específico do usuário
  Future<void> _clearUserCache(String userId) async {
    await _localStorage.remove(key: '${userId}_devices', box: _devicesBox);
    await _localStorage.remove(
      key: '${userId}_devices_timestamp',
      box: _devicesBox,
    );
    
    if (kDebugMode) {
      debugPrint('📱 DeviceLocalDataSource: Cleared cache for user $userId');
    }
  }
}
