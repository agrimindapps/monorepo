import 'package:core/core.dart' show Equatable;

import '../../domain/entities/plant.dart';

/// View modes for plants display
enum ViewMode { grid, list }

/// Sort options for plants
enum SortBy { newest, oldest, alphabetical, lastModified }

/// Immutable state class for PlantsProvider
/// This provides better performance by avoiding unnecessary rebuilds
/// and makes state management more predictable
class PlantsState extends Equatable {
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

  /// Creates a copy of this state with some values changed
  PlantsState copyWith({
    List<Plant>? plants,
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
      plants: plants ?? this.plants,
      selectedPlant:
          clearSelectedPlant ? null : selectedPlant ?? this.selectedPlant,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      filterBySpace: filterBySpace ?? this.filterBySpace,
    );
  }

  /// Factory constructor for the initial state
  factory PlantsState.initial() {
    return const PlantsState();
  }

  /// Factory constructor for loading state
  factory PlantsState.loading() {
    return const PlantsState(isLoading: true);
  }

  /// Factory constructor for error state
  factory PlantsState.error(String message, {PlantsState? previousState}) {
    if (previousState != null) {
      return previousState.copyWith(isLoading: false, error: message);
    }
    return PlantsState(error: message);
  }
  bool get hasError => error != null;
  bool get isEmpty => plants.isEmpty && !isLoading;
  bool get hasPlants => plants.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get isSearchEmpty => searchQuery.isNotEmpty && searchResults.isEmpty;

  /// Plants count
  int get plantsCount => plants.length;

  /// Filtered plants based on current space filter
  List<Plant> get filteredPlants {
    if (filterBySpace == null) return plants;
    return plants.where((plant) => plant.spaceId == filterBySpace).toList();
  }

  /// Get plants by status
  List<Plant> getPlantsNeedingWater() {
    return plants.where((plant) {
      if (plant.config?.enableWateringCare != true) return false;
      if (plant.config?.lastWateringDate == null) return true;

      final daysSinceLastWatering =
          DateTime.now().difference(plant.config!.lastWateringDate!).inDays;

      return daysSinceLastWatering >= (plant.config?.wateringIntervalDays ?? 7);
    }).toList();
  }

  List<Plant> getPlantsNeedingFertilizer() {
    return plants.where((plant) {
      if (plant.config?.enableFertilizerCare != true) return false;
      if (plant.config?.lastFertilizerDate == null) return true;

      final daysSinceLastFertilizer =
          DateTime.now().difference(plant.config!.lastFertilizerDate!).inDays;

      return daysSinceLastFertilizer >=
          (plant.config?.fertilizingIntervalDays ?? 30);
    }).toList();
  }

  @override
  List<Object?> get props => [
    plants,
    selectedPlant,
    isLoading,
    isSearching,
    error,
    searchQuery,
    searchResults,
    viewMode,
    sortBy,
    filterBySpace,
  ];

  @override
  String toString() {
    return 'PlantsState('
        'plantsCount: $plantsCount, '
        'isLoading: $isLoading, '
        'hasError: $hasError, '
        'viewMode: $viewMode, '
        'sortBy: $sortBy'
        ')';
  }
}
