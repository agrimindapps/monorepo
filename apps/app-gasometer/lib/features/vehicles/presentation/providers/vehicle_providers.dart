import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/vehicle_repository.dart';
import '../../data/datasources/vehicle_local_datasource.dart';

part 'vehicle_providers.g.dart';

/// Provides the VehicleRepository instance (DAO)
@riverpod
VehicleRepository vehicleDao(VehicleDaoRef ref) {
  final database = ref.watch(gasometerDatabaseProvider);
  return VehicleRepository(database);
}

/// Provides the VehicleLocalDataSource instance
@riverpod
VehicleLocalDataSource vehicleLocalDataSource(VehicleLocalDataSourceRef ref) {
  final dao = ref.watch(vehicleDaoProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return VehicleLocalDataSource(dao, syncTrigger);
}

/// Stream of vehicles for a specific user (reactive)
@riverpod
Stream<List<VehicleData>> vehiclesStream(VehiclesStreamRef ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.watchVehiclesByUserId(userId);
}

/// Stream of active (not sold) vehicles for a specific user
@riverpod
Stream<List<VehicleData>> activeVehiclesStream(
  ActiveVehiclesStreamRef ref,
  String userId,
) async* {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  final allVehicles = datasource.watchVehiclesByUserId(userId);

  await for (final vehicles in allVehicles) {
    yield vehicles.where((v) => !v.vendido && !v.isDeleted).toList();
  }
}

/// Future provider to fetch a single vehicle by ID
@riverpod
Future<VehicleData?> vehicle(VehicleRef ref, int vehicleId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.findById(vehicleId);
}

/// Future provider to fetch active vehicles (one-time fetch)
@riverpod
Future<List<VehicleData>> activeVehicles(ActiveVehiclesRef ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.getActiveVehicles(userId);
}

/// Future provider to fetch sold vehicles
@riverpod
Future<List<VehicleData>> soldVehicles(SoldVehiclesRef ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.getSoldVehicles(userId);
}

/// Future provider to get distinct brands
@riverpod
Future<List<String>> vehicleBrands(VehicleBrandsRef ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.findDistinctBrands(userId);
}

/// Future provider to count active vehicles
@riverpod
Future<int> activeVehiclesCount(ActiveVehiclesCountRef ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.countActiveVehicles(userId);
}
