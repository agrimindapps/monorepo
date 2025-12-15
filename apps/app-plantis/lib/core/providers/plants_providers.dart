import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plant_by_id_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/search_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../features/plants/presentation/providers/plants_providers.dart';
import '../auth/auth_state_notifier.dart';
import '../data/adapters/auth_state_provider_adapter.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';

part 'plants_providers.g.dart';

// ============================================================================
// STATE MODEL - Manual (custom methods not compatible with @freezed)
// ============================================================================

/// Plants State model for Riverpod state management
/// Refactored to single source of truth - only stores allPlants
/// filteredPlants and searchResults are computed from allPlants + filter params
class PlantsState {
  /// Single source of truth - all plants loaded from repository
  final List<Plant> allPlants;
  final Plant? selectedPlant;
  final bool isLoading;
  final bool isSearching;
  final String? error;

  // Filter parameters (not duplicate state, just criteria)
  final String searchQuery;
  final ViewMode viewMode;
  final SortBy sortBy;
  final String? filterBySpace;

  const PlantsState({
    this.allPlants = const [],
    this.selectedPlant,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.viewMode = ViewMode.grid,
    this.sortBy = SortBy.newest,
    this.filterBySpace,
  });

  // Custom getters
  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  bool get isGroupedBySpaces => viewMode == ViewMode.groupedBySpaces;
  int get plantsCount => allPlants.length;

  /// Computed property - plants filtered by space
  /// No stored state, computed on-demand from allPlants + filterBySpace
  List<Plant> get filteredPlants {
    if (filterBySpace == null) {
      return List.from(allPlants);
    }
    return allPlants.where((plant) => plant.spaceId == filterBySpace).toList();
  }

  /// Computed property - search results (accent-insensitive)
  /// No stored state, computed on-demand from allPlants + searchQuery
  List<Plant> get searchResults {
    if (searchQuery.isEmpty) {
      return const [];
    }

    String norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp('[áàâãä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll(RegExp('[ç]'), 'c')
        .trim();

    final q = norm(searchQuery);
    return allPlants.where((plant) {
      final name = norm(plant.name);
      final species = norm(plant.species ?? '');
      final notes = norm(plant.notes ?? '');
      return name.contains(q) || species.contains(q) || notes.contains(q);
    }).toList();
  }

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup = searchQuery.isNotEmpty
        ? searchResults
        : filteredPlants;
    final Map<String?, List<Plant>> groupedPlants = {};

    for (final plant in plantsToGroup) {
      final spaceId = plant.spaceId;
      if (!groupedPlants.containsKey(spaceId)) {
        groupedPlants[spaceId] = [];
      }
      groupedPlants[spaceId]!.add(plant);
    }

    return groupedPlants;
  }

  /// Gets the count of plants in each space
  Map<String?, int> get plantCountsBySpace {
    final grouped = plantsGroupedBySpaces;
    return grouped.map((spaceId, plants) => MapEntry(spaceId, plants.length));
  }

  List<Plant> getPlantsNeedingWater() {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return allPlants.where((plant) {
      final config = plant.config;
      if (config == null) return false;
      if (config.enableWateringCare == true &&
          config.wateringIntervalDays != null) {
        final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
        final nextWatering = lastWatering.add(
          Duration(days: config.wateringIntervalDays!),
        );

        return nextWatering.isBefore(threshold) ||
            nextWatering.isAtSameMomentAs(threshold);
      }
      if (config.wateringIntervalDays != null) {
        final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
        final nextWatering = lastWatering.add(
          Duration(days: config.wateringIntervalDays!),
        );

        return nextWatering.isBefore(threshold) ||
            nextWatering.isAtSameMomentAs(threshold);
      }

      return false;
    }).toList();
  }

