import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../repositories/device_repository.dart';
import '../../data/models/device_model.dart';

class UpdateDeviceActivityUseCase {
  final DeviceRepository _repository;

  UpdateDeviceActivityUseCase(this._repository);

  Future<Either<Failure, DeviceModel>> call({
    required String userId,
    required String deviceUuid,
  }) async {
    return await _repository.updateLastActivity(
      userId: userId,
      deviceUuid: deviceUuid,
    );
  }
}