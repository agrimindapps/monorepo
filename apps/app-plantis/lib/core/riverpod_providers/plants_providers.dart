import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_state_notifier.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../features/plants/domain/usecases/delete_plant_usecase.dart';
import '../../features/plants/domain/usecases/get_plants_usecase.dart';
import '../../features/plants/domain/usecases/update_plant_usecase.dart';

// part 'plants_providers.g.dart';

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

  // Convenience getters
  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  bool get isGroupedBySpaces => viewMode == ViewMode.groupedBySpaces;
  int get plantsCount => allPlants.length;

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup = searchQuery.isNotEmpty ? searchResults : filteredPlants;
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

  // Get plants that need watering soon (next 2 days)
  List<Plant> getPlantsNeedingWater() {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return allPlants.where((plant) {
      final config = plant.config;
      if (config == null) return false;

      // Check if watering care is enabled and has valid interval
      if (config.enableWateringCare == true && config.wateringIntervalDays != null) {
        final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
        final nextWatering = lastWatering.add(
          Duration(days: config.wateringIntervalDays!),
        );

        return nextWatering.isBefore(threshold) ||
            nextWatering.isAtSameMomentAs(threshold);
      }

      // Fallback to old logic for backward compatibility
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

  // Get plants that need fertilizer soon (next 2 days)
  List<Plant> getPlantsNeedingFertilizer() {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return allPlants.where((plant) {
      final config = plant.config;
      if (config == null) return false;

      // Check if fertilizer care is enabled and has valid interval
      if (config.enableFertilizerCare == true && config.fertilizingIntervalDays != null) {
        final lastFertilizer = config.lastFertilizerDate ?? plant.createdAt ?? now;
        final nextFertilizer = lastFertilizer.add(
          Duration(days: config.fertilizingIntervalDays!),
        );

        return nextFertilizer.isBefore(threshold) ||
            nextFertilizer.isAtSameMomentAs(threshold);
      }

      // Fallback to old logic for backward compatibility
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

  // Get plants by care status
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

  // Helper method to check water status
  bool _checkWaterStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;

    // Use new care system if enabled
    if (config.enableWateringCare == true && config.wateringIntervalDays != null) {
      final lastWatering = config.lastWateringDate ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: config.wateringIntervalDays!),
      );
      final daysDifference = nextWatering.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    // Fallback to old system
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

  // Helper method to check fertilizer status
  bool _checkFertilizerStatus(Plant plant, DateTime now, int dayThreshold) {
    final config = plant.config;
    if (config == null) return false;

    // Use new care system if enabled
    if (config.enableFertilizerCare == true && config.fertilizingIntervalDays != null) {
      final lastFertilizer = config.lastFertilizerDate ?? plant.createdAt ?? now;
      final nextFertilizer = lastFertilizer.add(
        Duration(days: config.fertilizingIntervalDays!),
      );
      final daysDifference = nextFertilizer.difference(now).inDays;

      return dayThreshold == 0
          ? daysDifference <= 0
          : daysDifference > 0 && daysDifference <= dayThreshold;
    }

    // Fallback to old system
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

  // Helper method to check if plant is in good condition
  bool _isPlantInGoodCondition(Plant plant, DateTime now) {
    final waterGood = !_checkWaterStatus(plant, now, 0) && !_checkWaterStatus(plant, now, 2);
    final fertilizerGood = !_checkFertilizerStatus(plant, now, 0) && !_checkFertilizerStatus(plant, now, 2);

    final config = plant.config;
    final hasWaterCare = config?.enableWateringCare == true || config?.wateringIntervalDays != null;
    final hasFertilizerCare = config?.enableFertilizerCare == true || config?.fertilizingIntervalDays != null;

    // Plant is good if it doesn't need water or fertilizer within 2 days
    return (hasWaterCare ? waterGood : true) && (hasFertilizerCare ? fertilizerGood : true);
  }

  // Get plants by space
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
    return PlantsState(
      allPlants: allPlants ?? this.allPlants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
      selectedPlant: clearSelectedPlant ? null : (selectedPlant ?? this.selectedPlant),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
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

  // Stream subscriptions
  // ignore: cancel_subscriptions
  StreamSubscription<UserEntity?>? _authSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription<List<dynamic>>? _realtimeDataSubscription;

  @override
  Future<PlantsState> build() async {
    // Initialize dependencies (assuming they are registered in DI)
    _getPlantsUseCase = ref.read(getPlantsUseCaseProvider);
    _getPlantByIdUseCase = ref.read(getPlantByIdUseCaseProvider);
    _searchPlantsUseCase = ref.read(searchPlantsUseCaseProvider);
    _addPlantUseCase = ref.read(addPlantUseCaseProvider);
    _updatePlantUseCase = ref.read(updatePlantUseCaseProvider);
    _deletePlantUseCase = ref.read(deletePlantUseCaseProvider);
    _authStateNotifier = AuthStateNotifier.instance;

    // Initialize auth listener
    _initializeAuthListener();

    // Initialize real-time data stream
    _initializeRealtimeDataStream();

    // Start with empty state
    return const PlantsState();
  }

  /// Initializes the authentication state listener
  void _initializeAuthListener() {
    _authSubscription = _authStateNotifier.userStream.listen((user) {
      debugPrint('🔐 PlantsProvider: Auth state changed - user: ${user?.id}, initialized: ${_authStateNotifier.isInitialized}');
      // Only load plants if auth is fully initialized AND stable
      if (_authStateNotifier.isInitialized && user != null) {
        debugPrint('✅ PlantsProvider: Auth is stable, loading plants...');
        loadInitialData();
      } else if (_authStateNotifier.isInitialized && user == null) {
        debugPrint('🔄 PlantsProvider: No user but auth initialized - clearing plants');
        // Clear plants when user logs out
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(currentState.copyWith(
          allPlants: [],
          filteredPlants: [],
          clearSelectedPlant: true,
          clearError: true,
        ));
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
            debugPrint('🔄 PlantsProvider: Dados em tempo real recebidos - ${plants.length} plantas');

            // Convert from sync entities to domain entities
            final domainPlants = plants
                .map((syncPlant) => _convertSyncPlantToDomain(syncPlant))
                .where((plant) => plant != null)
                .cast<Plant>()
                .toList();

            // Update only if there are real changes
            if (_hasDataChanged(domainPlants)) {
              final currentState = state.valueOrNull ?? const PlantsState();
              final sortedPlants = _sortPlants(domainPlants, currentState.sortBy);
              final filteredPlants = _applyFilters(
                sortedPlants,
                currentState.filterBySpace,
                currentState.searchQuery,
              );

              state = AsyncData(currentState.copyWith(
                allPlants: sortedPlants,
                filteredPlants: filteredPlants,
              ));

              debugPrint('✅ PlantsProvider: UI atualizada com ${sortedPlants.length} plantas');
            }
          },
          onError: (dynamic error) {
            debugPrint('❌ PlantsProvider: Erro no stream de dados em tempo real: $error');
          },
        );

        debugPrint('✅ PlantsProvider: Stream de dados em tempo real configurado');
      } else {
        debugPrint('⚠️ PlantsProvider: Stream de dados não disponível - usando polling');
      }
    } catch (e) {
      debugPrint('❌ PlantsProvider: Erro ao configurar stream de dados: $e');
    }
  }

  /// Converts sync entity to domain entity
  Plant? _convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      // If already a Plant domain object, return directly
      if (syncPlant is Plant) {
        return syncPlant;
      }

      // If it's a sync entity, convert to domain
      if (syncPlant is BaseSyncEntity) {
        // Use PlantisSyncConfig mapping
        return Plant.fromJson(syncPlant.toFirebaseMap());
      }

      // If it's a Map, convert directly
      if (syncPlant is Map<String, dynamic>) {
        return Plant.fromJson(syncPlant);
      }

      return null;
    } catch (e) {
      debugPrint('❌ PlantsProvider: Erro ao converter plant de sync para domínio: $e');
      return null;
    }
  }

  /// Checks if data really changed to avoid unnecessary rebuilds
  bool _hasDataChanged(List<Plant> newPlants) {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.allPlants.length != newPlants.length) {
      return true;
    }

    // Compare IDs and update timestamps
    for (int i = 0; i < currentState.allPlants.length; i++) {
      final currentPlant = currentState.allPlants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        // Plant not found in new list - was removed
        return true;
      }

      // Compare update timestamp
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
      debugPrint('⚠️ PlantsProvider: Auth initialization timeout after ${timeout.inSeconds}s');
      return false;
    } catch (e) {
      debugPrint('❌ PlantsProvider: Auth initialization error: $e');
      return false;
    }
  }

  // Load plants with offline-first approach
  Future<void> loadPlants() async {
    if (kDebugMode) {
      print('📋 PlantsProvider.loadPlants() - Iniciando carregamento offline-first');
    }

    // Wait for authentication before loading plants
    if (!await _waitForAuthenticationWithTimeout()) {
      final currentState = state.valueOrNull ?? const PlantsState();
      state = AsyncData(currentState.copyWith(
        error: 'Aguardando autenticação...',
      ));
      return;
    }

    // OFFLINE-FIRST: Try to load local data first
    await _loadLocalDataFirst();

    // Then attempt to sync in background
    _syncInBackground();
  }

  /// Loads local data immediately for instant UI response
  Future<void> _loadLocalDataFirst() async {
    try {
      if (kDebugMode) {
        print('📦 PlantsProvider: Carregando dados locais primeiro...');
      }

      final currentState = state.valueOrNull ?? const PlantsState();

      // Only show loading if no plants exist yet (first load)
      final shouldShowLoading = currentState.allPlants.isEmpty;
      if (shouldShowLoading) {
        state = AsyncData(currentState.copyWith(
          isLoading: true,
          clearError: true,
        ));
      }

      // Try to get cached/local data first (immediate response)
      final localResult = await _getPlantsUseCase.call(const NoParams());

      localResult.fold(
        (failure) {
          if (kDebugMode) {
            print('⚠️ PlantsProvider: Dados locais não disponíveis: ${_getErrorMessage(failure)}');
          }
          // Don't set error yet - try remote sync
        },
        (plants) {
          if (kDebugMode) {
            print('✅ PlantsProvider: Dados locais carregados: ${plants.length} plantas');
          }
          _updatePlantsData(plants);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsProvider: Erro ao carregar dados locais: $e');
      }
    }
  }

  /// Syncs with remote data in background without blocking UI
  void _syncInBackground() {
    if (kDebugMode) {
      print('🔄 PlantsProvider: Iniciando sync em background...');
    }

    // Execute sync in background
    Future.delayed(const Duration(milliseconds: 100), () async {
      final result = await _getPlantsUseCase.call(const NoParams());

      result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ PlantsProvider: Background sync falhou: ${_getErrorMessage(failure)}');
          }
          // Only set error if no local data was loaded
          final currentState = state.valueOrNull ?? const PlantsState();
          if (currentState.allPlants.isEmpty) {
            state = AsyncData(currentState.copyWith(
              error: _getErrorMessage(failure),
            ));
          }
        },
        (plants) {
          if (kDebugMode) {
            print('✅ PlantsProvider: Background sync bem-sucedido: ${plants.length} plantas');
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

    state = AsyncData(currentState.copyWith(
      allPlants: sortedPlants,
      filteredPlants: filteredPlants,
      isLoading: false,
      clearError: true,
    ));

    if (kDebugMode) {
      print('✅ PlantsProvider: UI atualizada com ${sortedPlants.length} plantas');
      for (final plant in plants) {
        print('   - ${plant.name} (${plant.id})');
      }
    }
  }

  // Get plant by ID
  Future<Plant?> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(currentState.copyWith(
          error: _getErrorMessage(failure),
        ));
        return null;
      },
      (plant) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(currentState.copyWith(
          selectedPlant: plant,
        ));
        return plant;
      },
    );
  }

  // Search plants
  Future<void> searchPlants(String query) async {
    final currentState = state.valueOrNull ?? const PlantsState();

    if (query.trim().isEmpty) {
      state = AsyncData(currentState.copyWith(
        searchResults: [],
        isSearching: false,
        searchQuery: '',
      ));
      return;
    }

    state = AsyncData(currentState.copyWith(
      isSearching: true,
      searchQuery: query,
    ));

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(newState.copyWith(
          error: _getErrorMessage(failure),
          isSearching: false,
        ));
      },
      (results) {
        final newState = state.valueOrNull ?? const PlantsState();
        final sortedResults = _sortPlants(results, newState.sortBy);
        state = AsyncData(newState.copyWith(
          searchResults: sortedResults,
          isSearching: false,
        ));
      },
    );
  }

  // Add new plant
  Future<bool> addPlant(AddPlantParams params) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(
      isLoading: true,
      clearError: true,
    ));

    final result = await _addPlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(newState.copyWith(
          error: _getErrorMessage(failure),
          isLoading: false,
        ));
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

        state = AsyncData(newState.copyWith(
          allPlants: updatedPlants,
          filteredPlants: filteredPlants,
          isLoading: false,
          clearError: true,
        ));
        return true;
      },
    );
  }

  // Update existing plant
  Future<bool> updatePlant(UpdatePlantParams params) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(
      isLoading: true,
      clearError: true,
    ));

    final result = await _updatePlantUseCase.call(params);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(newState.copyWith(
          error: _getErrorMessage(failure),
          isLoading: false,
        ));
        return false;
      },
      (updatedPlant) {
        final newState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = newState.allPlants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        final sortedPlants = _sortPlants(updatedPlants, newState.sortBy);
        final filteredPlants = _applyFilters(
          sortedPlants,
          newState.filterBySpace,
          newState.searchQuery,
        );

        state = AsyncData(newState.copyWith(
          allPlants: sortedPlants,
          filteredPlants: filteredPlants,
          selectedPlant: newState.selectedPlant?.id == updatedPlant.id
              ? updatedPlant
              : newState.selectedPlant,
          isLoading: false,
          clearError: true,
        ));
        return true;
      },
    );
  }

  // Delete plant
  Future<bool> deletePlant(String id) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncData(currentState.copyWith(
      isLoading: true,
      clearError: true,
    ));

    final result = await _deletePlantUseCase.call(id);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const PlantsState();
        state = AsyncData(newState.copyWith(
          error: _getErrorMessage(failure),
          isLoading: false,
        ));
        return false;
      },
      (_) {
        final newState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = newState.allPlants.where((plant) => plant.id != id).toList();
        final updatedSearchResults = newState.searchResults.where((plant) => plant.id != id).toList();
        final filteredPlants = _applyFilters(
          updatedPlants,
          newState.filterBySpace,
          newState.searchQuery,
        );

        state = AsyncData(newState.copyWith(
          allPlants: updatedPlants,
          filteredPlants: filteredPlants,
          searchResults: updatedSearchResults,
          clearSelectedPlant: newState.selectedPlant?.id == id,
          isLoading: false,
          clearError: true,
        ));
        return true;
      },
    );
  }

  // UI state methods
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

      state = AsyncData(currentState.copyWith(
        allPlants: sortedPlants,
        filteredPlants: filteredPlants,
        searchResults: sortedSearchResults,
        sortBy: sort,
      ));
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

      state = AsyncData(currentState.copyWith(
        filterBySpace: spaceId,
        filteredPlants: filteredPlants,
      ));
    }
  }

  void clearSearch() {
    final currentState = state.valueOrNull ?? const PlantsState();
    if (currentState.searchQuery.isNotEmpty ||
        currentState.searchResults.isNotEmpty ||
        currentState.isSearching) {
      state = AsyncData(currentState.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
      ));
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

  // Load initial data for the plants list page
  Future<void> loadInitialData() async {
    await loadPlants();
  }

  // Refresh plants data and clear any existing errors
  Future<void> refreshPlants() async {
    if (kDebugMode) {
      print('🔄 PlantsProvider.refreshPlants() - Iniciando refresh');
      final currentState = state.valueOrNull ?? const PlantsState();
      print('🔄 PlantsProvider.refreshPlants() - Plantas antes: ${currentState.allPlants.length}');
    }

    clearError();
    await loadInitialData();

    if (kDebugMode) {
      print('✅ PlantsProvider.refreshPlants() - Refresh completo');
      final currentState = state.valueOrNull ?? const PlantsState();
      print('🔄 PlantsProvider.refreshPlants() - Plantas depois: ${currentState.allPlants.length}');
    }
  }

  // Helper methods
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

  List<Plant> _applyFilters(List<Plant> plants, String? filterBySpace, String searchQuery) {
    List<Plant> filtered = List.from(plants);

    if (filterBySpace != null) {
      filtered = filtered.where((plant) => plant.spaceId == filterBySpace).toList();
    }

    return filtered;
  }

  String _getErrorMessage(Failure failure) {
    // Log detailed error for debugging
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
        // More specific cache error messages
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
        // Check if it's specifically an auth error
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Sessão expirada. Tente fazer login novamente.';
        }
        if (failure.message.contains('403') || failure.message.contains('Forbidden')) {
          return 'Acesso negado. Verifique suas permissões.';
        }
        if (failure.message.contains('500') || failure.message.contains('Internal')) {
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

/// Main Plants provider using standard Riverpod
final plantsProvider = AsyncNotifierProvider<PlantsNotifier, PlantsState>(() {
  return PlantsNotifier();
});

// Compatibility providers for legacy code
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

// Dependency providers (these would need to be implemented based on your DI setup)
final getPlantsUseCaseProvider = Provider<GetPlantsUseCase>((ref) {
  throw UnimplementedError('GetPlantsUseCase provider needs to be implemented');
});

final getPlantByIdUseCaseProvider = Provider<GetPlantByIdUseCase>((ref) {
  throw UnimplementedError('GetPlantByIdUseCase provider needs to be implemented');
});

final searchPlantsUseCaseProvider = Provider<SearchPlantsUseCase>((ref) {
  throw UnimplementedError('SearchPlantsUseCase provider needs to be implemented');
});

final addPlantUseCaseProvider = Provider<AddPlantUseCase>((ref) {
  throw UnimplementedError('AddPlantUseCase provider needs to be implemented');
});

final updatePlantUseCaseProvider = Provider<UpdatePlantUseCase>((ref) {
  throw UnimplementedError('UpdatePlantUseCase provider needs to be implemented');
});

final deletePlantUseCaseProvider = Provider<DeletePlantUseCase>((ref) {
  throw UnimplementedError('DeletePlantUseCase provider needs to be implemented');
});

// Enums (ensure these are defined elsewhere or define them here)
enum ViewMode { grid, list, groupedBySpaces, groupedBySpacesGrid, groupedBySpacesList }
enum SortBy { newest, oldest, name, species }
enum CareStatus {
  needsWater,
  soonWater,
  needsFertilizer,
  soonFertilizer,
  good,
  unknown
}