import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_info_model.dart';

/// Implementação do repositório de dispositivos
@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _remoteDataSource;
  final DeviceLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  DeviceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );

  @override
  Future<Either<Failure, List<DeviceInfo>>> getUserDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Getting devices for user $userId');
      }

      // Primeiro tentar cache local
      final cachedResult = await _localDataSource.getCachedDevices(userId);
      
      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        if (kDebugMode) {
          debugPrint('📱 DeviceRepository: Offline - using cached data');
        }
        return cachedResult.fold(
          (failure) => Left(failure),
          (devices) => Right(devices.cast<DeviceInfo>()),
        );
      }

      // Tentar buscar dados remotos
      final remoteResult = await _remoteDataSource.getUserDevices(userId);
      
      return await remoteResult.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('❌ DeviceRepository: Remote failed - $failure, using cache');
          }
          // Se falhar no remoto, usar cache
          return cachedResult.fold(
            (cacheFailure) => Left(failure), // Retornar erro original se cache também falhar
            (devices) => Right(devices.cast<DeviceInfo>()),
          );
        },
        (remoteDevices) async {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Got ${remoteDevices.length} devices from remote');
          }
          
          // Atualizar cache com dados remotos
          await _localDataSource.cacheDevices(userId, remoteDevices);
          
          return Right(remoteDevices.cast<DeviceInfo>());
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Unexpected error - $e');
      }
      return Left(
        ServerFailure('Erro ao buscar dispositivos do usuário'),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceInfo>> validateDevice({
    required String userId,
    required DeviceInfo device,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Validating device ${device.uuid}');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        return const Left(
          NetworkFailure('Validação de dispositivo requer conexão com internet'),
        );
      }

      // Validar via remote datasource
      final deviceModel = DeviceInfoModel.fromEntity(device);
      final validationResult = await _remoteDataSource.validateDevice(userId, deviceModel);
      
      return validationResult.fold(
        (failure) => Left(failure),
        (validatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceRepository: Device validated successfully');
          }
          
          // Atualizar cache local com dispositivo validado
          _localDataSource.updateDevice(userId, validatedDevice);
          
          return Right(validatedDevice.toEntity());
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Validation error - $e');
      }
      return Left(
        ServerFailure('Erro ao validar dispositivo'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeDevice({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Revoking device $deviceUuid');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        return const Left(
          NetworkFailure('Revogação de dispositivo requer conexão com internet'),
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
          
          return const Right(unit);
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Revoke error - $e');
      }
      return Left(
        ServerFailure('Erro ao revogar dispositivo'),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceInfo>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Updating activity for device $deviceUuid');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        // Se offline, tentar obter do cache e simular atualização
        final cachedResult = await _localDataSource.getDeviceByUuid(deviceUuid);
        return cachedResult.fold(
          (failure) => Left(failure),
          (cachedDevice) {
            if (cachedDevice == null) {
              return const Left(
                UnexpectedFailure('Dispositivo não encontrado no cache'),
              );
            }
            
            // Simular atualização offline (apenas local)
            final updatedDevice = cachedDevice.copyWith(
              lastActiveAt: DateTime.now(),
            );
            
            _localDataSource.updateDevice(userId, updatedDevice);
            return Right(updatedDevice.toEntity());
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
          
          return Right(updatedDevice.toEntity());
        },
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRepository: Update activity error - $e');
      }
      return Left(
        ServerFailure('Erro ao atualizar atividade do dispositivo'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
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
        ServerFailure('Erro ao verificar limite de dispositivos'),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceInfo?>> getDeviceByUuid(String uuid) async {
    try {
      // Primeiro tentar cache local
      final localResult = await _localDataSource.getDeviceByUuid(uuid);
      
      return localResult.fold(
        (failure) => Left(failure),
        (cachedDevice) => Right(cachedDevice?.toEntity()),
      );

    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar dispositivo por UUID'),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
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
      final remoteResult = await _remoteDataSource.getDeviceStatistics(userId);
      return remoteResult.fold(
        (failure) => Left(failure),
        (statistics) {
          // Cache estatísticas
          _localDataSource.cacheStatistics(userId, statistics);
          return Right(statistics.toEntity());
        },
      );

    } catch (e) {
      return Left(
        ServerFailure('Erro ao obter estatísticas de dispositivos'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        return const Left(
          NetworkFailure('Revogação de dispositivos requer conexão com internet'),
        );
      }

      // Revogar via remote datasource
      final revokeResult = await _remoteDataSource.revokeAllOtherDevices(userId, currentDeviceUuid);
      
      return revokeResult.fold(
        (failure) => Left(failure),
        (_) {
          // Limpar cache para forçar refresh
          _localDataSource.clearCache(userId);
          return const Right(unit);
        },
      );

    } catch (e) {
      return Left(
        ServerFailure('Erro ao revogar outros dispositivos'),
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
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        return const Left(
          NetworkFailure('Limpeza de dispositivos requer conexão com internet'),
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
        ServerFailure('Erro ao limpar dispositivos inativos'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    try {
      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
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
        ServerFailure('Erro ao obter contagem de dispositivos ativos'),
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
        ServerFailure('Erro ao obter limite de dispositivos'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceInfo>>> syncDevices(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRepository: Syncing devices for user $userId');
      }

      // Verificar conectividade
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);
      
      if (!isConnected) {
        return const Left(
          NetworkFailure('Sincronização requer conexão com internet'),
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
          
          return Right(remoteDevices.cast<DeviceInfo>());
        },
      );

    } catch (e) {
      return Left(
        ServerFailure('Erro ao sincronizar dispositivos'),
      );
    }
  }
}
