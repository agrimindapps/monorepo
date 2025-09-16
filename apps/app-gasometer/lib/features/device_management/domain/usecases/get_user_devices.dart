import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_info.dart';
import '../repositories/device_repository.dart';

/// Use case para obter dispositivos do usuário
@lazySingleton
class GetUserDevicesUseCase {
  final DeviceRepository _repository;

  GetUserDevicesUseCase(this._repository);

  /// Executa o use case
  Future<Either<Failure, List<DeviceInfo>>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('ID do usuário não pode ser vazio'));
    }

    return await _repository.getUserDevices(userId);
  }
}
