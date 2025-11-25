import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/services/plants_sort_service.dart';

part 'plants_state.freezed.dart';

/// Immutable state for Plants feature
/// Contains all UI state needed for plants management
@freezed
sealed class PlantsState with _$PlantsState {
  const factory PlantsState({
    /// All plants loaded from repository
    @Default([]) List<Plant> plants,

    /// Currently selected plant (for detail view)
    Plant? selectedPlant,

    /// Loading state (initial load)
    @Default(false) bool isLoading,

    /// Search operation loading state
    @Default(false) bool isSearching,

    /// Error message (null if no error)
    String? error,

    /// Current search query
    @Default('') String searchQuery,

    /// Search results
    @Default([]) List<Plant> searchResults,

    /// Current view mode (grid, list, grouped)
    @Default(ViewMode.grid) ViewMode viewMode,

    /// Current sort criteria
    @Default(SortBy.newest) SortBy sortBy,

    /// Filter by space ID (null = show all)
    String? filterBySpace,
  }) = _PlantsState;
}

/// Extension providing factory constructors and computed properties for PlantsState
extension PlantsStateX on PlantsState {
  /// Initial state factory
  static PlantsState initial() => const PlantsState();

  // Computed properties

  /// Total count of plants
  int get plantsCount => plants.length;

  /// Has error
  bool get hasError => error != null;

  /// Is searching
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Search results count
  int get searchResultsCount => searchResults.length;

  /// Has selected plant
  bool get hasSelectedPlant => selectedPlant != null;

  /// Is empty
  bool get isEmpty => plants.isEmpty && !isLoading;

  /// Has plants
  bool get hasPlants => plants.isNotEmpty;

  /// Has search results
  bool get hasSearchResults => searchResults.isNotEmpty;

  /// Is search empty
  bool get isSearchEmpty => searchQuery.isNotEmpty && searchResults.isEmpty;

  /// Is grouped view mode
  bool get isGroupedBySpaces =>
      viewMode == ViewMode.groupedBySpaces ||
      viewMode == ViewMode.groupedBySpacesGrid ||
      viewMode == ViewMode.groupedBySpacesList;

  /// Filtered plants based on current space filter
  List<Plant> get filteredPlants {
    if (filterBySpace == null) return plants;
    return plants.where((plant) => plant.spaceId == filterBySpace).toList();
  }
}
