import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/delete_fuel_record.dart';
import '../../domain/usecases/get_all_fuel_records.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import '../../domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../domain/usecases/search_fuel_records.dart';
import '../../domain/usecases/update_fuel_record.dart';

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

  List<FuelRecordEntity> get fuelRecords {
    // Se há busca ativa, retornar os filtrados; senão, retornar todos
    return _searchQuery.isNotEmpty ? _filteredFuelRecords : _fuelRecords;
  }
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

  void searchFuelRecords(String query) {
    _searchQuery = query.trim();
    _applyCurrentFilters();
    
    if (_searchQuery.isNotEmpty && _searchQuery.length >= 2) {
      debugPrint('🔍 Encontrados ${_filteredFuelRecords.length} registros para "$_searchQuery"');
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredFuelRecords.clear();
    notifyListeners();
  }

  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    _setLoading(true);
    _clearError();

    final consumptionResult = await _getAverageConsumption(
      GetAverageConsumptionParams(vehicleId: vehicleId),
    );

    consumptionResult.fold(
      (failure) => debugPrint('Erro ao carregar consumo médio: ${failure.message}'),
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
      (failure) => debugPrint('Erro ao carregar total gasto: ${failure.message}'),
      (total) => _totalSpent = total,
    );

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

  FuelRecordEntity? getFuelRecordById(String id) {
    try {
      return _fuelRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

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

  void clearError() {
    _clearError();
  }

  void filterByVehicle(String vehicleId) {
    if (_currentVehicleFilter != vehicleId) {
      loadFuelRecordsByVehicle(vehicleId);
    }
  }

  
  void clearAllFilters() {
    _currentVehicleFilter = '';
    clearSearch();
    loadAllFuelRecords();
  }


  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = fuelRecords.where((record) {
      return record.data.isAfter(startDate) && record.data.isBefore(endDate);
    }).toList();
    return recordsInRange.map((r) => r.valorTotal).fold(0.0, (a, b) => a + b);
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = fuelRecords.where((record) {
      return record.data.isAfter(startDate) && record.data.isBefore(endDate);
    }).toList();
    return recordsInRange.map((r) => r.litros).fold(0.0, (a, b) => a + b);
  }

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
    // Se não há busca ativa, limpar os filtros e usar todos os registros
    if (_searchQuery.isEmpty) {
      _filteredFuelRecords.clear();
    } else {
      // Aplicar busca nos registros carregados
      _filteredFuelRecords = _fuelRecords.where((record) {
        final searchLower = _searchQuery.toLowerCase();
        return record.nomePosto?.toLowerCase().contains(searchLower) == true ||
               record.marcaPosto?.toLowerCase().contains(searchLower) == true ||
               record.observacoes?.toLowerCase().contains(searchLower) == true ||
               record.tipoCombustivel.displayName.toLowerCase().contains(searchLower);
      }).toList();
    }
    
    notifyListeners();
  }
}