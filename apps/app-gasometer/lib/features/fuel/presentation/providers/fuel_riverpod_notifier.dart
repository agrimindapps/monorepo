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
import '../../domain/usecases/update_fuel_record.dart';

part 'fuel_riverpod_notifier.g.dart';

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

// ========== RIVERPOD NOTIFIER ==========

@riverpod
class FuelRiverpod extends _$FuelRiverpod {
  late GetAllFuelRecords _getAllFuelRecords;
  late GetFuelRecordsByVehicle _getFuelRecordsByVehicle;
  late AddFuelRecord _addFuelRecord;
  late UpdateFuelRecord _updateFuelRecord;
  late DeleteFuelRecord _deleteFuelRecord;
  late GetAverageConsumption _getAverageConsumption;
  late GetTotalSpent _getTotalSpent;
  late GetRecentFuelRecords _getRecentFuelRecords;
  late ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  Box<dynamic>? _offlineQueueBox;

  @override
  FutureOr<FuelState> build() async {
    // Inject use cases from GetIt
    final getIt = ModularInjectionContainer.instance;
    _getAllFuelRecords = getIt<GetAllFuelRecords>();
    _getFuelRecordsByVehicle = getIt<GetFuelRecordsByVehicle>();
    _addFuelRecord = getIt<AddFuelRecord>();
    _updateFuelRecord = getIt<UpdateFuelRecord>();
    _deleteFuelRecord = getIt<DeleteFuelRecord>();
    _getAverageConsumption = getIt<GetAverageConsumption>();
    _getTotalSpent = getIt<GetTotalSpent>();
    _getRecentFuelRecords = getIt<GetRecentFuelRecords>();
    _connectivityService = getIt<ConnectivityService>();

    // Setup lifecycle cleanup
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _offlineQueueBox?.close();
    });

    // Initialize
    await _setupConnectivityListener();
    await _loadOfflineQueue();

    final initialState = await _loadAllRecords();

    // Sync offline records if online
    if (initialState.isOnline && initialState.hasPendingRecords) {
      // ignore: unawaited_futures
      syncPendingRecords(); // Fire and forget - sync in background
    }

    return initialState;
  }

  // ========== INITIALIZATION ==========

  Future<void> _setupConnectivityListener() async {
    // Get initial connectivity state
    final result = await _connectivityService.isOnline();
    var isOnline = true;

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🔌 Erro ao verificar conectividade inicial: ${failure.message}');
        }
      },
      (online) {
        isOnline = online;
        if (kDebugMode) {
          debugPrint('🔌 Conectividade inicial: ${online ? 'online' : 'offline'}');
        }
      },
    );

    // Update state with initial connectivity
    state = AsyncValue.data(const FuelState().copyWith(isOnline: isOnline));

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (online) {
        _onConnectivityChanged(online);
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('🔌 Erro no stream de conectividade: $error');
        }
      },
    );
  }

  void _onConnectivityChanged(bool isOnline) {
    state.whenData((currentState) {
      final wasOnline = currentState.isOnline;
      state = AsyncValue.data(currentState.copyWith(isOnline: isOnline));

      if (kDebugMode) {
        debugPrint('🔌 Conectividade mudou: ${wasOnline ? 'online' : 'offline'} → ${isOnline ? 'online' : 'offline'}');
      }

      // Auto-sync when coming back online
      if (!wasOnline && isOnline && currentState.hasPendingRecords) {
        syncPendingRecords();
      }
    });
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

        state.whenData((currentState) {
          state = AsyncValue.data(currentState.copyWith(pendingRecords: pendingRecords));
        });

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

      final currentState = state.value;
      if (currentState != null) {
        final data = currentState.pendingRecords.map((r) => r.toFirebaseMap()).toList();
        await _offlineQueueBox?.put('pending_records', data);

        if (kDebugMode) {
          debugPrint('🚗 Fila offline salva: ${data.length} registros');
        }
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

  Future<FuelState> _loadAllRecords() async {
    final result = await _getAllFuelRecords();

    return result.fold(
      (failure) => FuelState(
        errorMessage: _mapFailureToMessage(failure),
        isInitialized: true,
      ),
      (records) => FuelState(
        fuelRecords: records,
        isInitialized: true,
        statistics: _calculateStatistics(records),
      ),
    );
  }

  Future<void> loadFuelRecords() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _getAllFuelRecords();

      return result.fold(
        (failure) => FuelState(
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
        ),
        (records) {
          if (kDebugMode) {
            debugPrint('🚗 Carregados ${records.length} registros de combustível');
          }

          return FuelState(
            fuelRecords: records,
            isInitialized: true,
            statistics: _calculateStatistics(records),
          );
        },
      );
    });
  }

  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: true,
        selectedVehicleId: vehicleId,
        clearError: true,
      ));
    });

    final result = await _getFuelRecordsByVehicle(
      GetFuelRecordsByVehicleParams(vehicleId: vehicleId),
    );

    state.whenData((currentState) {
      result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ));
        },
        (records) {
          if (kDebugMode) {
            debugPrint('🚗 Carregados ${records.length} registros para veículo $vehicleId');
          }

          state = AsyncValue.data(currentState.copyWith(
            fuelRecords: records,
            isLoading: false,
            statistics: _calculateStatistics(records),
          ));
        },
      );
    });
  }

  Future<bool> addFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, clearError: true));

    try {
      // Check if online
      if (!currentState.isOnline) {
        // Save to offline queue
        await _addToOfflineQueue(record);

        // Add to local list immediately for UI
        final updatedRecords = [record, ...currentState.fuelRecords];
        state = AsyncValue.data(currentState.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        ));

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

          final updatedRecords = [record, ...currentState.fuelRecords];
          state = AsyncValue.data(currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          ));

          if (kDebugMode) {
            debugPrint('🔌 Erro online, salvo offline: ${failure.message}');
          }

          return true; // Return true because we saved offline
        },
        (addedRecord) {
          final updatedRecords = [addedRecord, ...currentState.fuelRecords];
          state = AsyncValue.data(currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculateStatistics(updatedRecords),
          ));

          if (kDebugMode) {
            debugPrint('🚗 Registro adicionado online: ${addedRecord.id}');
          }

          return true;
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao adicionar registro: $e',
      ));
      return false;
    }
  }

  Future<bool> updateFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _updateFuelRecord(UpdateFuelRecordParams(fuelRecord: record));

    return result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        ));
        return false;
      },
      (updatedRecord) {
        final updatedRecords = currentState.fuelRecords.map((r) {
          return r.id == updatedRecord.id ? updatedRecord : r;
        }).toList();

        state = AsyncValue.data(currentState.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        ));

        if (kDebugMode) {
          debugPrint('🚗 Registro atualizado: ${updatedRecord.id}');
        }

        return true;
      },
    );
  }

  Future<bool> deleteFuelRecord(String recordId) async {
    if (recordId.isEmpty) return false;

    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _deleteFuelRecord(DeleteFuelRecordParams(id: recordId));

    return result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        ));
        return false;
      },
      (_) {
        final updatedRecords = currentState.fuelRecords.where((r) => r.id != recordId).toList();
        state = AsyncValue.data(currentState.copyWith(
          fuelRecords: updatedRecords,
          isLoading: false,
          statistics: _calculateStatistics(updatedRecords),
        ));

        if (kDebugMode) {
          debugPrint('🚗 Registro removido: $recordId');
        }

        return true;
      },
    );
  }

  // ========== OFFLINE QUEUE MANAGEMENT ==========

  Future<void> _addToOfflineQueue(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState != null) {
      final updatedPending = [...currentState.pendingRecords, record];
      state = AsyncValue.data(currentState.copyWith(pendingRecords: updatedPending));
      await _saveOfflineQueue();
    }
  }

  Future<void> syncPendingRecords() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isOnline || !currentState.hasPendingRecords) return;

    state = AsyncValue.data(currentState.copyWith(isSyncing: true));

    if (kDebugMode) {
      debugPrint('🔌 Sincronizando ${currentState.pendingRecordsCount} registros pendentes...');
    }

    final recordsToSync = List<FuelRecordEntity>.from(currentState.pendingRecords);
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
    state = AsyncValue.data(currentState.copyWith(
      pendingRecords: failedRecords,
      isSyncing: false,
    ));

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
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query.trim()));

      if (kDebugMode && query.isNotEmpty) {
        debugPrint('🔍 Busca: "$query" - ${currentState.filteredRecords.length} resultados');
      }
    });
  }

  void clearSearch() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: '', clearSearchQuery: true));
    });
  }

  void filterByVehicle(String vehicleId) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedVehicleId: vehicleId));
    });
  }

  void clearVehicleFilter() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedVehicleId: null, clearVehicleFilter: true));
    });
  }

  void clearAllFilters() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        selectedVehicleId: null,
        searchQuery: '',
        clearVehicleFilter: true,
        clearSearchQuery: true,
      ));
    });
    loadFuelRecords();
  }

  // ========== ANALYTICS ==========

  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    final currentState = state.value;
    if (currentState == null) return;

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

      final updatedAnalyticsCache = Map<String, FuelAnalytics>.from(currentState.analytics);
      updatedAnalyticsCache[vehicleId] = analytics;

      state = AsyncValue.data(currentState.copyWith(analytics: updatedAnalyticsCache));

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
    return state.whenData((currentState) {
      try {
        return currentState.fuelRecords.firstWhere((record) => record.id == id);
      } catch (e) {
        return null;
      }
    }).value;
  }

  double getTotalSpentInDateRange(DateTime startDate, DateTime endDate) {
    return state.whenData((currentState) {
      final recordsInRange = currentState.fuelRecords.where((record) {
        return record.date.isAfter(startDate) && record.date.isBefore(endDate);
      }).toList();
      return recordsInRange.fold<double>(0.0, (total, record) => total + record.totalPrice);
    }).value ?? 0.0;
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    return state.whenData((currentState) {
      final recordsInRange = currentState.fuelRecords.where((record) {
        return record.date.isAfter(startDate) && record.date.isBefore(endDate);
      }).toList();
      return recordsInRange.fold<double>(0.0, (total, record) => total + record.liters);
    }).value ?? 0.0;
  }

  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: null, clearError: true));
    }
  }

  void clearAllData() {
    state = const AsyncValue.data(FuelState());
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
}

