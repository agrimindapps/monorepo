import 'package:core/core.dart' show GetIt;

import '../../../../database/repositories/odometer_reading_repository.dart';
import '../../../sync/domain/services/sync_write_trigger.dart';

/// DataSource local para leituras de odômetro usando Drift

class OdometerReadingLocalDataSource {
  OdometerReadingLocalDataSource(this._repository);

  final OdometerReadingRepository _repository;
  SyncWriteTrigger get _syncTrigger => GetIt.instance<SyncWriteTrigger>();

  void _notifySync() {
    _syncTrigger.scheduleSync();
  }

  // ========== CRUD BÁSICO ==========

  Future<int> create({
    required String userId,
    required int vehicleId,
    required double reading,
    required DateTime date,
    String? notes,
  }) async {
    final now = DateTime.now();
    final data = OdometerReadingData(
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
      reading: reading,
      date: date.millisecondsSinceEpoch,
      notes: notes,
    );

    final newId = await _repository.insert(data);
    _notifySync();
    return newId;
  }

  Future<OdometerReadingData?> findById(int id) async {
    return await _repository.findById(id);
  }

  Future<List<OdometerReadingData>> findAll() async {
    return await _repository.findAll();
  }

  Stream<List<OdometerReadingData>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<OdometerReadingData>> findByVehicleId(int vehicleId) async {
    return await _repository.findByVehicleId(vehicleId);
  }

  Stream<List<OdometerReadingData>> watchByVehicleId(int vehicleId) {
    return _repository.watchByVehicleId(vehicleId);
  }

  Future<OdometerReadingData?> findLatestByVehicleId(int vehicleId) async {
    return await _repository.findLatestByVehicleId(vehicleId);
  }

  Stream<OdometerReadingData?> watchLatestByVehicleId(int vehicleId) {
    return _repository.watchLatestByVehicleId(vehicleId);
  }

  Future<OdometerReadingData?> findFirstByVehicleId(int vehicleId) async {
    return await _repository.findFirstByVehicleId(vehicleId);
  }

  Future<List<OdometerReadingData>> findByPeriod(
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

  Future<List<OdometerReadingData>> findRecent(
    int vehicleId, {
    int limit = 10,
  }) async {
    return await _repository.findRecent(vehicleId, limit: limit);
  }

  Future<bool> update({
    required int id,
    required String userId,
    required int vehicleId,
    required double reading,
    required DateTime date,
    String? notes,
  }) async {
    // Buscar registro existente para preservar campos
    final existing = await _repository.findById(id);
    if (existing == null) return false;

    final data = OdometerReadingData(
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
      reading: reading,
      date: date.millisecondsSinceEpoch,
      notes: notes,
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

  Future<double> calculateTotalDistance(int vehicleId) async {
    return await _repository.calculateTotalDistance(vehicleId);
  }

  Future<double> calculateDistanceInPeriod(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.calculateDistanceInPeriod(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, double>> getAverageOdometerByMonth(int vehicleId) async {
    return await _repository.getAverageOdometerByMonth(vehicleId);
  }

  Future<int> countByVehicleId(int vehicleId) async {
    return await _repository.countByVehicleId(vehicleId);
  }

  Future<bool> existsDuplicateReading(
    int vehicleId,
    double reading,
    DateTime date,
  ) async {
    return await _repository.existsDuplicateReading(
      vehicleId,
      reading,
      date.millisecondsSinceEpoch,
    );
  }

  // ========== SINCRONIZAÇÃO ==========

  Future<List<OdometerReadingData>> findDirtyRecords() async {
    return await _repository.findDirtyRecords();
  }

  Future<void> markAsSynced(List<int> readingIds) async {
    return await _repository.markAsSynced(readingIds);
  }
}
