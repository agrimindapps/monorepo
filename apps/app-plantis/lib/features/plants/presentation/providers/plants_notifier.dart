import 'dart:async';

import 'package:core/core.dart' hide Column, SortBy;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/entities/plant.dart';
import '../../domain/services/plants_care_service.dart';
import '../../domain/services/plants_filter_service.dart';
import '../../domain/services/plants_sort_service.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plant_by_id_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/search_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import 'plants_providers.dart';
// Use plants_state.dart PlantsState which is @freezed and preferred
import 'plants_state.dart';

export '../../domain/services/plants_care_service.dart' show CareStatus;
export '../../domain/services/plants_sort_service.dart' show SortBy, ViewMode;
export 'plants_state.dart';

part 'plants_notifier.g.dart';

/// Plants Notifier refactored with specialized services
/// Now follows Single Responsibility Principle using Facade pattern
///
/// Delegates to:
/// - PlantsFilterService: Search & filtering
/// - PlantsSortService: Sorting & views
/// - PlantsCareService: Care analytics
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  late final PlantsFilterService _filterService;
  late final PlantsSortService _sortService;
  late final PlantsCareService _careService;
  late final SearchPlantsUseCase _searchPlantsUseCase;
  late final GetPlantsUseCase _getPlantsUseCase;
  late final GetPlantByIdUseCase _getPlantByIdUseCase;
  late final AddPlantUseCase _addPlantUseCase;
  late final UpdatePlantUseCase _updatePlantUseCase;
  late final DeletePlantUseCase _deletePlantUseCase;
  late final AuthStateNotifier _authStateNotifier;
  StreamSubscription<UserEntity?>? _authSubscription;
  StreamSubscription<List<dynamic>>? _realtimeDataSubscription;

  @override
  PlantsState build() {
    _filterService = PlantsFilterService();
    _sortService = PlantsSortService();
    _careService = PlantsCareService();
    _searchPlantsUseCase = ref.read(searchPlantsUseCaseProvider);
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _getPlantByIdUseCase = ref.read(getPlantByIdUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);
    _deletePlantUseCase = ref.read(deletePlantUseCaseProvider);
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
        state = state.copyWith(plants: [], selectedPlant: null, error: null);
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

      final dataStream = UnifiedSyncManager.instance.streamAll<Plant>(
        'plantis',
      );

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
              debugPrint('⏸️ PlantsNotifier: Aguardando inicialização de auth');
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
          if (!firebaseMap.containsKey('id') ||
              !firebaseMap.containsKey('name')) {
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

      state = state.copyWith(error: null);

      final localResult = await _getPlantsUseCase.call(const NoParams());

      localResult.fold(
        (Failure failure) {
          // Silent fail for local data
        },
        (List<Plant> plants) {
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
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (Failure failure) {
          if (state.plants.isEmpty) {
            state = state.copyWith(error: failure.toString());
          }
        },
        (List<Plant> plants) {
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
      error: null,
      isLoading: false,
    );
  }

  Future<Plant?> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (Failure failure) {
        state = state.copyWith(error: failure.toString());
        return null;
      },
      (Plant plant) {
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

    state = state.copyWith(searchQuery: query, isSearching: true);

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString(), isSearching: false);
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
    state = state.copyWith(isLoading: true, error: null);

    final result = await _addPlantUseCase.call(params);

    final success = result.fold(
      (Failure failure) {
        state = state.copyWith(error: failure.toString(), isLoading: false);
        return false;
      },
      (Plant plant) {
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
    state = state.copyWith(isLoading: true, error: null);

    final result = await _updatePlantUseCase.call(params);

    final success = result.fold(
      (Failure failure) {
        state = state.copyWith(error: failure.toString(), isLoading: false);
        return false;
      },
      (Plant updatedPlant) {
        final updatedPlants = state.plants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        final sorted = _sortService.sortPlants(updatedPlants, state.sortBy);

        state = state.copyWith(
          plants: _applyFilters(sorted),
          selectedPlant: state.selectedPlant?.id == updatedPlant.id
              ? updatedPlant
              : state.selectedPlant,
          isLoading: false,
        );
        return true;
      },
    );

    return success;
  }

  Future<bool> deletePlant(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _deletePlantUseCase.call(id);

    final success = result.fold(
      (Failure failure) {
        state = state.copyWith(error: failure.toString(), isLoading: false);
        return false;
      },
      (_) {
        state = state.copyWith(
          plants: _applyFilters(state.plants.where((p) => p.id != id).toList()),
          searchResults: state.searchResults.where((p) => p.id != id).toList(),
          selectedPlant:
              state.selectedPlant?.id == id ? null : state.selectedPlant,
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
        plants: _applyFilters(state.plants),
      );
    }
  }

  void clearSearch() {
    if (state.searchQuery.isNotEmpty ||
        state.searchResults.isNotEmpty ||
        state.isSearching) {
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
      state = state.copyWith(selectedPlant: null);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
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

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> getPlantsGroupedBySpaces() {
    final plantsToGroup =
        state.searchQuery.isNotEmpty ? state.searchResults : state.plants;
    return _filterService.groupPlantsBySpaces(plantsToGroup);
  }

  /// Gets the count of plants in each space
  Map<String?, int> getPlantCountsBySpace() {
    final plantsToGroup =
        state.searchQuery.isNotEmpty ? state.searchResults : state.plants;
    return _filterService.getPlantCountsBySpace(plantsToGroup);
  }

  /// Get total plants count
  int get plantsCount => state.plants.length;

  List<Plant> _applyFilters(List<Plant> plants) {
    List<Plant> filtered = List.from(plants);

    if (state.filterBySpace != null) {
      filtered = _filterService.filterBySpace(filtered, state.filterBySpace);
    }

    return filtered;
  }
}

/// Alias for backwards compatibility - use plantsProvider for new code
const plantsNotifierProvider = plantsProvider;
