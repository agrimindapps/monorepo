import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../auth/auth_state_notifier.dart';
import '../data/adapters/auth_state_provider_adapter.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';
import 'state/plants_state_manager.dart' hide ViewMode;

/// Plants State model for Riverpod state management
class PlantsState {
  final List<Plant> allPlants;
  final List<Plant> filteredPlants;
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
    this.allPlants = const [],
    this.filteredPlants = const [],
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
  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  bool get isGroupedBySpaces => viewMode == ViewMode.groupedBySpaces;
  int get plantsCount => allPlants.length;

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup =
        searchQuery.isNotEmpty ? searchResults : filteredPlants;
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
    List<Plant>? filteredPlants,
    Plant? selectedPlant,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? searchQuery,
    List<Plant>? searchResults,
    ViewMode? viewMode,
    SortBy? sortBy,
    String? filterBySpace,
    bool clearError = false,
    bool clearSelectedPlant = false,
  }) {
    final newAllPlants = allPlants ?? this.allPlants;
    final newSearchQuery = searchQuery ?? this.searchQuery;
    final newFilterBySpace = filterBySpace ?? this.filterBySpace;

    // Se filteredPlants não foi fornecido explicitamente e não há filtros ativos,
    // então filteredPlants deve ser igual a allPlants
    final newFilteredPlants = filteredPlants ??
        (allPlants != null && newSearchQuery.isEmpty && newFilterBySpace == null
            ? newAllPlants
            : this.filteredPlants);

    return PlantsState(
      allPlants: newAllPlants,
      filteredPlants: newFilteredPlants,
      selectedPlant:
          clearSelectedPlant ? null : (selectedPlant ?? this.selectedPlant),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      searchQuery: newSearchQuery,
      searchResults: searchResults ?? this.searchResults,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: newFilterBySpace,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantsState &&
          runtimeType == other.runtimeType &&
          allPlants == other.allPlants &&
          filteredPlants == other.filteredPlants &&
          selectedPlant == other.selectedPlant &&
          isLoading == other.isLoading &&
          isSearching == other.isSearching &&
          error == other.error &&
          searchQuery == other.searchQuery &&
          searchResults == other.searchResults &&
          viewMode == other.viewMode &&
          sortBy == other.sortBy &&
          filterBySpace == other.filterBySpace;

  @override
  int get hashCode =>
      allPlants.hashCode ^
      filteredPlants.hashCode ^
      selectedPlant.hashCode ^
      isLoading.hashCode ^
      isSearching.hashCode ^
      error.hashCode ^
      searchQuery.hashCode ^
      searchResults.hashCode ^
      viewMode.hashCode ^
      sortBy.hashCode ^
      filterBySpace.hashCode;
}

/// Plants Notifier that handles all plant operations with real-time sync
class PlantsNotifier extends AsyncNotifier<PlantsState> {
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
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _getPlantByIdUseCase = ref.read(getPlantByIdUseCaseProvider);
    _searchPlantsUseCase = ref.read(searchPlantsUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);
    _deletePlantUseCase = ref.read(deletePlantUseCaseProvider);
    _authStateNotifier = AuthStateNotifier.instance;
    _initializeAuthListener();
    _initializeRealtimeDataStream();
    ref.onDispose(() {
      _authSubscription?.cancel();
      _realtimeDataSubscription?.cancel();
    });
    if (_authStateNotifier.isInitialized &&
        _authStateNotifier.currentUser != null) {
      final result = await _getPlantsUseCase.call(const NoParams());
      return result.fold((failure) => PlantsState(error: failure.message), (
        plants,
      ) {
        final sortedPlants = _sortPlants(plants, SortBy.newest);
        return PlantsState(
          allPlants: sortedPlants,
          filteredPlants: sortedPlants,
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
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          currentState.copyWith(
            allPlants: [],
            filteredPlants: [],
            clearSelectedPlant: true,
            clearError: true,
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
            final domainPlants =
                plants
                    .map((syncPlant) => _convertSyncPlantToDomain(syncPlant))
                    .where((plant) => plant != null)
                    .cast<Plant>()
                    .toList();
            if (_hasDataChanged(domainPlants)) {
              final currentState = state.valueOrNull ?? const PlantsState();
              final sortedPlants = _sortPlants(
                domainPlants,
                currentState.sortBy,
              );
              final filteredPlants = _applyFilters(
                sortedPlants,
                currentState.filterBySpace,
                currentState.searchQuery,
              );

              state = AsyncData(
                currentState.copyWith(
                  allPlants: sortedPlants,
                  filteredPlants: filteredPlants,
                ),
              );
            }
          },
          onError: (dynamic error) {
            if (kDebugMode) {
              print('PlantsProvider stream error: $error');
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
        print('PlantsProvider stream initialization error: $e');
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
        print('Error converting plant: $e');
      }
      return null;
    }
  }

  /// Checks if data really changed to avoid unnecessary rebuilds
  bool _hasDataChanged(List<Plant> newPlants) {
    final currentState = state.valueOrNull ?? const PlantsState();
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

  Future<void> loadPlants() async {
    if (kDebugMode) {
      print(
        '📋 PlantsProvider.loadPlants() - Iniciando carregamento offline-first',
      );
    }
    if (!await _waitForAuthenticationWithTimeout()) {
      final currentState = state.valueOrNull ?? const PlantsState();
      state = AsyncData(
        currentState.copyWith(error: 'Aguardando autenticação...'),
      );
      return;
    }
    await _loadLocalDataFirst();
    _syncInBackground();
  }

  /// Loads local data immediately for instant UI response
  Future<void> _loadLocalDataFirst() async {
    try {
      if (kDebugMode) {
        print('📦 PlantsProvider: Carregando dados locais primeiro...');
      }

      final currentState = state.valueOrNull ?? const PlantsState();
      final shouldShowLoading = currentState.allPlants.isEmpty;
      if (shouldShowLoading) {
        state = AsyncData(
          currentState.copyWith(isLoading: true, clearError: true),
        );
      }
      final localResult = await _getPlantsUseCase.call(const NoParams());

      localResult.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '⚠️ PlantsProvider: Dados locais não disponíveis: ${_getErrorMessage(failure)}',
            );
          }
          // Se falhar ao carregar dados locais, desativa loading e mostra lista vazia
          // O sync em background tentará buscar dados remotos
          final currentState = state.valueOrNull ?? const PlantsState();
          state = AsyncData(
            currentState.copyWith(
              isLoading: false,
              allPlants: [],
              filteredPlants: [],
            ),
          );
        },
        (plants) {
          if (kDebugMode) {
            print(
              '✅ PlantsProvider: Dados locais carregados: ${plants.length} plantas',
            );
          }
          _updatePlantsData(plants);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsProvider: Erro ao carregar dados locais: $e');
      }
      // Em caso de exceção, desativa loading e mostra lista vazia
      final currentState = state.valueOrNull ?? const PlantsState();
      state = AsyncData(
        currentState.copyWith(
          isLoading: false,
          allPlants: [],
          filteredPlants: [],
        ),
      );
    }
  }

  /// Syncs with remote data in background without blocking UI
  void _syncInBackground() {
    if (kDebugMode) {
      print('🔄 PlantsProvider: Iniciando sync em background...');
    }
    Future.delayed(const Duration(milliseconds: 100), () async {
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          if (kDebugMode) {
            print(
              '❌ PlantsProvider: Background sync falhou: ${_getErrorMessage(failure)}',
            );
          }
          final currentState = state.valueOrNull ?? const PlantsState();
          if (currentState.allPlants.isEmpty) {
            state = AsyncData(
              currentState.copyWith(error: _getErrorMessage(failure)),
            );
          }
        },
        (plants) {
          if (kDebugMode) {
            print(
              '✅ PlantsProvider: Background sync bem-sucedido: ${plants.length} plantas',
            );
          }
          _updatePlantsData(plants);
        },
      );
    });
  }

  /// Updates plants data and notifies listeners
  void _updatePlantsData(List<Plant> plants) {
    final currentState = state.valueOrNull ?? const PlantsState();
    final sortedPlants = _sortPlants(plants, currentState.sortBy);
    final filteredPlants = _applyFilters(
      sortedPlants,
      currentState.filterBySpace,
      currentState.searchQuery,
    );

    if (kDebugMode) {
      print('🔄 PlantsProvider._updatePlantsData:');
      print('  - Input plants: ${plants.length}');
      print('  - Sorted plants: ${sortedPlants.length}');
      print('  - Filtered plants: ${filteredPlants.length}');
      print('  - Current filterBySpace: ${currentState.filterBySpace}');
      print('  - Current searchQuery: "${currentState.searchQuery}"');
    }

    state = AsyncData(
      currentState.copyWith(
        allPlants: sortedPlants,
        filteredPlants: filteredPlants,
        isLoading: false,
        clearError: true,
      ),
    );

    if (kDebugMode) {
      print(
        '✅ PlantsProvider: UI atualizada com ${sortedPlants.length} plantas',
      );
      for (final plant in plants) {
        print('   - ${plant.name} (${plant.id})');
      }
    }
  }

  Future<Plant?> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          currentState.copyWith(error: _getErrorMessage(failure)),
        );
        return null;
      },
      (plant) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(currentState.copyWith(selectedPlant: plant));
        return plant;
      },
    );
  }

  Future<void> searchPlants(String query) async {
    final currentState = state.valueOrNull ?? const PlantsState();

    if (query.trim().isEmpty) {
      state = AsyncData(
        currentState.copyWith(
          searchResults: [],
          isSearching: false,
          searchQuery: '',
        ),
      );
      return;
    }

    // Prefer local in-memory filtering when we already have plants loaded.
    // This avoids hitting the search use case (which may query Hive/remote)
    // on every keypress and matches the expected UX: keep all records in
    // memory and filter locally.
    if (currentState.allPlants.isNotEmpty) {
      state = AsyncData(
        currentState.copyWith(isSearching: true, searchQuery: query),
      );
      final lower = query.toLowerCase();
      final localResults =
          currentState.allPlants.where((p) {
            final name = p.name.toLowerCase();
            final species = (p.species ?? '').toLowerCase();
            // Match by name or species; adjust as needed (notes, tags, etc.)
            return name.contains(lower) || species.contains(lower);
          }).toList();

      final newState = state.valueOrNull ?? const PlantsState();
      final sortedResults = _sortPlants(localResults, newState.sortBy);
      state = AsyncData(
        newState.copyWith(searchResults: sortedResults, isSearching: false),
      );
      return;
    }

    // Fallback: no local data yet, use the search use case (may query remote)
    state = AsyncData(
      currentState.copyWith(isSearching: true, searchQuery: query),
    );

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(
            error: _getErrorMessage(failure),
            isSearching: false,
          ),
        );
      },
      (results) {
        final newState = state.valueOrNull ?? const PlantsState();
        final sortedResults = _sortPlants(results, newState.sortBy);
        state = AsyncData(
          newState.copyWith(searchResults: sortedResults, isSearching: false),
        );
      },
    );
  }

  Future<bool> addPlant(AddPlantParams params) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _addPlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (plant) {
        final newState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = [plant, ...newState.allPlants];
        final filteredPlants = _applyFilters(
          updatedPlants,
          newState.filterBySpace,
          newState.searchQuery,
        );

        state = AsyncData(
          newState.copyWith(
            allPlants: updatedPlants,
            filteredPlants: filteredPlants,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updatePlant(UpdatePlantParams params) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _updatePlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (updatedPlant) {
        final newState = state.valueOrNull ?? const PlantsState();
        final updatedPlants =
            newState.allPlants.map((p) {
              return p.id == updatedPlant.id ? updatedPlant : p;
            }).toList();

        final sortedPlants = _sortPlants(updatedPlants, newState.sortBy);
        final filteredPlants = _applyFilters(
          sortedPlants,
          newState.filterBySpace,
          newState.searchQuery,
        );

        state = AsyncData(
          newState.copyWith(
            allPlants: sortedPlants,
            filteredPlants: filteredPlants,
            selectedPlant:
                newState.selectedPlant?.id == updatedPlant.id
                    ? updatedPlant
                    : newState.selectedPlant,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deletePlant(String id) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(isLoading: true, clearError: true));

    final result = await _deletePlantUseCase.call(id);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(
          newState.copyWith(error: _getErrorMessage(failure), isLoading: false),
        );
        return false;
      },
      (_) {
        final newState = state.valueOrNull ?? const PlantsState();
        final updatedPlants =
            newState.allPlants.where((plant) => plant.id != id).toList();
        final updatedSearchResults =
            newState.searchResults.where((plant) => plant.id != id).toList();
        final filteredPlants = _applyFilters(
          updatedPlants,
          newState.filterBySpace,
          newState.searchQuery,
        );

        state = AsyncData(
          newState.copyWith(
            allPlants: updatedPlants,
            filteredPlants: filteredPlants,
            searchResults: updatedSearchResults,
            clearSelectedPlant: newState.selectedPlant?.id == id,
            isLoading: false,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  void setViewMode(ViewMode mode) {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.viewMode != mode) {
      state = AsyncData(currentState.copyWith(viewMode: mode));
    }
  }

  void setSortBy(SortBy sort) {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.sortBy != sort) {
      final sortedPlants = _sortPlants(currentState.allPlants, sort);
      final sortedSearchResults = _sortPlants(currentState.searchResults, sort);
      final filteredPlants = _applyFilters(
        sortedPlants,
        currentState.filterBySpace,
        currentState.searchQuery,
      );

      state = AsyncData(
        currentState.copyWith(
          allPlants: sortedPlants,
          filteredPlants: filteredPlants,
          searchResults: sortedSearchResults,
          sortBy: sort,
        ),
      );
    }
  }

  void setSpaceFilter(String? spaceId) {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.filterBySpace != spaceId) {
      final filteredPlants = _applyFilters(
        currentState.allPlants,
        spaceId,
        currentState.searchQuery,
      );

      state = AsyncData(
        currentState.copyWith(
          filterBySpace: spaceId,
          filteredPlants: filteredPlants,
        ),
      );
    }
  }

  void clearSearch() {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.searchQuery.isNotEmpty ||
        currentState.searchResults.isNotEmpty ||
        currentState.isSearching) {

      if (kDebugMode) {
        print('🧹 PlantsProvider.clearSearch():');
        print('  - Clearing searchQuery: "${currentState.searchQuery}"');
        print('  - Clearing searchResults: ${currentState.searchResults.length} plantas');
        print('  - Current allPlants: ${currentState.allPlants.length}');
      }

      // If there are no local plants but we have searchResults (user searched
      // and results were returned), copy those results to `filteredPlants`
      // so the UI keeps displaying them while we attempt to load local data.
      if (currentState.allPlants.isEmpty &&
          currentState.searchResults.isNotEmpty) {
        // Promote searchResults into allPlants so the UI shows them as the
        // canonical in-memory collection. We'll still trigger a background
        // load to refresh/replace local data when available.
        state = AsyncData(
          currentState.copyWith(
            searchQuery: '',
            searchResults: [],
            allPlants: currentState.searchResults,
            filteredPlants: currentState.searchResults,
            isSearching: false,
          ),
        );

        // fire-and-forget - loadInitialData will replace allPlants when done
        loadInitialData();
      } else {
        // Reaplica filtros para garantir que filteredPlants está sincronizado
        final filteredPlants = _applyFilters(
          currentState.allPlants,
          currentState.filterBySpace,
          '', // searchQuery vazio
        );

        state = AsyncData(
          currentState.copyWith(
            searchQuery: '',
            searchResults: [],
            filteredPlants: filteredPlants,
            isSearching: false,
          ),
        );

        if (kDebugMode) {
          print('✅ PlantsProvider.clearSearch() - filteredPlants atualizado: ${filteredPlants.length}');
        }
      }
    }
  }

  void toggleGroupedView() {
    final currentState = state.valueOrNull ?? const PlantsState();
    ViewMode newMode;
    if (currentState.viewMode == ViewMode.groupedBySpaces) {
      newMode = ViewMode.list; // Return to normal list
    } else {
      newMode = ViewMode.groupedBySpaces; // Change to grouped
    }
    state = AsyncData(currentState.copyWith(viewMode: newMode));
  }

  void clearSelectedPlant() {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.selectedPlant != null) {
      state = AsyncData(currentState.copyWith(clearSelectedPlant: true));
    }
  }

  void clearError() {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.hasError) {
      state = AsyncData(currentState.copyWith(clearError: true));
    }
  }

  Future<void> loadInitialData() async {
    await loadPlants();
  }

  Future<void> refreshPlants() async {
    if (kDebugMode) {
      print('🔄 PlantsProvider.refreshPlants() - Iniciando refresh');
      final currentState = state.valueOrNull ?? const PlantsState();
      print(
        '🔄 PlantsProvider.refreshPlants() - Plantas antes: ${currentState.allPlants.length}',
      );
    }

    clearError();
    await loadInitialData();

    if (kDebugMode) {
      print('✅ PlantsProvider.refreshPlants() - Refresh completo');
      final currentState = state.valueOrNull ?? const PlantsState();
      print(
        '🔄 PlantsProvider.refreshPlants() - Plantas depois: ${currentState.allPlants.length}',
      );
    }
  }

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

  List<Plant> _applyFilters(
    List<Plant> plants,
    String? filterBySpace,
    String searchQuery,
  ) {
    // Se não há filtros ativos, retorna a lista completa
    if (filterBySpace == null && searchQuery.isEmpty) {
      return List.from(plants);
    }

    List<Plant> filtered = List.from(plants);

    // Aplica filtro de espaço se ativo
    if (filterBySpace != null) {
      filtered =
          filtered.where((plant) => plant.spaceId == filterBySpace).toList();
    }

    // Nota: searchQuery é tratado separadamente em searchPlants()
    // e armazenado em searchResults, não em filteredPlants

    return filtered;
  }

  String _getErrorMessage(Failure failure) {
    if (kDebugMode) {
      print('PlantsProvider Error Details:');
      print('- Type: ${failure.runtimeType}');
      print('- Message: ${failure.message}');
      print('- Stack trace: ${StackTrace.current}');
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
        if (failure.message.contains('HiveError') ||
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
        final errorContext =
            kDebugMode ? ' (${failure.runtimeType}: ${failure.message})' : '';
        return 'Ops! Algo deu errado$errorContext';
    }
  }
}

/// Main Plants provider using standard Riverpod
final plantsProvider = AsyncNotifierProvider<PlantsNotifier, PlantsState>(() {
  return PlantsNotifier();
});
final allPlantsProvider = Provider<List<Plant>>((ref) {
  final plantsState = ref.watch(plantsProvider);
  return plantsState.maybeWhen(
    data: (PlantsState state) => state.allPlants,
    orElse: () => <Plant>[],
  );
});

final filteredPlantsProvider = Provider<List<Plant>>((ref) {
  final plantsState = ref.watch(plantsProvider);
  return plantsState.maybeWhen(
    data: (PlantsState state) => state.filteredPlants,
    orElse: () => <Plant>[],
  );
});

final plantsIsLoadingProvider = Provider<bool>((ref) {
  final plantsState = ref.watch(plantsProvider);
  return plantsState.maybeWhen(
    data: (PlantsState state) => state.isLoading,
    loading: () => true,
    orElse: () => false,
  );
});

final plantsErrorProvider = Provider<String?>((ref) {
  final plantsState = ref.watch(plantsProvider);
  return plantsState.maybeWhen(
    data: (PlantsState state) => state.error,
    error: (Object error, _) => error.toString(),
    orElse: () => null,
  );
});
final getPlantsUseCaseProvider = Provider<GetPlantsUseCase>((ref) {
  return GetIt.instance<GetPlantsUseCase>();
});

final getPlantByIdUseCaseProvider = Provider<GetPlantByIdUseCase>((ref) {
  return GetIt.instance<GetPlantByIdUseCase>();
});

final searchPlantsUseCaseProvider = Provider<SearchPlantsUseCase>((ref) {
  return GetIt.instance<SearchPlantsUseCase>();
});

final addPlantUseCaseProvider = Provider<AddPlantUseCase>((ref) {
  return GetIt.instance<AddPlantUseCase>();
});

final updatePlantUseCaseProvider = Provider<UpdatePlantUseCase>((ref) {
  return GetIt.instance<UpdatePlantUseCase>();
});

final deletePlantUseCaseProvider = Provider<DeletePlantUseCase>((ref) {
  return GetIt.instance<DeletePlantUseCase>();
});

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

/// Provider for AuthStateProvider interface
final authStateProvider = Provider<IAuthStateProvider>((ref) {
  return AuthStateProviderAdapter.instance();
});

/// Provider for PlantsDataService
final plantsDataServiceProvider = Provider<PlantsDataService>((ref) {
  return PlantsDataService.create(authProvider: ref.read(authStateProvider));
});

/// Provider for PlantsFilterService
final plantsFilterServiceProvider = Provider<PlantsFilterService>((ref) {
  return PlantsFilterService();
});

/// Provider for PlantsCareCalculator
final plantsCareCalculatorProvider = Provider<PlantsCareCalculator>((ref) {
  return PlantsCareCalculator();
});

/// SOLID Services Providers (Simplified approach for compatibility)
final _solidPlantsDataService = PlantsDataService.create();
final _solidPlantsFilterService = PlantsFilterService();
final _solidPlantsCareCalculator = PlantsCareCalculator();
final _solidAuthStateProvider = AuthStateProviderAdapter.instance();

/// Provider for PlantsStateManager (new SOLID-compliant state manager)
final plantsStateManagerProvider = Provider<PlantsStateManager>((ref) {
  return PlantsStateManager(
    dataService: _solidPlantsDataService,
    filterService: _solidPlantsFilterService,
    careCalculator: _solidPlantsCareCalculator,
    authProvider: _solidAuthStateProvider,
  );
});

/// Convenience providers for accessing state manager data
final plantsStateProvider = Provider((ref) {
  return ref.watch(plantsStateManagerProvider).state;
});

final plantsListProvider = Provider((ref) {
  final state = ref.watch(plantsStateProvider);
  return state.filteredPlants;
});

final plantsLoadingProvider = Provider((ref) {
  final state = ref.watch(plantsStateProvider);
  return state.isLoading;
});

/// Provider for care statistics
final plantsCareStatisticsProvider = Provider((ref) {
  final stateManager = ref.watch(plantsStateManagerProvider);
  return stateManager.getCareStatistics();
});

/// Provider for plants needing water soon
final plantsNeedingWaterProvider = Provider((ref) {
  final stateManager = ref.watch(plantsStateManagerProvider);
  return stateManager.getPlantsNeedingWaterSoon(2); // Next 2 days
});
