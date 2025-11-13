import 'package:core/core.dart';

import '../services/image_sync_service.dart';
import '../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../features/fuel/domain/usecases/add_fuel_record.dart';
import '../../features/fuel/domain/usecases/delete_fuel_record.dart';
import '../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../features/fuel/domain/usecases/update_fuel_record.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../features/vehicles/domain/usecases/add_vehicle.dart';
import '../../features/vehicles/domain/usecases/delete_vehicle.dart';
import '../../features/vehicles/domain/usecases/get_all_vehicles.dart';
import '../../features/vehicles/domain/usecases/get_vehicle_by_id.dart';
import '../../features/vehicles/domain/usecases/update_vehicle.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return GetIt.instance<FirebaseAuthService>();
});

// Removed: Hive storage migrated to Drift
// Use GasometerDatabase instead

final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService>((
  ref,
) {
  return GetIt.instance<FirebaseAnalyticsService>();
});

final firebaseCrashlyticsServiceProvider = Provider<FirebaseCrashlyticsService>(
  (ref) {
    return GetIt.instance<FirebaseCrashlyticsService>();
  },
);

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return GetIt.instance<ConnectivityService>();
});

final imageSyncServiceProvider = Provider<ImageSyncService>((ref) {
  return GetIt.instance<ImageSyncService>();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return GetIt.instance<VehicleRepository>();
});

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  return GetIt.instance<FuelRepository>();
});
final getAllVehiclesProvider = Provider<GetAllVehicles>((ref) {
  return GetIt.instance<GetAllVehicles>();
});

final addVehicleProvider = Provider<AddVehicle>((ref) {
  return GetIt.instance<AddVehicle>();
});

final updateVehicleProvider = Provider<UpdateVehicle>((ref) {
  return GetIt.instance<UpdateVehicle>();
});

final deleteVehicleProvider = Provider<DeleteVehicle>((ref) {
  return GetIt.instance<DeleteVehicle>();
});

final getVehicleByIdProvider = Provider<GetVehicleById>((ref) {
  return GetIt.instance<GetVehicleById>();
});
final getAllFuelRecordsProvider = Provider<GetAllFuelRecords>((ref) {
  return GetIt.instance<GetAllFuelRecords>();
});

final getFuelRecordsByVehicleProvider = Provider<GetFuelRecordsByVehicle>((
  ref,
) {
  return GetIt.instance<GetFuelRecordsByVehicle>();
});

final addFuelRecordProvider = Provider<AddFuelRecord>((ref) {
  return GetIt.instance<AddFuelRecord>();
});

final updateFuelRecordProvider = Provider<UpdateFuelRecord>((ref) {
  return GetIt.instance<UpdateFuelRecord>();
});

final deleteFuelRecordProvider = Provider<DeleteFuelRecord>((ref) {
  return GetIt.instance<DeleteFuelRecord>();
});
final gasometerSharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  return GetIt.instance<SharedPreferences>();
});
final appRatingRepositoryProvider = Provider<IAppRatingRepository>((ref) {
  try {
    return GetIt.instance<IAppRatingRepository>();
  } catch (e) {
    throw Exception(
      'IAppRatingRepository not registered in GetIt. Please register it in your dependency injection setup.',
    );
  }
});
