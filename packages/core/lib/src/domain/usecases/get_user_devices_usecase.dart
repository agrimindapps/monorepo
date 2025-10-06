import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/device_entity.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// Use case para obter todos os dispositivos de um usuário
/// Retorna lista de dispositivos ordenada por última atividade
class GetUserDevicesUseCase implements UseCase<List<DeviceEntity>, GetUserDevicesParams> {
  final IDeviceRepository _deviceRepository;

  const GetUserDevicesUseCase(this._deviceRepository);

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(GetUserDevicesParams params) async {
    try {
      final result = await _deviceRepository.getUserDevices(params.userId);
      
      return result.fold(
        (failure) => Left(failure),
        (devices) {
          final sortedDevices = List<DeviceEntity>.from(devices)
            ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
          if (params.activeOnly) {
            final activeDevices = sortedDevices.where((device) => device.isActive).toList();
            return Right(activeDevices);
          }
          
          return Right(sortedDevices);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar dispositivos do usuário',
          code: 'GET_DEVICES_ERROR',
          details: e,
        ),
      );
    }
  }
}

/// Parâmetros para GetUserDevicesUseCase
class GetUserDevicesParams {
  final String userId;
  final bool activeOnly;

  const GetUserDevicesParams({
    required this.userId,
    this.activeOnly = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetUserDevicesParams &&
        other.userId == userId &&
        other.activeOnly == activeOnly;
  }

  @override
  int get hashCode => userId.hashCode ^ activeOnly.hashCode;

  @override
  String toString() => 'GetUserDevicesParams(userId: $userId, activeOnly: $activeOnly)';
}