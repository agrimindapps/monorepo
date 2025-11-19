import 'package:core/core.dart' show GetIt;
import 'package:injectable/injectable.dart';

import '../../../../database/repositories/fuel_supply_repository.dart';
import '../../../sync/domain/services/sync_write_trigger.dart';

/// DataSource local para abastecimentos usando Drift
@lazySingleton
class FuelSupplyLocalDataSource {
  FuelSupplyLocalDataSource(this._repository);

  final FuelSupplyRepository _repository;
  SyncWriteTrigger get _syncTrigger => GetIt.instance<SyncWriteTrigger>();

  void _notifySync() {
    _syncTrigger.scheduleSync();
  }

  // ========== CRUD BÁSICO ==========

  Future<int> create({
    required String userId,
    required int vehicleId,
    required DateTime date,
    required double odometer,
    required double liters,
    required double pricePerLiter,
    required double totalPrice,
    required bool fullTank,
    int? fuelType,
    String? gasStationName,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    final now = DateTime.now();
    final data = FuelSupplyData(
      id: 0, // Auto-increment
      userId: userId,
      moduleName: 'gasometer',
      vehicleId: vehicleId,
      createdAt: now,
      updatedAt: now,
      lastSyncAt: null,
      isDirty: true,
      isDeleted: false,
      version: 1,
      date: date.millisecondsSinceEpoch,
      odometer: odometer,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalPrice: totalPrice,
      fullTank: fullTank,
      fuelType: fuelType ?? 0,
      gasStationName: gasStationName,
      notes: notes,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    final newId = await _repository.insert(data);
    _notifySync();
    return newId;
  }

  Future<FuelSupplyData?> findById(int id) async {
    return await _repository.findById(id);
  }

  Future<List<FuelSupplyData>> findAll() async {
    return await _repository.findAll();
  }

  Stream<List<FuelSupplyData>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<FuelSupplyData>> findByVehicleId(
    int vehicleId, {
    int? limit,
  }) async {
    return await _repository.findByVehicleId(vehicleId, limit: limit);
  }

  Stream<List<FuelSupplyData>> watchByVehicleId(int vehicleId) {
    return _repository.watchByVehicleId(vehicleId);
  }

  Future<FuelSupplyData?> findLastByVehicleId(int vehicleId) async {
    return await _repository.findLastByVehicleId(vehicleId);
  }

  Future<List<FuelSupplyData>> findByPeriod(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.findByPeriod(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<FuelSupplyData>> findFullTankByVehicleId(int vehicleId) async {
    return await _repository.findFullTankByVehicleId(vehicleId);
  }

  Future<bool> update({
    required int id,
    required String userId,
    required int vehicleId,
    required DateTime date,
    required double odometer,
    required double liters,
    required double pricePerLiter,
    required double totalPrice,
    required bool fullTank,
    int? fuelType,
    String? gasStationName,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    // Buscar registro existente para preservar campos
    final existing = await _repository.findById(id);
    if (existing == null) return false;

    final data = FuelSupplyData(
      id: id,
      userId: userId,
      moduleName: existing.moduleName,
      vehicleId: vehicleId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: existing.lastSyncAt,
      isDirty: true,
      isDeleted: existing.isDeleted,
      version: existing.version + 1,
      date: date.millisecondsSinceEpoch,
      odometer: odometer,
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalPrice: totalPrice,
      fullTank: fullTank,
      fuelType: fuelType ?? 0,
      gasStationName: gasStationName,
      notes: notes,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    final success = await _repository.update(data);
    if (success) _notifySync();
    return success;
  }

  Future<bool> delete(int id) async {
    final success = await _repository.softDelete(id);
    if (success) _notifySync();
    return success;
  }

  // ========== ESTATÍSTICAS ==========

  Future<double> calculateTotalSpent(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.calculateTotalSpent(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<double> calculateTotalLiters(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.calculateTotalLiters(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<double> calculateAveragePricePerLiter(int vehicleId) async {
    return await _repository.calculateAveragePricePerLiter(vehicleId);
  }

  Future<int> countByVehicleId(int vehicleId) async {
    return await _repository.countByVehicleId(vehicleId);
  }

  // ========== SINCRONIZAÇÃO ==========

  Future<List<FuelSupplyData>> findDirtyRecords() async {
    return await _repository.findDirtyRecords();
  }

  Future<void> markAsSynced(List<int> supplyIds) async {
    return await _repository.markAsSynced(supplyIds);
  }
}
