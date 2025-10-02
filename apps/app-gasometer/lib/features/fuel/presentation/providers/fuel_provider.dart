import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/providers/base_provider.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/delete_fuel_record.dart';
import '../../domain/usecases/get_all_fuel_records.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import '../../domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../domain/usecases/update_fuel_record.dart';
import '../services/fuel_filters_service.dart';
import '../services/fuel_statistics_service.dart';

/// Provider for managing fuel records operations
///
/// This provider handles CRUD operations for fuel records and integrates
/// with analytics and connectivity management.
@injectable
class FuelProvider extends BaseProvider {
  FuelProvider({
    required GetAllFuelRecords getAllFuelRecords,
    required GetFuelRecordsByVehicle getFuelRecordsByVehicle,
    required AddFuelRecord addFuelRecord,
    required UpdateFuelRecord updateFuelRecord,
    required DeleteFuelRecord deleteFuelRecord,
    required GetAverageConsumption getAverageConsumption,
    required GetTotalSpent getTotalSpent,
    required GetRecentFuelRecords getRecentFuelRecords,
    required core.ConnectivityService connectivityService,
  })  : _getAllFuelRecords = getAllFuelRecords,
        _getFuelRecordsByVehicle = getFuelRecordsByVehicle,
        _addFuelRecord = addFuelRecord,
        _updateFuelRecord = updateFuelRecord,
        _deleteFuelRecord = deleteFuelRecord,
        _getAverageConsumption = getAverageConsumption,
        _getTotalSpent = getTotalSpent,
        _getRecentFuelRecords = getRecentFuelRecords,
        _connectivityService = connectivityService,
        _statisticsService = FuelStatisticsService(),
        _filtersService = FuelFiltersService() {
    _initializeConnectivity();
  }

  // Use Cases
  final GetAllFuelRecords _getAllFuelRecords;
  final GetFuelRecordsByVehicle _getFuelRecordsByVehicle;
  final AddFuelRecord _addFuelRecord;
  final UpdateFuelRecord _updateFuelRecord;
  final DeleteFuelRecord _deleteFuelRecord;
  final GetAverageConsumption _getAverageConsumption;
  final GetTotalSpent _getTotalSpent;
  final GetRecentFuelRecords _getRecentFuelRecords;

  // Services
  final core.ConnectivityService _connectivityService;
  final FuelStatisticsService _statisticsService;
  final FuelFiltersService _filtersService;

  // Connectivity
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;
  final List<FuelRecordEntity> _offlinePendingRecords = [];

  // Internal state
  List<FuelRecordEntity> _fuelRecords = [];
  List<FuelRecordEntity> _filteredFuelRecords = [];
  String _currentVehicleFilter = '';
  String _searchQuery = '';

  // Analytics data
  double _averageConsumption = 0.0;
  double _totalSpent = 0.0;
  List<FuelRecordEntity> _recentRecords = [];

  // Cached statistics
  FuelStatistics? _cachedStatistics;
  bool _statisticsNeedRecalculation = true;

  // ===========================================
  // GETTERS
  // ===========================================

  List<FuelRecordEntity> get fuelRecords {
    return _searchQuery.isNotEmpty ? _filteredFuelRecords : _fuelRecords;
  }

  String get currentVehicleFilter => _currentVehicleFilter;
  String get searchQuery => _searchQuery;
  double get averageConsumption => _averageConsumption;
  double get totalSpent => _totalSpent;
  List<FuelRecordEntity> get recentRecords => _recentRecords;

  FuelStatistics get statistics {
    final records = fuelRecords;
    if (_cachedStatistics == null ||
        _statisticsNeedRecalculation ||
        _cachedStatistics!.needsRecalculation ||
        _cachedStatistics!.totalRecords != records.length) {
      _cachedStatistics = _statisticsService.calculateStatistics(records);
      _statisticsNeedRecalculation = false;
    }
    return _cachedStatistics!;
  }

  bool get hasRecords => fuelRecords.isNotEmpty;
  int get recordsCount => fuelRecords.length;
  bool get hasActiveVehicleFilter => _currentVehicleFilter.isNotEmpty;
  bool get hasActiveSearch => _searchQuery.isNotEmpty;
  bool get hasActiveFilters => hasActiveVehicleFilter || hasActiveSearch;

  String get activeFiltersDescription {
    if (hasActiveSearch && hasActiveVehicleFilter) {
      return 'Busca: "$_searchQuery" no veículo selecionado';
    } else if (hasActiveSearch) {
      return 'Busca: "$_searchQuery"';
    } else if (hasActiveVehicleFilter) {
      return 'Veículo selecionado';
    }
    return '';
  }

  // Connectivity getters
  bool get isOnline => _isOnline;
  bool get hasOfflinePendingRecords => _offlinePendingRecords.isNotEmpty;
  int get offlinePendingRecordsCount => _offlinePendingRecords.length;
  List<FuelRecordEntity> get offlinePendingRecords =>
      List.unmodifiable(_offlinePendingRecords);

