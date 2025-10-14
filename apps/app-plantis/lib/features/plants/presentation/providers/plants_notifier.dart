import 'dart:async';

import 'package:core/core.dart' hide getIt, SortBy;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/entities/plant.dart';
import '../../domain/services/plants_care_service.dart';
import '../../domain/services/plants_crud_service.dart';
import '../../domain/services/plants_filter_service.dart';
import '../../domain/services/plants_sort_service.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
export '../../domain/services/plants_care_service.dart' show CareStatus;
export '../../domain/services/plants_sort_service.dart' show SortBy, ViewMode;

part 'plants_notifier.g.dart';

/// State for Plants feature
class PlantsState {
  final List<Plant> plants;
  final Plant? selectedPlant;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String searchQuery;
  final List<Plant> searchResults;
  final ViewMode viewMode;
  final SortBy sortBy;
  final String? filterBySpace;

  const PlantsState({
    this.plants = const [],
    this.selectedPlant,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.searchResults = const [],
    this.viewMode = ViewMode.grid,
    this.sortBy = SortBy.newest,
    this.filterBySpace,
  });

  PlantsState copyWith({
    List<Plant>? plants,
    Plant? selectedPlant,
    bool? clearSelectedPlant,
    bool? isLoading,
    bool? isSearching,
    String? error,
    bool? clearError,
    String? searchQuery,
    List<Plant>? searchResults,
    ViewMode? viewMode,
    SortBy? sortBy,
    String? filterBySpace,
    bool? clearFilterBySpace,
  }) {
    return PlantsState(
      plants: plants ?? this.plants,
      selectedPlant: clearSelectedPlant == true ? null : (selectedPlant ?? this.selectedPlant),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError == true ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: clearFilterBySpace == true ? null : (filterBySpace ?? this.filterBySpace),
    );
  }

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup = searchQuery.isNotEmpty ? searchResults : plants;
    final filterService = PlantsFilterService();
    return filterService.groupPlantsBySpaces(plantsToGroup);
  }

  /// Gets the count of plants in each space
  Map<String?, int> get plantCountsBySpace {
    final plantsToGroup = searchQuery.isNotEmpty ? searchResults : plants;
    final filterService = PlantsFilterService();
    return filterService.getPlantCountsBySpace(plantsToGroup);
  }

  /// Check if current view is grouped by spaces
  bool get isGroupedBySpaces {
    final sortService = PlantsSortService();
    return sortService.isGroupedView(viewMode);
  }

  /// Get plants count
  int get plantsCount {
    final crudService = PlantsCrudService(
      getPlantsUseCase: GetIt.instance<GetPlantsUseCase>(),
      getPlantByIdUseCase: GetIt.instance<GetPlantByIdUseCase>(),
      addPlantUseCase: GetIt.instance<AddPlantUseCase>(),
      updatePlantUseCase: GetIt.instance<UpdatePlantUseCase>(),
      deletePlantUseCase: GetIt.instance<DeletePlantUseCase>(),
    );
    return crudService.getPlantCount(plants);
  }
}

