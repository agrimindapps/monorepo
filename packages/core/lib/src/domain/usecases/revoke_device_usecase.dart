import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// A use case for revoking a specific device.
///
/// This use case removes the device's access to the system.
class RevokeDeviceUseCase implements UseCase<void, RevokeDeviceParams> {
  final IDeviceRepository _deviceRepository;

  /// Creates a new instance of [RevokeDeviceUseCase].
  ///
  /// [_deviceRepository] The repository to manage device data.
  const RevokeDeviceUseCase(this._deviceRepository);

  @override
  Future<Either<Failure, void>> call(RevokeDeviceParams params) async {
    try {
      final deviceResult = await _deviceRepository.getDeviceByUuid(params.deviceUuid);
      
      return await deviceResult.fold(
        (failure) async => Left(failure),
        (device) async {
          if (device == null) {
            return Left(
              NotFoundFailure(
                'Dispositivo não encontrado',
                code: 'DEVICE_NOT_FOUND',
                details: 'UUID: ${params.deviceUuid}',
              ),
            );
          }
          
          if (!device.isActive) {
            return Left(
              ValidationFailure(
                'Dispositivo já está revogado',
                code: 'DEVICE_ALREADY_REVOKED',
                details: 'UUID: ${params.deviceUuid}',
              ),
            );
          }
          return await _deviceRepository.revokeDevice(
            userId: params.userId,
            deviceUuid: params.deviceUuid,
          );
        },
      );
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
}

/// A use case for revoking all other devices except the current one.
///
/// This is useful for remote logout or security purposes.
class RevokeAllOtherDevicesUseCase implements UseCase<void, RevokeAllOtherDevicesParams> {
  final IDeviceRepository _deviceRepository;

  /// Creates a new instance of [RevokeAllOtherDevicesUseCase].
  ///
  /// [_deviceRepository] The repository to manage device data.
  const RevokeAllOtherDevicesUseCase(this._deviceRepository);

  @override
  Future<Either<Failure, void>> call(RevokeAllOtherDevicesParams params) async {
    try {
      return await _deviceRepository.revokeAllOtherDevices(
        userId: params.userId,
        currentDeviceUuid: params.currentDeviceUuid,
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
}

/// Parameters for the [RevokeDeviceUseCase].
class RevokeDeviceParams {
  /// The unique identifier of the user.
  final String userId;

  /// The unique identifier of the device to be revoked.
  final String deviceUuid;

  /// Creates a new instance of [RevokeDeviceParams].
  ///
  /// [userId] The user's unique identifier.
  /// [deviceUuid] The unique identifier of the device to be revoked.
  const RevokeDeviceParams({
    required this.userId,
    required this.deviceUuid,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevokeDeviceParams &&
        other.userId == userId &&
        other.deviceUuid == deviceUuid;
  }

  @override
  int get hashCode => userId.hashCode ^ deviceUuid.hashCode;

  @override
  String toString() => 'RevokeDeviceParams(userId: $userId, deviceUuid: $deviceUuid)';
}

/// Parameters for the [RevokeAllOtherDevicesUseCase].
class RevokeAllOtherDevicesParams {
  /// The unique identifier of the user.
  final String userId;

  /// The unique identifier of the current device, which should not be revoked.
  final String currentDeviceUuid;

  /// Creates a new instance of [RevokeAllOtherDevicesParams].
  ///
  /// [userId] The user's unique identifier.
  /// [currentDeviceUuid] The unique identifier of the current device.
  const RevokeAllOtherDevicesParams({
    required this.userId,
    required this.currentDeviceUuid,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevokeAllOtherDevicesParams &&
        other.userId == userId &&
        other.currentDeviceUuid == currentDeviceUuid;
  }

  @override
  int get hashCode => userId.hashCode ^ currentDeviceUuid.hashCode;

  @override
  String toString() => 'RevokeAllOtherDevicesParams(userId: $userId, currentDeviceUuid: $currentDeviceUuid)';
}