  List<Plant> getPlantsNeedingFertilizer() {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return allPlants.where((plant) {
      final config = plant.config;
      if (config == null) return false;
      if (config.enableFertilizerCare == true &&
          config.fertilizingIntervalDays != null) {
        final lastFertilizer =
            config.lastFertilizerDate ?? plant.createdAt ?? now;
        final nextFertilizer = lastFertilizer.add(
          Duration(days: config.fertilizingIntervalDays!),
        );

        return nextFertilizer.isBefore(threshold) ||
            nextFertilizer.isAtSameMomentAs(threshold);
      }
      if (config.fertilizingIntervalDays != null) {
        final lastFertilizer = plant.updatedAt ?? plant.createdAt ?? now;
        final nextFertilizer = lastFertilizer.add(
          Duration(days: config.fertilizingIntervalDays!),
        );

        return nextFertilizer.isBefore(threshold) ||
            nextFertilizer.isAtSameMomentAs(threshold);
      }

      return false;
    }).toList();
  }

  List<Plant> getPlantsByCareStatus(CareStatus status) {
    final now = DateTime.now();

    return allPlants.where((plant) {
      final config = plant.config;
      if (config == null) {
        return status == CareStatus.unknown;
      }

      switch (status) {
        case CareStatus.needsWater:
          return _checkWaterStatus(plant, now, 0);
        case CareStatus.soonWater:
          return _checkWaterStatus(plant, now, 2);
        case CareStatus.needsFertilizer:
          return _checkFertilizerStatus(plant, now, 0);
        case CareStatus.soonFertilizer:
          return _checkFertilizerStatus(plant, now, 2);
        case CareStatus.good:
          return _isPlantInGoodCondition(plant, now);
        case CareStatus.unknown:
          return config.wateringIntervalDays == null &&
              config.fertilizingIntervalDays == null;
      }
    }).toList();
  }

