import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/plant.dart';
import '../../domain/usecases/add_plant_usecase.dart';
import '../../domain/usecases/delete_plant_usecase.dart';
import '../../domain/usecases/get_plants_usecase.dart';
import '../../domain/usecases/update_plant_usecase.dart';

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

    final result = await _getPlantsUseCase.call(const NoParams());

    result.fold(
      (failure) => _setError(_getErrorMessage(failure)), 
      (plants) {
        // Successful load - ensure error is cleared and plants are updated
        _clearError();
        _plants = _sortPlants(plants);
        _applyFilters();
      }
    );

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

    return _plants.where((plant) {
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

    return _plants.where((plant) {
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

enum ViewMode { grid, list, groupedBySpaces }

enum SortBy { newest, oldest, name, species }

enum CareStatus { 
  needsWater, 
  soonWater, 
  needsFertilizer,
  soonFertilizer,
  good, 
  unknown 
}
