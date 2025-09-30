import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/usecases/add_fuel_record.dart';
import '../../domain/usecases/delete_fuel_record.dart';
import '../../domain/usecases/get_all_fuel_records.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import '../../domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../domain/usecases/search_fuel_records.dart';
import '../../domain/usecases/update_fuel_record.dart';

// ========== MODELS ==========

/// Statistics for analytics caching
class FuelStatistics {
  const FuelStatistics({
    required this.totalLiters,
    required this.totalCost,
    required this.averagePrice,
    required this.averageConsumption,
    required this.totalRecords,
    required this.lastUpdated,
  });

  final double totalLiters;
  final double totalCost;
  final double averagePrice;
  final double averageConsumption;
  final int totalRecords;
  final DateTime lastUpdated;

  bool get needsRecalculation {
    final now = DateTime.now();
    const maxCacheTime = Duration(minutes: 5);
    return now.difference(lastUpdated) > maxCacheTime;
  }
}

/// Analytics data from use cases
class FuelAnalytics {
  const FuelAnalytics({
    required this.vehicleId,
    required this.averageConsumption,
    required this.totalSpent,
    required this.recentRecords,
    required this.period,
  });

  final String vehicleId;
  final double averageConsumption;
  final double totalSpent;
  final List<FuelRecordEntity> recentRecords;
  final int period; // days

  static const FuelAnalytics empty = FuelAnalytics(
    vehicleId: '',
    averageConsumption: 0,
    totalSpent: 0,
    recentRecords: [],
    period: 30,
  );
}

// ========== STATE ==========

/// Fuel State - manages fuel records, analytics, offline queue
class FuelState {
  const FuelState({
    this.fuelRecords = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.selectedVehicleId,
    this.searchQuery = '',
    this.statistics,
    this.analytics = const {},
    this.isOnline = true,
    this.pendingRecords = const [],
    this.isSyncing = false,
  });

  final List<FuelRecordEntity> fuelRecords;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;
  final String? selectedVehicleId;
  final String searchQuery;
  final FuelStatistics? statistics;
  final Map<String, FuelAnalytics> analytics; // Cache por vehicleId
  final bool isOnline;
  final List<FuelRecordEntity> pendingRecords; // Offline queue
  final bool isSyncing;

  // Computed getters
  bool get hasRecords => fuelRecords.isNotEmpty;
  int get recordCount => fuelRecords.length;
  bool get hasError => errorMessage != null;
  bool get hasActiveVehicleFilter => selectedVehicleId != null;
  bool get hasActiveSearch => searchQuery.isNotEmpty;
  bool get hasActiveFilters => hasActiveVehicleFilter || hasActiveSearch;
  bool get hasPendingRecords => pendingRecords.isNotEmpty;
  int get pendingRecordsCount => pendingRecords.length;

  /// Filtered records by vehicle and search
  List<FuelRecordEntity> get filteredRecords {
    var records = fuelRecords;

    // Filter by vehicle
    if (selectedVehicleId != null) {
      records = records.where((r) => r.vehicleId == selectedVehicleId).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      records = records.where((record) {
        return record.gasStationName?.toLowerCase().contains(query) == true ||
            record.gasStationBrand?.toLowerCase().contains(query) == true ||
            record.notes?.toLowerCase().contains(query) == true ||
            record.fuelType.displayName.toLowerCase().contains(query);
      }).toList();
    }

    return records;
  }

  /// Get analytics for selected vehicle
  FuelAnalytics? get selectedVehicleAnalytics {
    if (selectedVehicleId == null) return null;
    return analytics[selectedVehicleId];
  }

