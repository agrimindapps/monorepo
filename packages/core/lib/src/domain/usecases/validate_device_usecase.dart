import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/device_entity.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// A use case for validating a device for a user.
///
/// This use case checks if the device can be used and registers it if it is valid.
class ValidateDeviceUseCase implements UseCase<DeviceEntity, ValidateDeviceParams> {
  final IDeviceRepository _deviceRepository;

  /// Creates a new instance of [ValidateDeviceUseCase].
  ///
  /// [_deviceRepository] The repository to manage device data.
  const ValidateDeviceUseCase(this._deviceRepository);

  @override
  Future<Either<Failure, DeviceEntity>> call(ValidateDeviceParams params) async {
    try {
      final canAddResult = await _deviceRepository.canAddMoreDevices(
        params.userId,
        isPremium: params.isPremium,
      );
      
      return await canAddResult.fold(
        (failure) async => Left(failure),
        (canAdd) async {
          final existingDeviceResult = await _deviceRepository.getDeviceByUuid(
            params.device.uuid,
          );
          
          return await existingDeviceResult.fold(
            (failure) async => Left(failure),
            (existingDevice) async {
              if (existingDevice != null) {
                return await _deviceRepository.updateLastActivity(
                  userId: params.userId,
                  deviceUuid: params.device.uuid,
                );
              }
              if (!canAdd) {
                return const Left(
                  ValidationFailure(
                    'Limite de dispositivos atingido',
                    code: 'DEVICE_LIMIT_EXCEEDED',
                    details: 'O usuário já possui o número máximo de dispositivos permitidos',
                  ),
                );
              }
              return await _deviceRepository.validateDevice(
                userId: params.userId,
                device: params.device,
              );
            },
          );
        },
      );
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
}

/// Parameters for the [ValidateDeviceUseCase].
class ValidateDeviceParams {
  /// The unique identifier of the user.
  final String userId;

  /// The device entity to be validated.
  final DeviceEntity device;

  /// Whether the user is a premium subscriber.
  final bool isPremium;

  /// Creates a new instance of [ValidateDeviceParams].
  ///
  /// [userId] The user's unique identifier.
  /// [device] The device entity to be validated.
  /// [isPremium] Whether the user is a premium subscriber.
  const ValidateDeviceParams({
    required this.userId,
    required this.device,
    this.isPremium = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateDeviceParams &&
        other.userId == userId &&
        other.device == device &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode => userId.hashCode ^ device.hashCode ^ isPremium.hashCode;

  @override
  String toString() => 'ValidateDeviceParams(userId: $userId, device: ${device.uuid}, isPremium: $isPremium)';
}
