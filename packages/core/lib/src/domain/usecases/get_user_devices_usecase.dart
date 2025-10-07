import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/device_entity.dart';
import '../repositories/i_device_repository.dart';
import 'base_usecase.dart';

/// A use case to get all devices for a user.
///
/// Returns a list of devices sorted by the last activity time.
class GetUserDevicesUseCase implements UseCase<List<DeviceEntity>, GetUserDevicesParams> {
  final IDeviceRepository _deviceRepository;

  /// Creates a new instance of [GetUserDevicesUseCase].
  ///
  /// [deviceRepository] The repository to fetch device data.
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

/// Parameters for the [GetUserDevicesUseCase].
class GetUserDevicesParams {
  /// The unique identifier of the user.
  final String userId;

  /// A flag to indicate if only active devices should be returned.
  final bool activeOnly;

  /// Creates a new instance of [GetUserDevicesParams].
  ///
  /// [userId] The unique identifier of the user.
  /// [activeOnly] A flag to indicate if only active devices should be returned.
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
