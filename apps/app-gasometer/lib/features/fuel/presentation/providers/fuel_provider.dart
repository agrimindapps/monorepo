import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/usecases/get_all_fuel_records.dart';
import '../../domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/update_fuel_record.dart';
import '../../domain/usecases/delete_fuel_record.dart';
import '../../domain/usecases/search_fuel_records.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import '../../../../core/error/failures.dart';

@injectable
class FuelProvider extends ChangeNotifier {
  final GetAllFuelRecords _getAllFuelRecords;
  final GetFuelRecordsByVehicle _getFuelRecordsByVehicle;
  final AddFuelRecord _addFuelRecord;
  final UpdateFuelRecord _updateFuelRecord;
  final DeleteFuelRecord _deleteFuelRecord;
  final SearchFuelRecords _searchFuelRecords;
  final GetAverageConsumption _getAverageConsumption;
  final GetTotalSpent _getTotalSpent;
  final GetRecentFuelRecords _getRecentFuelRecords;

  List<FuelRecordEntity> _fuelRecords = [];
  List<FuelRecordEntity> _filteredFuelRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentVehicleFilter = '';
  String _searchQuery = '';

  // Analytics data
  double _averageConsumption = 0.0;
  double _totalSpent = 0.0;
  List<FuelRecordEntity> _recentRecords = [];

  FuelProvider({
    required GetAllFuelRecords getAllFuelRecords,
    required GetFuelRecordsByVehicle getFuelRecordsByVehicle,
    required AddFuelRecord addFuelRecord,
    required UpdateFuelRecord updateFuelRecord,
    required DeleteFuelRecord deleteFuelRecord,
    required SearchFuelRecords searchFuelRecords,
    required GetAverageConsumption getAverageConsumption,
    required GetTotalSpent getTotalSpent,
    required GetRecentFuelRecords getRecentFuelRecords,
  })  : _getAllFuelRecords = getAllFuelRecords,
        _getFuelRecordsByVehicle = getFuelRecordsByVehicle,
        _addFuelRecord = addFuelRecord,
        _updateFuelRecord = updateFuelRecord,
        _deleteFuelRecord = deleteFuelRecord,
        _searchFuelRecords = searchFuelRecords,
        _getAverageConsumption = getAverageConsumption,
        _getTotalSpent = getTotalSpent,
        _getRecentFuelRecords = getRecentFuelRecords;

  // Getters
  List<FuelRecordEntity> get fuelRecords => _filteredFuelRecords.isEmpty ? _fuelRecords : _filteredFuelRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentVehicleFilter => _currentVehicleFilter;
  String get searchQuery => _searchQuery;
  double get averageConsumption => _averageConsumption;
  double get totalSpent => _totalSpent;
  List<FuelRecordEntity> get recentRecords => _recentRecords;

  bool get hasError => _errorMessage != null;
  bool get hasRecords => fuelRecords.isNotEmpty;
  int get recordsCount => fuelRecords.length;

  // Load all fuel records
  Future<void> loadAllFuelRecords() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllFuelRecords();

    result.fold(
      (failure) => _handleError(failure),
      (records) {
        _fuelRecords = records;
        _applyCurrentFilters();
        debugPrint('🚗 Carregados ${records.length} registros de combustível');
      },
    );

