import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../database/gasometer_database.dart';
import '../../data/datasources/vehicle_local_datasource.dart';
import '../providers/vehicle_providers.dart';

part 'vehicle_controller.g.dart';

/// Controller for vehicle CRUD operations
///
/// This controller manages all vehicle-related business logic,
/// delegating database operations to VehicleLocalDataSource.
@riverpod
class VehicleController extends _$VehicleController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Get the datasource from providers
  VehicleLocalDataSource get _datasource =>
      ref.read(vehicleLocalDataSourceProvider);

  /// Add a new vehicle
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
    state = const AsyncValue.loading();
    try {
      final id = await _datasource.addVehicle(
        userId: userId,
        marca: marca,
        modelo: modelo,
        ano: ano,
        placa: placa,
        cor: cor,
        combustivel: combustivel,
        odometroInicial: odometroInicial,
        renavan: renavan,
        chassi: chassi,
        odometroAtual: odometroAtual,
        vendido: vendido,
        valorVenda: valorVenda,
        foto: foto,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update a vehicle with partial changes
  Future<bool> updateVehicle(int id, VehiclesCompanion updates) async {
    state = const AsyncValue.loading();
    try {
      final success = await _datasource.updateVehicle(id, updates);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update only the odometer reading
  Future<bool> updateOdometer(int vehicleId, double newOdometer) async {
    state = const AsyncValue.loading();
    try {
      final success = await _datasource.updateOdometer(vehicleId, newOdometer);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Mark a vehicle as sold
  Future<bool> markAsSold(int vehicleId, double saleValue) async {
    state = const AsyncValue.loading();
    try {
      final success = await _datasource.markAsSold(vehicleId, saleValue);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Soft delete a vehicle (mark as deleted)
  Future<bool> deleteVehicle(int vehicleId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _datasource.deleteVehicle(vehicleId);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Permanently delete a vehicle (hard delete)
  Future<bool> hardDeleteVehicle(int vehicleId) async {
    state = const AsyncValue.loading();
    try {
      final success = await _datasource.deleteVehiclePermanently(vehicleId);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Validate if a plate already exists
  Future<bool> validatePlate(String userId, String placa) async {
    return await _datasource.plateExists(userId, placa);
  }

  /// Validate if a plate exists for a different vehicle (for updates)
  Future<bool> validatePlateForUpdate(
    String userId,
    int vehicleId,
    String placa,
  ) async {
    return await _datasource.plateExistsForOtherVehicle(
      userId,
      vehicleId,
      placa,
    );
  }
}
