import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/fuel_record_entity.dart';
import '../../domain/services/fuel_calculation_service.dart';
import '../../domain/services/fuel_connectivity_service.dart';
import '../../domain/services/fuel_crud_service.dart';
import '../../domain/services/fuel_query_service.dart';
import '../../domain/services/fuel_sync_service.dart';
import '../../domain/usecases/get_fuel_analytics.dart';
import 'providers.dart';

part 'fuel_riverpod_notifier.g.dart';

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

/// Fuel State - manages fuel records, analytics, offline queue
class FuelState {
  const FuelState({
    this.fuelRecords = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.selectedVehicleId,
    this.selectedMonth,
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
  final DateTime? selectedMonth;
  final String searchQuery;
  final FuelStatistics? statistics;
  final Map<String, FuelAnalytics> analytics; // Cache por vehicleId
  final bool isOnline;
  final List<FuelRecordEntity> pendingRecords; // Offline queue
  final bool isSyncing;
  bool get hasRecords => fuelRecords.isNotEmpty;
  int get recordCount => fuelRecords.length;
  bool get hasError => errorMessage != null;
  bool get hasActiveVehicleFilter => selectedVehicleId != null;
  bool get hasActiveMonthFilter => selectedMonth != null;
  bool get hasActiveSearch => searchQuery.isNotEmpty;
  bool get hasActiveFilters => hasActiveVehicleFilter || hasActiveSearch || hasActiveMonthFilter;
  bool get hasPendingRecords => pendingRecords.isNotEmpty;
  int get pendingRecordsCount => pendingRecords.length;

  /// Filtered records by vehicle and search
  List<FuelRecordEntity> get filteredRecords {
    var records = fuelRecords;
    if (selectedVehicleId != null) {
      records = records.where((r) => r.vehicleId == selectedVehicleId).toList();
    }
    if (selectedMonth != null) {
      records = records.where((r) =>
          r.date.year == selectedMonth!.year &&
          r.date.month == selectedMonth!.month).toList();
    }
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
    DateTime? selectedMonth,
    String? searchQuery,
    FuelStatistics? statistics,
    Map<String, FuelAnalytics>? analytics,
    bool? isOnline,
    List<FuelRecordEntity>? pendingRecords,
    bool? isSyncing,
    bool clearError = false,
    bool clearVehicleFilter = false,
    bool clearMonthFilter = false,
    bool clearSearchQuery = false,
  }) {
    return FuelState(
      fuelRecords: fuelRecords ?? this.fuelRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
      selectedVehicleId: clearVehicleFilter
          ? null
          : (selectedVehicleId ?? this.selectedVehicleId),
      selectedMonth: clearMonthFilter
          ? null
          : (selectedMonth ?? this.selectedMonth),
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      statistics: statistics ?? this.statistics,
      analytics: analytics ?? this.analytics,
      isOnline: isOnline ?? this.isOnline,
      pendingRecords: pendingRecords ?? this.pendingRecords,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

@riverpod
class FuelRiverpod extends _$FuelRiverpod {
  // Specialized Services (SRP)
  late FuelCrudService _crudService;
  late FuelQueryService _queryService;
  late FuelSyncService _syncService;
  late FuelCalculationService _calculationService;
  late FuelConnectivityService _connectivityService;

  // Use cases
  late GetAverageConsumption _getAverageConsumption;
  late GetTotalSpent _getTotalSpent;
  late GetRecentFuelRecords _getRecentFuelRecords;

  StreamSubscription<bool>? _connectivitySubscription;

  @override
  FutureOr<FuelState> build() async {
    // Initialize specialized services via Bridge Providers
    _crudService = ref.watch(fuelCrudServiceProvider);
    _queryService = ref.watch(fuelQueryServiceProvider);
    _syncService = ref.watch(fuelSyncServiceProvider);
    _calculationService = ref.watch(fuelCalculationServiceProvider);
    _connectivityService = ref.watch(fuelConnectivityServiceProvider);

    // Initialize use cases for analytics via Bridge Providers
    _getAverageConsumption = ref.watch(getAverageConsumptionProvider);
    _getTotalSpent = ref.watch(getTotalSpentProvider);
    _getRecentFuelRecords = ref.watch(getRecentFuelRecordsProvider);

    ref.onDispose(() {
      _connectivitySubscription?.cancel();
      _connectivityService.dispose();
    });

    await _setupConnectivityListener();
    final pendingRecords = await _loadPendingRecords();

    final initialState = await _loadAllRecords();
    final stateWithPending = initialState.copyWith(
      pendingRecords: pendingRecords,
    );

    if (stateWithPending.isOnline && stateWithPending.hasPendingRecords) {
      unawaited(syncPendingRecords());
    }

    return stateWithPending;
  }

  Future<void> _setupConnectivityListener() async {
    final isOnline = await _connectivityService.initialize();

    state = AsyncValue.data(const FuelState().copyWith(isOnline: isOnline));

    _connectivitySubscription = _connectivityService.addConnectivityListener(
      _onConnectivityChanged,
      onError: (error) {
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

      if (_connectivityService.hasGoneOnline(wasOnline) &&
          currentState.hasPendingRecords) {
        unawaited(syncPendingRecords());
      }
    });
  }

  Future<FuelState> _loadAllRecords() async {
    final result = await _queryService.loadAllRecords();

    return result.fold(
      (failure) => FuelState(
        errorMessage: _mapFailureToMessage(failure),
        isInitialized: true,
      ),
      (records) => FuelState(
        fuelRecords: records,
        isInitialized: true,
        statistics: _calculationService.calculateStatistics(records),
      ),
    );
  }

  Future<List<FuelRecordEntity>> _loadPendingRecords() async {
    final result = await _syncService.loadPendingRecords();
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🚗 Erro ao carregar registros pendentes: ${failure.message}');
        }
        return [];
      },
      (records) => records,
    );
  }

  Future<void> loadFuelRecords() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _queryService.loadAllRecords(forceRefresh: true);

      return result.fold(
        (failure) => FuelState(
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
        ),
        (records) {
          if (kDebugMode) {
            debugPrint(
              '🚗 Carregados ${records.length} registros de combustível',
            );
          }

          return FuelState(
            fuelRecords: records,
            isInitialized: true,
            statistics: _calculationService.calculateStatistics(records),
          );
        },
      );
    });
  }

  Future<void> loadFuelRecordsByVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: true,
          selectedVehicleId: vehicleId,
          clearError: true,
        ),
      );
    });

    final result = await _queryService.loadRecordsByVehicle(vehicleId);

    state.whenData((currentState) {
      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (records) {
          if (kDebugMode) {
            debugPrint(
              '🚗 Carregados ${records.length} registros para veículo $vehicleId',
            );
          }

          state = AsyncValue.data(
            currentState.copyWith(
              fuelRecords: records,
              isLoading: false,
              statistics: _calculationService.calculateStatistics(records),
            ),
          );
        },
      );
    });
  }

  Future<bool> addFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.addFuel(record);

    return result.fold(
      (failure) async {
        final updatedPending = await _loadPendingRecords();
        final updatedRecords = [record, ...currentState.fuelRecords];

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
            pendingRecords: updatedPending,
          ),
        );

        if (kDebugMode) {
          debugPrint(
            '🔌 Registro salvo localmente (Drift), será sincronizado: ${failure.message}',
          );
        }

        return true;
      },
      (addedRecord) async {
        final updatedRecords = [addedRecord, ...currentState.fuelRecords];
        final updatedPending = await _loadPendingRecords();

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
            pendingRecords: updatedPending,
          ),
        );

        if (kDebugMode) {
          debugPrint(
            '🚗 Registro adicionado e sincronizado: ${addedRecord.id}',
          );
        }

        return true;
      },
    );
  }

  Future<bool> updateFuelRecord(FuelRecordEntity record) async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.updateFuel(record);

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
        return false;
      },
      (updatedRecord) {
        final updatedRecords = currentState.fuelRecords.map((r) {
          return r.id == updatedRecord.id ? updatedRecord : r;
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
          ),
        );

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

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    final result = await _crudService.deleteFuel(recordId);

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
        return false;
      },
      (_) {
        final updatedRecords = currentState.fuelRecords
            .where((r) => r.id != recordId)
            .toList();
        state = AsyncValue.data(
          currentState.copyWith(
            fuelRecords: updatedRecords,
            isLoading: false,
            statistics: _calculationService.calculateStatistics(updatedRecords),
          ),
        );

        if (kDebugMode) {
          debugPrint('🚗 Registro removido: $recordId');
        }

        return true;
      },
    );
  }

  Future<void> syncPendingRecords() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isOnline ||
        !currentState.hasPendingRecords) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isSyncing: true));

    if (kDebugMode) {
      debugPrint(
        '🔌 Sincronizando ${currentState.pendingRecordsCount} registros pendentes...',
      );
    }

    // Delegate sync to FuelSyncService
    final recordsToSync = List<FuelRecordEntity>.from(
      currentState.pendingRecords,
    );
    final syncedIds = <String>[];
    final failedRecords = <FuelRecordEntity>[];

    for (final record in recordsToSync) {
      try {
        final result = await _crudService.addFuel(record);

        result.fold(
          (failure) {
            failedRecords.add(record);
            if (kDebugMode) {
              debugPrint(
                '🔌 Falha ao sincronizar registro: ${failure.message}',
              );
            }
          },
          (syncedRecord) {
            syncedIds.add(syncedRecord.id);
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

    // Mark synced records
    if (syncedIds.isNotEmpty) {
      await _syncService.markRecordsAsSynced(syncedIds);
    }

    // Reload pending records
    final updatedPending = await _loadPendingRecords();

    state = AsyncValue.data(
      currentState.copyWith(pendingRecords: updatedPending, isSyncing: false),
    );

    if (updatedPending.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔌 Todos os registros foram sincronizados!');
      }
    } else {
      if (kDebugMode) {
        debugPrint('🔌 ${updatedPending.length} registros ainda pendentes');
      }
    }

    await loadFuelRecords();
  }

  void searchFuelRecords(String query) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(searchQuery: query.trim()));

      if (kDebugMode && query.isNotEmpty) {
        debugPrint(
          '🔍 Busca: "$query" - ${currentState.filteredRecords.length} resultados',
        );
      }
    });
  }

  void clearSearch() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(searchQuery: '', clearSearchQuery: true),
      );
    });
  }

  void filterByVehicle(String vehicleId) {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(selectedVehicleId: vehicleId),
      );
    });
  }

  void selectMonth(DateTime month) {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(selectedMonth: month),
      );
    });
  }

  void clearMonthFilter() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(clearMonthFilter: true),
      );
    });
  }

  void clearVehicleFilter() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          selectedVehicleId: null,
          clearVehicleFilter: true,
        ),
      );
    });
  }

  void clearAllFilters() {
    state.whenData((currentState) {
      state = AsyncValue.data(
        currentState.copyWith(
          selectedVehicleId: null,
          searchQuery: '',
          clearVehicleFilter: true,
          clearSearchQuery: true,
          clearMonthFilter: true,
        ),
      );
    });
    loadFuelRecords();
  }

  Future<void> loadAnalytics(String vehicleId) async {
    if (vehicleId.isEmpty) return;

    final currentState = state.value;
    if (currentState == null) return;

    try {
      final consumptionResult = await _getAverageConsumption(
        GetAverageConsumptionParams(vehicleId: vehicleId),
      );

      double averageConsumption = 0.0;
      consumptionResult.fold(
        (failure) =>
            debugPrint('Erro ao carregar consumo médio: ${failure.message}'),
        (consumption) => averageConsumption = consumption,
      );
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final totalSpentResult = await _getTotalSpent(
        GetTotalSpentParams(vehicleId: vehicleId, startDate: thirtyDaysAgo),
      );

      double totalSpent = 0.0;
      totalSpentResult.fold(
        (failure) =>
            debugPrint('Erro ao carregar total gasto: ${failure.message}'),
        (total) => totalSpent = total,
      );
      final recentResult = await _getRecentFuelRecords(
        GetRecentFuelRecordsParams(vehicleId: vehicleId, limit: 5),
      );

      List<FuelRecordEntity> recentRecords = [];
      recentResult.fold(
        (failure) => debugPrint(
          'Erro ao carregar registros recentes: ${failure.message}',
        ),
        (records) => recentRecords = records,
      );
      final analytics = FuelAnalytics(
        vehicleId: vehicleId,
        averageConsumption: averageConsumption,
        totalSpent: totalSpent,
        recentRecords: recentRecords,
        period: 30,
      );

      final updatedAnalyticsCache = Map<String, FuelAnalytics>.from(
        currentState.analytics,
      );
      updatedAnalyticsCache[vehicleId] = analytics;

      state = AsyncValue.data(
        currentState.copyWith(analytics: updatedAnalyticsCache),
      );

      if (kDebugMode) {
        debugPrint('🚗 Analytics carregados para veículo $vehicleId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚗 Erro ao carregar analytics: $e');
      }
    }
  }

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
          return _calculationService.calculateTotalSpentInRange(
            currentState.fuelRecords,
            startDate,
            endDate,
          );
        }).value ??
        0.0;
  }

  double getTotalLitersInDateRange(DateTime startDate, DateTime endDate) {
    return state.whenData((currentState) {
          return _calculationService.calculateTotalLitersInRange(
            currentState.fuelRecords,
            startDate,
            endDate,
          );
        }).value ??
        0.0;
  }

  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: null, clearError: true),
      );
    }
  }

  void clearAllData() {
    state = const AsyncValue.data(FuelState());
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

/// Filtered records provider
@riverpod
List<FuelRecordEntity> filteredFuelRecords(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.filteredRecords,
        loading: () => [],
        error: (_, __) => [],
      );
}

