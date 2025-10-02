import 'dart:async';

import 'package:core/core.dart';

import '../../../../core/providers/base_provider.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/delete_maintenance_record.dart';
import '../../domain/usecases/get_all_maintenance_records.dart';
import '../../domain/usecases/get_maintenance_analytics.dart';
import '../../domain/usecases/get_maintenance_records_by_vehicle.dart';
import '../../domain/usecases/get_upcoming_maintenance_records.dart';
import '../../domain/usecases/update_maintenance_record.dart';
import '../services/maintenance_statistics_service.dart';

/// Provider for managing maintenance records operations
///
/// This provider handles CRUD operations for maintenance records and integrates
/// with analytics and statistics.
@injectable
class MaintenanceProvider extends BaseProvider {
  MaintenanceProvider(
    this._getAllMaintenanceRecords,
    this._getMaintenanceRecordsByVehicle,
    this._addMaintenanceRecord,
    this._updateMaintenanceRecord,
    this._deleteMaintenanceRecord,
    this._getUpcomingMaintenanceRecords,
    this._getMaintenanceAnalytics,
  ) : _statisticsService = MaintenanceStatisticsService();

  // Use Cases
  final GetAllMaintenanceRecords _getAllMaintenanceRecords;
  final GetMaintenanceRecordsByVehicle _getMaintenanceRecordsByVehicle;
  final AddMaintenanceRecord _addMaintenanceRecord;
  final UpdateMaintenanceRecord _updateMaintenanceRecord;
  final DeleteMaintenanceRecord _deleteMaintenanceRecord;
  final GetUpcomingMaintenanceRecords _getUpcomingMaintenanceRecords;
  final GetMaintenanceAnalytics _getMaintenanceAnalytics;

  // Services
  final MaintenanceStatisticsService _statisticsService;

  // Internal state
  List<MaintenanceEntity> _maintenanceRecords = [];
  List<MaintenanceEntity> _upcomingRecords = [];
  MaintenanceAnalytics? _analytics;
  String? _selectedVehicleId;

  // Cached statistics
  MaintenanceStatistics? _cachedStatistics;
  bool _statisticsNeedRecalculation = true;

  // ===========================================
  // GETTERS
  // ===========================================

  List<MaintenanceEntity> get maintenanceRecords =>
      List.unmodifiable(_maintenanceRecords);
  List<MaintenanceEntity> get upcomingRecords =>
      List.unmodifiable(_upcomingRecords);
  MaintenanceAnalytics? get analytics => _analytics;
  String? get selectedVehicleId => _selectedVehicleId;

  /// Filtered records by selected vehicle
  List<MaintenanceEntity> get filteredRecords {
    if (_selectedVehicleId == null) return _maintenanceRecords;
    return _maintenanceRecords
        .where((record) => record.vehicleId == _selectedVehicleId)
        .toList();
  }

  /// Cached statistics getter
  MaintenanceStatistics get statistics {
    final records = filteredRecords;
    if (_cachedStatistics == null ||
        _statisticsNeedRecalculation ||
        _cachedStatistics!.needsRecalculation ||
        _cachedStatistics!.totalRecords != records.length) {
      _cachedStatistics = _statisticsService.calculateStatistics(records);
      _statisticsNeedRecalculation = false;
    }
    return _cachedStatistics!;
  }

  // Convenience getters for maintenance statistics
  double get totalMaintenanceCost => statistics.totalCost;

  Map<MaintenanceType, int> get maintenanceCountByType =>
      _statisticsService.getMaintenanceCountByType(statistics);

  List<MaintenanceEntity> get recentMaintenanceRecords =>
      statistics.recentRecords;

  List<MaintenanceEntity> get overdueMaintenance =>
      _statisticsService.getOverdueMaintenance(filteredRecords);

  List<MaintenanceEntity> get pendingMaintenance =>
      _statisticsService.getPendingMaintenance(filteredRecords);

  List<MaintenanceEntity> get completedMaintenance =>
      _statisticsService.getCompletedMaintenance(filteredRecords);

  // Formatted getters for UI
  String get formattedTotalCost => statistics.formattedTotalCost;
  String get maintenanceCountSummary => statistics.maintenanceCountSummary;

  // ===========================================
  // VEHICLE SELECTION
  // ===========================================

  /// Selects a vehicle and loads its maintenance data
  void selectVehicle(String? vehicleId) {
    if (_selectedVehicleId != vehicleId) {
      _selectedVehicleId = vehicleId;
      _invalidateStatistics();
      notifyListeners();
      if (vehicleId != null) {
        loadMaintenanceRecordsByVehicle(vehicleId);
        loadUpcomingMaintenanceRecords(vehicleId);
        loadMaintenanceAnalytics(vehicleId);
      }
    }
  }

  // ===========================================
  // LOADING OPERATIONS
  // ===========================================

  /// Loads all maintenance records
  Future<void> loadAllMaintenanceRecords() async {
    await executeListOperation(
      () async {
        final result = await _getAllMaintenanceRecords(const NoParams());
        return result.fold(
          (failure) => throw failure,
          (records) => records,
        );
      },
      operationName: 'loadAllMaintenanceRecords',
      onSuccess: (records) {
        _maintenanceRecords = records;
        _sortRecords();
        _invalidateStatistics();
        logInfo('Loaded ${records.length} maintenance records');
      },
    );
  }

