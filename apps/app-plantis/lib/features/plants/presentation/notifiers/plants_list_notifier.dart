import 'package:core/core.dart' hide Column, getIt;

import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';

part 'plants_list_notifier.g.dart';

/// State para listagem e filtragem de plantas
class PlantsListState {
  final List<Plant> plants;
  final List<Plant> filteredPlants;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const PlantsListState({
    this.plants = const [],
    this.filteredPlants = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  bool get hasPlants => plants.isNotEmpty;
  bool get isEmpty => plants.isEmpty && !isLoading;
  int get plantsCount => plants.length;

  List<Plant> get displayPlants =>
      filteredPlants.isEmpty && searchQuery.isEmpty ? plants : filteredPlants;

  PlantsListState copyWith({
    List<Plant>? plants,
    List<Plant>? filteredPlants,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return PlantsListState(
      plants: plants ?? this.plants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier para gerenciamento de lista de plantas
@riverpod
class PlantsListNotifier extends _$PlantsListNotifier {
  late final PlantsRepository _plantsRepository;

  @override
  Future<PlantsListState> build() async {
    _plantsRepository = ref.read(plantsRepositoryProvider);
    return await _loadPlantsInternal();
  }

  Future<PlantsListState> _loadPlantsInternal() async {
    final result = await _plantsRepository.getPlants();

    return result.fold(
      (failure) => PlantsListState(errorMessage: failure.message),
      (plants) => PlantsListState(plants: plants),
    );
  }

  /// Load plants from repository
  Future<void> loadPlants() async {
    state = AsyncValue.data(
      (state.valueOrNull ?? const PlantsListState()).copyWith(isLoading: true),
    );

    final result = await _plantsRepository.getPlants();

    result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          ),
        );
      },
      (plants) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        state = AsyncValue.data(
          currentState.copyWith(
            plants: plants,
            isLoading: false,
          ),
        );
        if (currentState.searchQuery.isNotEmpty) {
          _applySearch();
        }
      },
    );
  }

  /// Add a new plant
  Future<void> addPlant(Plant plant) async {
    final result = await _plantsRepository.addPlant(plant);

    result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: failure.message),
        );
      },
      (addedPlant) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        final updatedPlants = [...currentState.plants, addedPlant];

        state = AsyncValue.data(
          currentState.copyWith(plants: updatedPlants),
        );
        _applySearch();
      },
    );
  }

  /// Update an existing plant
  Future<void> updatePlant(Plant plant) async {
    final result = await _plantsRepository.updatePlant(plant);

    result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: failure.message),
        );
      },
      (updatedPlant) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        final updatedPlants = currentState.plants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        state = AsyncValue.data(
          currentState.copyWith(plants: updatedPlants),
        );
        _applySearch();
      },
    );
  }

  Future<void> deletePlant(String id) async {
    final result = await _plantsRepository.deletePlant(id);

    result.fold(
      (failure) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        state = AsyncValue.data(
          currentState.copyWith(errorMessage: failure.message),
        );
      },
      (_) {
        final currentState = state.valueOrNull ?? const PlantsListState();
        final updatedPlants =
            currentState.plants.where((plant) => plant.id != id).toList();
        final updatedFilteredPlants = currentState.filteredPlants
            .where((plant) => plant.id != id)
            .toList();

        state = AsyncValue.data(
          currentState.copyWith(
            plants: updatedPlants,
            filteredPlants: updatedFilteredPlants,
          ),
        );
      },
    );
  }

  /// Search plants locally
  void searchPlants(String query) {
    final currentState = state.valueOrNull ?? const PlantsListState();
    state = AsyncValue.data(
      currentState.copyWith(searchQuery: query.trim().toLowerCase()),
    );

    _applySearch();
  }

  /// Clear search
  void clearSearch() {
    final currentState = state.valueOrNull ?? const PlantsListState();
    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        filteredPlants: [],
      ),
    );
  }

  /// Perform remote search
  Future<void> performRemoteSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    final currentState = state.valueOrNull ?? const PlantsListState();
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    final result = await _plantsRepository.searchPlants(query);

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          ),
        );
      },
      (searchResults) {
        state = AsyncValue.data(
          currentState.copyWith(
            searchQuery: query.trim().toLowerCase(),
            filteredPlants: searchResults,
            isLoading: false,
          ),
        );
      },
    );
  }

  /// Get plants by space
  List<Plant> getPlantsBySpace(String spaceId) {
    final currentState = state.valueOrNull ?? const PlantsListState();
    final plantsToFilter = currentState.displayPlants;

    return plantsToFilter.where((plant) => plant.spaceId == spaceId).toList();
  }

  /// Get plants with images
  List<Plant> getPlantsWithImages() {
    final currentState = state.valueOrNull ?? const PlantsListState();
    final plantsToFilter = currentState.displayPlants;

    return plantsToFilter.where((plant) => plant.hasImage).toList();
  }

  /// Get recent plants
  List<Plant> getRecentPlants({int days = 7}) {
    final currentState = state.valueOrNull ?? const PlantsListState();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final plantsToFilter = currentState.displayPlants;

    return plantsToFilter
        .where((plant) => plant.createdAt?.isAfter(cutoffDate) ?? false)
        .toList();
  }

  /// Get plant by ID
  Plant? getPlantById(String id) {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    try {
      return currentState.plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh plants (alias for loadPlants)
  Future<void> refresh() async {
    await loadPlants();
  }

  /// Apply local search filtering
  void _applySearch() {
    final currentState = state.valueOrNull ?? const PlantsListState();

    if (currentState.searchQuery.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(filteredPlants: []));
      return;
    }

    final filtered = currentState.plants.where((plant) {
      final name = plant.name.toLowerCase();
      final species = plant.species?.toLowerCase() ?? '';
      final notes = plant.notes?.toLowerCase() ?? '';

      return name.contains(currentState.searchQuery) ||
          species.contains(currentState.searchQuery) ||
          notes.contains(currentState.searchQuery);
    }).toList();

    state = AsyncValue.data(currentState.copyWith(filteredPlants: filtered));
  }

  /// Clear error message
  void clearError() {
    final currentState = state.valueOrNull ?? const PlantsListState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }
}
@riverpod
PlantsRepository plantsRepository(Ref ref) {
  return GetIt.instance<PlantsRepository>();
}
