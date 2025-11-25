import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/vehicle_repository.dart';
import '../../data/datasources/vehicle_local_datasource.dart';

part 'vehicle_providers.g.dart';

/// Provides the VehicleRepository instance (DAO)
@riverpod
VehicleRepository vehicleDao(Ref ref) {
  final database = ref.watch(gasometerDatabaseProvider);
  return VehicleRepository(database);
}

/// Provides the VehicleLocalDataSource instance
@riverpod
VehicleLocalDataSource vehicleLocalDataSource(Ref ref) {
  final dao = ref.watch(vehicleDaoProvider);
  final syncTrigger = ref.watch(syncWriteTriggerProvider);
  return VehicleLocalDataSource(dao, syncTrigger);
}

/// Stream of vehicles for a specific user (reactive)
@riverpod
Stream<List<VehicleData>> vehiclesStream(Ref ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.watchVehiclesByUserId(userId);
}

/// Stream of active (not sold) vehicles for a specific user
@riverpod
Stream<List<VehicleData>> activeVehiclesStream(
  Ref ref,
  String userId,
) async* {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  final allVehicles = datasource.watchVehiclesByUserId(userId);

  await for (final vehicles in allVehicles) {
    yield vehicles.where((v) => v.vendido == false && v.isDeleted == false).toList();
  }
}

/// Future provider to fetch a single vehicle by ID
@riverpod
Future<VehicleData?> vehicle(Ref ref, int vehicleId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.findById(vehicleId);
}

/// Future provider to fetch active vehicles (one-time fetch)
@riverpod
Future<List<VehicleData>> activeVehiclesList(Ref ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.getActiveVehicles(userId);
}

/// Future provider to fetch sold vehicles
@riverpod
Future<List<VehicleData>> soldVehicles(Ref ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.getSoldVehicles(userId);
}

/// Future provider to get distinct brands
@riverpod
Future<List<String>> vehicleBrands(Ref ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.findDistinctBrands(userId);
}

/// Future provider to count active vehicles
@riverpod
Future<int> activeVehiclesCount(Ref ref, String userId) {
  final datasource = ref.watch(vehicleLocalDataSourceProvider);
  return datasource.countActiveVehicles(userId);
}
