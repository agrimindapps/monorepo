import 'package:provider/provider.dart';

import '../../domain/entities/plant.dart';
import '../providers/plants_provider.dart';

/// Granular selectors to minimize widget rebuilds
/// Each selector listens only to specific parts of the provider state
class PlantsSelectors {
  /// Selector for plant count only
  static Selector<PlantsProvider, int> plantsCount() {
    return Selector<PlantsProvider, int>(
      selector: (_, provider) => provider.plantsCount,
      builder: (context, plantsCount, child) => child!,
    );
  }

  /// Selector for search query only
  static Selector<PlantsProvider, String> searchQuery() {
    return Selector<PlantsProvider, String>(
      selector: (_, provider) => provider.searchQuery,
      builder: (context, searchQuery, child) => child!,
    );
  }

  /// Selector for view mode only
  static Selector<PlantsProvider, ViewMode> viewMode() {
    return Selector<PlantsProvider, ViewMode>(
      selector: (_, provider) => provider.viewMode,
      builder: (context, viewMode, child) => child!,
    );
  }

  /// Selector for loading state only
  static Selector<PlantsProvider, bool> isLoading() {
    return Selector<PlantsProvider, bool>(
      selector: (_, provider) => provider.isLoading,
      builder: (context, isLoading, child) => child!,
    );
  }

  /// Selector for error state only
  static Selector<PlantsProvider, String?> error() {
    return Selector<PlantsProvider, String?>(
      selector: (_, provider) => provider.error,
      builder: (context, error, child) => child!,
    );
  }

  /// Selector for plants list only (optimized with shouldRebuild)
  static Selector<PlantsProvider, List<Plant>> plantsList() {
    return Selector<PlantsProvider, List<Plant>>(
      selector: (_, provider) => provider.plants,
      shouldRebuild: (previous, next) {
        // Only rebuild if the list actually changed
        if (previous.length != next.length) return true;

        // Check if any plant IDs changed (efficient comparison)
        for (int i = 0; i < previous.length; i++) {
          if (previous[i].id != next[i].id) return true;
        }

        return false;
      },
      builder: (context, plants, child) => child!,
    );
  }

  /// Selector for search results only
  static Selector<PlantsProvider, List<Plant>> searchResults() {
    return Selector<PlantsProvider, List<Plant>>(
      selector: (_, provider) => provider.searchResults,
      shouldRebuild: (previous, next) {
        // Only rebuild if the list actually changed
        if (previous.length != next.length) return true;

        // Check if any plant IDs changed
        for (int i = 0; i < previous.length; i++) {
          if (previous[i].id != next[i].id) return true;
        }

        return false;
      },
      builder: (context, searchResults, child) => child!,
    );
  }

  /// Combined selector for display data (what plants to show)
  static Selector<PlantsProvider, PlantsDisplayData> displayData() {
    return Selector<PlantsProvider, PlantsDisplayData>(
      selector:
          (_, provider) => PlantsDisplayData(
            plants:
                provider.searchQuery.isNotEmpty
                    ? provider.searchResults
                    : provider.plants,
            isSearching: provider.searchQuery.isNotEmpty,
            searchQuery: provider.searchQuery,
          ),
      shouldRebuild: (previous, next) {
        return previous.plants.length != next.plants.length ||
            previous.isSearching != next.isSearching ||
            previous.searchQuery != next.searchQuery;
      },
      builder: (context, displayData, child) => child!,
    );
  }

  /// Selector for app bar data (count, search, view mode)
  static Selector<PlantsProvider, AppBarData> appBarData() {
    return Selector<PlantsProvider, AppBarData>(
      selector:
          (_, provider) => AppBarData(
            plantsCount: provider.plantsCount,
            searchQuery: provider.searchQuery,
            viewMode: provider.viewMode,
          ),
      shouldRebuild: (previous, next) {
        return previous.plantsCount != next.plantsCount ||
            previous.searchQuery != next.searchQuery ||
            previous.viewMode != next.viewMode;
      },
      builder: (context, appBarData, child) => child!,
    );
  }

  /// Selector for loading and error states
  static Selector<PlantsProvider, LoadingErrorState> loadingErrorState() {
    return Selector<PlantsProvider, LoadingErrorState>(
      selector:
          (_, provider) => LoadingErrorState(
            isLoading: provider.isLoading,
            error: provider.error,
            hasPlants: provider.plants.isNotEmpty,
          ),
      shouldRebuild: (previous, next) {
        return previous.isLoading != next.isLoading ||
            previous.error != next.error ||
            previous.hasPlants != next.hasPlants;
      },
      builder: (context, state, child) => child!,
    );
  }
}

/// Data classes for combined selectors
class PlantsDisplayData {
  final List<Plant> plants;
  final bool isSearching;
  final String searchQuery;

  const PlantsDisplayData({
    required this.plants,
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantsDisplayData &&
        other.plants.length == plants.length &&
        other.isSearching == isSearching &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode =>
      plants.length.hashCode ^ isSearching.hashCode ^ searchQuery.hashCode;
}

class AppBarData {
  final int plantsCount;
  final String searchQuery;
  final ViewMode viewMode;

  const AppBarData({
    required this.plantsCount,
    required this.searchQuery,
    required this.viewMode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppBarData &&
        other.plantsCount == plantsCount &&
        other.searchQuery == searchQuery &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode =>
      plantsCount.hashCode ^ searchQuery.hashCode ^ viewMode.hashCode;
}

class LoadingErrorState {
  final bool isLoading;
  final String? error;
  final bool hasPlants;

  const LoadingErrorState({
    required this.isLoading,
    required this.error,
    required this.hasPlants,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingErrorState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.hasPlants == hasPlants;
  }

  @override
  int get hashCode => isLoading.hashCode ^ error.hashCode ^ hasPlants.hashCode;
}
