import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart' as db_providers;
import '../../domain/usecases/add_odometer_reading.dart';
import '../../domain/usecases/delete_odometer_reading.dart';
import '../../domain/usecases/get_all_odometer_readings.dart';
import '../../domain/usecases/get_last_odometer_reading.dart';
import '../../domain/usecases/get_odometer_readings_by_vehicle.dart';
import '../../domain/usecases/update_odometer_reading.dart';

part 'odometer_providers.g.dart';

@riverpod
AddOdometerReadingUseCase addOdometerReading(Ref ref) {
  return AddOdometerReadingUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}

@riverpod
UpdateOdometerReadingUseCase updateOdometerReading(Ref ref) {
  return UpdateOdometerReadingUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}

@riverpod
DeleteOdometerReadingUseCase deleteOdometerReading(Ref ref) {
  return DeleteOdometerReadingUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}

@riverpod
GetAllOdometerReadingsUseCase getAllOdometerReadings(Ref ref) {
  return GetAllOdometerReadingsUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}

@riverpod
GetOdometerReadingsByVehicleUseCase getOdometerReadingsByVehicle(Ref ref) {
  return GetOdometerReadingsByVehicleUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}

@riverpod
GetLastOdometerReadingUseCase getLastOdometerReading(Ref ref) {
  return GetLastOdometerReadingUseCase(ref.watch(db_providers.odometerRepositoryProvider));
}
