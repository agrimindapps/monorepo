import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/i_device_repository.dart';
import '../../shared/utils/failure.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_device_service.dart';
import 'datasources/device_local_datasource.dart';

/// Implementação unificada do repositório de dispositivos para todo o monorepo
/// Coordena operações entre local cache e Firebase remote
class DeviceRepositoryImpl implements IDeviceRepository {
  final DeviceLocalDataSource _localDataSource;
  final FirebaseDeviceService _remoteDataSource;
  final ConnectivityService _connectivityService;

  /// Limite padrão de dispositivos mobile (web não conta)
  static const int defaultDeviceLimit = 3;

  DeviceRepositoryImpl({
    required DeviceLocalDataSource localDataSource,
    required FirebaseDeviceService remoteDataSource,
    required ConnectivityService connectivityService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _connectivityService = connectivityService;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(
    String userId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting devices for user $userId');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );

      // Se offline, usar cache local
      if (!isConnected) {
        if (kDebugMode) {
          debugPrint('📱 DeviceRepository: Offline - using cached data');
        }
        return await _localDataSource.getCachedDevices(userId);
      }

      // Buscar do Firebase
      final remoteResult =
          await _remoteDataSource.getDevicesFromFirestore(userId);

      return await remoteResult.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint(
              '⚠️ DeviceRepository: Remote failed - $failure, using cache',
            );
          }
          return await _localDataSource.getCachedDevices(userId);
        },
        (devices) async {
          if (kDebugMode) {
            debugPrint(
              '✅ DeviceRepository: Got ${devices.length} devices from remote',
            );
          }

          // Atualizar cache local
          await _localDataSource.cacheDevices(userId, devices);

          return Right(devices);
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
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(
    String deviceUuid,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting device $deviceUuid');
      }

      return await _localDataSource.getDeviceByUuid(deviceUuid);
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
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Validating device ${device.uuid}');
      }

      // Validação requer conexão
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

      // Verificar se é plataforma web (não conta no limite)
      if (device.platform.toLowerCase() == 'web') {
        if (kDebugMode) {
          debugPrint(
            '📱 DeviceRepository: Web platform - skipping device limit check',
          );
        }
        // Web não precisa validação de limite, apenas registra
        final result = await _remoteDataSource.validateDevice(
          userId: userId,
          device: device,
        );

        return result.fold(
          (failure) => Left(failure),
          (validatedDevice) async {
            await _localDataSource.updateDevice(userId, validatedDevice);
            return Right(validatedDevice);
          },
        );
      }

      // Verificar limite de dispositivos mobile
      final canAddResult = await canAddMoreDevices(userId);

      return await canAddResult.fold(
        (failure) async => Left(failure),
        (canAdd) async {
          // Verificar se dispositivo já existe
          final existingResult =
              await _localDataSource.getDeviceByUuid(device.uuid);

          final existingDevice = existingResult.fold(
            (failure) => null,
            (device) => device,
          );

          if (existingDevice != null) {
            if (kDebugMode) {
              debugPrint(
                '📱 DeviceRepository: Device exists, updating activity',
              );
            }

            // Dispositivo existente, atualizar última atividade
            final updateResult = await _remoteDataSource.updateDeviceLastActivity(
              userId: userId,
              deviceUuid: device.uuid,
            );

            return updateResult.fold(
              (failure) => Left(failure),
              (updatedDevice) async {
                await _localDataSource.updateDevice(userId, updatedDevice);
                return Right(updatedDevice);
              },
            );
          }

          // Novo dispositivo
          if (!canAdd) {
            if (kDebugMode) {
              debugPrint('❌ DeviceRepository: Device limit exceeded');
            }
            return const Left(
              ValidationFailure(
                'Limite de dispositivos atingido. Remova um dispositivo antes de adicionar outro.',
                code: 'DEVICE_LIMIT_EXCEEDED',
              ),
            );
          }

          // Validar novo dispositivo
          final validationResult = await _remoteDataSource.validateDevice(
            userId: userId,
            device: device,
          );

          return validationResult.fold(
            (failure) => Left(failure),
            (validatedDevice) async {
              if (kDebugMode) {
                debugPrint(
                  '✅ DeviceRepository: Device validated successfully',
                );
              }
              await _localDataSource.updateDevice(userId, validatedDevice);
              return Right(validatedDevice);
            },
          );
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

      // Revogação requer conexão
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

      final revokeResult = await _remoteDataSource.revokeDevice(
        userId: userId,
        deviceUuid: deviceUuid,
      );

      return revokeResult.fold(
        (failure) => Left(failure),
        (_) async {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Device revoked successfully');
          }
          await _localDataSource.removeDevice(userId, deviceUuid);
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
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Revoking all other devices');
      }

      // Requer conexão
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

      final revokeResult = await _remoteDataSource.revokeAllOtherDevices(
        userId: userId,
        currentDeviceUuid: currentDeviceUuid,
      );

      return revokeResult.fold(
        (failure) => Left(failure),
        (_) async {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: All other devices revoked');
          }
          await _localDataSource.clearCache(userId);
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
  Future<Either<Failure, DeviceEntity>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 DeviceRepository: Updating activity for device $deviceUuid',
        );
      }

      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );

      // Se offline, atualizar apenas local
      if (!isConnected) {
        final cachedResult =
            await _localDataSource.getDeviceByUuid(deviceUuid);
        return cachedResult.fold(
          (failure) => Left(failure),
          (cachedDevice) async {
            if (cachedDevice == null) {
              return const Left(
                NotFoundFailure(
                  'Dispositivo não encontrado no cache',
                  code: 'DEVICE_NOT_FOUND_OFFLINE',
                ),
              );
            }

            final updatedDevice = cachedDevice.copyWith(
              lastActiveAt: DateTime.now(),
            ) as DeviceEntity;

            await _localDataSource.updateDevice(userId, updatedDevice);
            return Right(updatedDevice);
          },
        );
      }

      // Atualizar no Firebase
      final updateResult = await _remoteDataSource.updateDeviceLastActivity(
        userId: userId,
        deviceUuid: deviceUuid,
      );

      return updateResult.fold(
        (failure) => Left(failure),
        (updatedDevice) async {
          if (kDebugMode) {
            debugPrint(
              '✅ DeviceRepository: Device activity updated successfully',
            );
          }
          await _localDataSource.updateDevice(userId, updatedDevice);
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
        // Usar cache para verificar
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => const Right(false), // Falhar seguramente
          (devices) {
            // Contar apenas dispositivos mobile ativos
            final mobileDevices = devices
                .where((d) =>
                    d.isActive && d.platform.toLowerCase() != 'web')
                .length;
            return Right(mobileDevices < defaultDeviceLimit);
          },
        );
      }

      // Verificar com Firebase
      final countResult = await _remoteDataSource.getActiveDeviceCount(userId);

      return countResult.fold(
        (failure) => Left(failure),
        (count) {
          // count já exclui web devices na query do Firebase
          final canAdd = count < defaultDeviceLimit;
          if (kDebugMode) {
            debugPrint(
              '📱 DeviceRepository: User has $count/$defaultDeviceLimit mobile devices, can add: $canAdd',
            );
          }
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
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );

      if (!isConnected) {
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => Left(failure),
          (devices) {
            final activeCount = devices
                .where((d) =>
                    d.isActive && d.platform.toLowerCase() != 'web')
                .length;
            return Right(activeCount);
          },
        );
      }

      return await _remoteDataSource.getActiveDeviceCount(userId);
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
    // TODO: Integrar com subscription status para premium (ex: 10 dispositivos)
    return const Right(defaultDeviceLimit);
  }

