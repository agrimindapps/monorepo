import 'package:core/core.dart' show GetIt;
import 'package:injectable/injectable.dart';

import '../../../../database/repositories/maintenance_repository.dart';
import '../../../sync/domain/services/sync_write_trigger.dart';

/// DataSource local para manutenções usando Drift
@lazySingleton
class MaintenanceLocalDataSource {
  MaintenanceLocalDataSource(this._repository);

  final MaintenanceRepository _repository;
  SyncWriteTrigger get _syncTrigger => GetIt.instance<SyncWriteTrigger>();

  void _notifySync() {
    _syncTrigger.scheduleSync();
  }

  // ========== CRUD BÁSICO ==========

  Future<int> create({
    required String userId,
    required int vehicleId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime data,
    required int odometro,
    int? proximaRevisao,
    bool concluida = false,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    final now = DateTime.now();
    final maintenanceData = MaintenanceData(
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
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      data: data.millisecondsSinceEpoch,
      odometro: odometro,
      proximaRevisao: proximaRevisao,
      concluida: concluida,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    final newId = await _repository.insert(maintenanceData);
    _notifySync();
    return newId;
  }

  Future<MaintenanceData?> findById(int id) async {
    return await _repository.findById(id);
  }

  Future<List<MaintenanceData>> findAll() async {
    return await _repository.findAll();
  }

  Stream<List<MaintenanceData>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<MaintenanceData>> findByVehicleId(int vehicleId) async {
    return await _repository.findByVehicleId(vehicleId);
  }

  Stream<List<MaintenanceData>> watchByVehicleId(int vehicleId) {
    return _repository.watchByVehicleId(vehicleId);
  }

  Future<List<MaintenanceData>> findPendingByVehicleId(int vehicleId) async {
    return await _repository.findPendingByVehicleId(vehicleId);
  }

  Stream<List<MaintenanceData>> watchPendingByVehicleId(int vehicleId) {
    return _repository.watchPendingByVehicleId(vehicleId);
  }

  Future<List<MaintenanceData>> findCompletedByVehicleId(int vehicleId) async {
    return await _repository.findCompletedByVehicleId(vehicleId);
  }

  Future<List<MaintenanceData>> findByType(int vehicleId, String tipo) async {
    return await _repository.findByType(vehicleId, tipo);
  }

  Future<List<MaintenanceData>> findByPeriod(
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

  Future<bool> update({
    required int id,
    required String userId,
    required int vehicleId,
    required String tipo,
    required String descricao,
    required double valor,
    required DateTime data,
    required int odometro,
    int? proximaRevisao,
    bool? concluida,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    // Buscar registro existente para preservar campos
    final existing = await _repository.findById(id);
    if (existing == null) return false;

    final maintenanceData = MaintenanceData(
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
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      data: data.millisecondsSinceEpoch,
      odometro: odometro,
      proximaRevisao: proximaRevisao,
      concluida: concluida ?? existing.concluida,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    final success = await _repository.update(maintenanceData);
    if (success) _notifySync();
    return success;
  }

  Future<bool> delete(int id) async {
    final success = await _repository.softDelete(id);
    if (success) _notifySync();
    return success;
  }

  Future<bool> markAsCompleted(int maintenanceId) async {
    final success = await _repository.markAsCompleted(maintenanceId);
    if (success) _notifySync();
    return success;
  }

  // ========== ESTATÍSTICAS ==========

  Future<double> calculateTotalCost(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.calculateTotalCost(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<int> countByVehicleId(int vehicleId) async {
    return await _repository.countByVehicleId(vehicleId);
  }

  Future<int> countPendingByVehicleId(int vehicleId) async {
    return await _repository.countPendingByVehicleId(vehicleId);
  }

  Future<List<String>> findDistinctTypes(int vehicleId) async {
    return await _repository.findDistinctTypes(vehicleId);
  }

  // ========== SINCRONIZAÇÃO ==========

  Future<List<MaintenanceData>> findDirtyRecords() async {
    return await _repository.findDirtyRecords();
  }

  Future<void> markAsSynced(List<int> maintenanceIds) async {
    return await _repository.markAsSynced(maintenanceIds);
  }
}
