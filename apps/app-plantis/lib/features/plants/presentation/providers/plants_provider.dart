import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';

class PlantsProvider extends ChangeNotifier {
  final GetPlantsUseCase _getPlantsUseCase;
  final GetPlantByIdUseCase _getPlantByIdUseCase;
  final SearchPlantsUseCase _searchPlantsUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;

  PlantsProvider({
    required GetPlantsUseCase getPlantsUseCase,
    required GetPlantByIdUseCase getPlantByIdUseCase,
    required SearchPlantsUseCase searchPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
  }) : _getPlantsUseCase = getPlantsUseCase,
       _getPlantByIdUseCase = getPlantByIdUseCase,
       _searchPlantsUseCase = searchPlantsUseCase,
       _addPlantUseCase = addPlantUseCase,
       _updatePlantUseCase = updatePlantUseCase,
       _deletePlantUseCase = deletePlantUseCase;

  List<Plant> _plants = [];
  List<Plant> get plants => _plants;

  Plant? _selectedPlant;
  Plant? get selectedPlant => _selectedPlant;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Plant> _searchResults = [];
  List<Plant> get searchResults => _searchResults;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  SortBy _sortBy = SortBy.newest;
  SortBy get sortBy => _sortBy;

  String? _filterBySpace;
  String? get filterBySpace => _filterBySpace;

  // Load all plants
  Future<void> loadPlants() async {
    // Only show loading if no plants exist yet (first load)
    final shouldShowLoading = _plants.isEmpty;

    if (shouldShowLoading) {
      _setLoading(true);
    }
    _clearError();

    final result = await _getPlantsUseCase.call(NoParams());

    result.fold((failure) => _setError(_getErrorMessage(failure)), (plants) {
      _plants = _sortPlants(plants);
      _applyFilters();
    });

    if (shouldShowLoading) {
      _setLoading(false);
    }
  }

  // Get plant by ID
  Future<Plant?> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return null;
      },
      (plant) {
        _selectedPlant = plant;
        notifyListeners();
        return plant;
      },
    );
  }

  // Search plants
  Future<void> searchPlants(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    final result = await _searchPlantsUseCase.call(SearchPlantsParams(query));

    result.fold((failure) => _setError(_getErrorMessage(failure)), (results) {
      _searchResults = _sortPlants(results);
      _isSearching = false;
    });

    notifyListeners();
  }

  // Add new plant
  Future<bool> addPlant(AddPlantParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _addPlantUseCase.call(params);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (plant) {
        _plants.insert(0, plant);
        _applyFilters();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Update existing plant
  Future<bool> updatePlant(UpdatePlantParams params) async {
    _setLoading(true);
    _clearError();

    final result = await _updatePlantUseCase.call(params);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (updatedPlant) {
        final index = _plants.indexWhere((p) => p.id == updatedPlant.id);
        if (index != -1) {
          _plants[index] = updatedPlant;
          _plants = _sortPlants(_plants);
          _applyFilters();
        }

        // Update selected plant if it's the same
        if (_selectedPlant?.id == updatedPlant.id) {
          _selectedPlant = updatedPlant;
        }

        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Delete plant
  Future<bool> deletePlant(String id) async {
    _setLoading(true);
    _clearError();

    final result = await _deletePlantUseCase.call(id);

    final success = result.fold(
      (failure) {
        _setError(_getErrorMessage(failure));
        return false;
      },
      (_) {
        _plants.removeWhere((plant) => plant.id == id);
        _searchResults.removeWhere((plant) => plant.id == id);

        // Clear selected plant if it was deleted
        if (_selectedPlant?.id == id) {
          _selectedPlant = null;
        }

        _applyFilters();
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Set view mode
  void setViewMode(ViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  // Set sort order
  void setSortBy(SortBy sort) {
    if (_sortBy != sort) {
      _sortBy = sort;
      _plants = _sortPlants(_plants);
      _searchResults = _sortPlants(_searchResults);
      _applyFilters();
    }
  }

  // Set space filter
  void setSpaceFilter(String? spaceId) {
    if (_filterBySpace != spaceId) {
      _filterBySpace = spaceId;
      _applyFilters();
    }
  }

  // Clear search
  void clearSearch() {
    if (_searchQuery.isNotEmpty || _searchResults.isNotEmpty || _isSearching) {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Groups plants by spaces for grouped view
  Map<String?, List<Plant>> get plantsGroupedBySpaces {
    final plantsToGroup = _searchQuery.isNotEmpty ? _searchResults : _plants;
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
  
  /// Toggle between normal view and grouped by spaces view
  void toggleGroupedView() {
    if (_viewMode == ViewMode.groupedBySpaces) {
      _viewMode = ViewMode.list; // Volta para lista normal
    } else {
      _viewMode = ViewMode.groupedBySpaces; // Muda para agrupado
    }
    notifyListeners();
  }
  
  /// Check if current view is grouped by spaces
  bool get isGroupedBySpaces => _viewMode == ViewMode.groupedBySpaces;

  // Clear selected plant
  void clearSelectedPlant() {
    if (_selectedPlant != null) {
      _selectedPlant = null;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Get plants by space
  List<Plant> getPlantsBySpace(String spaceId) {
    return _plants.where((plant) => plant.spaceId == spaceId).toList();
  }

  // Get plants count
  int get plantsCount => _plants.length;

  // Get plants that need watering soon (next 2 days)
  List<Plant> getPlantsNeedingWater() {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    return _plants.where((plant) {
      if (plant.config?.wateringIntervalDays == null) return false;

      final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: plant.config!.wateringIntervalDays!),
      );

      return nextWatering.isBefore(threshold) ||
          nextWatering.isAtSameMomentAs(threshold);
    }).toList();
  }

  // Get plants by care status
  List<Plant> getPlantsByCareStatus(CareStatus status) {
    final now = DateTime.now();

    return _plants.where((plant) {
      if (plant.config?.wateringIntervalDays == null) {
        return status == CareStatus.unknown;
      }

      final lastWatering = plant.updatedAt ?? plant.createdAt ?? now;
      final nextWatering = lastWatering.add(
        Duration(days: plant.config!.wateringIntervalDays!),
      );

      final daysDifference = nextWatering.difference(now).inDays;

      switch (status) {
        case CareStatus.needsWater:
          return daysDifference <= 0;
        case CareStatus.soonWater:
          return daysDifference > 0 && daysDifference <= 2;
        case CareStatus.good:
          return daysDifference > 2;
        case CareStatus.unknown:
          return false;
      }
    }).toList();
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  List<Plant> _sortPlants(List<Plant> plants) {
    final sortedPlants = List<Plant>.from(plants);

    switch (_sortBy) {
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

  void _applyFilters() {
    List<Plant> filtered = List.from(_plants);

    if (_filterBySpace != null) {
      filtered =
          filtered.where((plant) => plant.spaceId == _filterBySpace).toList();
    }

    _plants = filtered;
    notifyListeners();
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure _:
        return failure.message;
      case CacheFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sem conexão com a internet';
      case ServerFailure _:
        // Check if it's specifically an auth error
        if (failure.message.contains('não autenticado') ||
            failure.message.contains('unauthorized') ||
            failure.message.contains('Usuário não autenticado')) {
          return 'Erro de autenticação. Tente fazer login novamente.';
        }
        return failure.message;
      case NotFoundFailure _:
        return failure.message;
      default:
        return 'Erro inesperado';
    }
  }
}

enum ViewMode { grid, list, groupedBySpaces }

enum SortBy { newest, oldest, name, species }

enum CareStatus { needsWater, soonWater, good, unknown }
