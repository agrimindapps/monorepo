import 'package:core/core.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/services/maintenance_filter_service.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/delete_maintenance_record.dart';
import '../../domain/usecases/get_all_maintenance_records.dart';
import '../../domain/usecases/get_maintenance_records_by_vehicle.dart';
import '../../domain/usecases/update_maintenance_record.dart';

part 'unified_maintenance_notifier.g.dart';

/// State for unified maintenance management
class UnifiedMaintenanceState {
  const UnifiedMaintenanceState({
    this.allMaintenances = const [],
    this.filteredMaintenances = const [],
    this.filters = const MaintenanceFilters(),
    this.sorting = const MaintenanceSorting(),
    this.statistics = const {},
    this.error,
  });

  final List<MaintenanceEntity> allMaintenances;
  final List<MaintenanceEntity> filteredMaintenances;
  final MaintenanceFilters filters;
  final MaintenanceSorting sorting;
  final Map<String, dynamic> statistics;
  final String? error;

  // Computed properties
  bool get hasActiveFilters => filters.hasActiveFilters;
  int get totalRecords => allMaintenances.length;
  int get filteredRecords => filteredMaintenances.length;

  double get totalCost => filteredMaintenances.fold(
        0.0,
        (total, record) => total + record.cost,
      );

  double get averageCost =>
      filteredMaintenances.isEmpty ? 0.0 : totalCost / filteredMaintenances.length;

  String get formattedTotalCost =>
      'R\$ ${totalCost.toStringAsFixed(2).replaceAll('.', ',')}';

  String get formattedAverageCost =>
      'R\$ ${averageCost.toStringAsFixed(2).replaceAll('.', ',')}';

  String get filterSummary {
    final activeFilters = <String>[];

    if (filters.vehicleId != null) activeFilters.add('Veículo');
    if (filters.type != null) activeFilters.add('Tipo');
    if (filters.status != null) activeFilters.add('Status');
    if (filters.startDate != null || filters.endDate != null) {
      activeFilters.add('Período');
    }
    if (filters.minCost != null || filters.maxCost != null) {
      activeFilters.add('Valor');
    }
    if (filters.searchQuery.isNotEmpty) activeFilters.add('Busca');

    if (activeFilters.isEmpty) {
      return 'Todos os registros';
    }

    return 'Filtros: ${activeFilters.join(', ')}';
  }

  UnifiedMaintenanceState copyWith({
    List<MaintenanceEntity>? allMaintenances,
    List<MaintenanceEntity>? filteredMaintenances,
    MaintenanceFilters? filters,
    MaintenanceSorting? sorting,
    Map<String, dynamic>? statistics,
    String? error,
    bool clearError = false,
  }) {
    return UnifiedMaintenanceState(
      allMaintenances: allMaintenances ?? this.allMaintenances,
      filteredMaintenances: filteredMaintenances ?? this.filteredMaintenances,
      filters: filters ?? this.filters,
      sorting: sorting ?? this.sorting,
      statistics: statistics ?? this.statistics,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Consolidated maintenance notifier that combines CRUD operations with filtering/listing
@riverpod
class UnifiedMaintenanceNotifier extends _$UnifiedMaintenanceNotifier {
  late GetAllMaintenanceRecords _getAllMaintenanceRecords;
  late GetMaintenanceRecordsByVehicle _getMaintenanceRecordsByVehicle;
  late AddMaintenanceRecord _addMaintenanceRecord;
  late UpdateMaintenanceRecord _updateMaintenanceRecord;
  late DeleteMaintenanceRecord _deleteMaintenanceRecord;
  late MaintenanceFilterService _filterService;

  @override
  Future<UnifiedMaintenanceState> build() async {
    // Get dependencies from GetIt
    _getAllMaintenanceRecords = getIt<GetAllMaintenanceRecords>();
    _getMaintenanceRecordsByVehicle = getIt<GetMaintenanceRecordsByVehicle>();
    _addMaintenanceRecord = getIt<AddMaintenanceRecord>();
    _updateMaintenanceRecord = getIt<UpdateMaintenanceRecord>();
    _deleteMaintenanceRecord = getIt<DeleteMaintenanceRecord>();
    _filterService = getIt<MaintenanceFilterService>();

    // Load initial data
    return _loadMaintenances();
  }

  // Core CRUD Operations

  /// Load all maintenance records
  Future<UnifiedMaintenanceState> _loadMaintenances() async {
    final result = await _getAllMaintenanceRecords(const NoParams());

    return result.fold(
      (failure) => UnifiedMaintenanceState(error: failure.message),
      (records) {
        final filteredRecords = _filterService.applyFiltersAndSorting(
          records,
          const MaintenanceFilters(),
          const MaintenanceSorting(),
        );
        final statistics = _filterService.calculateStatistics(filteredRecords);

        return UnifiedMaintenanceState(
          allMaintenances: records,
          filteredMaintenances: filteredRecords,
          statistics: statistics,
        );
      },
    );
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadMaintenances);
  }

  /// Load maintenance records for specific vehicle
  Future<void> loadMaintenancesByVehicle(String vehicleId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _getMaintenanceRecordsByVehicle(
        GetMaintenanceRecordsByVehicleParams(vehicleId: vehicleId),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (records) {
          final currentState = state.value ?? const UnifiedMaintenanceState();

          // Auto-apply vehicle filter if not already set
          final filters = currentState.filters.vehicleId != vehicleId
              ? currentState.filters.copyWith(vehicleId: vehicleId)
              : currentState.filters;

          final filteredRecords = _filterService.applyFiltersAndSorting(
            records,
            filters,
            currentState.sorting,
          );
          final statistics = _filterService.calculateStatistics(filteredRecords);

          return UnifiedMaintenanceState(
            allMaintenances: records,
            filteredMaintenances: filteredRecords,
            filters: filters,
            sorting: currentState.sorting,
            statistics: statistics,
          );
        },
      );
    });
  }

