import 'package:injectable/injectable.dart';

import '../../../../core/services/local_data_service.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../mappers/maintenance_mapper.dart';
import '../models/maintenance_model.dart';

/// Service responsible for managing maintenance cache operations
/// Follows SRP by handling only local cache operations
@lazySingleton
class MaintenanceCacheManager {
  MaintenanceCacheManager(this._localDataService);

  final LocalDataService _localDataService;

  /// Get all cached maintenance records
  List<MaintenanceEntity> getAllCached() {
    try {
      final records = _localDataService
          .getAllMaintenanceRecords()
          .map(
            (record) => MaintenanceMapper.modelToEntity(
              MaintenanceModel.fromHiveMap(record),
            ),
          )
          .toList();

      return records;
    } catch (e) {
      return [];
    }
  }

  /// Get cached maintenance record by ID
  MaintenanceEntity? getCachedById(String id) {
    try {
      final recordData = _localDataService.getMaintenanceRecord(id);

      if (recordData == null) return null;

      final model = MaintenanceModel.fromHiveMap(recordData);
      return MaintenanceMapper.modelToEntity(model);
    } catch (e) {
      return null;
    }
  }

  /// Cache a single maintenance record
  Future<void> cacheRecord(MaintenanceEntity maintenance) async {
    try {
      final model = MaintenanceMapper.entityToModel(maintenance);
      await _localDataService.saveMaintenanceRecord(
        maintenance.id,
        model.toHiveMap(),
      );
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Cache multiple maintenance records
  Future<void> cacheRecords(List<MaintenanceEntity> records) async {
    for (final record in records) {
      await cacheRecord(record);
    }
  }

  /// Update cached maintenance record
  Future<void> updateCached(MaintenanceEntity maintenance) async {
    try {
      final existingData = _localDataService.getMaintenanceRecord(
        maintenance.id,
      );

      if (existingData == null) {
        // If not in cache, just cache it
        await cacheRecord(maintenance);
        return;
      }

      final existingModel = MaintenanceModel.fromHiveMap(existingData);
      final model = MaintenanceMapper.updateModelFromEntity(
        existingModel,
        maintenance,
      );

      await _localDataService.saveMaintenanceRecord(
        maintenance.id,
        model.toHiveMap(),
      );
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Remove cached maintenance record
  Future<void> removeCached(String id) async {
    try {
      await _localDataService.deleteMaintenanceRecord(id);
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Clear all cached maintenance records
  Future<void> clearAllCached() async {
    try {
      final allRecords = _localDataService.getAllMaintenanceRecords();
      for (final record in allRecords) {
        final id = record['id'] as String?;
        if (id != null) {
          await _localDataService.deleteMaintenanceRecord(id);
        }
      }
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cached records count
  int getCachedCount() {
    try {
      return _localDataService.getAllMaintenanceRecords().length;
    } catch (e) {
      return 0;
    }
  }

  /// Check if a record exists in cache
  bool isCached(String id) {
    try {
      final recordData = _localDataService.getMaintenanceRecord(id);
      return recordData != null;
    } catch (e) {
      return false;
    }
  }

  /// Get cached records by vehicle ID
  List<MaintenanceEntity> getCachedByVehicle(String vehicleId) {
    try {
      final records = _localDataService
          .getAllMaintenanceRecords()
          .where((record) => record['veiculoId'] == vehicleId)
          .map(
            (record) => MaintenanceMapper.modelToEntity(
              MaintenanceModel.fromHiveMap(record),
            ),
          )
          .toList();

      return records;
    } catch (e) {
      return [];
    }
  }

  /// Get dirty (unsynced) records
  List<MaintenanceEntity> getDirtyCached() {
    try {
      final records = _localDataService
          .getAllMaintenanceRecords()
          .map(
            (record) => MaintenanceMapper.modelToEntity(
              MaintenanceModel.fromHiveMap(record),
            ),
          )
          .where((entity) => entity.isDirty)
          .toList();

      return records;
    } catch (e) {
      return [];
    }
  }

  /// Get cached records that need sync
  List<MaintenanceEntity> getRecordsNeedingSync() {
    try {
      final records = _localDataService
          .getAllMaintenanceRecords()
          .map(
            (record) => MaintenanceMapper.modelToEntity(
              MaintenanceModel.fromHiveMap(record),
            ),
          )
          .where((entity) {
            // Records that are dirty or never synced
            return entity.isDirty || entity.lastSyncAt == null;
          })
          .toList();

      return records;
    } catch (e) {
      return [];
    }
  }

  /// Mark cached record as synced
  Future<void> markAsSynced(String id) async {
    try {
      final recordData = _localDataService.getMaintenanceRecord(id);
      if (recordData == null) return;

      final model = MaintenanceModel.fromHiveMap(recordData);
      final updatedModel = model.copyWith(
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );

      await _localDataService.saveMaintenanceRecord(
        id,
        updatedModel.toHiveMap(),
      );
    } catch (e) {
      // Silent fail for cache operations
    }
  }

  /// Get cache statistics
  MaintenanceCacheStatistics getCacheStatistics() {
    try {
      final allRecords = getAllCached();
      final dirtyRecords = getDirtyCached();
      final needsSync = getRecordsNeedingSync();

      return MaintenanceCacheStatistics(
        totalRecords: allRecords.length,
        dirtyRecords: dirtyRecords.length,
        needsSyncRecords: needsSync.length,
        syncedRecords: allRecords.length - dirtyRecords.length,
      );
    } catch (e) {
      return const MaintenanceCacheStatistics(
        totalRecords: 0,
        dirtyRecords: 0,
        needsSyncRecords: 0,
        syncedRecords: 0,
      );
    }
  }

  /// Cleanup old deleted records (soft delete cleanup)
  Future<void> cleanupOldDeletedRecords({int daysOld = 90}) async {
    try {
      final allRecords = getAllCached();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      for (final record in allRecords) {
        if (record.isDeleted &&
            record.updatedAt != null &&
            record.updatedAt!.isBefore(cutoffDate)) {
          await removeCached(record.id);
        }
      }
    } catch (e) {
      // Silent fail for cleanup operations
    }
  }
}

/// Cache statistics model
class MaintenanceCacheStatistics {
  final int totalRecords;
  final int dirtyRecords;
  final int needsSyncRecords;
  final int syncedRecords;

  const MaintenanceCacheStatistics({
    required this.totalRecords,
    required this.dirtyRecords,
    required this.needsSyncRecords,
    required this.syncedRecords,
  });

  double get syncPercentage {
    if (totalRecords == 0) return 100.0;
    return (syncedRecords / totalRecords) * 100;
  }

  bool get hasUnsyncedData => dirtyRecords > 0 || needsSyncRecords > 0;
}
