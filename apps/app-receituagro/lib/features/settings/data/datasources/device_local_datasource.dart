import 'package:core/core.dart';
import 'package:core/core.dart';

/// Local data source para armazenamento de dispositivos
/// Usa Hive para cache local temporário
abstract class DeviceLocalDataSource {
  Future<Either<Failure, List<DeviceEntity>>> getCachedDevices(String userId);
  Future<Either<Failure, void>> cacheDevices(
    String userId,
    List<DeviceEntity> devices,
  );
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String uuid);
  Future<Either<Failure, void>> clearCache(String userId);
  Future<Either<Failure, void>> removeDevice(String userId, String deviceUuid);
  Future<Either<Failure, void>> updateDevice(
    String userId,
    DeviceEntity device,
  );
}

/// Implementação do datasource local usando Hive
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

      // Verificar se o cache ainda é válido
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

            if (now.difference(cachedAt) > _cacheExpiry) {
              // Cache expirado, limpar
              await _clearUserCache(userId);
              return const Right(<DeviceEntity>[]);
            }
          }

          // Recuperar dispositivos do cache
          final cachedResult = await _localStorage
              .getList<Map<String, dynamic>>(key: cacheKey, box: _devicesBox);

          return cachedResult.fold((failure) => const Right(<DeviceEntity>[]), (
            cached,
          ) {
            if (cached.isEmpty) {
              return const Right(<DeviceEntity>[]);
            }

            // Converter para entities
            final devices =
                cached
                    .map((deviceMap) => DeviceEntity.fromJson(deviceMap))
                    .toList();

            return Right(devices);
          });
        },
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao recuperar dispositivos do cache: $e',
          code: 'CACHE_GET_ERROR',
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

      // Converter entities para maps
      final deviceMaps = devices.map((device) => device.toJson()).toList();

      // Armazenar dispositivos
      final saveDevicesResult = await _localStorage
          .saveList<Map<String, dynamic>>(
            key: cacheKey,
            data: deviceMaps,
            box: _devicesBox,
          );

      if (saveDevicesResult.isLeft()) {
        return saveDevicesResult;
      }

      // Armazenar timestamp
      final saveTimestampResult = await _localStorage.save<int>(
        key: timestampKey,
        data: DateTime.now().millisecondsSinceEpoch,
        box: _devicesBox,
      );

      return saveTimestampResult;
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao armazenar dispositivos no cache: $e',
          code: 'CACHE_PUT_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String uuid) async {
    try {
      // Buscar em todos os caches de usuários
      final keysResult = await _localStorage.getKeys(box: _devicesBox);

      return await keysResult.fold((failure) async => const Right(null), (
        allKeys,
      ) async {
        for (final key in allKeys) {
          if (key.endsWith('_devices')) {
            final devicesResult = await _localStorage
                .getList<Map<String, dynamic>>(key: key, box: _devicesBox);

            final deviceFound = await devicesResult.fold(
              (failure) async => null,
              (devices) async {
                for (final deviceMap in devices) {
                  final device = DeviceEntity.fromJson(deviceMap);
                  if (device.uuid == uuid) {
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
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar dispositivo por UUID: $e',
          code: 'DEVICE_SEARCH_ERROR',
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
      return Left(
        CacheFailure('Erro ao limpar cache: $e', code: 'CACHE_CLEAR_ERROR'),
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

      return devicesResult.fold((failure) => Left(failure), (devices) async {
        // Remover dispositivo da lista
        final updatedDevices =
            devices.where((device) => device.uuid != deviceUuid).toList();

        // Atualizar cache
        return await cacheDevices(userId, updatedDevices);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao remover dispositivo do cache: $e',
          code: 'DEVICE_REMOVE_ERROR',
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

      return devicesResult.fold((failure) => Left(failure), (devices) async {
        // Encontrar e atualizar dispositivo
        final updatedDevices =
            devices.map((existingDevice) {
              return existingDevice.uuid == device.uuid
                  ? device
                  : existingDevice;
            }).toList();

        // Se o dispositivo não existe, adicionar
        if (!devices.any((d) => d.uuid == device.uuid)) {
          updatedDevices.add(device);
        }

        // Atualizar cache
        return await cacheDevices(userId, updatedDevices);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao atualizar dispositivo no cache: $e',
          code: 'DEVICE_UPDATE_ERROR',
        ),
      );
    }
  }

  /// Limpa cache específico do usuário
  Future<void> _clearUserCache(String userId) async {
    await _localStorage.remove(key: '${userId}_devices', box: _devicesBox);
    await _localStorage.remove(
      key: '${userId}_devices_timestamp',
      box: _devicesBox,
    );
  }
}
