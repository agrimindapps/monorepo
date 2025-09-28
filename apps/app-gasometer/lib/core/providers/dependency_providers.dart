import 'package:core/core.dart';

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

// Core Services Providers using GetIt integration
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return GetIt.instance<FirebaseAuthService>();
});

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  return GetIt.instance<HiveStorageService>();
});

final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService>((ref) {
  return GetIt.instance<FirebaseAnalyticsService>();
});

final firebaseCrashlyticsServiceProvider = Provider<FirebaseCrashlyticsService>((ref) {
  return GetIt.instance<FirebaseCrashlyticsService>();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return GetIt.instance<ConnectivityService>();
});

// Repository Providers
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return GetIt.instance<VehicleRepository>();
});

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  return GetIt.instance<FuelRepository>();
});

// Vehicle Use Cases Providers
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

// Fuel Use Cases Providers
final getAllFuelRecordsProvider = Provider<GetAllFuelRecords>((ref) {
  return GetIt.instance<GetAllFuelRecords>();
});

final getFuelRecordsByVehicleProvider = Provider<GetFuelRecordsByVehicle>((ref) {
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
