import 'package:core/core.dart' hide Column;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';

/// Implementação do repositório de dispositivos
/// Segue padrão offline-first: tenta cache local primeiro, depois remoto
class DeviceRepositoryImpl implements IDeviceRepository {
  final DeviceLocalDataSource _localDataSource;
  final DeviceRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  DeviceRepositoryImpl({
    required DeviceLocalDataSource localDataSource,
    required DeviceRemoteDataSource remoteDataSource,
    required ConnectivityService connectivityService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _connectivityService = connectivityService;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(String userId) async {
    try {
      // Verifica conectividade via stream
      final isConnected = await _connectivityService.connectivityStream.first;

      if (isConnected) {
        // Busca do servidor
        try {
          final remoteDevices = await _remoteDataSource.getUserDevices(userId);

          // Atualiza cache
          await _localDataSource.cacheUserDevices(userId, remoteDevices);

          return Right(remoteDevices);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ DeviceRepository: Erro ao buscar do servidor, usando cache');
          }
          // Fallback para cache em caso de erro
          final cachedDevices = await _localDataSource.getCachedDevices(userId);
          return Right(cachedDevices);
        }
      }

      // Offline: usa cache
      final cachedDevices = await _localDataSource.getCachedDevices(userId);
      return Right(cachedDevices);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos',
          code: 'GET_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String deviceUuid) async {
    try {
      // Busca em cache local primeiro (mais rápido)
      // Como não temos userId aqui, retornamos null
      // Este método seria usado pelo core package com acesso direto ao Firestore
      return const Right(null);
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
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  }) async {
    try {
      // Validação é feita pelo DeviceManagementService do core
      // Aqui apenas retornamos o device
      return Right(device);
    } catch (e) {
      return Left(
        ValidationFailure(
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
      final isConnected = await _connectivityService.connectivityStream.first;

      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Sem conexão com a internet',
            code: 'NO_INTERNET',
          ),
        );
      }

      // Revoga no servidor
      await _remoteDataSource.revokeDevice(userId, deviceUuid);

      // Remove do cache local
      await _localDataSource.removeDevice(userId, deviceUuid);

      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);

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
      final isConnected = await _connectivityService.connectivityStream.first;

      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Sem conexão com a internet',
            code: 'NO_INTERNET',
          ),
        );
      }

      // Busca todos os dispositivos
      final devicesResult = await getUserDevices(userId);

      return await devicesResult.fold(
        (failure) async => Left(failure),
        (devices) async {
          // Revoga todos exceto o atual
          for (final device in devices) {
            if (device.uuid != currentDeviceUuid && device.isActive) {
              await revokeDevice(userId: userId, deviceUuid: device.uuid);
            }
          }

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos',
          code: 'REVOKE_ALL_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      // Esta operação seria feita pelo DeviceManagementService do core
      // Retornamos erro não implementado
      return const Left(
        ServerFailure(
          'Método não implementado neste repositório',
          code: 'NOT_IMPLEMENTED',
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao atualizar atividade',
          code: 'UPDATE_ACTIVITY_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      final devicesResult = await getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          final activeCount = devices.where((d) => d.isActive).length;
          const maxDevices = 3; // Limite padrão

          return Right(activeCount < maxDevices);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite',
          code: 'CHECK_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      final devicesResult = await getUserDevices(userId);

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
          'Erro ao contar dispositivos',
          code: 'COUNT_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getDeviceLimit(String userId) async {
    try {
      // Por enquanto retorna limite padrão
      // Futuramente poderia consultar subscription status
      return const Right(3);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter limite',
          code: 'GET_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> cleanupInactiveDevices({
    required String userId,
    required int inactiveDays,
  }) async {
    try {
      final devicesResult = await getUserDevices(userId);

      return await devicesResult.fold(
        (failure) async => Left(failure),
        (devices) async {
          final removedUuids = <String>[];

          for (final device in devices) {
            if (device.inactiveDuration.inDays > inactiveDays) {
              final revokeResult = await revokeDevice(
                userId: userId,
                deviceUuid: device.uuid,
              );

              revokeResult.fold(
                (_) {}, // Ignora erros individuais
                (_) => removedUuids.add(device.uuid),
              );
            }
          }

          return Right(removedUuids);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao limpar dispositivos',
          code: 'CLEANUP_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId) async {
    try {
      final devicesResult = await getUserDevices(userId);

      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          final activeDevices = devices.where((d) => d.isActive).toList();

          // Agrupa por plataforma
          final devicesByPlatform = <String, int>{};
          for (final device in activeDevices) {
            devicesByPlatform[device.platform] =
                (devicesByPlatform[device.platform] ?? 0) + 1;
          }

          // Ordena por última atividade
          final sortedDevices = List<DeviceEntity>.from(devices)
            ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));

          return Right(
            DeviceStatistics(
              totalDevices: devices.length,
              activeDevices: activeDevices.length,
              devicesByPlatform: devicesByPlatform,
              lastActiveDevice: sortedDevices.isNotEmpty ? sortedDevices.first : null,
              oldestDevice: sortedDevices.isNotEmpty ? sortedDevices.last : null,
              newestDevice: devices.isNotEmpty
                  ? devices.reduce((a, b) =>
                      a.firstLoginAt.isAfter(b.firstLoginAt) ? a : b)
                  : null,
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas',
          code: 'GET_STATS_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> syncDevices(String userId) async {
    try {
      final isConnected = await _connectivityService.connectivityStream.first;

      if (!isConnected) {
        // Retorna cache se offline
        final cachedDevices = await _localDataSource.getCachedDevices(userId);
        return Right(cachedDevices);
      }

      // Busca do servidor e atualiza cache
      final remoteDevices = await _remoteDataSource.getUserDevices(userId);
      await _localDataSource.cacheUserDevices(userId, remoteDevices);

      return Right(remoteDevices);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao sincronizar dispositivos',
          code: 'SYNC_ERROR',
          details: e,
        ),
      );
    }
  }
}
