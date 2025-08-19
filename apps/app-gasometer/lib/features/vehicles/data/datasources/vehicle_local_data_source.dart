import 'package:injectable/injectable.dart';
import '../../../../core/services/local_data_service.dart';
import '../models/vehicle_model.dart';

abstract class VehicleLocalDataSource {
  Future<List<VehicleModel>> getAllVehicles();
  Future<VehicleModel?> getVehicleById(String id);
  Future<void> saveVehicle(VehicleModel vehicle);
  Future<void> updateVehicle(VehicleModel vehicle);
  Future<void> deleteVehicle(String id);
  Future<void> clearAllVehicles();
}

@LazySingleton(as: VehicleLocalDataSource)
class VehicleLocalDataSourceImpl implements VehicleLocalDataSource {
  final LocalDataService _localDataService;

  VehicleLocalDataSourceImpl(this._localDataService);

  @override
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final vehiclesData = _localDataService.getAllVehicles();
      return vehiclesData
          .map((data) => VehicleModel.fromJson(data))
          .toList();
    } catch (e) {
      throw LocalDataSourceException('Failed to get all vehicles: $e');
    }
  }

  @override
  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      final vehicleData = _localDataService.getVehicle(id);
      if (vehicleData == null) return null;
      return VehicleModel.fromJson(vehicleData);
    } catch (e) {
      throw LocalDataSourceException('Failed to get vehicle by id: $e');
    }
  }

  @override
  Future<void> saveVehicle(VehicleModel vehicle) async {
    try {
      await _localDataService.saveVehicle(vehicle.id, vehicle.toJson());
    } catch (e) {
      throw LocalDataSourceException('Failed to save vehicle: $e');
    }
  }

  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      await _localDataService.saveVehicle(vehicle.id, vehicle.toJson());
    } catch (e) {
      throw LocalDataSourceException('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _localDataService.deleteVehicle(id);
    } catch (e) {
      throw LocalDataSourceException('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<void> clearAllVehicles() async {
    try {
      final vehicles = await getAllVehicles();
      for (final vehicle in vehicles) {
        await deleteVehicle(vehicle.id);
      }
    } catch (e) {
      throw LocalDataSourceException('Failed to clear all vehicles: $e');
    }
  }
}

class LocalDataSourceException implements Exception {
  final String message;
  LocalDataSourceException(this.message);

  @override
  String toString() => 'LocalDataSourceException: $message';
}