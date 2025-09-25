import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/delete_fuel_record.dart';
import '../../domain/usecases/get_all_fuel_records.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import '../../domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../domain/usecases/search_fuel_records.dart';
import '../../domain/usecases/update_fuel_record.dart';

// Statistics models for caching
class FuelStatistics {
  final double totalLiters;
  final double totalCost;
  final double averagePrice;
  final double averageConsumption;
  final int totalRecords;
  final DateTime lastUpdated;

  const FuelStatistics({
    required this.totalLiters,
    required this.totalCost,
    required this.averagePrice,
    required this.averageConsumption,
    required this.totalRecords,
    required this.lastUpdated,
  });

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }
}

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
  final ErrorHandler _errorHandler;
  final ErrorReporter _errorReporter;

  // Connectivity
  late final core.ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;
  final List<FuelRecordEntity> _offlinePendingRecords = [];

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
  
  // Cached statistics
  FuelStatistics? _cachedStatistics;
  bool _statisticsNeedRecalculation = true;

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
    required ErrorHandler errorHandler,
    required ErrorReporter errorReporter,
  })  : _getAllFuelRecords = getAllFuelRecords,
        _getFuelRecordsByVehicle = getFuelRecordsByVehicle,
        _addFuelRecord = addFuelRecord,
        _updateFuelRecord = updateFuelRecord,
        _deleteFuelRecord = deleteFuelRecord,
        _searchFuelRecords = searchFuelRecords,
        _getAverageConsumption = getAverageConsumption,
        _getTotalSpent = getTotalSpent,
        _getRecentFuelRecords = getRecentFuelRecords,
        _errorHandler = errorHandler,
        _errorReporter = errorReporter {
    _connectivityService = sl<core.ConnectivityService>();
    _initializeConnectivity();
  }

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
  
  // Cached statistics getter
  FuelStatistics get statistics {
    final records = fuelRecords;
    if (_cachedStatistics == null || 
        _statisticsNeedRecalculation || 
        _cachedStatistics!.needsRecalculation ||
        _cachedStatistics!.totalRecords != records.length) {
      _cachedStatistics = _calculateStatistics(records);
      _statisticsNeedRecalculation = false;
    }
    return _cachedStatistics!;
  }

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

    final result = await _errorHandler.handleProviderOperation(
      () async {
        final result = await _getAllFuelRecords();
        return result.fold(
          (failure) => throw _convertFailureToError(failure),
          (records) => records,
        );
      },
      providerName: 'FuelProvider',
      methodName: 'loadAllFuelRecords',
    );

    result.fold(
      (error) => _handleError(error),
      (records) {
        _fuelRecords = records;
        _applyCurrentFilters();
        _invalidateStatistics();
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
        _invalidateStatistics();
        debugPrint('🚗 Carregados ${records.length} registros para veículo $vehicleId');
      },
    );

    _setLoading(false);
  }

  Future<bool> addFuelRecord(FuelRecordEntity fuelRecord) async {
    _setLoading(true);
    _clearError();

    // Check connectivity first
    if (!_isOnline) {
      // Save offline - add to pending list and local records
      _offlinePendingRecords.add(fuelRecord);
      _fuelRecords.insert(0, fuelRecord); // Add to UI immediately
      _applyCurrentFilters();
      _invalidateStatistics();
      _setLoading(false);
      debugPrint('🔌 Registro salvo offline: ${fuelRecord.id}');
      return true;
    }

    // Online - try to sync immediately
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
        _setLoading(false);
        debugPrint('🔌 Erro online, salvo offline: ${failure.message}');
        return true; // Return true because we saved offline
      },
      (addedRecord) {
        _fuelRecords.insert(0, addedRecord); // Add to beginning (most recent)
        _applyCurrentFilters();
        _invalidateStatistics();
        _setLoading(false);
        debugPrint('🚗 Registro de combustível sincronizado: ${addedRecord.id}');
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
          _invalidateStatistics();
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
        _invalidateStatistics();
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
    _invalidateStatistics();
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
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
    return recordsInRange.map((r) => r.totalPrice).fold(0.0, (a, b) => a + b);
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = fuelRecords.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
    return recordsInRange.map((r) => r.liters).fold(0.0, (a, b) => a + b);
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

  void _handleError(dynamic error) {
    if (error is Failure) {
      _errorMessage = _mapFailureToMessage(error);
    } else if (error is AppError) {
      _errorMessage = error.displayMessage;
      _errorReporter.reportProviderError(
        error,
        providerName: 'FuelProvider',
        method: 'handleError',
        state: {
          'records_count': _fuelRecords.length,
          'is_loading': _isLoading,
          'search_query': _searchQuery,
        },
      );
    } else {
      _errorMessage = 'Erro inesperado: ${error.toString()}';
    }
    
    debugPrint('🚗 Erro no FuelProvider: $_errorMessage');
    notifyListeners();
  }

  AppError _convertFailureToError(Failure failure) {
    if (failure is NetworkFailure) {
      return NetworkError(
        message: 'Erro de conexão ao carregar dados de combustível',
      );
    } else if (failure is ServerFailure) {
      return ServerError(
        message: 'Erro do servidor ao processar dados de combustível',
        statusCode: 500,
      );
    } else if (failure is ValidationFailure) {
      return ValidationError(
        message: failure.message,
      );
    } else {
      return UnexpectedError(
        message: 'Erro inesperado no carregamento de combustível: ${failure.message}',
      );
    }
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
        return record.gasStationName?.toLowerCase().contains(searchLower) == true ||
               record.gasStationBrand?.toLowerCase().contains(searchLower) == true ||
               record.notes?.toLowerCase().contains(searchLower) == true ||
               record.fuelType.displayName.toLowerCase().contains(searchLower);
      }).toList();
    }
    
    notifyListeners();
  }
  
  // Statistics calculation method
  FuelStatistics _calculateStatistics(List<FuelRecordEntity> records) {
    if (records.isEmpty) {
      return FuelStatistics(
        totalLiters: 0.0,
        totalCost: 0.0,
        averagePrice: 0.0,
        averageConsumption: 0.0,
        totalRecords: 0,
        lastUpdated: DateTime.now(),
      );
    }
    
    final totalLiters = records.fold<double>(0, (sum, record) => sum + record.liters);
    final totalCost = records.fold<double>(0, (sum, record) => sum + record.totalPrice);
    final averagePrice = records.fold<double>(0, (sum, record) => sum + record.pricePerLiter) / records.length;
    
    // Calculate consumption only for records with odometer data
    double averageConsumption = 0.0;
    final recordsWithConsumption = records.where((r) => r.consumption != null && r.consumption! > 0).toList();
    if (recordsWithConsumption.isNotEmpty) {
      averageConsumption = recordsWithConsumption.fold<double>(0, (sum, record) => sum + record.consumption!) / recordsWithConsumption.length;
    }
    
    return FuelStatistics(
      totalLiters: totalLiters,
      totalCost: totalCost,
      averagePrice: averagePrice,
      averageConsumption: averageConsumption,
      totalRecords: records.length,
      lastUpdated: DateTime.now(),
    );
  }

  void _invalidateStatistics() {
    _statisticsNeedRecalculation = true;
  }

  // ===== CONNECTIVITY METHODS =====

  void _initializeConnectivity() {
    _connectivityService.isOnline().then((result) {
      result.fold(
        (failure) => debugPrint('🔌 Erro ao verificar conectividade inicial: ${failure.message}'),
        (isOnline) {
          _isOnline = isOnline;
          if (isOnline) _syncOfflinePendingRecords();
        },
      );
    });

    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
      onError: (Object error) => debugPrint('🔌 Erro no stream de conectividade: $error'),
    );
  }

  void _onConnectivityChanged(bool isOnline) {
    final wasOnline = _isOnline;
    _isOnline = isOnline;

    debugPrint('🔌 Conectividade mudou: ${wasOnline ? 'online' : 'offline'} → ${isOnline ? 'online' : 'offline'}');

    if (!wasOnline && isOnline) {
      // Ficamos online - sincronizar dados offline
      _syncOfflinePendingRecords();
    }

    notifyListeners();
  }

  Future<void> _syncOfflinePendingRecords() async {
    if (_offlinePendingRecords.isEmpty) return;

    debugPrint('🔌 Sincronizando ${_offlinePendingRecords.length} registros offline...');

    final recordsToSync = List<FuelRecordEntity>.from(_offlinePendingRecords);
    _offlinePendingRecords.clear();

    for (final record in recordsToSync) {
      try {
        final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record));
        result.fold(
          (failure) {
            // Se falhou, volta para a lista de offline
            _offlinePendingRecords.add(record);
            debugPrint('🔌 Falha ao sincronizar registro: ${failure.message}');
          },
          (syncedRecord) {
            debugPrint('🔌 Registro sincronizado com sucesso: ${syncedRecord.id}');
          },
        );
      } catch (e) {
        _offlinePendingRecords.add(record);
        debugPrint('🔌 Erro ao sincronizar registro: $e');
      }
    }

    if (_offlinePendingRecords.isEmpty) {
      debugPrint('🔌 Todos os registros foram sincronizados!');
    }

    notifyListeners();
  }

  // Getters para UI

  bool get isOnline => _isOnline;
  bool get hasOfflinePendingRecords => _offlinePendingRecords.isNotEmpty;
  int get offlinePendingRecordsCount => _offlinePendingRecords.length;
  List<FuelRecordEntity> get offlinePendingRecords => List.unmodifiable(_offlinePendingRecords);

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}