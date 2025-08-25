import 'dart:convert';

import 'package:core/core.dart';
import 'package:hive/hive.dart';

import '../../../../../core/data/models/legacy/planta_model.dart';
import '../../../domain/entities/plant.dart';
import 'plants_search_service.dart';

abstract class PlantsLocalDatasource {
  Future<List<Plant>> getPlants();
  Future<Plant?> getPlantById(String id);
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String id);
  Future<List<Plant>> searchPlants(String query);
  Future<List<Plant>> getPlantsBySpace(String spaceId);
  Future<void> clearCache();
}

class PlantsLocalDatasourceImpl implements PlantsLocalDatasource {
  static const String _boxName = 'plants';
  Box<String>? _box;

  // Cache for performance optimization
  List<Plant>? _cachedPlants;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Helper method to convert Plant entity back to PlantaModel for storage
  PlantaModel _plantToPlantaModel(Plant plant) {
    return PlantaModel(
      id: plant.id,
      nome: plant.name,
      especie: plant.species,
      espacoId: plant.spaceId,
      imagePaths: plant.imageUrls,
      observacoes: plant.notes,
      fotoBase64: plant.imageBase64,
      dataCadastro: plant.plantingDate,
      createdAtMs: plant.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: plant.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: plant.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: plant.isDirty,
      isDeleted: plant.isDeleted,
      version: plant.version,
      userId: plant.userId,
      moduleName: plant.moduleName,
    );
  }

  final PlantsSearchService _searchService = PlantsSearchService.instance;

  Future<Box<String>> get box async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  @override
  Future<List<Plant>> getPlants() async {
    try {
      // Check if cache is still valid
      if (_cachedPlants != null && _cacheTimestamp != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTimestamp!).compareTo(_cacheValidity) < 0) {
          return _cachedPlants!;
        }
      }

      final hiveBox = await box;
      final plants = <Plant>[];

      for (final key in hiveBox.keys) {
        final plantJson = hiveBox.get(key);
        if (plantJson != null) {
          final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
          final plantaModel = PlantaModel.fromJson(plantData);
          final plant = Plant.fromPlantaModel(plantaModel);
          if (!plant.isDeleted) {
            plants.add(plant);
          }
        }
      }

      // Sort by creation date (newest first)
      plants.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

      // Update cache
      _cachedPlants = plants;
      _cacheTimestamp = DateTime.now();

      // Update search index
      await _searchService.updateSearchIndexFromPlants(plants);

      return plants;
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar plantas do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<Plant?> getPlantById(String id) async {
    try {
      final hiveBox = await box;
      final plantJson = hiveBox.get(id);

      if (plantJson == null) {
        return null;
      }

      final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
      final plantaModel = PlantaModel.fromJson(plantData);
      final plant = Plant.fromPlantaModel(plantaModel);

      return plant.isDeleted ? null : plant;
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    try {
      final hiveBox = await box;
      final plantaModel = _plantToPlantaModel(plant);
      final plantJson = jsonEncode(plantaModel.toJson());
      await hiveBox.put(plant.id, plantJson);

      // Invalidate cache
      _invalidateCache();
    } catch (e) {
      throw CacheFailure(
        'Erro ao salvar planta no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    try {
      final hiveBox = await box;
      final plantaModel = _plantToPlantaModel(plant);
      final plantJson = jsonEncode(plantaModel.toJson());
      await hiveBox.put(plant.id, plantJson);

      // Invalidate cache
      _invalidateCache();
    } catch (e) {
      throw CacheFailure(
        'Erro ao atualizar planta no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    try {
      final hiveBox = await box;

      // Get existing plant first
      final plantJson = hiveBox.get(id);
      if (plantJson != null) {
        final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
        final plantaModel = PlantaModel.fromJson(plantData);
        final plant = Plant.fromPlantaModel(plantaModel);

        // Soft delete - mark as deleted
        final deletedPlant = plant.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        final deletedPlantaModel = _plantToPlantaModel(deletedPlant);
        final updatedJson = jsonEncode(deletedPlantaModel.toJson());
        await hiveBox.put(id, updatedJson);

        // Invalidate cache
        _invalidateCache();
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao deletar planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Plant>> searchPlants(String query) async {
    try {
      // Use optimized search service and convert result
      final plantaModels = await _searchService.searchWithDebounce(
        query,
        const Duration(milliseconds: 300),
      );

      // Convert PlantaModel to Plant
      return plantaModels
          .map((plantaModel) => Plant.fromPlantaModel(plantaModel))
          .toList();
    } catch (e) {
      // Fallback to basic search if search service fails
      try {
        final allPlants = await getPlants();
        final searchQuery = query.toLowerCase().trim();

        return allPlants.where((plant) {
          final name = plant.name.toLowerCase();
          final species = (plant.species ?? '').toLowerCase();
          final notes = (plant.notes ?? '').toLowerCase();

          return name.contains(searchQuery) ||
              species.contains(searchQuery) ||
              notes.contains(searchQuery);
        }).toList();
      } catch (fallbackError) {
        throw CacheFailure(
          'Erro ao buscar plantas no cache local: ${fallbackError.toString()}',
        );
      }
    }
  }

  @override
  Future<List<Plant>> getPlantsBySpace(String spaceId) async {
    try {
      final allPlants = await getPlants();
      return allPlants.where((plant) => plant.spaceId == spaceId).toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar plantas por espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final hiveBox = await box;
      await hiveBox.clear();

      // Clear all caches
      _invalidateCache();
      _searchService.clearCache();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }

  /// Invalidate memory cache and search cache
  void _invalidateCache() {
    _cachedPlants = null;
    _cacheTimestamp = null;
    _searchService.clearCache();
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'plantsCache': {
        'cached': _cachedPlants != null,
        'cacheSize': _cachedPlants?.length ?? 0,
        'cacheAge':
            _cacheTimestamp != null
                ? DateTime.now().difference(_cacheTimestamp!).inMinutes
                : null,
      },
      'searchCache': _searchService.getCacheStats(),
    };
  }
}