/// Selected vehicle ID provider
@riverpod
String? selectedFuelVehicleId(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.selectedVehicleId,
        loading: () => null,
        error: (_, __) => null,
      );
}

/// Search query provider
@riverpod
String fuelSearchQuery(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.searchQuery,
        loading: () => '',
        error: (_, __) => '',
      );
}

/// Statistics provider
@riverpod
FuelStatistics? fuelStatistics(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.statistics,
        loading: () => null,
        error: (_, __) => null,
      );
}

/// Offline queue providers
@riverpod
int fuelPendingCount(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.pendingRecordsCount,
        loading: () => 0,
        error: (_, __) => 0,
      );
}

@riverpod
bool fuelHasPendingRecords(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.hasPendingRecords,
        loading: () => false,
        error: (_, __) => false,
      );
}

@riverpod
bool fuelIsOnline(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.isOnline,
        loading: () => true,
        error: (_, __) => true,
      );
}

@riverpod
bool fuelIsSyncing(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.isSyncing,
        loading: () => false,
        error: (_, __) => false,
      );
}

/// Loading and error providers
@riverpod
bool fuelIsLoading(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.isLoading,
        loading: () => true,
        error: (_, __) => false,
      );
}

@riverpod
String? fuelErrorMessage(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.errorMessage,
        loading: () => null,
        error: (error, _) => error.toString(),
      );
}

@riverpod
bool fuelHasError(Ref ref) {
  return ref
      .watch(fuelRiverpodProvider)
      .when(
        data: (state) => state.hasError,
        loading: () => false,
        error: (_, __) => true,
      );
}
