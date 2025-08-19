import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';
import '../../domain/usecases/get_all_maintenance_records.dart';
import '../../domain/usecases/get_maintenance_records_by_vehicle.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/update_maintenance_record.dart';
import '../../domain/usecases/delete_maintenance_record.dart';
import '../../domain/usecases/get_upcoming_maintenance_records.dart';
import '../../domain/usecases/get_maintenance_analytics.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class MaintenanceProvider extends ChangeNotifier {
  final GetAllMaintenanceRecords _getAllMaintenanceRecords;
  final GetMaintenanceRecordsByVehicle _getMaintenanceRecordsByVehicle;
  final AddMaintenanceRecord _addMaintenanceRecord;
  final UpdateMaintenanceRecord _updateMaintenanceRecord;
  final DeleteMaintenanceRecord _deleteMaintenanceRecord;
  final GetUpcomingMaintenanceRecords _getUpcomingMaintenanceRecords;
  final GetMaintenanceAnalytics _getMaintenanceAnalytics;

  MaintenanceProvider(
    this._getAllMaintenanceRecords,
    this._getMaintenanceRecordsByVehicle,
    this._addMaintenanceRecord,
    this._updateMaintenanceRecord,
    this._deleteMaintenanceRecord,
    this._getUpcomingMaintenanceRecords,
    this._getMaintenanceAnalytics,
  );

  // State variables
  List<MaintenanceEntity> _maintenanceRecords = [];
  List<MaintenanceEntity> _upcomingRecords = [];
  MaintenanceAnalytics? _analytics;
  
  bool _isLoading = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingAnalytics = false;
  String? _errorMessage;
  String? _selectedVehicleId;

  // Getters
  List<MaintenanceEntity> get maintenanceRecords => _maintenanceRecords;
  List<MaintenanceEntity> get upcomingRecords => _upcomingRecords;
  MaintenanceAnalytics? get analytics => _analytics;
  
  bool get isLoading => _isLoading;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get errorMessage => _errorMessage;
  String? get selectedVehicleId => _selectedVehicleId;

  // Filtered records
  List<MaintenanceEntity> get filteredRecords {
    if (_selectedVehicleId == null) return _maintenanceRecords;
    return _maintenanceRecords.where((record) => record.vehicleId == _selectedVehicleId).toList();
  }

  // Statistics getters
  double get totalMaintenanceCost {
    return filteredRecords.fold(0.0, (sum, record) => sum + record.cost);
  }

  Map<MaintenanceType, int> get maintenanceCountByType {
    final counts = <MaintenanceType, int>{};
    for (final record in filteredRecords) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }
    return counts;
  }

  List<MaintenanceEntity> get recentMaintenanceRecords {
    final sorted = List<MaintenanceEntity>.from(filteredRecords);
    sorted.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    return sorted.take(5).toList();
  }

  List<MaintenanceEntity> get overdueMaintenance {
    final now = DateTime.now();
    return filteredRecords.where((record) {
      if (record.nextServiceDate == null) return false;
      return record.nextServiceDate!.isBefore(now);
    }).toList();
  }

  List<MaintenanceEntity> get pendingMaintenance {
    return filteredRecords.where((record) => record.status == MaintenanceStatus.pending).toList();
  }

  List<MaintenanceEntity> get completedMaintenance {
    return filteredRecords.where((record) => record.status == MaintenanceStatus.completed).toList();
  }

  // Methods
  void selectVehicle(String? vehicleId) {
    if (_selectedVehicleId != vehicleId) {
      _selectedVehicleId = vehicleId;
      notifyListeners();
      if (vehicleId != null) {
        loadMaintenanceRecordsByVehicle(vehicleId);
        loadUpcomingMaintenanceRecords(vehicleId);
        loadMaintenanceAnalytics(vehicleId);
      }
    }
  }

  Future<void> loadAllMaintenanceRecords() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllMaintenanceRecords(NoParams());
    
    result.fold(
      (failure) => _setError(failure.message),
      (records) {
        _maintenanceRecords = records;
        _setLoading(false);
      },
    );
  }

  Future<void> loadMaintenanceRecordsByVehicle(String vehicleId) async {
    _setLoading(true);
    _clearError();

    final result = await _getMaintenanceRecordsByVehicle(
      GetMaintenanceRecordsByVehicleParams(vehicleId: vehicleId),
    );
    
    result.fold(
      (failure) => _setError(failure.message),
      (records) {
        _maintenanceRecords = records;
        _setLoading(false);
      },
    );
  }

  Future<void> loadUpcomingMaintenanceRecords(String vehicleId, {int days = 30}) async {
    _setLoadingUpcoming(true);

    final result = await _getUpcomingMaintenanceRecords(
      GetUpcomingMaintenanceRecordsParams(vehicleId: vehicleId, days: days),
    );
    
    result.fold(
      (failure) => _setError(failure.message),
      (records) {
        _upcomingRecords = records;
        _setLoadingUpcoming(false);
      },
    );
  }

  Future<void> loadMaintenanceAnalytics(String vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    _setLoadingAnalytics(true);

    final result = await _getMaintenanceAnalytics(
      GetMaintenanceAnalyticsParams(
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    
    result.fold(
      (failure) => _setError(failure.message),
      (analytics) {
        _analytics = analytics;
        _setLoadingAnalytics(false);
      },
    );
  }

  Future<bool> addMaintenanceRecord(MaintenanceEntity maintenance) async {
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
        _maintenanceRecords.add(addedRecord);
        _sortRecords();
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
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
        final index = _maintenanceRecords.indexWhere((r) => r.id == updatedRecord.id);
        if (index != -1) {
          _maintenanceRecords[index] = updatedRecord;
          notifyListeners();
        }
        return true;
      },
    );
  }

  Future<bool> deleteMaintenanceRecord(String id) async {
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
        _maintenanceRecords.removeWhere((record) => record.id == id);
        notifyListeners();
        return true;
      },
    );
  }

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

  List<MaintenanceEntity> getMaintenanceRecordsByType(MaintenanceType type) {
    return filteredRecords.where((record) => record.type == type).toList();
  }

  List<MaintenanceEntity> getMaintenanceRecordsByStatus(MaintenanceStatus status) {
    return filteredRecords.where((record) => record.status == status).toList();
  }

  List<MaintenanceEntity> getMaintenanceRecordsByDateRange(DateTime startDate, DateTime endDate) {
    return filteredRecords.where((record) {
      return record.serviceDate.isAfter(startDate) && record.serviceDate.isBefore(endDate);
    }).toList();
  }

  // Formatted getters for UI
  String get formattedTotalCost => 'R\$ ${totalMaintenanceCost.toStringAsFixed(2)}';

  String get maintenanceCountSummary {
    final preventive = maintenanceCountByType[MaintenanceType.preventive] ?? 0;
    final corrective = maintenanceCountByType[MaintenanceType.corrective] ?? 0;
    final inspection = maintenanceCountByType[MaintenanceType.inspection] ?? 0;
    final emergency = maintenanceCountByType[MaintenanceType.emergency] ?? 0;
    
    return '$preventive preventivas, $corrective corretivas, $inspection revisões, $emergency emergenciais';
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  void _setLoadingUpcoming(bool loading) {
    _isLoadingUpcoming = loading;
    notifyListeners();
  }

  void _setLoadingAnalytics(bool loading) {
    _isLoadingAnalytics = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _isLoadingUpcoming = false;
    _isLoadingAnalytics = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _sortRecords() {
    _maintenanceRecords.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  }

  // Clear all data
  void clear() {
    _maintenanceRecords.clear();
    _upcomingRecords.clear();
    _analytics = null;
    _selectedVehicleId = null;
    _isLoading = false;
    _isLoadingUpcoming = false;
    _isLoadingAnalytics = false;
    _errorMessage = null;
    notifyListeners();
  }
}