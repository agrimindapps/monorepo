import 'package:core/core.dart' hide Column;

/// Configuração de limite de dispositivos para o Receituagro
/// Web não conta no limite, apenas dispositivos mobile (iOS/Android)
const _deviceLimitConfig = DeviceLimitConfig(
  maxMobileDevices: 3,
  maxWebDevices: -1, // Web ilimitado
  countWebInLimit: false, // Web não conta no limite
  premiumMaxMobileDevices: 10,
  allowEmulators: true,
);

/// Remote data source para operações de dispositivos via Firebase
abstract class DeviceRemoteDataSource {
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(String userId);
  Future<Either<Failure, DeviceEntity>> validateDevice(String userId, DeviceEntity device);
  Future<Either<Failure, void>> revokeDevice(String userId, String deviceUuid);
  Future<Either<Failure, DeviceEntity>> updateLastActivity(String userId, String deviceUuid);
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId);
  Future<Either<Failure, void>> revokeAllOtherDevices(String userId, String currentDeviceUuid);
  Future<Either<Failure, List<DeviceEntity>>> cleanupInactiveDevices(String userId, int inactiveDays);
}

/// Implementação do datasource remoto usando Firebase
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final FirebaseDeviceService? _firebaseDeviceService;
  
  DeviceRemoteDataSourceImpl({
    required FirebaseDeviceService? firebaseDeviceService,
  }) : _firebaseDeviceService = firebaseDeviceService;
  
  /// Helper method to check if service is available
  bool get _isServiceAvailable => _firebaseDeviceService != null;

  @override
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(String userId) async {
    if (_firebaseDeviceService == null) {
      return const Right([]); // Return empty list for Web compatibility
    }
    
    try {
      return await _firebaseDeviceService.getDevicesFromFirestore(userId);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos do servidor: $e',
          code: 'REMOTE_GET_DEVICES_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> validateDevice(String userId, DeviceEntity device) async {
    if (!_isServiceAvailable) {
      return Right(device);
    }
    
    try {
      return await _firebaseDeviceService!.validateDevice(
        userId: userId,
        device: device,
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao validar dispositivo no servidor: $e',
          code: 'REMOTE_VALIDATE_DEVICE_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokeDevice(String userId, String deviceUuid) async {
    if (!_isServiceAvailable) {
      return const Right(null);
    }
    
    try {
      return await _firebaseDeviceService!.revokeDevice(
        userId: userId,
        deviceUuid: deviceUuid,
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar dispositivo no servidor: $e',
          code: 'REMOTE_REVOKE_DEVICE_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> updateLastActivity(String userId, String deviceUuid) async {
    if (!_isServiceAvailable) {
      return Right(DeviceEntity(
        id: deviceUuid,
        uuid: deviceUuid,
        name: 'Web Device',
        model: 'Web Browser',
        platform: 'web',
        systemVersion: 'Unknown',
        appVersion: '1.0.0',
        buildNumber: '1',
        isPhysicalDevice: false,
        manufacturer: 'Web',
        firstLoginAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
      ));
    }
    
    try {
      return await _firebaseDeviceService!.updateDeviceLastActivity(
        userId: userId,
        deviceUuid: deviceUuid,
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao atualizar atividade do dispositivo: $e',
          code: 'REMOTE_UPDATE_ACTIVITY_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    if (!_isServiceAvailable) {
      return const Right(true); // Web sempre pode adicionar (não conta no limite)
    }
    
    try {
      // Busca dispositivos para contar apenas mobile
      final devicesResult = await _firebaseDeviceService!.getDevicesFromFirestore(userId);
      
      return devicesResult.fold(
        (failure) => Left(failure),
        (devices) {
          // Conta apenas dispositivos mobile (iOS/Android)
          final mobileCount = devices
              .where((d) => d.isActive && _deviceLimitConfig.isMobilePlatform(d.platform))
              .length;
          
          final canAdd = mobileCount < _deviceLimitConfig.maxMobileDevices;
          return Right(canAdd);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao verificar limite de dispositivos: $e',
          code: 'REMOTE_CHECK_LIMIT_ERROR',
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
          
          // Conta por tipo de dispositivo
          final mobileCount = activeDevices
              .where((d) => _deviceLimitConfig.isMobilePlatform(d.platform))
              .length;
          final webCount = activeDevices
              .where((d) => _deviceLimitConfig.isWebOrDesktopPlatform(d.platform))
              .length;
          
          final platformStats = <String, int>{
            'mobile': mobileCount,
            'web': webCount,
          };
          
          // Também agrupa por plataforma específica
          for (final device in devices) {
            final platform = device.platform;
            platformStats[platform] = (platformStats[platform] ?? 0) + 1;
          }
          
          return Right(
            DeviceStatistics(
              totalDevices: devices.length,
              activeDevices: activeDevices.length,
              devicesByPlatform: platformStats,
              lastActiveDevice: devices.isNotEmpty
                  ? devices.reduce((a, b) => a.lastActiveAt.isAfter(b.lastActiveAt) ? a : b)
                  : null,
              oldestDevice: devices.isNotEmpty
                  ? devices.reduce((a, b) => (a.createdAt ?? DateTime.now()).isBefore(b.createdAt ?? DateTime.now()) ? a : b)
                  : null,
              newestDevice: devices.isNotEmpty
                  ? devices.reduce((a, b) => (a.createdAt ?? DateTime.now()).isAfter(b.createdAt ?? DateTime.now()) ? a : b)
                  : null,
            ),
          );
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao obter estatísticas de dispositivos: $e',
          code: 'REMOTE_GET_STATS_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokeAllOtherDevices(String userId, String currentDeviceUuid) async {
    try {
      final devicesResult = await getUserDevices(userId);
      
      return await devicesResult.fold(
        (failure) async => Left(failure),
        (devices) async {
          final devicesToRevoke = devices
              .where((device) => device.uuid != currentDeviceUuid && device.isActive)
              .toList();
          final revokeResults = await Future.wait(
            devicesToRevoke.map((device) => 
              revokeDevice(userId, device.uuid)
            ),
          );
          for (final result in revokeResults) {
            if (result.isLeft()) {
              return result;
            }
          }
          
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos: $e',
          code: 'REMOTE_REVOKE_ALL_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> cleanupInactiveDevices(String userId, int inactiveDays) async {
    try {
      final devicesResult = await getUserDevices(userId);
      
      return await devicesResult.fold(
        (failure) async => Left(failure),
        (devices) async {
          final now = DateTime.now();
          final cutoffDate = now.subtract(Duration(days: inactiveDays));
          final inactiveDevices = devices
              .where((device) => 
                device.isActive && 
                device.lastActiveAt.isBefore(cutoffDate)
              )
              .toList();
          final cleanupResults = await Future.wait(
            inactiveDevices.map((device) => 
              revokeDevice(userId, device.uuid)
            ),
          );
          for (final result in cleanupResults) {
            if (result.isLeft()) {
              return const Left(
                ServerFailure(
                  'Erro parcial durante limpeza de dispositivos inativos',
                  code: 'CLEANUP_PARTIAL_ERROR',
                ),
              );
            }
          }
          
          return Right(inactiveDevices);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao limpar dispositivos inativos: $e',
          code: 'REMOTE_CLEANUP_ERROR',
        ),
      );
    }
  }
}