  FuelState copyWith({
    List<FuelRecordEntity>? fuelRecords,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    String? selectedVehicleId,
    String? searchQuery,
    FuelStatistics? statistics,
    Map<String, FuelAnalytics>? analytics,
    bool? isOnline,
    List<FuelRecordEntity>? pendingRecords,
    bool? isSyncing,
    bool clearError = false,
    bool clearVehicleFilter = false,
    bool clearSearchQuery = false,
  }) {
    return FuelState(
      fuelRecords: fuelRecords ?? this.fuelRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
      selectedVehicleId: clearVehicleFilter ? null : (selectedVehicleId ?? this.selectedVehicleId),
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      statistics: statistics ?? this.statistics,
      analytics: analytics ?? this.analytics,
      isOnline: isOnline ?? this.isOnline,
      pendingRecords: pendingRecords ?? this.pendingRecords,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// ========== NOTIFIER ==========

/// FuelNotifier - Complete fuel management with offline queue, connectivity, analytics
class FuelNotifier extends StateNotifier<FuelState> {
  FuelNotifier({
    required GetAllFuelRecords getAllFuelRecords,
    required GetFuelRecordsByVehicle getFuelRecordsByVehicle,
    required AddFuelRecord addFuelRecord,
    required UpdateFuelRecord updateFuelRecord,
    required DeleteFuelRecord deleteFuelRecord,
    required SearchFuelRecords searchFuelRecords,
    required GetAverageConsumption getAverageConsumption,
    required GetTotalSpent getTotalSpent,
    required GetRecentFuelRecords getRecentFuelRecords,
    required ConnectivityService connectivityService,
  })  : _getAllFuelRecords = getAllFuelRecords,
        _getFuelRecordsByVehicle = getFuelRecordsByVehicle,
        _addFuelRecord = addFuelRecord,
        _updateFuelRecord = updateFuelRecord,
        _deleteFuelRecord = deleteFuelRecord,
        _searchFuelRecords = searchFuelRecords,
        _getAverageConsumption = getAverageConsumption,
        _getTotalSpent = getTotalSpent,
        _getRecentFuelRecords = getRecentFuelRecords,
        _connectivityService = connectivityService,
        super(const FuelState()) {
    _initialize();
  }

  final GetAllFuelRecords _getAllFuelRecords;
  final GetFuelRecordsByVehicle _getFuelRecordsByVehicle;
  final AddFuelRecord _addFuelRecord;
  final UpdateFuelRecord _updateFuelRecord;
  final DeleteFuelRecord _deleteFuelRecord;
  final SearchFuelRecords _searchFuelRecords;
  final GetAverageConsumption _getAverageConsumption;
  final GetTotalSpent _getTotalSpent;
  final GetRecentFuelRecords _getRecentFuelRecords;
  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  Box<dynamic>? _offlineQueueBox;

  // ========== INITIALIZATION ==========

  Future<void> _initialize() async {
    try {
      // 1. Setup connectivity listener
      await _setupConnectivityListener();

      // 2. Load offline queue from Hive
      await _loadOfflineQueue();

      // 3. Load fuel records
      await loadFuelRecords();

      // 4. Sync offline records if online
      if (state.isOnline && state.hasPendingRecords) {
        await syncPendingRecords();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao inicializar FuelNotifier: $e');
      }
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> _setupConnectivityListener() async {
    // Get initial connectivity state
    final result = await _connectivityService.isOnline();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🔌 Erro ao verificar conectividade inicial: ${failure.message}');
        }
      },
      (isOnline) {
        state = state.copyWith(isOnline: isOnline);
        if (kDebugMode) {
          debugPrint('🔌 Conectividade inicial: ${isOnline ? 'online' : 'offline'}');
        }
      },
    );

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isOnline) {
        _onConnectivityChanged(isOnline);
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('🔌 Erro no stream de conectividade: $error');
        }
      },
    );
  }

  void _onConnectivityChanged(bool isOnline) {
    final wasOnline = state.isOnline;
    state = state.copyWith(isOnline: isOnline);

    if (kDebugMode) {
      debugPrint('🔌 Conectividade mudou: ${wasOnline ? 'online' : 'offline'} → ${isOnline ? 'online' : 'offline'}');
    }

    // Auto-sync when coming back online
    if (!wasOnline && isOnline && state.hasPendingRecords) {
      syncPendingRecords();
    }
  }

  // ========== OFFLINE QUEUE PERSISTENCE ==========

  Future<void> _loadOfflineQueue() async {
    try {
      _offlineQueueBox = await Hive.openBox('fuel_offline_queue');
      final data = _offlineQueueBox?.get('pending_records') as List?;

      if (data != null && data.isNotEmpty) {
        final pendingRecords = data
            .map((json) => FuelRecordEntity.fromFirebaseMap(json as Map<String, dynamic>))
            .toList();

        state = state.copyWith(pendingRecords: pendingRecords);

        if (kDebugMode) {
          debugPrint('🚗 Carregados ${pendingRecords.length} registros pendentes do Hive');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar fila offline: $e');
      }
    }
  }

  Future<void> _saveOfflineQueue() async {
    try {
      _offlineQueueBox ??= await Hive.openBox('fuel_offline_queue');

      final data = state.pendingRecords.map((r) => r.toFirebaseMap()).toList();
      await _offlineQueueBox?.put('pending_records', data);

      if (kDebugMode) {
        debugPrint('🚗 Fila offline salva: ${data.length} registros');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao salvar fila offline: $e');
      }
    }
  }

  Future<void> _clearOfflineQueue() async {
    try {
      await _offlineQueueBox?.delete('pending_records');
      if (kDebugMode) {
        debugPrint('🚗 Fila offline limpa');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao limpar fila offline: $e');
      }
    }
  }

  // ========== CRUD OPERATIONS ==========

  Future<void> loadFuelRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null, clearError: true);

    try {
      final result = await _getAllFuelRecords();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
            isInitialized: true,
          );
        },
        (records) {
          state = state.copyWith(
            fuelRecords: records,
            isLoading: false,
            isInitialized: true,
            statistics: _calculateStatistics(records),
          );

          if (kDebugMode) {
            debugPrint('🚗 Carregados ${records.length} registros de combustível');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar registros: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedVehicleId: vehicleId,
      clearError: true,
    );

    try {
      final result = await _getFuelRecordsByVehicle(
        GetFuelRecordsByVehicleParams(vehicleId: vehicleId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
        },
        (records) {
          state = state.copyWith(
            fuelRecords: records,
            isLoading: false,
            statistics: _calculateStatistics(records),
          );

          if (kDebugMode) {
            debugPrint('🚗 Carregados ${records.length} registros para veículo $vehicleId');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar registros do veículo: $e',
      );
    }
  }

  Future<bool> addFuelRecord(FuelRecordEntity record) async {
    state = state.copyWith(isLoading: true, errorMessage: null, clearError: true);

    try {
      // Check if online
      if (!state.isOnline) {
        // Save to offline queue
        await _addToOfflineQueue(record);

        // Add to local list immediately for UI
        final updatedRecords = [record, ...state.fuelRecords];
        state = state.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        );

        if (kDebugMode) {
          debugPrint('🔌 Registro salvo offline: ${record.id}');
        }

        return true;
      }

      // Try to add online
      final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record));

      return result.fold(
        (failure) async {
          // Failed online - save offline as fallback
          await _addToOfflineQueue(record);

          final updatedRecords = [record, ...state.fuelRecords];
          state = state.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          );

          if (kDebugMode) {
            debugPrint('🔌 Erro online, salvo offline: ${failure.message}');
          }

          return true; // Return true because we saved offline
        },
        (addedRecord) {
          final updatedRecords = [addedRecord, ...state.fuelRecords];
          state = state.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          );

          if (kDebugMode) {
            debugPrint('🚗 Registro adicionado online: ${addedRecord.id}');
          }

          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao adicionar registro: $e',
      );
      return false;
    }
  }

  Future<bool> updateFuelRecord(FuelRecordEntity record) async {
    state = state.copyWith(isLoading: true, errorMessage: null, clearError: true);

    try {
      final result = await _updateFuelRecord(UpdateFuelRecordParams(fuelRecord: record));

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
          return false;
        },
        (updatedRecord) {
          final updatedRecords = state.fuelRecords.map((r) {
            return r.id == updatedRecord.id ? updatedRecord : r;
          }).toList();

          state = state.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          );

          if (kDebugMode) {
            debugPrint('🚗 Registro atualizado: ${updatedRecord.id}');
          }

          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar registro: $e',
      );
      return false;
    }
  }

  Future<bool> deleteFuelRecord(String recordId) async {
    if (recordId.isEmpty) return false;

    state = state.copyWith(isLoading: true, errorMessage: null, clearError: true);

    try {
      final result = await _deleteFuelRecord(DeleteFuelRecordParams(id: recordId));

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          );
          return false;
        },
        (_) {
          final updatedRecords = state.fuelRecords.where((r) => r.id != recordId).toList();
          state = state.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          );

          if (kDebugMode) {
            debugPrint('🚗 Registro removido: $recordId');
          }

          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao remover registro: $e',
      );
      return false;
    }
  }

  // ========== OFFLINE QUEUE MANAGEMENT ==========

  Future<void> _addToOfflineQueue(FuelRecordEntity record) async {
    final updatedPending = [...state.pendingRecords, record];
    state = state.copyWith(pendingRecords: updatedPending);
    await _saveOfflineQueue();
  }

  Future<void> syncPendingRecords() async {
    if (!state.isOnline || !state.hasPendingRecords) return;

    state = state.copyWith(isSyncing: true);

    if (kDebugMode) {
      debugPrint('🔌 Sincronizando ${state.pendingRecordsCount} registros pendentes...');
    }

    final recordsToSync = List<FuelRecordEntity>.from(state.pendingRecords);
    final failedRecords = <FuelRecordEntity>[];

    for (final record in recordsToSync) {
      try {
        final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record));

        result.fold(
          (failure) {
            failedRecords.add(record);
            if (kDebugMode) {
              debugPrint('🔌 Falha ao sincronizar registro: ${failure.message}');
            }
          },
          (syncedRecord) {
            if (kDebugMode) {
              debugPrint('🔌 Registro sincronizado: ${syncedRecord.id}');
            }
          },
        );
      } catch (e) {
        failedRecords.add(record);
        if (kDebugMode) {
          debugPrint('🔌 Erro ao sincronizar registro: $e');
        }
      }
    }

    // Update pending records with only failed ones
    state = state.copyWith(
      pendingRecords: failedRecords,
      isSyncing: false,
    );

    if (failedRecords.isEmpty) {
      await _clearOfflineQueue();
      if (kDebugMode) {
        debugPrint('🔌 Todos os registros foram sincronizados!');
      }
    } else {
      await _saveOfflineQueue();
      if (kDebugMode) {
        debugPrint('🔌 ${failedRecords.length} registros ainda pendentes');
      }
    }

    // Reload records after sync
    await loadFuelRecords();
  }

  // ========== SEARCH & FILTER ==========

  void searchFuelRecords(String query) {
    state = state.copyWith(searchQuery: query.trim());

    if (kDebugMode && query.isNotEmpty) {
      debugPrint('🔍 Busca: "$query" - ${state.filteredRecords.length} resultados');
    }
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', clearSearchQuery: true);
  }

  void filterByVehicle(String vehicleId) {
    state = state.copyWith(selectedVehicleId: vehicleId);
  }

  void clearVehicleFilter() {
    state = state.copyWith(selectedVehicleId: null, clearVehicleFilter: true);
  }

  void clearAllFilters() {
    state = state.copyWith(
      selectedVehicleId: null,
      searchQuery: '',
      clearVehicleFilter: true,
      clearSearchQuery: true,
    );
    loadFuelRecords();
  }

  // ========== ANALYTICS ==========

  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    try {
      // Load average consumption
      final consumptionResult = await _getAverageConsumption(
        GetAverageConsumptionParams(vehicleId: vehicleId),
      );

      double averageConsumption = 0.0;
      consumptionResult.fold(
        (failure) => debugPrint('Erro ao carregar consumo médio: ${failure.message}'),
        (consumption) => averageConsumption = consumption,
      );

      // Load total spent (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final totalSpentResult = await _getTotalSpent(
        GetTotalSpentParams(
          vehicleId: vehicleId,
          startDate: thirtyDaysAgo,
        ),
      );

      double totalSpent = 0.0;
      totalSpentResult.fold(
        (failure) => debugPrint('Erro ao carregar total gasto: ${failure.message}'),
        (total) => totalSpent = total,
      );

      // Load recent records
      final recentResult = await _getRecentFuelRecords(
        GetRecentFuelRecordsParams(vehicleId: vehicleId, limit: 5),
      );

      List<FuelRecordEntity> recentRecords = [];
      recentResult.fold(
        (failure) => debugPrint('Erro ao carregar registros recentes: ${failure.message}'),
        (records) => recentRecords = records,
      );

      // Update analytics cache
      final analytics = FuelAnalytics(
        vehicleId: vehicleId,
        averageConsumption: averageConsumption,
        totalSpent: totalSpent,
        recentRecords: recentRecords,
        period: 30,
      );

      final updatedAnalyticsCache = Map<String, FuelAnalytics>.from(state.analytics);
      updatedAnalyticsCache[vehicleId] = analytics;

      state = state.copyWith(analytics: updatedAnalyticsCache);

      if (kDebugMode) {
        debugPrint('🚗 Analytics carregados para veículo $vehicleId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar analytics: $e');
      }
    }
  }

  // ========== UTILITY METHODS ==========

  FuelRecordEntity? getFuelRecordById(String id) {
    try {
      return state.fuelRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = state.fuelRecords.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
    return recordsInRange.fold<double>(0.0, (sum, record) => sum + record.totalPrice);
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    final recordsInRange = state.fuelRecords.where((record) {
      return record.date.isAfter(startDate) && record.date.isBefore(endDate);
    }).toList();
    return recordsInRange.fold<double>(0.0, (sum, record) => sum + record.liters);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, clearError: true);
  }

  void clearAllData() {
    state = const FuelState();
  }

  // ========== STATISTICS CALCULATION ==========

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

    final totalLiters = records.fold<double>(0, (total, record) => total + record.liters);
    final totalCost = records.fold<double>(0, (total, record) => total + record.totalPrice);
    final averagePrice = records.fold<double>(0, (total, record) => total + record.pricePerLiter) / records.length;

    // Calculate average consumption only for records with data
    double averageConsumption = 0.0;
    final recordsWithConsumption = records.where((r) => r.consumption != null && r.consumption! > 0).toList();
    if (recordsWithConsumption.isNotEmpty) {
      averageConsumption = recordsWithConsumption.fold<double>(0, (total, record) => total + record.consumption!) / recordsWithConsumption.length;
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

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
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

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _offlineQueueBox?.close();
    super.dispose();
  }
}