  // ===========================================
  // LOADING OPERATIONS
  // ===========================================

  /// Loads all fuel records
  Future<void> loadAllFuelRecords() async {
    await executeListOperation(
      () async {
        final result = await _getAllFuelRecords();
        return result.fold(
          (failure) => throw failure,
          (records) => records,
        );
      },
      operationName: 'loadAllFuelRecords',
      onSuccess: (records) {
        _fuelRecords = records;
        _applyCurrentFilters();
        _invalidateStatistics();
        logInfo('Loaded ${records.length} fuel records');
      },
    );
  }

  /// Loads fuel records for a specific vehicle
  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    _currentVehicleFilter = vehicleId;

    await executeListOperation(
      () async {
        final result = await _getFuelRecordsByVehicle(
          GetFuelRecordsByVehicleParams(vehicleId: vehicleId),
        );
        return result.fold(
          (failure) => throw failure,
          (records) => records,
        );
      },
      operationName: 'loadFuelRecordsByVehicle',
      onSuccess: (records) {
        _fuelRecords = records;
        _applyCurrentFilters();
        _invalidateStatistics();
        logInfo('Loaded ${records.length} records for vehicle $vehicleId');
      },
    );
  }

  // ===========================================
  // CRUD OPERATIONS
  // ===========================================

  /// Adds a new fuel record
  Future<bool> addFuelRecord(FuelRecordEntity fuelRecord) async {
    // Check connectivity first
    if (!_isOnline) {
      // Save offline - add to pending list and local records
      _offlinePendingRecords.add(fuelRecord);
      _fuelRecords.insert(0, fuelRecord);
      _applyCurrentFilters();
      _invalidateStatistics();
      notifyListeners();
      logInfo('Record saved offline: ${fuelRecord.id}');
      return true;
    }

    // Online - try to sync immediately
    return await executeDataOperation(
      () async {
        final result = await _addFuelRecord(
          AddFuelRecordParams(fuelRecord: fuelRecord),
        );
        return result.fold(
          (failure) {
            // Failed online - save offline as fallback
            _offlinePendingRecords.add(fuelRecord);
            _fuelRecords.insert(0, fuelRecord);
            _applyCurrentFilters();
            _invalidateStatistics();
            logInfo('Online error, saved offline: ${failure.message}');
            // Return a success value since we saved offline
            return fuelRecord;
          },
          (addedRecord) => addedRecord,
        );
      },
      operationName: 'addFuelRecord',
      onSuccess: (addedRecord) {
        // Only add if not already added offline
        if (!_offlinePendingRecords.contains(fuelRecord)) {
          _fuelRecords.insert(0, addedRecord);
        }
        _applyCurrentFilters();
        _invalidateStatistics();
        logInfo('Fuel record synced: ${addedRecord.id}');
      },
    ).then((result) => result != null);
  }

  /// Updates an existing fuel record
  Future<bool> updateFuelRecord(FuelRecordEntity fuelRecord) async {
    return await executeDataOperation(
      () async {
        final result = await _updateFuelRecord(
          UpdateFuelRecordParams(fuelRecord: fuelRecord),
        );
        return result.fold(
          (failure) => throw failure,
          (updatedRecord) => updatedRecord,
        );
      },
      operationName: 'updateFuelRecord',
      onSuccess: (updatedRecord) {
        final index = _fuelRecords.indexWhere((r) => r.id == updatedRecord.id);
        if (index != -1) {
          _fuelRecords[index] = updatedRecord;
          _applyCurrentFilters();
          _invalidateStatistics();
        }
        logInfo('Fuel record updated: ${updatedRecord.id}');
      },
    ).then((result) => result != null);
  }

  /// Deletes a fuel record
  Future<bool> deleteFuelRecord(String id) async {
    if (id.isEmpty) return false;

    return await executeDataOperation(
      () async {
        final result = await _deleteFuelRecord(
          DeleteFuelRecordParams(id: id),
        );
        return result.fold(
          (failure) => throw failure,
          (_) => true, // Unit to boolean
        );
      },
      operationName: 'deleteFuelRecord',
      onSuccess: (success) {
        _fuelRecords.removeWhere((record) => record.id == id);
        _applyCurrentFilters();
        _invalidateStatistics();
        logInfo('Fuel record deleted: $id');
      },
    ).then((result) => result == true);
  }

  // ===========================================
  // SEARCH AND FILTER OPERATIONS
  // ===========================================

  /// Searches fuel records by query
  void searchFuelRecords(String query) {
    _searchQuery = query.trim();
    _applyCurrentFilters();

    if (_searchQuery.isNotEmpty && _searchQuery.length >= 2) {
      logInfo('Search found ${_filteredFuelRecords.length} records for "$_searchQuery"');
    }
  }

  /// Clears search query
  void clearSearch() {
    _searchQuery = '';
    _filteredFuelRecords.clear();
    notifyListeners();
  }

  /// Filters records by vehicle
  void filterByVehicle(String vehicleId) {
    if (_currentVehicleFilter != vehicleId) {
      loadFuelRecordsByVehicle(vehicleId);
    }
  }

  /// Clears all filters
  void clearAllFilters() {
    _currentVehicleFilter = '';
    clearSearch();
    loadAllFuelRecords();
  }

  /// Applies current filters using service
  void _applyCurrentFilters() {
    if (_searchQuery.isEmpty) {
      _filteredFuelRecords.clear();
    } else {
      _filteredFuelRecords = _filtersService.applySearchFilter(
        _fuelRecords,
        _searchQuery,
      );
    }
    notifyListeners();
  }

  // ===========================================
  // ANALYTICS OPERATIONS
  // ===========================================

  /// Loads analytics for a vehicle
  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    final consumptionResult = await _getAverageConsumption(
      GetAverageConsumptionParams(vehicleId: vehicleId),
    );

    consumptionResult.fold(
      (failure) => debugPrint('Error loading average consumption: ${failure.message}'),
      (consumption) => _averageConsumption = consumption,
    );

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final totalSpentResult = await _getTotalSpent(
      GetTotalSpentParams(
        vehicleId: vehicleId,
        startDate: thirtyDaysAgo,
      ),
    );

    totalSpentResult.fold(
      (failure) => debugPrint('Error loading total spent: ${failure.message}'),
      (total) => _totalSpent = total,
    );

    final recentResult = await _getRecentFuelRecords(
      GetRecentFuelRecordsParams(vehicleId: vehicleId, limit: 5),
    );

    recentResult.fold(
      (failure) => debugPrint('Error loading recent records: ${failure.message}'),
      (records) => _recentRecords = records,
    );

    notifyListeners();
    logInfo('Analytics loaded for vehicle $vehicleId');
  }

  // ===========================================
  // HELPER METHODS
  // ===========================================

  /// Gets a fuel record by ID
  FuelRecordEntity? getFuelRecordById(String id) {
    try {
      return _fuelRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets total spent in date range using service
  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    return _statisticsService.getTotalSpentInDateRange(
      fuelRecords,
      startDate,
      endDate,
    );
  }

  /// Gets total liters in date range using service
  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    return _statisticsService.getTotalLitersInDateRange(
      fuelRecords,
      startDate,
      endDate,
    );
  }

  /// Clears all data
  void clearAllData() {
    _fuelRecords.clear();
    _filteredFuelRecords.clear();
    _currentVehicleFilter = '';
    _searchQuery = '';
    _averageConsumption = 0.0;
    _totalSpent = 0.0;
    _recentRecords.clear();
    _invalidateStatistics();
    setState(ProviderState.loaded);
    notifyListeners();
  }

  /// Invalidates cached statistics
  void _invalidateStatistics() {
    _statisticsNeedRecalculation = true;
  }

  // ===========================================
  // CONNECTIVITY METHODS
  // ===========================================

  /// Initializes connectivity monitoring
  void _initializeConnectivity() {
    _connectivityService.isOnline().then((result) {
      result.fold(
        (failure) => debugPrint('Error checking initial connectivity: ${failure.message}'),
        (isOnline) {
          _isOnline = isOnline;
          if (isOnline) _syncOfflinePendingRecords();
        },
      );
    });

    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
      onError: (Object error) => debugPrint('Error in connectivity stream: $error'),
    );
  }

  /// Handles connectivity changes
  void _onConnectivityChanged(bool isOnline) {
    final wasOnline = _isOnline;
    _isOnline = isOnline;

    debugPrint('Connectivity changed: ${wasOnline ? 'online' : 'offline'} → ${isOnline ? 'online' : 'offline'}');

    if (!wasOnline && isOnline) {
      // Came back online - sync offline data
      _syncOfflinePendingRecords();
    }

    notifyListeners();
  }

  /// Syncs offline pending records
  Future<void> _syncOfflinePendingRecords() async {
    if (_offlinePendingRecords.isEmpty) return;

    debugPrint('Syncing ${_offlinePendingRecords.length} offline records...');

    final recordsToSync = List<FuelRecordEntity>.from(_offlinePendingRecords);
    _offlinePendingRecords.clear();

    for (final record in recordsToSync) {
      try {
        final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record));
        result.fold(
          (failure) {
            // Failed - add back to offline list
            _offlinePendingRecords.add(record);
            debugPrint('Failed to sync record: ${failure.message}');
          },
          (syncedRecord) {
            debugPrint('Record synced successfully: ${syncedRecord.id}');
          },
        );
      } catch (e) {
        _offlinePendingRecords.add(record);
        debugPrint('Error syncing record: $e');
      }
    }

    if (_offlinePendingRecords.isEmpty) {
      debugPrint('All records synced!');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
