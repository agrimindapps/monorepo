import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';

/// Implementação do repositório de dispositivos
/// Segue o padrão Repository coordenando operações entre local e remote datasources
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
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting devices for user $userId');
      }

      // Primeiro tentar cache local
      final cachedResult = await _localDataSource.getCachedDevices(userId);
      
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        if (kDebugMode) {
          debugPrint('📱 DeviceRepository: Offline - using cached data');
        }
        return cachedResult;
      }

      // Tentar buscar dados remotos
      final remoteResult = await _remoteDataSource.getUserDevices(userId);
      
      return await remoteResult.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('❌ DeviceRepository: Remote failed - $failure, using cache');
          }
          // Se falhar no remoto, usar cache
          return cachedResult;
        },
        (remoteDevices) async {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Got ${remoteDevices.length} devices from remote');
          }
          
          // Atualizar cache com dados remotos
          await _localDataSource.cacheDevices(userId, remoteDevices);
          
          return Right(remoteDevices);
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Unexpected error - $e');
      }
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
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Validating device ${device.uuid}');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Validação de dispositivo requer conexão com internet',
            code: 'OFFLINE_VALIDATION_ERROR',
          ),
        );
      }

      // Validar via remote datasource
      final validationResult = await _remoteDataSource.validateDevice(userId, device);
      
      return validationResult.fold(
        (failure) => Left(failure),
        (validatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Device validated successfully');
          }
          
          // Atualizar cache local com dispositivo validado
          _localDataSource.updateDevice(userId, validatedDevice);
          
          return Right(validatedDevice);
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Validation error - $e');
      }
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
        debugPrint('🔄 DeviceRepository: Revoking device $deviceUuid');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Revogação de dispositivo requer conexão com internet',
            code: 'OFFLINE_REVOKE_ERROR',
          ),
        );
      }

      // Revogar via remote datasource
      final revokeResult = await _remoteDataSource.revokeDevice(userId, deviceUuid);
      
      return revokeResult.fold(
        (failure) => Left(failure),
        (_) {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Device revoked successfully');
          }
          
          // Remover do cache local
          _localDataSource.removeDevice(userId, deviceUuid);
          
          return const Right(null);
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Revoke error - $e');
      }
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
  Future<Either<Failure, DeviceEntity>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Updating activity for device $deviceUuid');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        // Se offline, tentar obter do cache e simular atualização
        final cachedResult = await _localDataSource.getDeviceByUuid(deviceUuid);
        return cachedResult.fold(
          (failure) => Left(failure),
          (cachedDevice) {
            if (cachedDevice == null) {
              return const Left(
                NotFoundFailure(
                  'Dispositivo não encontrado no cache',
                  code: 'DEVICE_NOT_FOUND_OFFLINE',
                ),
              );
            }
            
            // Simular atualização offline (apenas local)
            final updatedDevice = cachedDevice.copyWith(
              lastActiveAt: DateTime.now(),
            ) as DeviceEntity;
            
            _localDataSource.updateDevice(userId, updatedDevice);
            return Right(updatedDevice);
          },
        );
      }

      // Atualizar via remote datasource
      final updateResult = await _remoteDataSource.updateLastActivity(userId, deviceUuid);
      
      return updateResult.fold(
        (failure) => Left(failure),
        (updatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Device activity updated successfully');
          }
          
          // Atualizar cache local
          _localDataSource.updateDevice(userId, updatedDevice);
          
          return Right(updatedDevice);
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Update activity error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao atualizar atividade do dispositivo',
          code: 'UPDATE_ACTIVITY_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        // Se offline, verificar no cache local
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => const Right(false), // Falhar seguramente
          (devices) {
            final activeDevices = devices.where((d) => d.isActive).length;
            return Right(activeDevices < 3); // Limite padrão
          },
        );
      }

      // Verificar via remote datasource
      return await _remoteDataSource.canAddMoreDevices(userId);

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
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String uuid) async {
    try {
      // Primeiro tentar cache local
      final localResult = await _localDataSource.getDeviceByUuid(uuid);
      
      return localResult.fold(
        (failure) => Left(failure),
        (cachedDevice) => Right(cachedDevice),
      );

    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar dispositivo por UUID',
          code: 'GET_DEVICE_BY_UUID_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        // Se offline, gerar estatísticas do cache
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => Left(failure),
          (devices) {
            final activeDevices = devices.where((d) => d.isActive).length;
            final devicesByPlatform = <String, int>{};
            
            for (final device in devices) {
              final platform = device.platform;
              devicesByPlatform[platform] = (devicesByPlatform[platform] ?? 0) + 1;
            }
            
            return Right(
              DeviceStatistics(
                totalDevices: devices.length,
                activeDevices: activeDevices,
                devicesByPlatform: devicesByPlatform,
                lastActiveDevice: devices.isNotEmpty
                    ? devices.reduce((a, b) => a.lastActiveAt.isAfter(b.lastActiveAt) ? a : b)
                    : null,
                oldestDevice: devices.isNotEmpty
                    ? devices.reduce((a, b) => a.firstLoginAt.isBefore(b.firstLoginAt) ? a : b)
                    : null,
                newestDevice: devices.isNotEmpty
                    ? devices.reduce((a, b) => a.firstLoginAt.isAfter(b.firstLoginAt) ? a : b)
                    : null,
              ),
            );
          },
        );
      }

      // Obter estatísticas via remote datasource
      return await _remoteDataSource.getDeviceStatistics(userId);

    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos',
          code: 'GET_DEVICE_STATS_ERROR',
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
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Revogação de dispositivos requer conexão com internet',
            code: 'OFFLINE_REVOKE_ALL_ERROR',
          ),
        );
      }

      // Revogar via remote datasource
      final revokeResult = await _remoteDataSource.revokeAllOtherDevices(userId, currentDeviceUuid);
      
      return revokeResult.fold(
        (failure) => Left(failure),
        (_) {
          // Limpar cache para forçar refresh
          _localDataSource.clearCache(userId);
          return const Right(null);
        },
      );

    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos',
          code: 'REVOKE_ALL_OTHER_ERROR',
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
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Limpeza de dispositivos requer conexão com internet',
            code: 'OFFLINE_CLEANUP_ERROR',
          ),
        );
      }

      // Limpar via remote datasource
      final cleanupResult = await _remoteDataSource.cleanupInactiveDevices(userId, inactiveDays);
      
      return cleanupResult.fold(
        (failure) => Left(failure),
        (removedDevices) {
          // Atualizar cache removendo dispositivos limpos
          final removedUuids = removedDevices.map((device) => device.uuid).toList();
          for (final uuid in removedUuids) {
            _localDataSource.removeDevice(userId, uuid);
          }
          
          return Right(removedUuids);
        },
      );

    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao limpar dispositivos inativos',
          code: 'CLEANUP_INACTIVE_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        // Se offline, contar do cache
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => Left(failure),
          (devices) {
            final activeCount = devices.where((d) => d.isActive).length;
            return Right(activeCount);
          },
        );
      }

      // Obter contagem via remote datasource
      final devicesResult = await _remoteDataSource.getUserDevices(userId);
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
          'Erro ao obter contagem de dispositivos ativos',
          code: 'GET_ACTIVE_COUNT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getDeviceLimit(String userId) async {
    try {
      // Por enquanto, limite fixo de 3 dispositivos
      // No futuro pode ser configurável ou baseado no plano do usuário
      return const Right(3);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter limite de dispositivos',
          code: 'GET_DEVICE_LIMIT_ERROR',
          details: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> syncDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Syncing devices for user $userId');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );
      
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            'Sincronização requer conexão com internet',
            code: 'OFFLINE_SYNC_ERROR',
          ),
        );
      }

      // Buscar dados remotos
      final remoteResult = await _remoteDataSource.getUserDevices(userId);
      
      return await remoteResult.fold(
        (failure) async => Left(failure),
        (remoteDevices) async {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Synced ${remoteDevices.length} devices');
          }
          
          // Limpar cache atual
          await _localDataSource.clearCache(userId);
          
          // Armazenar dados atualizados
          await _localDataSource.cacheDevices(userId, remoteDevices);
          
          return Right(remoteDevices);
        },
      );

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
}