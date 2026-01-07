import 'package:core/core.dart' hide SortBy;
import 'package:flutter/foundation.dart';

import '../entities/plant.dart';
import '../usecases/add_plant_usecase.dart';
import '../usecases/delete_plant_usecase.dart';
import '../usecases/get_plant_by_id_usecase.dart';
import '../usecases/get_plants_usecase.dart';
import '../usecases/update_plant_usecase.dart';
import 'plants_sort_service.dart' show PlantsSortService, SortBy;

/// Orchestrator that coordinates complex plant operations
/// Extracts business logic from PlantsNotifier following Clean Architecture
///
/// Responsibilities:
/// - Coordinates multi-step operations (CRUD with side effects)
/// - Manages data loading strategies (local-first, background sync)
/// - Handles entity conversions and validations
/// - Centralizes error handling patterns
class PlantsDomainOrchestrator {
  final GetPlantsUseCase _getPlantsUseCase;
  final GetPlantByIdUseCase _getPlantByIdUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;
  final PlantsSortService _sortService;

  PlantsDomainOrchestrator({
    required GetPlantsUseCase getPlantsUseCase,
    required GetPlantByIdUseCase getPlantByIdUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
    required PlantsSortService sortService,
  }) : _getPlantsUseCase = getPlantsUseCase,
       _getPlantByIdUseCase = getPlantByIdUseCase,
       _addPlantUseCase = addPlantUseCase,
       _updatePlantUseCase = updatePlantUseCase,
       _deletePlantUseCase = deletePlantUseCase,
       _sortService = sortService;

  /// Loads plants with local-first strategy
  /// Returns immediately with cached data, syncs in background
  Future<PlantsLoadResult> loadPlantsLocalFirst() async {
    try {
      final result = await _getPlantsUseCase.call(const NoParams());

      return result.fold(
        (failure) => PlantsLoadResult.failure(failure.toString()),
        (plants) => PlantsLoadResult.success(plants),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsDomainOrchestrator: Error loading plants: $e');
      }
      return PlantsLoadResult.failure(e.toString());
    }
  }

  /// Gets a single plant by ID
  Future<PlantResult> getPlantById(String id) async {
    final result = await _getPlantByIdUseCase.call(id);

    return result.fold(
      (failure) => PlantResult.failure(failure.toString()),
      (plant) => PlantResult.success(plant),
    );
  }

  /// Adds a new plant with validation and sorting
  Future<PlantOperationResult> addPlant(
    AddPlantParams params,
    List<Plant> currentPlants,
    SortBy sortBy,
  ) async {
    final result = await _addPlantUseCase.call(params);

    return result.fold(
      (failure) => PlantOperationResult.failure(failure.toString()),
      (plant) {
        final updatedPlants = [plant, ...currentPlants];
        final sorted = _sortService.sortPlants(updatedPlants, sortBy);
        return PlantOperationResult.success(
          plant: plant,
          updatedPlants: sorted,
        );
      },
    );
  }

  /// Updates an existing plant
  Future<PlantOperationResult> updatePlant(
    UpdatePlantParams params,
    List<Plant> currentPlants,
    SortBy sortBy,
  ) async {
    final result = await _updatePlantUseCase.call(params);

    return result.fold(
      (failure) => PlantOperationResult.failure(failure.toString()),
      (updatedPlant) {
        final updatedPlants = currentPlants.map((p) {
          return p.id == updatedPlant.id ? updatedPlant : p;
        }).toList();

        final sorted = _sortService.sortPlants(updatedPlants, sortBy);

        return PlantOperationResult.success(
          plant: updatedPlant,
          updatedPlants: sorted,
        );
      },
    );
  }

  /// Deletes a plant and updates the list
  Future<PlantDeletionResult> deletePlant(
    String id,
    List<Plant> currentPlants,
    List<Plant> searchResults,
  ) async {
    final result = await _deletePlantUseCase.call(id);

    return result.fold(
      (failure) => PlantDeletionResult.failure(failure.toString()),
      (_) {
        final updatedPlants = currentPlants.where((p) => p.id != id).toList();
        final updatedSearchResults = searchResults
            .where((p) => p.id != id)
            .toList();

        return PlantDeletionResult.success(
          deletedId: id,
          updatedPlants: updatedPlants,
          updatedSearchResults: updatedSearchResults,
        );
      },
    );
  }

