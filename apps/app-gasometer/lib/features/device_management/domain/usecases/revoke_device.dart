import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/device_repository.dart';

/// Use case para revogar acesso de um dispositivo
@lazySingleton
class RevokeDeviceUseCase {
  final DeviceRepository _repository;

  RevokeDeviceUseCase(this._repository);

  /// Revoga acesso de um dispositivo específico
  Future<Either<Failure, Unit>> call({
    required String userId,
    required String deviceUuid,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('ID do usuário não pode ser vazio'));
    }

    if (deviceUuid.isEmpty) {
      return const Left(ValidationFailure('UUID do dispositivo não pode ser vazio'));
    }

    return await _repository.revokeDevice(
      userId: userId,
      deviceUuid: deviceUuid,
    );
  }

  /// Revoga acesso de todos os outros dispositivos exceto o atual
  Future<Either<Failure, Unit>> revokeAllOthers({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('ID do usuário não pode ser vazio'));
    }

    if (currentDeviceUuid.isEmpty) {
      return const Left(ValidationFailure('UUID do dispositivo atual não pode ser vazio'));
    }

    return await _repository.revokeAllOtherDevices(
      userId: userId,
      currentDeviceUuid: currentDeviceUuid,
    );
  }
}
