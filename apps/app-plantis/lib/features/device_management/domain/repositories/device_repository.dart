import 'package:core/core.dart';

import '../../../device_management/data/models/device_model.dart';

/// Device Repository Interface
abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(
    String userId,
  );
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId);
  Future<Either<Failure, void>> clearCache();
}