    _setLoading(false);
  }

  // Load fuel records by vehicle
  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    _setLoading(true);
    _clearError();
    _currentVehicleFilter = vehicleId;

    final result = await _getFuelRecordsByVehicle(
      GetFuelRecordsByVehicleParams(vehicleId: vehicleId),
    );

    result.fold(
      (failure) => _handleError(failure),
      (records) {
        _fuelRecords = records;
        _applyCurrentFilters();
        debugPrint('🚗 Carregados ${records.length} registros para veículo $vehicleId');
      },
    );

    _setLoading(false);
  }

  // Add new fuel record
  Future<bool> addFuelRecord(FuelRecordEntity fuelRecord) async {
    _setLoading(true);
    _clearError();

    final result = await _addFuelRecord(
      AddFuelRecordParams(fuelRecord: fuelRecord),
    );

    return result.fold(
      (failure) {
        _handleError(failure);
        _setLoading(false);
        return false;
      },
      (addedRecord) {
        _fuelRecords.insert(0, addedRecord); // Add to beginning (most recent)
        _applyCurrentFilters();
        _setLoading(false);
        debugPrint('🚗 Registro de combustível adicionado: ${addedRecord.id}');
        return true;
      },
    );
  }

  // Update fuel record
  Future<bool> updateFuelRecord(FuelRecordEntity fuelRecord) async {
    _setLoading(true);
    _clearError();

    final result = await _updateFuelRecord(
      UpdateFuelRecordParams(fuelRecord: fuelRecord),
    );

    return result.fold(
      (failure) {
        _handleError(failure);
        _setLoading(false);
        return false;
      },
      (updatedRecord) {
        final index = _fuelRecords.indexWhere((r) => r.id == updatedRecord.id);
        if (index != -1) {
          _fuelRecords[index] = updatedRecord;
          _applyCurrentFilters();
        }
        _setLoading(false);
        debugPrint('🚗 Registro de combustível atualizado: ${updatedRecord.id}');
        return true;
      },
    );
  }

  // Delete fuel record
  Future<bool> deleteFuelRecord(String id) async {
    if (id.isEmpty) return false;

    _setLoading(true);
    _clearError();

    final result = await _deleteFuelRecord(
      DeleteFuelRecordParams(id: id),
    );

    return result.fold(
      (failure) {
        _handleError(failure);
        _setLoading(false);
        return false;
      },
      (_) {
        _fuelRecords.removeWhere((record) => record.id == id);
        _applyCurrentFilters();
        _setLoading(false);
        debugPrint('🚗 Registro de combustível removido: $id');
        return true;
      },
    );
  }

  // Search fuel records
  Future<void> searchFuelRecords(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredFuelRecords.clear();
      notifyListeners();
      return;
    }

    if (_searchQuery.length < 2) {
      _filteredFuelRecords.clear();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    final result = await _searchFuelRecords(
      SearchFuelRecordsParams(query: _searchQuery),
    );

    result.fold(
      (failure) => _handleError(failure),
      (records) {
        _filteredFuelRecords = records;
        debugPrint('🔍 Encontrados ${records.length} registros para "$_searchQuery"');
      },
    );

    _setLoading(false);
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredFuelRecords.clear();
    notifyListeners();
  }

  // Load analytics for vehicle
  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    _setLoading(true);
    _clearError();

    // Load average consumption
    final consumptionResult = await _getAverageConsumption(
      GetAverageConsumptionParams(vehicleId: vehicleId),
    );

    consumptionResult.fold(
      (failure) => debugPrint('Erro ao carregar consumo médio: ${failure.message}'),
      (consumption) => _averageConsumption = consumption,
    );

    // Load total spent (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final totalSpentResult = await _getTotalSpent(
      GetTotalSpentParams(
        vehicleId: vehicleId,
        startDate: thirtyDaysAgo,
      ),
    );

    totalSpentResult.fold(
      (failure) => debugPrint('Erro ao carregar total gasto: ${failure.message}'),
      (total) => _totalSpent = total,
    );

    // Load recent records
    final recentResult = await _getRecentFuelRecords(
      GetRecentFuelRecordsParams(vehicleId: vehicleId, limit: 5),
    );

    recentResult.fold(
      (failure) => debugPrint('Erro ao carregar registros recentes: ${failure.message}'),
      (records) => _recentRecords = records,
    );

    _setLoading(false);
    debugPrint('🚗 Analytics carregados para veículo $vehicleId');
  }

  // Get fuel record by ID
  FuelRecordEntity? getFuelRecordById(String id) {
    try {
      return _fuelRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all data
  void clearAllData() {
    _fuelRecords.clear();
    _filteredFuelRecords.clear();
    _currentVehicleFilter = '';
    _searchQuery = '';
    _averageConsumption = 0.0;
    _totalSpent = 0.0;
    _recentRecords.clear();
    _clearError();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Filter by vehicle
  void filterByVehicle(String vehicleId) {
    if (_currentVehicleFilter != vehicleId) {
      loadFuelRecordsByVehicle(vehicleId);
    }
  }

  // Clear vehicle filter
  void clearVehicleFilter() {
    _currentVehicleFilter = '';
    loadAllFuelRecords();
  }

  // Get records for specific date range
  List<FuelRecordEntity> getRecordsInDateRange(DateTime startDate, DateTime endDate) {
    return fuelRecords.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
  }

  // Get total spent in date range
  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = getRecordsInDateRange(startDate, endDate);
    return recordsInRange.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
  }

  // Get total liters in date range
  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = getRecordsInDateRange(startDate, endDate);
    return recordsInRange.map((r) => r.liters).fold(0.0, (a, b) => a + b);
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _handleError(Failure failure) {
    _errorMessage = _mapFailureToMessage(failure);
    debugPrint('🚗 Erro no FuelProvider: $_errorMessage');
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is InvalidFuelDataFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is CacheFailure) {
      return 'Erro no armazenamento local. Tente reiniciar o app.';
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  void _applyCurrentFilters() {
    // If there's a search query, keep the search results
    if (_searchQuery.isNotEmpty && _filteredFuelRecords.isNotEmpty) {
      return;
    }

    // Otherwise clear filtered results to show all records
    _filteredFuelRecords.clear();
    notifyListeners();
  }
}