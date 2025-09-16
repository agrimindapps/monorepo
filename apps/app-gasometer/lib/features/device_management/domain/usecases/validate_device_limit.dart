import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_info.dart';
import '../repositories/device_repository.dart';

/// Use case para validar limite de dispositivos
@lazySingleton
class ValidateDeviceLimitUseCase {
  final DeviceRepository _repository;

  ValidateDeviceLimitUseCase(this._repository);

  /// Valida se o usuário pode adicionar um novo dispositivo
  /// Retorna true se pode adicionar, false caso contrário
  Future<Either<Failure, bool>> call({
    required String userId,
    required DeviceInfo device,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('ID do usuário não pode ser vazio'));
    }

    // 1. Verificar dispositivo atual já existe
    final existingDeviceResult = await _repository.getDeviceByUuid(device.uuid);
    
    return await existingDeviceResult.fold(
      (failure) => Left(failure),
      (existingDevice) async {
        // Se o dispositivo já existe e está ativo, pode continuar
        if (existingDevice != null && existingDevice.isActive) {
          return const Right(true);
        }

        // 2. Verificar limite de dispositivos
        final canAddResult = await _repository.canAddMoreDevices(userId);
        return canAddResult.fold(
          (failure) => Left(failure),
          (canAdd) {
            if (!canAdd) {
              return const Left(
                ValidationFailure(
                  'Limite de dispositivos atingido. Máximo de 3 dispositivos simultâneos.',
                ),
              );
            }
            return const Right(true);
          },
        );
      },
    );
  }

  /// Valida dispositivo e o registra se permitido
  Future<Either<Failure, DeviceInfo>> validateAndRegisterDevice({
    required String userId,
    required DeviceInfo device,
  }) async {
    // 1. Validar limite
    final validationResult = await call(userId: userId, device: device);
    
    return await validationResult.fold(
      (failure) => Left(failure),
      (canAdd) async {
        if (!canAdd) {
          return const Left(
            ValidationFailure(
              'Não é possível adicionar este dispositivo',
            ),
          );
        }

        // 2. Registrar/validar dispositivo
        return await _repository.validateDevice(
          userId: userId,
          device: device,
        );
      },
    );
  }
}
