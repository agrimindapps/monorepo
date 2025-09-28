import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_filter_service.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/delete_maintenance_record.dart';
import '../../domain/usecases/get_all_maintenance_records.dart';
import '../../domain/usecases/get_maintenance_records_by_vehicle.dart';
import '../../domain/usecases/update_maintenance_record.dart';

/// Consolidated maintenance provider that combines CRUD operations with filtering/listing
/// Replaces both MaintenanceProvider and MaintenancesProvider
@injectable
class UnifiedMaintenanceProvider extends ChangeNotifier {

  UnifiedMaintenanceProvider(
    this._getAllMaintenanceRecords,
    this._getMaintenanceRecordsByVehicle,
    this._addMaintenanceRecord,
    this._updateMaintenanceRecord,
    this._deleteMaintenanceRecord,
    this._filterService,
  );
  final GetAllMaintenanceRecords _getAllMaintenanceRecords;
  final GetMaintenanceRecordsByVehicle _getMaintenanceRecordsByVehicle;
  final AddMaintenanceRecord _addMaintenanceRecord;
  final UpdateMaintenanceRecord _updateMaintenanceRecord;
  final DeleteMaintenanceRecord _deleteMaintenanceRecord;
  final MaintenanceFilterService _filterService;

  // Core data state
  List<MaintenanceEntity> _allMaintenances = [];
  List<MaintenanceEntity> _filteredMaintenances = [];
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter and sort state
  MaintenanceFilters _filters = MaintenanceFilters.empty;
  MaintenanceSorting _sorting = const MaintenanceSorting();
  
  // Analytics state
  Map<String, dynamic> _statistics = {};

  // Stream subscriptions for auto-sync
  StreamSubscription<void>? _syncSubscription;

  // Getters
  List<MaintenanceEntity> get maintenances => _filteredMaintenances;
  List<MaintenanceEntity> get allMaintenances => _allMaintenances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MaintenanceFilters get filters => _filters;
  MaintenanceSorting get sorting => _sorting;
  Map<String, dynamic> get statistics => _statistics;

  // Computed getters
  bool get hasActiveFilters => _filters.hasActiveFilters;
  int get totalRecords => _allMaintenances.length;
  int get filteredRecords => _filteredMaintenances.length;
  
  List<MaintenanceEntity> get completedMaintenances => 
      _filterService.getRecordsByStatus(_filteredMaintenances, MaintenanceStatus.completed);
  
  List<MaintenanceEntity> get pendingMaintenances => 
      _filterService.getRecordsByStatus(_filteredMaintenances, MaintenanceStatus.pending);
  
  List<MaintenanceEntity> get overdueMaintenances => 
      _filterService.getOverdueRecords(_filteredMaintenances);
  
  List<MaintenanceEntity> get upcomingMaintenances => 
      _filterService.getUpcomingRecords(_filteredMaintenances);
  
  List<MaintenanceEntity> get highCostMaintenances => 
      _filterService.getHighCostRecords(_filteredMaintenances);
  
  double get totalCost => _filteredMaintenances.fold(0.0, (sum, record) => sum + record.cost);
  double get averageCost => _filteredMaintenances.isEmpty ? 0.0 : totalCost / _filteredMaintenances.length;

  // Core CRUD Operations

  /// Load all maintenance records
  Future<void> loadAllMaintenances() async {
    await _executeWithLoading(() async {
      final result = await _getAllMaintenanceRecords(const NoParams());
      
      result.fold(
        (failure) => throw Exception(failure.message),
        (records) {
          _allMaintenances = records;
          _applyFiltersAndSorting();
          _calculateStatistics();
        },
      );
    });
  }

  /// Load maintenance records for specific vehicle
  Future<void> loadMaintenancesByVehicle(String vehicleId) async {
    await _executeWithLoading(() async {
      final result = await _getMaintenanceRecordsByVehicle(
        GetMaintenanceRecordsByVehicleParams(vehicleId: vehicleId),
      );
      
      result.fold(
        (failure) => throw Exception(failure.message),
        (records) {
          _allMaintenances = records;
          // Auto-apply vehicle filter if not already set
          if (_filters.vehicleId != vehicleId) {
            _filters = _filters.copyWith(vehicleId: vehicleId);
          }
          _applyFiltersAndSorting();
          _calculateStatistics();
        },
      );
    });
  }