  @override
  Future<Either<Failure, List<String>>> cleanupInactiveDevices({
    required String userId,
    required int inactiveDays,
  }) async {
    try {
      // Requer conexão
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

      final cleanupResult = await _remoteDataSource.cleanupInactiveDevices(
        userId: userId,
        inactiveDays: inactiveDays,
      );

      return cleanupResult.fold(
        (failure) => Left(failure),
        (removedUuids) async {
          if (kDebugMode) {
            debugPrint(
              '✅ DeviceRepository: Cleaned up ${removedUuids.length} inactive devices',
            );
          }

          // Remover do cache local
          for (final uuid in removedUuids) {
            await _localDataSource.removeDevice(userId, uuid);
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
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(
    String userId,
  ) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivityService.checkConnectivity();
      final isConnected = connectivityResult.fold(
        (failure) => false,
        (connected) => connected,
      );

      if (!isConnected) {
        // Gerar estatísticas do cache
        final cachedResult = await _localDataSource.getCachedDevices(userId);
        return cachedResult.fold(
          (failure) => Left(failure),
          (devices) => Right(_buildStatistics(devices)),
        );
      }

      // Buscar estatísticas do Firebase
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
  Future<Either<Failure, List<DeviceEntity>>> syncDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Syncing devices for user $userId');
      }

      // Requer conexão
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

      final remoteResult =
          await _remoteDataSource.getDevicesFromFirestore(userId);

      return await remoteResult.fold(
        (failure) async => Left(failure),
        (remoteDevices) async {
          if (kDebugMode) {
            debugPrint(
              '✅ DeviceRepository: Synced ${remoteDevices.length} devices',
            );
          }

          // Limpar e atualizar cache
          await _localDataSource.clearCache(userId);
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

  /// Constrói estatísticas a partir da lista de dispositivos
  DeviceStatistics _buildStatistics(List<DeviceEntity> devices) {
    final activeDevices = devices.where((d) => d.isActive).toList();
    final devicesByPlatform = <String, int>{};

    for (final device in devices) {
      final platform = device.platform;
      devicesByPlatform[platform] = (devicesByPlatform[platform] ?? 0) + 1;
    }

    DeviceEntity? lastActive;
    DeviceEntity? oldest;
    DeviceEntity? newest;

    for (final device in activeDevices) {
      // Last active
      if (lastActive == null ||
          device.lastActiveAt.isAfter(lastActive.lastActiveAt)) {
        lastActive = device;
      }

      // Oldest
      if (oldest == null ||
          device.firstLoginAt.isBefore(oldest.firstLoginAt)) {
        oldest = device;
      }

      // Newest
      if (newest == null ||
          device.firstLoginAt.isAfter(newest.firstLoginAt)) {
        newest = device;
      }
    }

    return DeviceStatistics(
      totalDevices: devices.length,
      activeDevices: activeDevices.length,
      devicesByPlatform: devicesByPlatform,
      lastActiveDevice: lastActive,
      oldestDevice: oldest,
      newestDevice: newest,
    );
  }
}
