import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../domain/entities/plant.dart';
import '../../models/plant_model.dart';
import 'plants_search_service.dart';

abstract class PlantsLocalDatasource {
  Future<List<Plant>> getPlants();
  Future<Plant?> getPlantById(String id);
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String id);
  Future<void> hardDeletePlant(String id);
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
        try {
          final plantJson = hiveBox.get(key);
          if (plantJson != null) {
            final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
            final plant = PlantModel.fromJson(plantData);
            if (!plant.isDeleted) {
              plants.add(plant);
            }
          }
        } catch (e) {
          // Log corrupted data and remove from Hive
          print('Found corrupted plant data for key $key: $e');
          try {
            await hiveBox.delete(key);
            print('Removed corrupted plant data for key: $key');
          } catch (deleteError) {
            print('Failed to remove corrupted data for key $key: $deleteError');
          }
          // Continue processing other plants
          continue;
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

      try {
        final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
        final plant = PlantModel.fromJson(plantData);

        return plant.isDeleted ? null : plant;
      } catch (corruptionError) {
        // Handle corrupted individual plant data
        print('Found corrupted plant data for ID $id: $corruptionError');
        try {
          await hiveBox.delete(id);
          print('Removed corrupted plant data for ID: $id');
        } catch (deleteError) {
          print('Failed to remove corrupted data for ID $id: $deleteError');
        }
        return null;
      }
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    try {
      if (kDebugMode) {
        print('🌱 PlantsLocalDatasourceImpl.addPlant() - Iniciando');
        print(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - plant.id: ${plant.id}',
        );
        print(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - plant.name: ${plant.name}',
        );
      }

      final hiveBox = await box;

      // Verificar se a planta já existe
      if (hiveBox.containsKey(plant.id)) {
        if (kDebugMode) {
          print(
            '⚠️ PlantsLocalDatasourceImpl.addPlant() - Planta já existe com id: ${plant.id}',
          );
        }
      }

      final plantModel = PlantModel.fromEntity(plant);
      final plantJson = jsonEncode(plantModel.toJson());

      if (kDebugMode) {
        print('🌱 PlantsLocalDatasourceImpl.addPlant() - Gravando no Hive');
      }

      await hiveBox.put(plant.id, plantJson);

      if (kDebugMode) {
        print('✅ PlantsLocalDatasourceImpl.addPlant() - Gravado com sucesso');
        print(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - Total de plantas no box: ${hiveBox.length}',
        );
      }

      // Invalidate cache
      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsLocalDatasourceImpl.addPlant() - Erro: $e');
      }
      throw CacheFailure(
        'Erro ao salvar planta no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    try {
      final hiveBox = await box;
      final plantModel = PlantModel.fromEntity(plant);
      final plantJson = jsonEncode(plantModel.toJson());
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
        final plant = PlantModel.fromJson(plantData);

        // Soft delete - mark as deleted
        final deletedPlant = plant.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        final updatedJson = jsonEncode(deletedPlant.toJson());
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

  /// Remove fisicamente a planta do Hive (para resolver duplicações)
  @override
  Future<void> hardDeletePlant(String id) async {
    try {
      if (kDebugMode) {
        print('🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Iniciando');
        print('🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - id: $id');
      }

      final hiveBox = await box;

      // Verificar se existe antes de deletar
      final exists = hiveBox.containsKey(id);
      if (kDebugMode) {
        print(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Registro existe: $exists',
        );
        print(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Total antes da remoção: ${hiveBox.length}',
        );
      }

      await hiveBox.delete(id);

      if (kDebugMode) {
        print(
          '✅ PlantsLocalDatasourceImpl.hardDeletePlant() - Removido fisicamente',
        );
        print(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Total após remoção: ${hiveBox.length}',
        );
      }

      // Invalidate cache
      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsLocalDatasourceImpl.hardDeletePlant() - Erro: $e');
      }
      throw CacheFailure(
        'Erro ao remover fisicamente planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Plant>> searchPlants(String query) async {
    try {
      // Use optimized search service - now returns Plant entities directly
      final results = await _searchService.searchWithDebounce(
        query,
        const Duration(milliseconds: 300),
      );

      return results;
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