/// Plants Notifier refactored with specialized services
/// Now follows Single Responsibility Principle using Facade pattern
///
/// Delegates to:
/// - PlantsCrudService: CRUD operations
/// - PlantsFilterService: Search & filtering
/// - PlantsSortService: Sorting & views
/// - PlantsCareService: Care analytics
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  late final PlantsCrudService _crudService;
  late final PlantsFilterService _filterService;
  late final PlantsSortService _sortService;
  late final PlantsCareService _careService;
  late final SearchPlantsUseCase _searchPlantsUseCase;
  late final AuthStateNotifier _authStateNotifier;
  StreamSubscription<UserEntity?>? _authSubscription;
  StreamSubscription<List<dynamic>>? _realtimeDataSubscription;

  @override
  PlantsState build() {
    _crudService = PlantsCrudService(
      getPlantsUseCase: ref.read(getPlantsUseCaseProvider),
      getPlantByIdUseCase: ref.read(getPlantByIdUseCaseProvider),
      addPlantUseCase: ref.read(addPlantUseCaseProvider),
      updatePlantUseCase: ref.read(updatePlantUseCaseProvider),
      deletePlantUseCase: ref.read(deletePlantUseCaseProvider),
    );

    _filterService = PlantsFilterService();
    _sortService = PlantsSortService();
    _careService = PlantsCareService();
    _searchPlantsUseCase = ref.read(searchPlantsUseCaseProvider);
    _authStateNotifier = AuthStateNotifier.instance;
    ref.onDispose(() {
      _authSubscription?.cancel();
      _realtimeDataSubscription?.cancel();
    });
    _initializeAuthListener();
    _initializeRealtimeDataStream();
    return const PlantsState();
  }

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint(
        '🔐 PlantsNotifier: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}',
      );

      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ PlantsNotifier: Auth is stable, loading plants...');
        loadInitialData();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint(
          '🔄 PlantsNotifier: No user but auth initialized - clearing plants',
        );
        state = state.copyWith(
          plants: [],
          clearSelectedPlant: true,
          clearError: true,
        );
      }
    });
  }

  /// Inicializa o stream de dados em tempo real do UnifiedSyncManager
  void _initializeRealtimeDataStream() {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 PlantsNotifier: Iniciando configuração de real-time stream...',
        );
      }

      final dataStream = UnifiedSyncManager.instance.streamAll<Plant>('plantis');

      if (dataStream == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ PlantsNotifier: Stream de dados não disponível - usando polling',
          );
        }
        return;
      }

      _realtimeDataSubscription = dataStream.listen(
        (List<dynamic> plants) {
          if (kDebugMode) {
            debugPrint(
              '🔄 PlantsNotifier: Dados em tempo real recebidos - ${plants.length} plantas',
            );
          }

          if (!_authStateNotifier.isInitialized) {
            if (kDebugMode) {
              debugPrint(
                '⏸️ PlantsNotifier: Aguardando inicialização de auth',
              );
            }
            return;
          }

          final domainPlants = <Plant>[];
          for (final syncPlant in plants) {
            final plant = _convertSyncPlantToDomain(syncPlant);
            if (plant != null) {
              domainPlants.add(plant);
            }
          }

          if (_hasDataChanged(domainPlants)) {
            _updatePlantsData(domainPlants);
          }
        },
        onError: (dynamic error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint('❌ PlantsNotifier: Erro no stream: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsNotifier: Erro ao configurar stream: $e');
      }
    }
  }

  /// Converte entidade de sync para entidade de domínio
  Plant? _convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      if (syncPlant == null) return null;

      if (syncPlant is Plant) {
        if (syncPlant.id.isEmpty) return null;
        return syncPlant;
      }

      if (syncPlant is BaseSyncEntity) {
        try {
          final firebaseMap = syncPlant.toFirebaseMap();
          if (!firebaseMap.containsKey('id') || !firebaseMap.containsKey('name')) {
            return null;
          }
          return Plant.fromJson(firebaseMap);
        } catch (e) {
          return null;
        }
      }

      if (syncPlant is Map<String, dynamic>) {
        if (!syncPlant.containsKey('id') || !syncPlant.containsKey('name')) {
          return null;
        }
        return Plant.fromJson(syncPlant);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se os dados realmente mudaram
  bool _hasDataChanged(List<Plant> newPlants) {
    final currentPlants = state.plants;

    if (currentPlants.length != newPlants.length) {
      return true;
    }

    for (int i = 0; i < currentPlants.length; i++) {
      final currentPlant = currentPlants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        return true;
      }

      if (currentPlant.updatedAt != newPlant.updatedAt) {
        return true;
      }
    }

    return false;
  }

  /// Wait for authentication initialization with timeout
  Future<bool> _waitForAuthenticationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_authStateNotifier.isInitialized) {
      return true;
    }

    try {
      await _authStateNotifier.initializedStream
          .where((isInitialized) => isInitialized)
          .timeout(timeout)
          .first;
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<void> loadPlants() async {
    if (!await _waitForAuthenticationWithTimeout()) {
      state = state.copyWith(error: 'Aguardando autenticação...');
      return;
    }

    await _loadLocalDataFirst();
    _syncInBackground();
  }

  /// Loads local data immediately for instant UI response
  Future<void> _loadLocalDataFirst() async {
    try {
      final shouldShowLoading = state.plants.isEmpty;
      if (shouldShowLoading) {
        state = state.copyWith(isLoading: true);
      }

      state = state.copyWith(clearError: true);

      final localResult = await _crudService.getAllPlants();

      localResult.fold(
        (failure) {
        },
        (plants) {
          _updatePlantsData(plants);
          state = state.copyWith(isLoading: false);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsNotifier: Erro ao carregar dados locais: $e');
      }
    }
  }

  /// Syncs with remote data in background
  void _syncInBackground() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      final result = await _crudService.getAllPlants();

      result.fold(
        (failure) {
          if (state.plants.isEmpty) {
            state = state.copyWith(error: _crudService.getErrorMessage(failure));
          }
        },
        (plants) {
          _updatePlantsData(plants);
        },
      );
    });
  }

  /// Updates plants data
  void _updatePlantsData(List<Plant> plants) {
    final sorted = _sortService.sortPlants(plants, state.sortBy);

    state = state.copyWith(
      plants: _applyFilters(sorted),
      clearError: true,
      isLoading: false,
    );
  }
  Future<Plant?> getPlantById(String id) async {
    final result = await _crudService.getPlantById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: _crudService.getErrorMessage(failure));
        return null;
      },
      (plant) {
        state = state.copyWith(selectedPlant: plant);
        return plant;
      },
    );
  }
  Future<void> searchPlants(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      isSearching: true,
    );

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold(
      (failure) {
        state = state.copyWith(
          error: _crudService.getErrorMessage(failure),
          isSearching: false,
        );
      },
      (results) {
        state = state.copyWith(
          searchResults: _sortService.sortPlants(results, state.sortBy),
          isSearching: false,
        );
      },
    );
  }
  Future<bool> addPlant(AddPlantParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _crudService.addPlant(params);

    final success = result.fold(
      (failure) {
        state = state.copyWith(
          error: _crudService.getErrorMessage(failure),
          isLoading: false,
        );
        return false;
      },
      (plant) {
        final newPlants = [plant, ...state.plants];
        state = state.copyWith(
          plants: _applyFilters(newPlants),
          isLoading: false,
        );
        return true;
      },
    );

    return success;
  }
  Future<bool> updatePlant(UpdatePlantParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _crudService.updatePlant(params);

    final success = result.fold(
      (failure) {
        state = state.copyWith(
          error: _crudService.getErrorMessage(failure),
          isLoading: false,
        );
        return false;
      },
      (updatedPlant) {
        final updatedPlants = state.plants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        final sorted = _sortService.sortPlants(updatedPlants, state.sortBy);

        state = state.copyWith(
          plants: _applyFilters(sorted),
          selectedPlant: state.selectedPlant?.id == updatedPlant.id ? updatedPlant : state.selectedPlant,
          isLoading: false,
        );
        return true;
      },
    );

    return success;
  }
  Future<bool> deletePlant(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _crudService.deletePlant(id);

    final success = result.fold(
      (failure) {
        state = state.copyWith(
          error: _crudService.getErrorMessage(failure),
          isLoading: false,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          plants: _applyFilters(state.plants.where((p) => p.id != id).toList()),
          searchResults: state.searchResults.where((p) => p.id != id).toList(),
          clearSelectedPlant: state.selectedPlant?.id == id,
          isLoading: false,
        );
        return true;
      },
    );

    return success;
  }
  void setViewMode(ViewMode mode) {
    if (state.viewMode != mode) {
      state = state.copyWith(viewMode: mode);
    }
  }
  void setSortBy(SortBy sort) {
    if (state.sortBy != sort) {
      final sorted = _sortService.sortPlants(state.plants, sort);
      final sortedSearch = _sortService.sortPlants(state.searchResults, sort);

      state = state.copyWith(
        sortBy: sort,
        plants: _applyFilters(sorted),
        searchResults: sortedSearch,
      );
    }
  }
  void setSpaceFilter(String? spaceId) {
    if (state.filterBySpace != spaceId) {
      state = state.copyWith(
        filterBySpace: spaceId,
        clearFilterBySpace: spaceId == null,
        plants: _applyFilters(state.plants),
      );
    }
  }
  void clearSearch() {
    if (state.searchQuery.isNotEmpty || state.searchResults.isNotEmpty || state.isSearching) {
      state = state.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
      );
    }
  }

  /// Toggle between normal view and grouped by spaces view
  void toggleGroupedView() {
    final newViewMode = _sortService.toggleGroupedView(state.viewMode);
    state = state.copyWith(viewMode: newViewMode);
  }
  void clearSelectedPlant() {
    if (state.selectedPlant != null) {
      state = state.copyWith(clearSelectedPlant: true);
    }
  }
  void clearError() {
    state = state.copyWith(clearError: true);
  }
  List<Plant> getPlantsBySpace(String spaceId) {
    return state.plants.where((plant) => plant.spaceId == spaceId).toList();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    await loadPlants();
  }

  /// Refresh plants data
  Future<void> refreshPlants() async {
    clearError();
    await loadInitialData();
  }
  List<Plant> getPlantsNeedingWater() {
    return _careService.getPlantsNeedingWater(state.plants);
  }
  List<Plant> getPlantsNeedingFertilizer() {
    return _careService.getPlantsNeedingFertilizer(state.plants);
  }
  List<Plant> getPlantsByCareStatus(CareStatus status) {
    return _careService.getPlantsByCareStatus(state.plants, status);
  }
  List<Plant> _applyFilters(List<Plant> plants) {
    List<Plant> filtered = List.from(plants);

    if (state.filterBySpace != null) {
      filtered = _filterService.filterBySpace(filtered, state.filterBySpace);
    }

    return filtered;
  }
}
@riverpod
GetPlantsUseCase getPlantsUseCase(Ref ref) {
  return GetIt.instance<GetPlantsUseCase>();
}

@riverpod
GetPlantByIdUseCase getPlantByIdUseCase(Ref ref) {
  return GetIt.instance<GetPlantByIdUseCase>();
}

@riverpod
SearchPlantsUseCase searchPlantsUseCase(Ref ref) {
  return GetIt.instance<SearchPlantsUseCase>();
}

@riverpod
AddPlantUseCase addPlantUseCase(Ref ref) {
  return GetIt.instance<AddPlantUseCase>();
}

@riverpod
UpdatePlantUseCase updatePlantUseCase(Ref ref) {
  return GetIt.instance<UpdatePlantUseCase>();
}

@riverpod
DeletePlantUseCase deletePlantUseCase(Ref ref) {
  return GetIt.instance<DeletePlantUseCase>();
}