  /// Converts sync entity to domain Plant
  /// Handles multiple entity types from UnifiedSyncManager
  Plant? convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      if (syncPlant == null) return null;

      // Already a domain Plant
      if (syncPlant is Plant) {
        if (syncPlant.id.isEmpty) return null;
        return syncPlant;
      }

      // BaseSyncEntity from core
      if (syncPlant is BaseSyncEntity) {
        try {
          final firebaseMap = syncPlant.toFirebaseMap();
          if (!firebaseMap.containsKey('id') ||
              !firebaseMap.containsKey('name')) {
            return null;
          }
          return Plant.fromJson(firebaseMap);
        } catch (e) {
          return null;
        }
      }

      // Raw Map from Firebase
      if (syncPlant is Map<String, dynamic>) {
        if (!syncPlant.containsKey('id') || !syncPlant.containsKey('name')) {
          return null;
        }
        return Plant.fromJson(syncPlant);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsDomainOrchestrator: Conversion error: $e');
      }
      return null;
    }
  }

  /// Detects if plant data has actually changed
  /// Avoids unnecessary state updates
  bool hasDataChanged(List<Plant> currentPlants, List<Plant> newPlants) {
    if (currentPlants.length != newPlants.length) {
      return true;
    }

    for (int i = 0; i < currentPlants.length; i++) {
      final currentPlant = currentPlants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        // Plant not found in new list
        return true;
      }

      // Compare key fields that indicate changes
      if (currentPlant.name != newPlant.name ||
          currentPlant.updatedAt != newPlant.updatedAt ||
          currentPlant.lastWatered != newPlant.lastWatered ||
          currentPlant.config?.lastFertilizerDate !=
              newPlant.config?.lastFertilizerDate) {
        return true;
      }
    }

    return false;
  }
}

/// Result types for orchestrator operations

class PlantsLoadResult {
  final List<Plant>? plants;
  final String? error;
  final bool isSuccess;

  const PlantsLoadResult._({this.plants, this.error, required this.isSuccess});

  factory PlantsLoadResult.success(List<Plant> plants) {
    return PlantsLoadResult._(plants: plants, isSuccess: true);
  }

  factory PlantsLoadResult.failure(String error) {
    return PlantsLoadResult._(error: error, isSuccess: false);
  }
}

class PlantResult {
  final Plant? plant;
  final String? error;
  final bool isSuccess;

  const PlantResult._({this.plant, this.error, required this.isSuccess});

  factory PlantResult.success(Plant plant) {
    return PlantResult._(plant: plant, isSuccess: true);
  }

  factory PlantResult.failure(String error) {
    return PlantResult._(error: error, isSuccess: false);
  }
}

class PlantOperationResult {
  final Plant? plant;
  final List<Plant>? updatedPlants;
  final String? error;
  final bool isSuccess;

  const PlantOperationResult._({
    this.plant,
    this.updatedPlants,
    this.error,
    required this.isSuccess,
  });

  factory PlantOperationResult.success({
    required Plant plant,
    required List<Plant> updatedPlants,
  }) {
    return PlantOperationResult._(
      plant: plant,
      updatedPlants: updatedPlants,
      isSuccess: true,
    );
  }

  factory PlantOperationResult.failure(String error) {
    return PlantOperationResult._(error: error, isSuccess: false);
  }
}

class PlantDeletionResult {
  final String? deletedId;
  final List<Plant>? updatedPlants;
  final List<Plant>? updatedSearchResults;
  final String? error;
  final bool isSuccess;

  const PlantDeletionResult._({
    this.deletedId,
    this.updatedPlants,
    this.updatedSearchResults,
    this.error,
    required this.isSuccess,
  });

  factory PlantDeletionResult.success({
    required String deletedId,
    required List<Plant> updatedPlants,
    required List<Plant> updatedSearchResults,
  }) {
    return PlantDeletionResult._(
      deletedId: deletedId,
      updatedPlants: updatedPlants,
      updatedSearchResults: updatedSearchResults,
      isSuccess: true,
    );
  }

  factory PlantDeletionResult.failure(String error) {
    return PlantDeletionResult._(error: error, isSuccess: false);
  }
}
