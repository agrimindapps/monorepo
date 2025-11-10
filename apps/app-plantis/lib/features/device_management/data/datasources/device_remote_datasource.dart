import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../models/device_model.dart';

/// Interface para datasource remoto de dispositivos
abstract class DeviceRemoteDataSource {
  /// Obtém todos os dispositivos do usuário do servidor
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);

  /// Obtém dispositivo específico do servidor
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);

  /// Valida um dispositivo com o servidor
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  /// Revoga todos os outros dispositivos exceto o atual
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });

  /// Atualiza a última atividade de um dispositivo
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);

  /// Obtém o número atual de dispositivos ativos do usuário
  Future<Either<Failure, int>> getActiveDeviceCount(String userId);

  /// Obtém estatísticas de dispositivos do usuário
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(
    String userId,
  );

  /// Sincroniza dispositivos com o servidor
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId);
}

/// Implementação real do datasource remoto usando Firebase
/// Integra com o FirebaseDeviceService do core package
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final FirebaseDeviceService _firebaseDeviceService;

  DeviceRemoteDataSourceImpl({
    required FirebaseDeviceService firebaseDeviceService,
  }) : _firebaseDeviceService = firebaseDeviceService;

  @override
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(
    String userId,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 DeviceRemote: Getting devices from Firestore for user $userId',
      );
    }

    final result = await _firebaseDeviceService.getDevicesFromFirestore(userId);

    return result.fold((failure) => Left(failure), (entities) {
      final models =
          entities.map((entity) => DeviceModel.fromEntity(entity)).toList();
      if (kDebugMode) {
        debugPrint(
          '✅ DeviceRemote: Found ${models.length} devices from Firestore',
        );
      }
      return Right(models);
    });
  }

  @override
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(
    String deviceUuid,
  ) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Getting device $deviceUuid from Firestore');
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 DeviceRemote: Validating device ${device.uuid} via Firebase',
      );
    }

    final result = await _firebaseDeviceService.validateDevice(
      userId: userId,
      device: device.toEntity(),
    );

    return result.fold((failure) => Left(failure), (entity) {
      final model = DeviceModel.fromEntity(entity);
      if (kDebugMode) {
        debugPrint('✅ DeviceRemote: Device validation successful');
      }
      return Right(model);
    });
  }

  @override
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Revoking device $deviceUuid via Firebase');
    }

    final result = await _firebaseDeviceService.revokeDevice(
      userId: userId,
      deviceUuid: deviceUuid,
    );

    return result.fold((failure) => Left(failure), (_) {
      if (kDebugMode) {
        debugPrint('✅ DeviceRemote: Device revocation successful');
      }
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Revoking all other devices via Firebase');
    }
    final devicesResult = await _firebaseDeviceService.getDevicesFromFirestore(
      userId,
    );

    return devicesResult.fold((failure) => Left(failure), (devices) async {
      try {
        for (final device in devices) {
          if (device.uuid != currentDeviceUuid) {
            final revokeResult = await _firebaseDeviceService.revokeDevice(
              userId: userId,
              deviceUuid: device.uuid,
            );
            if (revokeResult.isLeft()) {
              return revokeResult.fold(
                (failure) => Left(failure),
                (_) => const Right(null),
              );
            }
          }
        }

        if (kDebugMode) {
          debugPrint('✅ DeviceRemote: All other devices revoked successfully');
        }
        return const Right(null);
      } catch (e) {
        return Left(
          ServerFailure(
            'Erro ao revogar outros dispositivos',
            code: 'REVOKE_ALL_ERROR',
            details: e,
          ),
        );
      }
    });
  }

  @override
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 DeviceRemote: Updating last activity for $deviceUuid via Firebase',
      );
    }

    final result = await _firebaseDeviceService.updateDeviceLastActivity(
      userId: userId,
      deviceUuid: deviceUuid,
    );

    return result.fold((failure) => Left(failure), (entity) {
      final model = DeviceModel.fromEntity(entity);
      if (kDebugMode) {
        debugPrint('✅ DeviceRemote: Device activity updated successfully');
      }
      return Right(model);
    });
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Checking device limit for user $userId');
    }

    final result = await _firebaseDeviceService.getActiveDeviceCount(userId);

    return result.fold((failure) => Left(failure), (count) {
      const deviceLimit = 3; // Limite padrão
      final canAdd = count < deviceLimit;
      if (kDebugMode) {
        debugPrint(
          '✅ DeviceRemote: User has $count/$deviceLimit devices, can add: $canAdd',
        );
      }
      return Right(canAdd);
    });
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Getting active device count for $userId');
    }

    final result = await _firebaseDeviceService.getActiveDeviceCount(userId);

    return result.fold((failure) => Left(failure), (count) {
      if (kDebugMode) {
        debugPrint('✅ DeviceRemote: Found $count active devices');
      }
      return Right(count);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(
    String userId,
  ) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Getting device statistics for $userId');
    }
    final devicesResult = await _firebaseDeviceService.getDevicesFromFirestore(
      userId,
    );

    return devicesResult.fold((failure) => Left(failure), (devices) {
      final totalDevices = devices.length;
      final activeDevices = devices.where((d) => d.isActive).length;
      final inactiveDevices = totalDevices - activeDevices;

      final statistics = {
        'total_devices': totalDevices,
        'active_devices': activeDevices,
        'inactive_devices': inactiveDevices,
        'platforms': _groupDevicesByPlatform(devices),
      };

      if (kDebugMode) {
        debugPrint('✅ DeviceRemote: Generated statistics: $statistics');
      }

      return Right(statistics);
    });
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Syncing devices for $userId');
    }
    return getUserDevices(userId);
  }

  /// Helper para agrupar dispositivos por plataforma
  Map<String, int> _groupDevicesByPlatform(List<DeviceEntity> devices) {
    final platformCounts = <String, int>{};

    for (final device in devices) {
      final platform = device.platform;
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }

    return platformCounts;
  }
}