// ========== PROVIDERS ==========

/// Main fuel notifier provider
final fuelNotifierProvider = StateNotifierProvider<FuelNotifier, FuelState>((ref) {
  final getIt = ModularInjectionContainer.instance;

  return FuelNotifier(
    getAllFuelRecords: getIt<GetAllFuelRecords>(),
    getFuelRecordsByVehicle: getIt<GetFuelRecordsByVehicle>(),
    addFuelRecord: getIt<AddFuelRecord>(),
    updateFuelRecord: getIt<UpdateFuelRecord>(),
    deleteFuelRecord: getIt<DeleteFuelRecord>(),
    searchFuelRecords: getIt<SearchFuelRecords>(),
    getAverageConsumption: getIt<GetAverageConsumption>(),
    getTotalSpent: getIt<GetTotalSpent>(),
    getRecentFuelRecords: getIt<GetRecentFuelRecords>(),
    connectivityService: getIt<ConnectivityService>(),
  );
});

/// Derived providers for easier access

// Filtered records provider
final filteredFuelRecordsProvider = Provider<List<FuelRecordEntity>>((ref) {
  return ref.watch(fuelNotifierProvider).filteredRecords;
});

// Selected vehicle ID provider
final selectedFuelVehicleIdProvider = Provider<String?>((ref) {
  return ref.watch(fuelNotifierProvider).selectedVehicleId;
});