  /// Add new maintenance record
  Future<bool> addMaintenance(MaintenanceEntity maintenance) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _addMaintenanceRecord(
      AddMaintenanceRecordParams(maintenance: maintenance),
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (addedRecord) {
        final updatedAll = [...currentState.allMaintenances, addedRecord];
        final filteredRecords = _filterService.applyFiltersAndSorting(
          updatedAll,
          currentState.filters,
          currentState.sorting,
        );
        final statistics = _filterService.calculateStatistics(filteredRecords);

        state = AsyncValue.data(
          currentState.copyWith(
            allMaintenances: updatedAll,
            filteredMaintenances: filteredRecords,
            statistics: statistics,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Update existing maintenance record
  Future<bool> updateMaintenance(MaintenanceEntity maintenance) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _updateMaintenanceRecord(
      UpdateMaintenanceRecordParams(maintenance: maintenance),
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (updatedRecord) {
        final updatedAll = currentState.allMaintenances
            .map((r) => r.id == updatedRecord.id ? updatedRecord : r)
            .toList();

        final filteredRecords = _filterService.applyFiltersAndSorting(
          updatedAll,
          currentState.filters,
          currentState.sorting,
        );
        final statistics = _filterService.calculateStatistics(filteredRecords);

        state = AsyncValue.data(
          currentState.copyWith(
            allMaintenances: updatedAll,
            filteredMaintenances: filteredRecords,
            statistics: statistics,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Delete maintenance record
  Future<bool> deleteMaintenance(String id) async {
    final currentState = state.value;
    if (currentState == null) return false;

    final result = await _deleteMaintenanceRecord(
      DeleteMaintenanceRecordParams(id: id),
    );

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (_) {
        final updatedAll =
            currentState.allMaintenances.where((r) => r.id != id).toList();

        final filteredRecords = _filterService.applyFiltersAndSorting(
          updatedAll,
          currentState.filters,
          currentState.sorting,
        );
        final statistics = _filterService.calculateStatistics(filteredRecords);

        state = AsyncValue.data(
          currentState.copyWith(
            allMaintenances: updatedAll,
            filteredMaintenances: filteredRecords,
            statistics: statistics,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Get maintenance by ID
  MaintenanceEntity? getMaintenanceById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.allMaintenances.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtering and Sorting Operations

  /// Apply vehicle filter
  void filterByVehicle(String? vehicleId) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(
      vehicleId: vehicleId,
      clearVehicleId: vehicleId == null,
    );

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply type filter
  void filterByType(MaintenanceType? type) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(
      type: type,
      clearType: type == null,
    );

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply status filter
  void filterByStatus(MaintenanceStatus? status) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(
      status: status,
      clearStatus: status == null,
    );

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply date range filter
  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(
      startDate: startDate,
      endDate: endDate,
      clearDateRange: startDate == null && endDate == null,
    );

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply cost range filter
  void filterByCostRange(double? minCost, double? maxCost) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(
      minCost: minCost,
      maxCost: maxCost,
      clearCostRange: minCost == null && maxCost == null,
    );

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply search filter
  void search(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    final filters = currentState.filters.copyWith(searchQuery: query);

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Apply multiple filters at once
  void applyFilters(MaintenanceFilters filters) {
    final currentState = state.value;
    if (currentState == null) return;

    _applyFiltersAndSorting(filters, currentState.sorting);
  }

  /// Clear all filters
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    _applyFiltersAndSorting(
      const MaintenanceFilters(),
      currentState.sorting,
    );
  }

  /// Set sorting
  void setSorting(MaintenanceSortField field, {bool? ascending}) {
    final currentState = state.value;
    if (currentState == null) return;

    var sorting = currentState.sorting.toggleOrSet(field);
    if (ascending != null) {
      sorting = sorting.copyWith(ascending: ascending);
    }

    _applyFiltersAndSorting(currentState.filters, sorting);
  }

  /// Apply custom sorting
  void applySorting(MaintenanceSorting sorting) {
    final currentState = state.value;
    if (currentState == null) return;

    _applyFiltersAndSorting(currentState.filters, sorting);
  }

  /// Clear error message
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }

  // Private Methods

  void _applyFiltersAndSorting(
    MaintenanceFilters filters,
    MaintenanceSorting sorting,
  ) {
    final currentState = state.value;
    if (currentState == null) return;

    final filteredRecords = _filterService.applyFiltersAndSorting(
      currentState.allMaintenances,
      filters,
      sorting,
    );
    final statistics = _filterService.calculateStatistics(filteredRecords);

    state = AsyncValue.data(
      currentState.copyWith(
        filteredMaintenances: filteredRecords,
        filters: filters,
        sorting: sorting,
        statistics: statistics,
      ),
    );
  }
}

// Derived State Providers

/// Provider for completed maintenances
@riverpod
List<MaintenanceEntity> completedMaintenances(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getRecordsByStatus(
        state.filteredMaintenances,
        MaintenanceStatus.completed,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for pending maintenances
@riverpod
List<MaintenanceEntity> pendingMaintenances(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getRecordsByStatus(
        state.filteredMaintenances,
        MaintenanceStatus.pending,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for overdue maintenances
@riverpod
List<MaintenanceEntity> overdueMaintenances(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getOverdueRecords(state.filteredMaintenances);
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for upcoming maintenances
@riverpod
List<MaintenanceEntity> upcomingMaintenances(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getUpcomingRecords(state.filteredMaintenances);
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for high cost maintenances
@riverpod
List<MaintenanceEntity> highCostMaintenances(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getHighCostRecords(state.filteredMaintenances);
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for maintenances by type
@riverpod
List<MaintenanceEntity> maintenancesByType(
  Ref ref,
  MaintenanceType type,
) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getRecordsByType(state.filteredMaintenances, type);
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for maintenances by urgency
@riverpod
List<MaintenanceEntity> maintenancesByUrgency(
  Ref ref,
  String urgencyLevel,
) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getRecordsByUrgency(
        state.filteredMaintenances,
        urgencyLevel,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for recent maintenances
@riverpod
List<MaintenanceEntity> recentMaintenances(
  Ref ref, {
  int days = 30,
}) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      return filterService.getRecentRecords(
        state.filteredMaintenances,
        days: days,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for maintenance counts by type
@riverpod
Map<MaintenanceType, int> maintenanceCountsByType(Ref ref) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final counts = <MaintenanceType, int>{};
      for (final record in state.filteredMaintenances) {
        counts[record.type] = (counts[record.type] ?? 0) + 1;
      }
      return counts;
    },
    loading: () => {},
    error: (_, __) => {},
  );
}

/// Provider for statistics for specific period
@riverpod
Map<String, dynamic> statisticsForPeriod(
  Ref ref,
  DateTime start,
  DateTime end,
) {
  final stateAsync = ref.watch(unifiedMaintenanceNotifierProvider);

  return stateAsync.when(
    data: (state) {
      final filterService = getIt<MaintenanceFilterService>();
      final periodRecords = filterService.getRecordsByDateRange(
        state.allMaintenances,
        start,
        end,
      );
      return filterService.calculateStatistics(periodRecords);
    },
    loading: () => {},
    error: (_, __) => {},
  );
}
