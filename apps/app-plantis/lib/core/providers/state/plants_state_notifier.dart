import 'dart:async';

import 'package:core/core.dart' hide Column, getIt;

import '../../../features/plants/domain/entities/plant.dart';
import '../../../features/plants/domain/usecases/add_plant_usecase.dart';
import '../../../features/plants/domain/usecases/update_plant_usecase.dart';
import '../../interfaces/i_auth_state_provider.dart';
import '../../services/plants_care_calculator.dart' as care_service;
import '../../services/plants_data_service.dart';
import '../../services/plants_filter_service.dart' as filter_service;

part 'plants_state_notifier.g.dart';

/// Estado das plantas para gerenciamento UI
class PlantsState {
  final List<Plant> allPlants;
  final List<Plant> filteredPlants;
  final Plant? selectedPlant;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  final String searchQuery;
  final ViewMode viewMode;
  final PlantSortOption sortBy;
  final String? filterBySpace;
  final PlantCareStatus? filterByCareStatus;
  final bool showOnlyFavorites;
  final bool showOnlyNeedingWater;

  const PlantsState({
    this.allPlants = const [],
    this.filteredPlants = const [],
    this.selectedPlant,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.searchQuery = '',
    this.viewMode = ViewMode.grid,
    this.sortBy = PlantSortOption.nameAZ,
    this.filterBySpace,
    this.filterByCareStatus,
    this.showOnlyFavorites = false,
    this.showOnlyNeedingWater = false,
  });

  PlantsState copyWith({
    List<Plant>? allPlants,
    List<Plant>? filteredPlants,
    Plant? selectedPlant,
    bool? isLoading,
    bool? isSearching,
    String? error,
    String? searchQuery,
    ViewMode? viewMode,
    PlantSortOption? sortBy,
    String? filterBySpace,
    PlantCareStatus? filterByCareStatus,
    bool? showOnlyFavorites,
    bool? showOnlyNeedingWater,
    bool clearError = false,
    bool clearSelectedPlant = false,
  }) {
    return PlantsState(
      allPlants: allPlants ?? this.allPlants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
      selectedPlant:
          clearSelectedPlant ? null : (selectedPlant ?? this.selectedPlant),
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: filterBySpace ?? this.filterBySpace,
      filterByCareStatus: filterByCareStatus ?? this.filterByCareStatus,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      showOnlyNeedingWater: showOnlyNeedingWater ?? this.showOnlyNeedingWater,
    );
  }

  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  bool get isGroupedBySpaces => viewMode == ViewMode.groupedBySpaces;
  int get plantsCount => allPlants.length;

  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final Map<String?, List<Plant>> groupedPlants = {};

    for (final plant in filteredPlants) {
      final spaceId = plant.spaceId;
      if (!groupedPlants.containsKey(spaceId)) {
        groupedPlants[spaceId] = [];
      }
      groupedPlants[spaceId]!.add(plant);
    }

    return groupedPlants;
  }
}

enum ViewMode { grid, list, groupedBySpaces }

enum PlantSortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
  careUrgency,
  lastWatered,
}

enum PlantCareStatus { critical, needsWater, soon, healthy, unknown }

/// Notifier para coordenação de estado de plantas (UI)
@riverpod
class PlantsStateNotifier extends _$PlantsStateNotifier {
  late final PlantsDataService _dataService;
  late final filter_service.PlantsFilterService _filterService;
  late final care_service.PlantsCareCalculator _careCalculator;
  late final IAuthStateProvider _authProvider;

  StreamSubscription<UserEntity?>? _authSubscription;
  Timer? _autoRefreshTimer;