  /// Add new maintenance record
  Future<bool> addMaintenance(MaintenanceEntity maintenance) async {
    try {
      _clearError();

      final result = await _addMaintenanceRecord(
        AddMaintenanceRecordParams(maintenance: maintenance),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (addedRecord) {
          // Add to local list and refresh filtering
          _allMaintenances.add(addedRecord);
          _applyFiltersAndSorting();
          _calculateStatistics();
          
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao adicionar manutenção: $e');
      return false;
    }
  }

  /// Update existing maintenance record
  Future<bool> updateMaintenance(MaintenanceEntity maintenance) async {
    try {
      _clearError();

      final result = await _updateMaintenanceRecord(
        UpdateMaintenanceRecordParams(maintenance: maintenance),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (updatedRecord) {
          // Update in local list and refresh filtering
          final index = _allMaintenances.indexWhere((r) => r.id == updatedRecord.id);
          if (index != -1) {
            _allMaintenances[index] = updatedRecord;
            _applyFiltersAndSorting();
            _calculateStatistics();
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao atualizar manutenção: $e');
      return false;
    }
  }

  /// Delete maintenance record
  Future<bool> deleteMaintenance(String id) async {
    try {
      _clearError();

      final result = await _deleteMaintenanceRecord(
        DeleteMaintenanceRecordParams(id: id),
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          return false;
        },
        (_) {
          // Remove from local list and refresh filtering
          _allMaintenances.removeWhere((record) => record.id == id);
          _applyFiltersAndSorting();
          _calculateStatistics();
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro ao deletar manutenção: $e');
      return false;
    }
  }

  /// Get maintenance by ID
  MaintenanceEntity? getMaintenanceById(String id) {
    try {
      return _allMaintenances.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtering and Sorting Operations

  /// Apply vehicle filter
  void filterByVehicle(String? vehicleId) {
    _filters = _filters.copyWith(vehicleId: vehicleId, clearVehicleId: vehicleId == null);
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Apply type filter
  void filterByType(MaintenanceType? type) {
    _filters = _filters.copyWith(type: type, clearType: type == null);
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Apply status filter
  void filterByStatus(MaintenanceStatus? status) {
    _filters = _filters.copyWith(status: status, clearStatus: status == null);
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Apply date range filter
  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    _filters = _filters.copyWith(
      startDate: startDate,
      endDate: endDate,
      clearDateRange: startDate == null && endDate == null,
    );
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Apply cost range filter
  void filterByCostRange(double? minCost, double? maxCost) {
    _filters = _filters.copyWith(
      minCost: minCost,
      maxCost: maxCost,
      clearCostRange: minCost == null && maxCost == null,
    );
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Apply search filter
  void search(String query) {
    _filters = _filters.copyWith(searchQuery: query);
    _applyFiltersAndSorting();
    notifyListeners();
  }

  /// Apply multiple filters at once
  void applyFilters(MaintenanceFilters filters) {
    _filters = filters;
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filters = MaintenanceFilters.empty;
    _applyFiltersAndSorting();
    _calculateStatistics();
    notifyListeners();
  }

  /// Set sorting
  void setSorting(MaintenanceSortField field, {bool? ascending}) {
    _sorting = _sorting.toggleOrSet(field);
    if (ascending != null) {
      _sorting = _sorting.copyWith(ascending: ascending);
    }
    _applyFiltersAndSorting();
    notifyListeners();
  }

  /// Apply custom sorting
  void applySorting(MaintenanceSorting sorting) {
    _sorting = sorting;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  // Specialized Queries

  /// Get maintenances by type
  List<MaintenanceEntity> getMaintenancesByType(MaintenanceType type) {
    return _filterService.getRecordsByType(_filteredMaintenances, type);
  }

  /// Get maintenances by status
  List<MaintenanceEntity> getMaintenancesByStatus(MaintenanceStatus status) {
    return _filterService.getRecordsByStatus(_filteredMaintenances, status);
  }

  /// Get maintenances by urgency level
  List<MaintenanceEntity> getMaintenancesByUrgency(String urgencyLevel) {
    return _filterService.getRecordsByUrgency(_filteredMaintenances, urgencyLevel);
  }

  /// Get recent maintenances (last N days)
  List<MaintenanceEntity> getRecentMaintenances({int days = 30}) {
    return _filterService.getRecentRecords(_filteredMaintenances, days: days);
  }

  /// Search maintenances
  List<MaintenanceEntity> searchMaintenances(String query) {
    return _filterService.searchRecords(_filteredMaintenances, query);
  }

  // Analytics and Statistics

  /// Get statistics for current filtered records
  Map<String, dynamic> getCurrentStatistics() {
    return _filterService.calculateStatistics(_filteredMaintenances);
  }

  /// Get statistics for specific period
  Map<String, dynamic> getStatisticsForPeriod(DateTime start, DateTime end) {
    final periodRecords = _filterService.getRecordsByDateRange(_allMaintenances, start, end);
    return _filterService.calculateStatistics(periodRecords);
  }

  /// Get maintenance counts by type
  Map<MaintenanceType, int> getMaintenanceCountsByType() {
    final counts = <MaintenanceType, int>{};
    for (final record in _filteredMaintenances) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }
    return counts;
  }

  // Utility Methods

  /// Refresh all data
  Future<void> refresh() async {
    await loadAllMaintenances();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data and reset state
  void clear() {
    _allMaintenances.clear();
    _filteredMaintenances.clear();
    _filters = MaintenanceFilters.empty;
    _sorting = const MaintenanceSorting();
    _statistics.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Private Methods

  void _applyFiltersAndSorting() {
    _filteredMaintenances = _filterService.applyFiltersAndSorting(
      _allMaintenances,
      _filters,
      _sorting,
    );
  }

  void _calculateStatistics() {
    _statistics = _filterService.calculateStatistics(_filteredMaintenances);
  }

  Future<void> _executeWithLoading(Future<void> Function() operation) async {
    try {
      _setLoading(true);
      _clearError();
      await operation();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  // Observer Pattern for Auto-Sync

  /// Enable automatic synchronization with repository changes
  void enableAutoSync() {
    // This would connect to a stream from the repository
    // For now, we'll implement periodic refresh
    _syncSubscription = Stream<void>.periodic(const Duration(minutes: 5))
        .listen((_) => _refreshInBackground());
  }

  /// Disable automatic synchronization
  void disableAutoSync() {
    _syncSubscription?.cancel();
    _syncSubscription = null;
  }

  Future<void> _refreshInBackground() async {
    try {
      // Refresh without showing loading state to avoid UI disruption
      final result = await _getAllMaintenanceRecords(const NoParams());
      
      result.fold(
        (failure) {
          // Silently handle background sync failures
          debugPrint('Background sync failed: ${failure.message}');
        },
        (records) {
          // Only update if data has actually changed
          if (_hasDataChanged(records)) {
            _allMaintenances = records;
            _applyFiltersAndSorting();
            _calculateStatistics();
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('Background sync error: $e');
    }
  }

  bool _hasDataChanged(List<MaintenanceEntity> newRecords) {
    if (_allMaintenances.length != newRecords.length) {
      return true;
    }
    
    // Simple check - compare IDs and update timestamps
    final currentIds = _allMaintenances.map((r) => '${r.id}:${r.updatedAt?.millisecondsSinceEpoch ?? 0}').toSet();
    final newIds = newRecords.map((r) => '${r.id}:${r.updatedAt?.millisecondsSinceEpoch ?? 0}').toSet();
    
    return !currentIds.containsAll(newIds) || !newIds.containsAll(currentIds);
  }

  // Formatted getters for UI
  String get formattedTotalCost => 'R\$ ${totalCost.toStringAsFixed(2).replaceAll('.', ',')}';
  String get formattedAverageCost => 'R\$ ${averageCost.toStringAsFixed(2).replaceAll('.', ',')}';

  String get filterSummary {
    final activeFilters = <String>[];
    
    if (_filters.vehicleId != null) activeFilters.add('Veículo');
    if (_filters.type != null) activeFilters.add('Tipo');
    if (_filters.status != null) activeFilters.add('Status');
    if (_filters.startDate != null || _filters.endDate != null) activeFilters.add('Período');
    if (_filters.minCost != null || _filters.maxCost != null) activeFilters.add('Valor');
    if (_filters.searchQuery.isNotEmpty) activeFilters.add('Busca');
    
    if (activeFilters.isEmpty) {
      return 'Todos os registros';
    }
    
    return 'Filtros: ${activeFilters.join(', ')}';
  }
}