// Search query provider
final fuelSearchQueryProvider = Provider<String>((ref) {
  return ref.watch(fuelNotifierProvider).searchQuery;
});

// Statistics provider
final fuelStatisticsProvider = Provider<FuelStatistics?>((ref) {
  return ref.watch(fuelNotifierProvider).statistics;
});

// Analytics provider for specific vehicle
final fuelAnalyticsProvider = Provider.family<FuelAnalytics?, String>((ref, vehicleId) {
  final analytics = ref.watch(fuelNotifierProvider).analytics;
  return analytics[vehicleId];
});

// Offline queue providers
final fuelPendingCountProvider = Provider<int>((ref) {
  return ref.watch(fuelNotifierProvider).pendingRecordsCount;
});

final fuelHasPendingRecordsProvider = Provider<bool>((ref) {
  return ref.watch(fuelNotifierProvider).hasPendingRecords;
});

final fuelIsOnlineProvider = Provider<bool>((ref) {
  return ref.watch(fuelNotifierProvider).isOnline;
});

final fuelIsSyncingProvider = Provider<bool>((ref) {
  return ref.watch(fuelNotifierProvider).isSyncing;
});

// Loading and error providers
final fuelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fuelNotifierProvider).isLoading;
});

final fuelErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(fuelNotifierProvider).errorMessage;
});

final fuelHasErrorProvider = Provider<bool>((ref) {
  return ref.watch(fuelNotifierProvider).hasError;
});