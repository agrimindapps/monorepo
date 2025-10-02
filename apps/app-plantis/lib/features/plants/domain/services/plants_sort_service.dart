import '../entities/plant.dart';

/// Sorting criteria for plants
enum SortBy { newest, oldest, name, species }

/// View mode for displaying plants
enum ViewMode {
  grid,
  list,
  groupedBySpaces,
  groupedBySpacesGrid,
  groupedBySpacesList,
}

/// Service responsible for sorting plants
/// Extracted from PlantsProvider to follow Single Responsibility Principle
class PlantsSortService {
  /// Sort plants by given criteria
  List<Plant> sortPlants(List<Plant> plants, SortBy sortBy) {
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

  /// Check if view mode is grouped by spaces
  bool isGroupedView(ViewMode viewMode) {
    return viewMode == ViewMode.groupedBySpaces ||
        viewMode == ViewMode.groupedBySpacesGrid ||
        viewMode == ViewMode.groupedBySpacesList;
  }

  /// Toggle between grouped and normal view
  ViewMode toggleGroupedView(ViewMode currentMode) {
    if (isGroupedView(currentMode)) {
      return ViewMode.list; // Return to normal list view
    } else {
      return ViewMode.groupedBySpaces; // Switch to grouped
    }
  }
}
