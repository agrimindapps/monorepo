import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:core/core.dart';
import '../../models/plant_model.dart';

abstract class PlantsLocalDatasource {
  Future<List<PlantModel>> getPlants();
  Future<PlantModel?> getPlantById(String id);
  Future<void> addPlant(PlantModel plant);
  Future<void> updatePlant(PlantModel plant);
  Future<void> deletePlant(String id);
  Future<List<PlantModel>> searchPlants(String query);
  Future<List<PlantModel>> getPlantsBySpace(String spaceId);
  Future<void> clearCache();
}

class PlantsLocalDatasourceImpl implements PlantsLocalDatasource {
  static const String _boxName = 'plants';
  Box<String>? _box;

  Future<Box<String>> get box async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  @override
  Future<List<PlantModel>> getPlants() async {
    try {
      final hiveBox = await box;
      final plants = <PlantModel>[];
      
      for (final key in hiveBox.keys) {
        final plantJson = hiveBox.get(key);
        if (plantJson != null) {
          final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
          final plant = PlantModel.fromJson(plantData);
          if (!plant.isDeleted) {
            plants.add(plant);
          }
        }
      }
      
      // Sort by creation date (newest first)
      plants.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      
      return plants;
    } catch (e) {
      throw CacheFailure('Erro ao buscar plantas do cache local: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel?> getPlantById(String id) async {
    try {
      final hiveBox = await box;
      final plantJson = hiveBox.get(id);
      
      if (plantJson == null) {
        return null;
      }
      
      final plantData = jsonDecode(plantJson) as Map<String, dynamic>;
      final plant = PlantModel.fromJson(plantData);
      
      return plant.isDeleted ? null : plant;
    } catch (e) {
      throw CacheFailure('Erro ao buscar planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> addPlant(PlantModel plant) async {
    try {
      final hiveBox = await box;
      final plantJson = jsonEncode(plant.toJson());
      await hiveBox.put(plant.id, plantJson);
    } catch (e) {
      throw CacheFailure('Erro ao salvar planta no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePlant(PlantModel plant) async {
    try {
      final hiveBox = await box;
      final plantJson = jsonEncode(plant.toJson());
      await hiveBox.put(plant.id, plantJson);
    } catch (e) {
      throw CacheFailure('Erro ao atualizar planta no cache local: ${e.toString()}');
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
      }
    } catch (e) {
      throw CacheFailure('Erro ao deletar planta do cache local: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantModel>> searchPlants(String query) async {
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
    } catch (e) {
      throw CacheFailure('Erro ao buscar plantas no cache local: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantModel>> getPlantsBySpace(String spaceId) async {
    try {
      final allPlants = await getPlants();
      return allPlants.where((plant) => plant.spaceId == spaceId).toList();
    } catch (e) {
      throw CacheFailure('Erro ao buscar plantas por espaço no cache local: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final hiveBox = await box;
      await hiveBox.clear();
    } catch (e) {
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }
}