  @override
  Future<PlantsState> build() async {
    _dataService = ref.read(plantsDataServiceProvider);
    _filterService = ref.read(plantsFilterServiceProvider);
    _careCalculator = ref.read(plantsCareCalculatorProvider);
    _authProvider = ref.read(authStateProviderProviderProvider);
    _authSubscription = _authProvider.userStream.listen(_onAuthStateChanged);
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => refreshPlants(),
    );
    ref.onDispose(() {
      _authSubscription?.cancel();
      _autoRefreshTimer?.cancel();
    });
    return await _loadPlantsInternal();
  }

  void _onAuthStateChanged(UserEntity? user) {
    if (user != null) {
      loadPlants();
    } else {
      final currentState = state.valueOrNull ?? const PlantsState();
      state = AsyncValue.data(
        currentState.copyWith(
          allPlants: [],
          filteredPlants: [],
          clearSelectedPlant: true,
          clearError: true,
        ),
      );
    }
  }

  Future<PlantsState> _loadPlantsInternal() async {
    final result = await _dataService.loadPlants();

    return await result.fold(
      (failure) async => PlantsState(error: failure.message),
      (plants) async {
        final newState = PlantsState(allPlants: plants);
        await _applyFiltersToState(newState);
        return newState;
      },
    );
  }

  Future<void> loadPlants() async {
    final currentState = state.valueOrNull ?? const PlantsState();

    if (currentState.isLoading) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, clearError: true),
    );

    try {
      final result = await _dataService.loadPlants();

      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              error: failure.message,
            ),
          );
        },
        (plants) async {
          final newState = currentState.copyWith(
            allPlants: plants,
            isLoading: false,
            clearError: true,
          );
          state = AsyncValue.data(newState);
          await _applyFiltersToState(newState);
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro inesperado: $e',
        ),
      );
    }
  }

  Future<void> refreshPlants() async {
    await loadPlants();
  }

  Future<bool> addPlant(AddPlantParams params) async {
    final result = await _dataService.addPlant(params);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (plant) {
        final currentState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = [...currentState.allPlants, plant];
        final newState = currentState.copyWith(allPlants: updatedPlants);
        state = AsyncValue.data(newState);
        _applyFiltersToState(newState);
        return true;
      },
    );
  }

  Future<bool> updatePlant(UpdatePlantParams params) async {
    final result = await _dataService.updatePlant(params);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (updatedPlant) {
        final currentState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = currentState.allPlants.map((plant) {
          return plant.id == updatedPlant.id ? updatedPlant : plant;
        }).toList();

        final newState = currentState.copyWith(allPlants: updatedPlants);
        state = AsyncValue.data(newState);
        _applyFiltersToState(newState);
        return true;
      },
    );
  }

  Future<bool> deletePlant(String plantId) async {
    final result = await _dataService.deletePlant(plantId);

    return result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsState();
        state = AsyncValue.data(
          currentState.copyWith(error: failure.message),
        );
        return false;
      },
      (_) {
        final currentState = state.valueOrNull ?? const PlantsState();
        final updatedPlants = currentState.allPlants
            .where((plant) => plant.id != plantId)
            .toList();
        final newState = currentState.copyWith(
          allPlants: updatedPlants,
          clearSelectedPlant: currentState.selectedPlant?.id == plantId,
        );
        state = AsyncValue.data(newState);
        _applyFiltersToState(newState);
        return true;
      },
    );
  }

  void selectPlant(Plant? plant) {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncValue.data(currentState.copyWith(selectedPlant: plant));
  }

  Future<void> searchPlants(String query) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(
      searchQuery: query,
      isSearching: query.isNotEmpty,
    );
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> setSpaceFilter(String? spaceId) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(filterBySpace: spaceId);
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> setCareStatusFilter(PlantCareStatus? status) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(filterByCareStatus: status);
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> setFavoritesFilter(bool showOnlyFavorites) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(showOnlyFavorites: showOnlyFavorites);
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> setNeedingWaterFilter(bool showOnlyNeedingWater) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState =
        currentState.copyWith(showOnlyNeedingWater: showOnlyNeedingWater);
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> setSortBy(PlantSortOption sortBy) async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(sortBy: sortBy);
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  void setViewMode(ViewMode viewMode) {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncValue.data(currentState.copyWith(viewMode: viewMode));
  }

  Future<void> clearFilters() async {
    final currentState = state.valueOrNull ?? const PlantsState();
    final newState = currentState.copyWith(
      searchQuery: '',
      filterBySpace: null,
      filterByCareStatus: null,
      showOnlyFavorites: false,
      showOnlyNeedingWater: false,
      isSearching: false,
    );
    state = AsyncValue.data(newState);
    await _applyFiltersToState(newState);
  }

  Future<void> _applyFiltersToState(PlantsState currentState) async {
    final filtered = _filterService.searchWithFilters(
      plants: currentState.allPlants,
      searchTerm:
          currentState.searchQuery.isNotEmpty ? currentState.searchQuery : null,
      spaceId: currentState.filterBySpace,
      careStatus: _mapToServiceCareStatus(currentState.filterByCareStatus),
      onlyFavorites: currentState.showOnlyFavorites,
      onlyNeedingWater: currentState.showOnlyNeedingWater,
      sortOption: _mapToServiceSortOption(currentState.sortBy),
    );

    state = AsyncValue.data(currentState.copyWith(filteredPlants: filtered));
  }

  care_service.PlantCareStatistics getCareStatistics() {
    final currentState = state.valueOrNull ?? const PlantsState();
    return _careCalculator.calculateCareStatistics(currentState.allPlants);
  }

  List<Plant> getPlantsNeedingWaterSoon(int days) {
    final currentState = state.valueOrNull ?? const PlantsState();
    return _careCalculator.getPlantsNeedingWaterSoon(
      currentState.allPlants,
      days,
    );
  }

  PlantCareStatus getPlantCareStatus(Plant plant) {
    final serviceStatus = _careCalculator.calculateCareStatus(plant);
    return _mapFromServiceCareStatus(serviceStatus);
  }

  filter_service.PlantSortOption _mapToServiceSortOption(
    PlantSortOption option,
  ) {
    switch (option) {
      case PlantSortOption.nameAZ:
        return filter_service.PlantSortOption.nameAZ;
      case PlantSortOption.nameZA:
        return filter_service.PlantSortOption.nameZA;
      case PlantSortOption.dateNewest:
        return filter_service.PlantSortOption.dateNewest;
      case PlantSortOption.dateOldest:
        return filter_service.PlantSortOption.dateOldest;
      case PlantSortOption.careUrgency:
        return filter_service.PlantSortOption.careUrgency;
      case PlantSortOption.lastWatered:
        return filter_service.PlantSortOption.lastWatered;
    }
  }

  filter_service.PlantCareStatus? _mapToServiceCareStatus(
    PlantCareStatus? status,
  ) {
    if (status == null) return null;
    switch (status) {
      case PlantCareStatus.critical:
        return filter_service.PlantCareStatus.critical;
      case PlantCareStatus.needsWater:
        return filter_service.PlantCareStatus.needsWater;
      case PlantCareStatus.soon:
        return filter_service.PlantCareStatus.soon;
      case PlantCareStatus.healthy:
        return filter_service.PlantCareStatus.healthy;
      case PlantCareStatus.unknown:
        return filter_service.PlantCareStatus.unknown;
    }
  }

  PlantCareStatus _mapFromServiceCareStatus(
    care_service.PlantCareStatus serviceStatus,
  ) {
    switch (serviceStatus) {
      case care_service.PlantCareStatus.critical:
        return PlantCareStatus.critical;
      case care_service.PlantCareStatus.needsWater:
        return PlantCareStatus.needsWater;
      case care_service.PlantCareStatus.soon:
        return PlantCareStatus.soon;
      case care_service.PlantCareStatus.healthy:
        return PlantCareStatus.healthy;
      case care_service.PlantCareStatus.unknown:
        return PlantCareStatus.unknown;
    }
  }

  void clearError() {
    final currentState = state.valueOrNull ?? const PlantsState();
    state = AsyncValue.data(currentState.copyWith(clearError: true));
  }
}
@riverpod
PlantsDataService plantsDataService(Ref ref) {
  return GetIt.instance<PlantsDataService>();
}

@riverpod
filter_service.PlantsFilterService plantsFilterService(Ref ref) {
  return GetIt.instance<filter_service.PlantsFilterService>();
}

@riverpod
care_service.PlantsCareCalculator plantsCareCalculator(Ref ref) {
  return GetIt.instance<care_service.PlantsCareCalculator>();
}

@riverpod
IAuthStateProvider authStateProviderProvider(Ref ref) {
  return GetIt.instance<IAuthStateProvider>();
}
