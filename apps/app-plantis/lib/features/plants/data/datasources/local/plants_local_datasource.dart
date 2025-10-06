import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

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
  static const String _boxName = 'plants'; // Usa box do UnifiedSyncManager
  Box<dynamic>?
  _box; // Sem tipo específico para aceitar Box<dynamic> ou Box<String>
  List<Plant>? _cachedPlants;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  final PlantsSearchService _searchService = PlantsSearchService.instance;

  Future<Box<dynamic>> get box async {
    if (_box != null) return _box!;
    if (Hive.isBoxOpen(_boxName)) {
      if (kDebugMode) {
        debugPrint('ℹ️ Box "$_boxName" já está aberta - reutilizando');
      }
      _box = Hive.box(_boxName);
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<List<Plant>> getPlants() async {
    try {
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
          final plantJson = hiveBox.get(key) as String?;
          if (plantJson != null) {
            final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
            final plant = PlantModel.fromJson(plantData);
            if (!plant.isDeleted) {
              plants.add(plant);
            }
          }
        } catch (e) {
          debugPrint('Found corrupted plant data for key $key: $e');
          try {
            await hiveBox.delete(key);
            debugPrint('Removed corrupted plant data for key: $key');
          } catch (deleteError) {
            debugPrint(
              'Failed to remove corrupted data for key $key: $deleteError',
            );
          }
          continue;
        }
      }
      plants.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      _cachedPlants = plants;
      _cacheTimestamp = DateTime.now();
      await _searchService.updateSearchIndexFromPlants(plants);

      return plants;
    } catch (e) {
      throw Exception('Erro ao buscar plantas do cache local: ${e.toString()}');
    }
  }

  @override
  Future<Plant?> getPlantById(String id) async {
    try {
      final hiveBox = await box;
      final plantJson = hiveBox.get(id) as String?;

      if (plantJson == null) {
        return null;
      }

      try {
        final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
        final plant = PlantModel.fromJson(plantData);

        return plant.isDeleted ? null : plant;
      } catch (corruptionError) {
        debugPrint('Found corrupted plant data for ID $id: $corruptionError');
        try {
          await hiveBox.delete(id);
          debugPrint('Removed corrupted plant data for ID: $id');
        } catch (deleteError) {
          debugPrint(
            'Failed to remove corrupted data for ID $id: $deleteError',
          );
        }
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    try {
      if (kDebugMode) {
        debugPrint('🌱 PlantsLocalDatasourceImpl.addPlant() - Iniciando');
        debugPrint(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - plant.id: ${plant.id}',
        );
        debugPrint(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - plant.name: ${plant.name}',
        );
      }

      final hiveBox = await box;
      if (hiveBox.containsKey(plant.id)) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ PlantsLocalDatasourceImpl.addPlant() - Planta já existe com id: ${plant.id}',
          );
        }
      }

      final plantModel = PlantModel.fromEntity(plant);
      final plantJson = jsonEncode(plantModel.toJson());

      if (kDebugMode) {
        debugPrint(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - Gravando no Hive',
        );
      }

      await hiveBox.put(plant.id, plantJson);

      if (kDebugMode) {
        debugPrint(
          '✅ PlantsLocalDatasourceImpl.addPlant() - Gravado com sucesso',
        );
        debugPrint(
          '🌱 PlantsLocalDatasourceImpl.addPlant() - Total de plantas no box: ${hiveBox.length}',
        );
      }
      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsLocalDatasourceImpl.addPlant() - Erro: $e');
      }
      throw Exception('Erro ao salvar planta no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    try {
      final hiveBox = await box;
      final plantModel = PlantModel.fromEntity(plant);
      final plantJson = jsonEncode(plantModel.toJson());
      await hiveBox.put(plant.id, plantJson);
      _invalidateCache();
    } catch (e) {
      throw Exception(
        'Erro ao atualizar planta no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    try {
      final hiveBox = await box;
      final plantJson = hiveBox.get(id) as String?;
      if (plantJson != null) {
        final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
        final plant = PlantModel.fromJson(plantData);
        final deletedPlant = plant.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isDirty: true,
        );

        final updatedJson = jsonEncode(deletedPlant.toJson());
        await hiveBox.put(id, updatedJson);
        _invalidateCache();
      }
    } catch (e) {
      throw Exception('Erro ao deletar planta do cache local: ${e.toString()}');
    }
  }

  /// Remove fisicamente a planta do Hive (para resolver duplicações)
  @override
  Future<void> hardDeletePlant(String id) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Iniciando',
        );
        debugPrint('🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - id: $id');
      }

      final hiveBox = await box;
      final exists = hiveBox.containsKey(id);
      if (kDebugMode) {
        debugPrint(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Registro existe: $exists',
        );
        debugPrint(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Total antes da remoção: ${hiveBox.length}',
        );
      }

      await hiveBox.delete(id);

      if (kDebugMode) {
        debugPrint(
          '✅ PlantsLocalDatasourceImpl.hardDeletePlant() - Removido fisicamente',
        );
        debugPrint(
          '🗑️ PlantsLocalDatasourceImpl.hardDeletePlant() - Total após remoção: ${hiveBox.length}',
        );
      }
      _invalidateCache();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsLocalDatasourceImpl.hardDeletePlant() - Erro: $e');
      }
      throw Exception(
        'Erro ao remover fisicamente planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Plant>> searchPlants(String query) async {
    try {
      final results = await _searchService.searchWithDebounce(
        query,
        const Duration(milliseconds: 300),
      );

      return results;
    } catch (e) {
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
        throw Exception(
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
      throw Exception(
        'Erro ao buscar plantas por espaço no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final hiveBox = await box;
      await hiveBox.clear();
      _invalidateCache();
      _searchService.clearCache();
    } catch (e) {
      throw Exception('Erro ao limpar cache local: ${e.toString()}');
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
