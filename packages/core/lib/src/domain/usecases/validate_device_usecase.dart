import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/device_entity.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// Use case para validar um dispositivo para um usuário
/// Verifica se o dispositivo pode ser usado e o registra se válido
class ValidateDeviceUseCase implements UseCase<DeviceEntity, ValidateDeviceParams> {
  final IDeviceRepository _deviceRepository;

  const ValidateDeviceUseCase(this._deviceRepository);

  @override
  Future<Either<Failure, DeviceEntity>> call(ValidateDeviceParams params) async {
    try {
      // Primeiro, verifica se o usuário pode adicionar mais dispositivos
      final canAddResult = await _deviceRepository.canAddMoreDevices(params.userId);
      
      return await canAddResult.fold(
        (failure) async => Left(failure),
        (canAdd) async {
          // Se o dispositivo já existe, apenas valida
          final existingDeviceResult = await _deviceRepository.getDeviceByUuid(
            params.device.uuid,
          );
          
          return await existingDeviceResult.fold(
            (failure) async => Left(failure),
            (existingDevice) async {
              if (existingDevice != null) {
                // Dispositivo existe, atualiza última atividade
                return await _deviceRepository.updateLastActivity(
                  userId: params.userId,
                  deviceUuid: params.device.uuid,
                );
              }
              
              // Dispositivo novo, verifica se pode adicionar
              if (!canAdd) {
                return Left(
                  ValidationFailure(
                    'Limite de dispositivos atingido',
                    code: 'DEVICE_LIMIT_EXCEEDED',
                    details: 'O usuário já possui o número máximo de dispositivos permitidos',
                  ),
                );
              }
              
              // Valida e registra novo dispositivo
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

/// Parâmetros para ValidateDeviceUseCase
class ValidateDeviceParams {
  final String userId;
  final DeviceEntity device;

  const ValidateDeviceParams({
    required this.userId,
    required this.device,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateDeviceParams &&
        other.userId == userId &&
        other.device == device;
  }

  @override
  int get hashCode => userId.hashCode ^ device.hashCode;

  @override
  String toString() => 'ValidateDeviceParams(userId: $userId, device: ${device.uuid})';
}