  /// Loads maintenance records for a specific vehicle
  Future<void> loadMaintenanceRecordsByVehicle(String vehicleId) async {
    await executeListOperation(
      () async {
        final result = await _getMaintenanceRecordsByVehicle(
          GetMaintenanceRecordsByVehicleParams(vehicleId: vehicleId),
        );
        return result.fold(
          (failure) => throw failure,
          (records) => records,
        );
      },
      operationName: 'loadMaintenanceRecordsByVehicle',
      onSuccess: (records) {
        _maintenanceRecords = records;
        _sortRecords();
        _invalidateStatistics();
        logInfo('Loaded ${records.length} records for vehicle $vehicleId');
      },
    );
  }

  /// Loads upcoming maintenance records
  Future<void> loadUpcomingMaintenanceRecords(String vehicleId,
      {int days = 30}) async {
    await executeListOperation(
      () async {
        final result = await _getUpcomingMaintenanceRecords(
          GetUpcomingMaintenanceRecordsParams(
            vehicleId: vehicleId,
            days: days,
          ),
        );
        return result.fold(
          (failure) => throw failure,
          (records) => records,
        );
      },
      operationName: 'loadUpcomingMaintenanceRecords',
      onSuccess: (records) {
        _upcomingRecords = records;
        logInfo('Loaded ${records.length} upcoming maintenance records');
      },
    );
  }

  /// Loads maintenance analytics
  Future<void> loadMaintenanceAnalytics(
    String vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await executeDataOperation(
      () async {
        final result = await _getMaintenanceAnalytics(
          GetMaintenanceAnalyticsParams(
            vehicleId: vehicleId,
            startDate: startDate,
            endDate: endDate,
          ),
        );
        return result.fold(
          (failure) => throw failure,
          (analytics) => analytics,
        );
      },
      operationName: 'loadMaintenanceAnalytics',
      onSuccess: (analytics) {
        _analytics = analytics;
        logInfo('Loaded maintenance analytics for vehicle $vehicleId');
      },
    );
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Adds a new maintenance record
  Future<bool> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    return await executeDataOperation(
      () async {
        final result = await _addMaintenanceRecord(
          AddMaintenanceRecordParams(maintenance: maintenance),
        );
        return result.fold(
          (failure) => throw failure,
          (addedRecord) => addedRecord,
        );
      },
      operationName: 'addMaintenanceRecord',
      onSuccess: (addedRecord) {
        _maintenanceRecords.add(addedRecord);
        _sortRecords();
        _invalidateStatistics();
        logInfo('Maintenance record added: ${addedRecord.id}');
      },
    ).then((result) => result != null);
  }

  /// Updates an existing maintenance record
  Future<bool> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
    return await executeDataOperation(
      () async {
        final result = await _updateMaintenanceRecord(
          UpdateMaintenanceRecordParams(maintenance: maintenance),
        );
        return result.fold(
          (failure) => throw failure,
          (updatedRecord) => updatedRecord,
        );
      },
      operationName: 'updateMaintenanceRecord',
      onSuccess: (updatedRecord) {
        final index =
            _maintenanceRecords.indexWhere((r) => r.id == updatedRecord.id);
        if (index != -1) {
          _maintenanceRecords[index] = updatedRecord;
          _invalidateStatistics();
        }
        logInfo('Maintenance record updated: ${updatedRecord.id}');
      },
    ).then((result) => result != null);
  }

  /// Deletes a maintenance record
  Future<bool> deleteMaintenanceRecord(String id) async {
    return await executeDataOperation(
      () async {
        final result = await _deleteMaintenanceRecord(
          DeleteMaintenanceRecordParams(id: id),
        );
        return result.fold(
          (failure) => throw failure,
          (_) => true,
        );
      },
      operationName: 'deleteMaintenanceRecord',
      onSuccess: (_) {
        _maintenanceRecords.removeWhere((record) => record.id == id);
        _invalidateStatistics();
        logInfo('Maintenance record deleted: $id');
      },
    ).then((result) => result == true);
  }

  // ===========================================
  // QUERY OPERATIONS
  // ===========================================

  /// Searches maintenance records by query
  List<MaintenanceEntity> searchMaintenanceRecords(String query) {
    if (query.isEmpty) return filteredRecords;

    final lowerQuery = query.toLowerCase();
    return filteredRecords.where((record) {
      return record.title.toLowerCase().contains(lowerQuery) ||
          record.description.toLowerCase().contains(lowerQuery) ||
          record.workshopName?.toLowerCase().contains(lowerQuery) == true ||
          record.notes?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  /// Gets maintenance records by type
  List<MaintenanceEntity> getMaintenanceRecordsByType(MaintenanceType type) {
    return filteredRecords.where((record) => record.type == type).toList();
  }

  /// Gets maintenance records by status
  List<MaintenanceEntity> getMaintenanceRecordsByStatus(
      MaintenanceStatus status) {
    return filteredRecords.where((record) => record.status == status).toList();
  }

  /// Gets maintenance records by date range
  List<MaintenanceEntity> getMaintenanceRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return filteredRecords.where((record) {
      return record.serviceDate.isAfter(startDate) &&
          record.serviceDate.isBefore(endDate);
    }).toList();
  }

  // ===========================================
  // HELPER METHODS
  // ===========================================

  /// Sorts records by service date (most recent first)
  void _sortRecords() {
    _maintenanceRecords
        .sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  }

  /// Invalidates cached statistics
  void _invalidateStatistics() {
    _statisticsNeedRecalculation = true;
  }

  /// Clears all data
  void clear() {
    _maintenanceRecords.clear();
    _upcomingRecords.clear();
    _analytics = null;
    _selectedVehicleId = null;
    _invalidateStatistics();
    setState(ProviderState.loaded);
    notifyListeners();
  }
}
