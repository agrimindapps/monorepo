import 'dart:async';

import 'package:core/core.dart' show GetIt;
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../database/repositories/vehicle_repository.dart';
import '../../../../database/gasometer_database.dart';
import '../../../sync/domain/services/sync_write_trigger.dart';

/// Local data source for vehicles using Drift
///
/// This class provides a clean abstraction over the Drift repository,
/// allowing the domain layer to remain database-agnostic.
///
/// **IMPORTANT:** This datasource uses the Drift repositories directly.
/// IDs are integers (auto-increment), not UUIDs.
@lazySingleton
class VehicleLocalDataSource {
  final VehicleRepository _repository;

  VehicleLocalDataSource(this._repository);

  SyncWriteTrigger get _syncTrigger => GetIt.instance<SyncWriteTrigger>();

  void _notifySync() {
    // Debounced para consolidar múltiplas operações em sequência
    _syncTrigger.scheduleSync();
  }

  /// Get all vehicles for a specific user
  Future<List<VehicleData>> getVehiclesByUserId(String userId) {
    return _repository.findByUserId(userId);
  }

  /// Watch vehicles for a specific user (reactive stream)
  Stream<List<VehicleData>> watchVehiclesByUserId(String userId) {
    return _repository.watchByUserId(userId);
  }

  /// Find a vehicle by ID
  Future<VehicleData?> findById(int id) {
    return _repository.findById(id);
  }

  /// Find a vehicle by license plate
  Future<VehicleData?> findByPlate(String userId, String placa) {
    return _repository.findByPlate(userId, placa);
  }

  /// Add a new vehicle
  /// Returns the ID of the created vehicle
  Future<int> addVehicle({
    required String userId,
    required String marca,
    required String modelo,
    required int ano,
    required String placa,
    required String cor,
    required int combustivel,
    required double odometroInicial,
    String renavan = '',
    String chassi = '',
    double odometroAtual = 0.0,
    bool vendido = false,
    double valorVenda = 0.0,
    String? foto,
  }) async {
    final companion = VehiclesCompanion.insert(
      userId: userId,
      marca: marca,
      modelo: modelo,
      ano: ano,
      placa: placa,
      cor: Value(cor),
      combustivel: Value(combustivel),
      odometroInicial: Value(odometroInicial),
      renavan: Value(renavan),
      chassi: Value(chassi),
      odometroAtual: Value(odometroAtual),
      vendido: Value(vendido),
      valorVenda: Value(valorVenda),
      foto: Value(foto),
      // 🔥 FIX: Marcar como "dirty" para sincronização com Firebase
      isDirty: const Value(true),
    );
    // Use the database insert method directly
    final newId = await _repository.database
        .into(_repository.table)
        .insert(companion);
    _notifySync();
    return newId;
  }

  /// Update an existing vehicle with partial updates
  Future<bool> updateVehicle(int id, VehiclesCompanion updates) async {
    final rowsAffected = await (_repository.database.update(
      _repository.table,
    )..where((tbl) => tbl.id.equals(id))).write(updates);
    final success = rowsAffected > 0;
    if (success) _notifySync();
    return success;
  }

  /// Update current odometer reading
  Future<bool> updateCurrentOdometer(int id, double odometer) {
    return _repository.updateOdometer(id, odometer).then((success) {
      if (success) _notifySync();
      return success;
    });
  }

  /// Alias for updateCurrentOdometer (for convenience)
  Future<bool> updateOdometer(int id, double odometer) {
    return updateCurrentOdometer(id, odometer);
  }

  /// Mark vehicle as sold
  Future<bool> markAsSold(int id, double saleValue) {
    return _repository.markAsSold(id, saleValue).then((success) {
      if (success) _notifySync();
      return success;
    });
  }

  /// Soft delete a vehicle (mark as deleted)
  Future<bool> deleteVehicle(int id) {
    return _repository.softDelete(id).then((success) {
      if (success) _notifySync();
      return success;
    });
  }

  /// Permanently delete a vehicle (hard delete)
  Future<bool> deleteVehiclePermanently(int id) {
    return _repository.delete(id).then((success) {
      if (success) _notifySync();
      return success;
    });
  }

  /// Get active (not sold) vehicles for a user
  Future<List<VehicleData>> getActiveVehicles(String userId) {
    return _repository.findActiveVehicles(userId);
  }

  /// Get sold vehicles for a user
  Future<List<VehicleData>> getSoldVehicles(String userId) {
    return _repository.findSoldVehicles(userId);
  }

  /// Search vehicles by brand
  Future<List<VehicleData>> findByBrand(String userId, String marca) {
    return _repository.findByBrand(userId, marca);
  }

  /// Find vehicles by year
  Future<List<VehicleData>> findByYear(String userId, int year) {
    return _repository.findByYear(userId, year);
  }

  /// Get distinct brands for a user
  Future<List<String>> findDistinctBrands(String userId) {
    return _repository.findDistinctBrands(userId);
  }

  /// Count active vehicles for a user
  Future<int> countActiveVehicles(String userId) {
    return _repository.countActiveVehicles(userId);
  }

  /// Get statistics: total kilometers driven
  Future<double> getTotalKilometersDriven(int vehicleId) async {
    final vehicle = await _repository.findById(vehicleId);
    if (vehicle == null) return 0.0;
    return vehicle.odometroAtual - vehicle.odometroInicial;
  }

  /// Check if plate exists (for validation)
  Future<bool> plateExists(String userId, String placa) async {
    final vehicle = await _repository.findByPlate(userId, placa);
    return vehicle != null;
  }

  /// Check if plate exists for another vehicle (for update validation)
  Future<bool> plateExistsForOtherVehicle(
    String userId,
    int vehicleId,
    String placa,
  ) async {
    final vehicle = await _repository.findByPlate(userId, placa);
    return vehicle != null && vehicle.id != vehicleId;
  }
}
