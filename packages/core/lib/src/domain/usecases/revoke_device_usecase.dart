import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// Use case para revogar um dispositivo específico
/// Remove o acesso do dispositivo ao sistema
class RevokeDeviceUseCase implements UseCase<void, RevokeDeviceParams> {
  final IDeviceRepository _deviceRepository;

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

/// Use case para revogar todos os outros dispositivos exceto o atual
/// Útil para logout remoto ou segurança
class RevokeAllOtherDevicesUseCase implements UseCase<void, RevokeAllOtherDevicesParams> {
  final IDeviceRepository _deviceRepository;

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

/// Parâmetros para RevokeDeviceUseCase
class RevokeDeviceParams {
  final String userId;
  final String deviceUuid;

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

/// Parâmetros para RevokeAllOtherDevicesUseCase
class RevokeAllOtherDevicesParams {
  final String userId;
  final String currentDeviceUuid;

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