  bool _checkWaterStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;
    if (config.enableWateringCare == true &&
        config.wateringIntervalDays != null) {
      final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: config.wateringIntervalDays!),
      );
      final daysDifference = nextWatering.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }
    if (config.wateringIntervalDays != null) {
      final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: config.wateringIntervalDays!),
      );
      final daysDifference = nextWatering.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    return false;
  }

  bool _checkFertilizerStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;
    if (config.enableFertilizerCare == true &&
        config.fertilizingIntervalDays != null) {
      final lastFertilizer =
          config.lastFertilizerDate ?? plant.createdAt ?? now;
      final nextFertilizer = lastFertilizer.add(
        Duration(days: config.fertilizingIntervalDays!),
      );
      final daysDifference = nextFertilizer.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }
    if (config.fertilizingIntervalDays != null) {
      final lastFertilizer = plant.updatedAt ?? plant.createdAt ?? now;
      final nextFertilizer = lastFertilizer.add(
        Duration(days: config.fertilizingIntervalDays!),
      );
      final daysDifference = nextFertilizer.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    return false;
  }

  bool _isPlantInGoodCondition(Plant plant, DateTime now) {
    final waterGood =
        !_checkWaterStatus(plant, now, 0) && !_checkWaterStatus(plant, now, 2);
    final fertilizerGood =
        !_checkFertilizerStatus(plant, now, 0) &&
        !_checkFertilizerStatus(plant, now, 2);

    final config = plant.config;
    final hasWaterCare =
        config?.enableWateringCare == true ||
        config?.wateringIntervalDays != null;
    final hasFertilizerCare =
        config?.enableFertilizerCare == true ||
        config?.fertilizingIntervalDays != null;
    return (hasWaterCare ? waterGood : true) &&
        (hasFertilizerCare ? fertilizerGood : true);
  }

  List<Plant> getPlantsBySpace(String spaceId) {
    return allPlants.where((plant) => plant.spaceId == spaceId).toList();
  }

  PlantsState copyWith({
    List<Plant>? allPlants,
    Plant? selectedPlant,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? searchQuery,
    ViewMode? viewMode,
    SortBy? sortBy,
    String? filterBySpace,
  }) {
    return PlantsState(
      allPlants: allPlants ?? this.allPlants,
      selectedPlant: selectedPlant ?? this.selectedPlant,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: filterBySpace ?? this.filterBySpace,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantsState &&
          runtimeType == other.runtimeType &&
          allPlants == other.allPlants &&
          selectedPlant == other.selectedPlant &&
          isLoading == other.isLoading &&
          isSearching == other.isSearching &&
          error == other.error &&
          searchQuery == other.searchQuery &&
          viewMode == other.viewMode &&
          sortBy == other.sortBy &&
          filterBySpace == other.filterBySpace;

  @override
  int get hashCode =>
      allPlants.hashCode ^
      selectedPlant.hashCode ^
      isLoading.hashCode ^
      isSearching.hashCode ^
      error.hashCode ^
      searchQuery.hashCode ^
      viewMode.hashCode ^
      sortBy.hashCode ^
      filterBySpace.hashCode;
}

// ============================================================================
// ENUMS
// ============================================================================

enum ViewMode {
  grid,
  list,
  groupedBySpaces,
  groupedBySpacesGrid,
  groupedBySpacesList,
}

enum SortBy { newest, oldest, name, species }

enum CareStatus {
  needsWater,
  soonWater,
  needsFertilizer,
  soonFertilizer,
  good,
  unknown,
}

// ============================================================================
// USE CASE PROVIDERS (Delegated to feature providers)
// ============================================================================

// UseCases are now provided by plants_providers.dart in features/plants

// ============================================================================
// SPECIALIZED SERVICES PROVIDERS (SOLID pattern)
// ============================================================================

@riverpod
IAuthStateProvider authStateProvider(Ref ref) {
  return AuthStateProviderAdapter.instance();
}

@riverpod
PlantsDataService plantsDataService(Ref ref) {
  return PlantsDataService(
    authProvider: ref.watch(authStateProviderProvider),
    getPlantsUseCase: ref.watch(getPlantsUseCaseProvider),
    addPlantUseCase: ref.watch(addPlantUseCaseProvider),
    updatePlantUseCase: ref.watch(updatePlantUseCaseProvider),
    deletePlantUseCase: ref.watch(deletePlantUseCaseProvider),
  );
}

@riverpod
PlantsFilterService plantsFilterService(Ref ref) {
  return PlantsFilterService();
}

@riverpod
PlantsCareCalculator plantsCareCalculator(Ref ref) {
  return PlantsCareCalculator();
}

// ============================================================================
// MAIN PLANTS NOTIFIER - @riverpod AsyncNotifier
// ============================================================================

/// Plants Notifier that handles all plant operations with real-time sync
@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  late final GetPlantsUseCase _getPlantsUseCase;
  late final GetPlantByIdUseCase _getPlantByIdUseCase;
  late final SearchPlantsUseCase _searchPlantsUseCase;
  late final AddPlantUseCase _addPlantUseCase;
  late final UpdatePlantUseCase _updatePlantUseCase;
  late final DeletePlantUseCase _deletePlantUseCase;
  late final AuthStateNotifier _authStateNotifier;
  StreamSubscription<UserEntity?>? _authSubscription;
  StreamSubscription<List<dynamic>>? _realtimeDataSubscription;

  @override
  Future<PlantsState> build() async {
    // Initialize use cases
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _getPlantByIdUseCase = ref.read(getPlantByIdUseCaseProvider);
    _searchPlantsUseCase = ref.read(searchPlantsUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);
    _deletePlantUseCase = ref.read(deletePlantUseCaseProvider);
    _authStateNotifier = AuthStateNotifier.instance;

    // Setup listeners
    _initializeAuthListener();
    _initializeRealtimeDataStream();

    // Cleanup on dispose
    ref.onDispose(() {
      _authSubscription?.cancel();
      _realtimeDataSubscription?.cancel();
    });

    // Load initial data if authenticated
    if (_authStateNotifier.isInitialized &&
        _authStateNotifier.currentUser != null) {
      final result = await _getPlantsUseCase.call(const NoParams());
      return result.fold((failure) => PlantsState(error: failure.message), (
        plants,
      ) {
        final sortedPlants = _sortPlants(plants, SortBy.newest);
        return PlantsState(
          allPlants: sortedPlants,
          // filteredPlants computed automatically via getter
        );
      });
    }

    return const PlantsState();
  }

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      if (_authStateNotifier.isInitialized && user != null) {
        loadInitialData();
      } else if (_authStateNotifier.isInitialized && user == null) {
        final currentState = state.value ?? const PlantsState();
        state = AsyncData(
          currentState.copyWith(
            allPlants: [],
            selectedPlant: null,
            error: null,
          ),
        );
      }
    });
  }

  /// Initializes the real-time data stream from UnifiedSyncManager
  void _initializeRealtimeDataStream() {
    try {
      final dataStream = UnifiedSyncManager.instance.streamAll('plantis');

      if (dataStream != null) {
        _realtimeDataSubscription = dataStream.listen(
          (List<dynamic> plants) {
            final domainPlants = plants
                .map((syncPlant) => _convertSyncPlantToDomain(syncPlant))
                .where((plant) => plant != null)
                .cast<Plant>()
                .toList();
            if (_hasDataChanged(domainPlants)) {
              final currentState = state.value ?? const PlantsState();
              final sortedPlants = _sortPlants(
                domainPlants,
                currentState.sortBy,
              );

              state = AsyncData(
                currentState.copyWith(
                  allPlants: sortedPlants,
                  // filteredPlants computed automatically from allPlants + filterBySpace
                ),
              );
            }
          },
          onError: (dynamic error) {
            if (kDebugMode) {
              debugPrint('PlantsProvider stream error: $error');
            }
          },
        );
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          loadInitialData();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PlantsProvider stream initialization error: $e');
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        loadInitialData();
      });
    }
  }

  /// Converts sync entity to domain entity
  Plant? _convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      if (syncPlant is Plant) {
        return syncPlant;
      }
      if (syncPlant is BaseSyncEntity) {
        return Plant.fromJson(syncPlant.toFirebaseMap());
      }
      if (syncPlant is Map<String, dynamic>) {
        return Plant.fromJson(syncPlant);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error converting plant: $e');
      }
      return null;
    }
  }

  /// Checks if data really changed to avoid unnecessary rebuilds
  bool _hasDataChanged(List<Plant> newPlants) {
    final currentState = state.value ?? const PlantsState();
    if (currentState.allPlants.length != newPlants.length) {
      return true;
    }
    for (int i = 0; i < currentState.allPlants.length; i++) {
      final currentPlant = currentState.allPlants[i];
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

    debugPrint('⏳ PlantsProvider: Waiting for auth initialization...');

    try {
      await _authStateNotifier.initializedStream
          .where((isInitialized) => isInitialized)
          .timeout(timeout)
          .first;

      debugPrint('✅ PlantsProvider: Auth initialization complete');
      return true;
    } on TimeoutException {
      debugPrint(
        '⚠️ PlantsProvider: Auth initialization timeout after ${timeout.inSeconds}s',
      );
      return false;
    } catch (e) {
      debugPrint('❌ PlantsProvider: Auth initialization error: $e');
      return false;
    }
  }

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  Future<void> loadPlants() async {
    if (kDebugMode) {
      debugPrint(
        '📋 PlantsProvider.loadPlants() - Iniciando carregamento offline-first',
      );
    }
    if (!await _waitForAuthenticationWithTimeout()) {
      final currentState = state.value ?? const PlantsState();
      state = AsyncData(
        currentState.copyWith(error: 'Aguardando autenticação...'),
      );
      return;
    }
    await _loadData();
  }

  /// Loads data (local + remote sync if connected)
  Future<void> _loadData() async {
    try {
      if (kDebugMode) {
        debugPrint('📦 PlantsProvider: Carregando dados...');
      }

      final currentState = state.value ?? const PlantsState();
      final shouldShowLoading = currentState.allPlants.isEmpty;
      if (shouldShowLoading) {
        state = AsyncData(currentState.copyWith(isLoading: true, error: null));
      }
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsProvider: Falha ao carregar dados: ${_getErrorMessage(failure)}',
            );
          }
          final currentState = state.value ?? const PlantsState();
          state = AsyncData(
            currentState.copyWith(
              isLoading: false,
              allPlants: [],
              error: _getErrorMessage(failure),
            ),
          );
        },
        (plants) {
          if (kDebugMode) {
            debugPrint(
              '✅ PlantsProvider: Dados carregados: ${plants.length} plantas',
            );
          }
          _updatePlantsData(plants);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsProvider: Erro ao carregar dados: $e');
      }
      final currentState = state.value ?? const PlantsState();
      state = AsyncData(
        currentState.copyWith(
          isLoading: false,
          allPlants: [],
          error: e.toString(),
        ),
      );
    }
  }

  /// Updates plants data and notifies listeners
  void _updatePlantsData(List<Plant> plants) {
    final currentState = state.value ?? const PlantsState();
    final sortedPlants = _sortPlants(plants, currentState.sortBy);

    if (kDebugMode) {
      debugPrint('🔄 PlantsProvider._updatePlantsData:');
      debugPrint('  - Input plants: ${plants.length}');
      debugPrint('  - Sorted plants: ${sortedPlants.length}');
      debugPrint('  - Current filterBySpace: ${currentState.filterBySpace}');
      debugPrint('  - Current searchQuery: "${currentState.searchQuery}"');
    }

    state = AsyncData(
      currentState.copyWith(
        allPlants: sortedPlants,
        isLoading: false,
        error: null,
      ),
    );

    if (kDebugMode) {
      debugPrint(
        '✅ PlantsProvider: UI atualizada com ${sortedPlants.length} plantas',
      );
      // filteredPlants will be computed automatically via getter
      for (final plant in plants) {
        debugPrint('   - ${plant.name} (${plant.id})');
      }
    }
  }

  Future<Plant?> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.value ?? const PlantsState();
        state = AsyncData(
          currentState.copyWith(error: _getErrorMessage(failure)),
        );
        return null;
      },
      (plant) {
        final currentState = state.value ?? const PlantsState();
        state = AsyncData(currentState.copyWith(selectedPlant: plant));
        return plant;
      },
    );
  }

  Future<void> searchPlants(String query) async {
    final currentState = state.value ?? const PlantsState();

    if (query.trim().isEmpty) {
      state = AsyncData(
        currentState.copyWith(isSearching: false, searchQuery: ''),
      );
      return;
    }

    // Prefer local in-memory filtering when we already have plants loaded.
    // searchResults is now computed automatically from allPlants + searchQuery
    // via the getter, so we just need to set the searchQuery
    if (currentState.allPlants.isNotEmpty) {
      state = AsyncData(
        currentState.copyWith(isSearching: true, searchQuery: query),
      );

      // Simulate async search completion
      final newState = state.value ?? const PlantsState();
      state = AsyncData(newState.copyWith(isSearching: false));
      return;
    }

    // Fallback: no local data yet, use the search use case (may query remote)
    state = AsyncData(
      currentState.copyWith(isSearching: true, searchQuery: query),
    );

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold(
      (failure) {
        final newState = state.value ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(
            error: _getErrorMessage(failure),
            isSearching: false,
          ),
        );
      },
      (results) {
        // Load results into allPlants so they can be filtered/searched
        final newState = state.value ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(
            allPlants: _sortPlants(results, newState.sortBy),
            isSearching: false,
          ),
        );
      },
    );
  }

  Future<bool> addPlant(AddPlantParams params) async {
    final currentState = state.value ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    final result = await _addPlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.value ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (plant) {
        final newState = state.value ?? const PlantsState();
        final updatedPlants = [plant, ...newState.allPlants];

        state = AsyncData(
          newState.copyWith(
            allPlants: updatedPlants,
            isLoading: false,
            error: null,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updatePlant(UpdatePlantParams params) async {
    final currentState = state.value ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    final result = await _updatePlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.value ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (updatedPlant) {
        final newState = state.value ?? const PlantsState();
        final updatedPlants = newState.allPlants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        final sortedPlants = _sortPlants(updatedPlants, newState.sortBy);

        state = AsyncData(
          newState.copyWith(
            allPlants: sortedPlants,
            selectedPlant: newState.selectedPlant?.id == updatedPlant.id
                ? updatedPlant
                : newState.selectedPlant,
            isLoading: false,
            error: null,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deletePlant(String id) async {
    final currentState = state.value ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    final result = await _deletePlantUseCase.call(id);

    return result.fold(
      (failure) {
        final newState = state.value ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (_) {
        final newState = state.value ?? const PlantsState();
        final updatedPlants = newState.allPlants
            .where((plant) => plant.id != id)
            .toList();

        state = AsyncData(
          newState.copyWith(
            allPlants: updatedPlants,
            selectedPlant: newState.selectedPlant?.id == id
                ? null
                : newState.selectedPlant,
            isLoading: false,
            error: null,
          ),
        );
        return true;
      },
    );
  }

  void setViewMode(ViewMode mode) {
    final currentState = state.value ?? const PlantsState();
    if (currentState.viewMode != mode) {
      state = AsyncData(currentState.copyWith(viewMode: mode));
    }
  }

  void setSortBy(SortBy sort) {
    final currentState = state.value ?? const PlantsState();
    if (currentState.sortBy != sort) {
      final sortedPlants = _sortPlants(currentState.allPlants, sort);

      state = AsyncData(
        currentState.copyWith(allPlants: sortedPlants, sortBy: sort),
      );
    }
  }

  void setSpaceFilter(String? spaceId) {
    final currentState = state.value ?? const PlantsState();
    if (currentState.filterBySpace != spaceId) {
      state = AsyncData(
        currentState.copyWith(
          filterBySpace: spaceId,
          // filteredPlants computed automatically from allPlants + filterBySpace
        ),
      );
    }
  }

  void clearSearch() {
    final currentState = state.value ?? const PlantsState();
    if (currentState.searchQuery.isNotEmpty || currentState.isSearching) {
      if (kDebugMode) {
        debugPrint('🧹 PlantsProvider.clearSearch():');
        debugPrint('  - Clearing searchQuery: "${currentState.searchQuery}"');
        debugPrint('  - Current allPlants: ${currentState.allPlants.length}');
      }

      // If there are no local plants but we have searchResults (user searched
      // and results were returned), copy those results to allPlants
      // so the UI keeps displaying them while we attempt to load local data.
      if (currentState.allPlants.isEmpty &&
          currentState.searchResults.isNotEmpty) {
        // Promote searchResults into allPlants so the UI shows them as the
        // canonical in-memory collection. We'll still trigger a background
        // load to refresh/replace local data when available.
        state = AsyncData(
          currentState.copyWith(
            searchQuery: '',
            allPlants: currentState.searchResults,
            isSearching: false,
          ),
        );

        // fire-and-forget - loadInitialData will replace allPlants when done
        loadInitialData();
      } else {
        state = AsyncData(
          currentState.copyWith(searchQuery: '', isSearching: false),
        );

        if (kDebugMode) {
          debugPrint('✅ PlantsProvider.clearSearch() - searchQuery cleared');
        }
      }
    }
  }

  void toggleGroupedView() {
    final currentState = state.value ?? const PlantsState();
    ViewMode newMode;
    if (currentState.viewMode == ViewMode.groupedBySpaces) {
      newMode = ViewMode.list; // Return to normal list
    } else {
      newMode = ViewMode.groupedBySpaces; // Change to grouped
    }
    state = AsyncData(currentState.copyWith(viewMode: newMode));
  }

  void clearSelectedPlant() {
    final currentState = state.value ?? const PlantsState();
    if (currentState.selectedPlant != null) {
      state = AsyncData(currentState.copyWith(selectedPlant: null));
    }
  }

  void clearError() {
    final currentState = state.value ?? const PlantsState();
    if (currentState.hasError) {
      state = AsyncData(currentState.copyWith(error: null));
    }
  }

  Future<void> loadInitialData() async {
    await loadPlants();
  }

  Future<void> refreshPlants() async {
    if (kDebugMode) {
      debugPrint('🔄 PlantsProvider.refreshPlants() - Iniciando refresh');
      final currentState = state.value ?? const PlantsState();
      debugPrint(
        '🔄 PlantsProvider.refreshPlants() - Plantas antes: ${currentState.allPlants.length}',
      );
    }

    clearError();
    await loadInitialData();

    if (kDebugMode) {
      debugPrint('✅ PlantsProvider.refreshPlants() - Refresh completo');
      final currentState = state.value ?? const PlantsState();
      debugPrint(
        '🔄 PlantsProvider.refreshPlants() - Plantas depois: ${currentState.allPlants.length}',
      );
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  List<Plant> _sortPlants(List<Plant> plants, SortBy sortBy) {
    final sortedPlants = List<Plant>.from(plants);

    switch (sortBy) {
      case SortBy.newest:
        sortedPlants.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
        break;
      case SortBy.oldest:
        sortedPlants.sort(
          (a, b) => (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          ),
        );
        break;
      case SortBy.name:
        sortedPlants.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortBy.species:
        sortedPlants.sort(
          (a, b) => (a.species ?? '').compareTo(b.species ?? ''),
        );
        break;
    }

    return sortedPlants;
  }

  // _applyFilters removed - filteredPlants now computed via getter from allPlants + filterBySpace

  String _getErrorMessage(Failure failure) {
    if (kDebugMode) {
      debugPrint('PlantsProvider Error Details:');
      debugPrint('- Type: ${failure.runtimeType}');
      debugPrint('- Message: ${failure.message}');
      debugPrint('- Stack trace: ${StackTrace.current}');
    }

    switch (failure.runtimeType) {
      case ValidationFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Dados inválidos fornecidos';
      case CacheFailure _:
        if (failure.message.contains('PlantaModelAdapter') ||
            failure.message.contains('TypeAdapter')) {
          return 'Erro ao acessar dados locais. O app será reiniciado para corrigir o problema.';
        }
        if (failure.message.contains('DatabaseError') ||
            failure.message.contains('corrupted')) {
          return 'Dados locais corrompidos. Sincronizando com servidor...';
        }
        return failure.message.isNotEmpty
            ? 'Cache: ${failure.message}'
            : 'Erro ao acessar dados locais';
      case NetworkFailure _:
        return 'Sem conexão com a internet. Verifique sua conectividade.';
      case ServerFailure _:
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Sessão expirada. Tente fazer login novamente.';
        }
        if (failure.message.contains('403') ||
            failure.message.contains('Forbidden')) {
          return 'Acesso negado. Verifique suas permissões.';
        }
        if (failure.message.contains('500') ||
            failure.message.contains('Internal')) {
          return 'Erro no servidor. Tente novamente em alguns instantes.';
        }
        return failure.message.isNotEmpty
            ? 'Servidor: ${failure.message}'
            : 'Erro no servidor';
      case NotFoundFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Dados não encontrados';
      default:
        final errorContext = kDebugMode
            ? ' (${failure.runtimeType}: ${failure.message})'
            : '';
        return 'Ops! Algo deu errado$errorContext';
    }
  }
}

// ============================================================================
// DERIVED PROVIDERS - Convenience accessors
// ============================================================================

@riverpod
List<Plant> allPlants(Ref ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);
  return plantsAsync.maybeWhen(
    data: (state) => state.allPlants,
    orElse: () => [],
  );
}

@riverpod
List<Plant> filteredPlants(Ref ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);
  return plantsAsync.maybeWhen(
    data: (state) => state.filteredPlants,
    orElse: () => [],
  );
}

@riverpod
bool plantsIsLoading(Ref ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);
  return plantsAsync.maybeWhen(
    data: (state) => state.isLoading,
    loading: () => true,
    orElse: () => false,
  );
}

@riverpod
String? plantsError(Ref ref) {
  final plantsAsync = ref.watch(plantsNotifierProvider);
  return plantsAsync.maybeWhen(
    data: (state) => state.error,
    error: (error, _) => error.toString(),
    orElse: () => null,
  );
}

/// Alias for backwards compatibility with legacy code
/// Use plantsProvider instead in new code

// ============================================================================
// LEGACY PROVIDER ALIASES - For backward compatibility
// ============================================================================
// ignore: deprecated_member_use_from_same_package
const plantsNotifierProvider = plantsProvider;
