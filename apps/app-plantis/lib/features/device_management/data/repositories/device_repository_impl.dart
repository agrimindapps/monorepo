import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../../domain/repositories/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';

/// Implementação simplificada do repository de dispositivos
/// Implementação mínima para compilar - usa stub implementations
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remoteDataSource;
  final DeviceLocalDataSource _localDataSource;

  DeviceRepositoryImpl({
    required DeviceRemoteDataSource remoteDataSource,
    required DeviceLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting devices for user $userId (stub)');
      }

      // Por enquanto, retorna apenas do cache local
      final result = await _localDataSource.getUserDevices(userId);

      return result.fold(
        (failure) => Left(failure),
        (devices) {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Found ${devices.length} devices');
          }
          return Right(devices);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos do usuário',
          code: 'GET_USER_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting device $deviceUuid (stub)');
      }

      return await _localDataSource.getDeviceByUuid(deviceUuid);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivo',
          code: 'GET_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Validating device ${device.uuid} (stub)');
      }

      // Simulação simples - apenas salva no cache local
      await _localDataSource.saveDevice(device);

      return Right(device);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao validar dispositivo',
          code: 'VALIDATE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Revoking device $deviceUuid (stub)');
      }

      // Remove do cache local
      return await _localDataSource.removeDevice(deviceUuid);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar dispositivo',
          code: 'REVOKE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Revoking all other devices (stub)');
      }

      // Obtém todos os dispositivos
      final devicesResult = await _localDataSource.getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) async {
          // Remove todos exceto o atual
          for (final device in devices) {
            if (device.uuid != currentDeviceUuid) {
              await _localDataSource.removeDevice(device.uuid);
            }
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos',
          code: 'REVOKE_ALL_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Updating last activity for $deviceUuid (stub)');
      }

      // Busca o dispositivo atual
      final deviceResult = await _localDataSource.getDeviceByUuid(deviceUuid);

      return deviceResult.fold(
        (failure) => Left(failure),
        (device) async {
          if (device == null) {
            return Left(
              NotFoundFailure('Dispositivo não encontrado: $deviceUuid'),
            );
          }

          // Cria uma nova instância com timestamp atualizado
          final updatedDevice = DeviceModel(
            id: device.id,
            uuid: device.uuid,
            name: device.name,
            model: device.model,
            platform: device.platform,
            systemVersion: device.systemVersion,
            appVersion: device.appVersion,
            buildNumber: device.buildNumber,
            isPhysicalDevice: device.isPhysicalDevice,
            manufacturer: device.manufacturer,
            firstLoginAt: device.firstLoginAt,
            lastActiveAt: DateTime.now(), // Atualiza timestamp
            isActive: device.isActive,
            createdAt: device.createdAt,
            updatedAt: DateTime.now(),
            plantisSpecificData: device.plantisSpecificData,
          );

          // Salva no cache
          await _localDataSource.saveDevice(updatedDevice);

          return Right(updatedDevice);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao atualizar última atividade',
          code: 'UPDATE_ACTIVITY_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Checking if user $userId can add more devices (stub)');
      }

      final devicesResult = await _localDataSource.getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          final activeDevices = devices.where((d) => d.isActive).length;
          final canAdd = activeDevices < 3; // Limite padrão
          return Right(canAdd);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite de dispositivos',
          code: 'CHECK_DEVICE_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting active device count for $userId (stub)');
      }

      final devicesResult = await _localDataSource.getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          final activeCount = devices.where((d) => d.isActive).length;
          return Right(activeCount);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao contar dispositivos ativos',
          code: 'COUNT_ACTIVE_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting device statistics for $userId (stub)');
      }

      return await _localDataSource.getDeviceStatistics(userId);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos',
          code: 'GET_STATISTICS_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Syncing devices for $userId (stub)');
      }

      // Por enquanto, apenas retorna os dispositivos do cache
      return await _localDataSource.getUserDevices(userId);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao sincronizar dispositivos',
          code: 'SYNC_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Clearing cache (stub)');
      }

      return await _localDataSource.clearAll();
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao limpar cache de dispositivos',
          code: 'CLEAR_CACHE_ERROR',
          details: e,
        ),
      );
    }
  }
}