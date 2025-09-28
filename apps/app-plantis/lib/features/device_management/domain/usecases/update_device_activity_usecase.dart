import 'package:core/core.dart';

import '../../data/models/device_model.dart';
import '../repositories/device_repository.dart';

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