// ========== DERIVED PROVIDERS ==========

/// Filtered records provider
@riverpod
List<FuelRecordEntity> filteredFuelRecords(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.filteredRecords,
        loading: () => [],
        error: (_, __) => [],
      );
}

/// Selected vehicle ID provider
@riverpod
String? selectedFuelVehicleId(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.selectedVehicleId,
        loading: () => null,
        error: (_, __) => null,
      );
}

/// Search query provider
@riverpod
String fuelSearchQuery(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.searchQuery,
        loading: () => '',
        error: (_, __) => '',
      );
}

/// Statistics provider
@riverpod
FuelStatistics? fuelStatistics(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.statistics,
        loading: () => null,
        error: (_, __) => null,
      );
}

/// Analytics provider for specific vehicle
@riverpod
FuelAnalytics? fuelAnalytics(Ref ref, String vehicleId) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.analytics[vehicleId],
        loading: () => null,
        error: (_, __) => null,
      );
}

/// Offline queue providers
@riverpod
int fuelPendingCount(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.pendingRecordsCount,
        loading: () => 0,
        error: (_, __) => 0,
      );
}

@riverpod
bool fuelHasPendingRecords(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.hasPendingRecords,
        loading: () => false,
        error: (_, __) => false,
      );
}

@riverpod
bool fuelIsOnline(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.isOnline,
        loading: () => true,
        error: (_, __) => true,
      );
}

@riverpod
bool fuelIsSyncing(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.isSyncing,
        loading: () => false,
        error: (_, __) => false,
      );
}

/// Loading and error providers
@riverpod
bool fuelIsLoading(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.isLoading,
        loading: () => true,
        error: (_, __) => false,
      );
}

@riverpod
String? fuelErrorMessage(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.errorMessage,
        loading: () => null,
        error: (error, _) => error.toString(),
      );
}

@riverpod
bool fuelHasError(Ref ref) {
  return ref.watch(fuelRiverpodProvider).when(
        data: (state) => state.hasError,
        loading: () => false,
        error: (_, __) => true,
      );
}
