import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../../core/services/rate_limiter_service.dart';
import '../../models/plant_model.dart';

abstract class PlantsRemoteDatasource {
  Future<List<PlantModel>> getPlants(String userId);
  Future<PlantModel> getPlantById(String id, String userId);
  Future<PlantModel> addPlant(PlantModel plant, String userId);
  Future<PlantModel> updatePlant(PlantModel plant, String userId);
  Future<void> deletePlant(String id, String userId);
  Future<List<PlantModel>> searchPlants(String query, String userId);
  Future<List<PlantModel>> getPlantsBySpace(String spaceId, String userId);
  Future<void> syncPlants(List<PlantModel> plants, String userId);
}

class PlantsRemoteDatasourceImpl implements PlantsRemoteDatasource {
  final FirebaseFirestore firestore;
  final RateLimiterService rateLimiter;

  PlantsRemoteDatasourceImpl({
    required this.firestore,
    required this.rateLimiter,
  });

  String _getUserPlantsPath(String userId) => 'users/$userId/plants';

  CollectionReference _getPlantsCollection(String userId) {
    return firestore.collection(_getUserPlantsPath(userId));
  }

  @override
  Future<List<PlantModel>> getPlants(String userId) async {
    try {
      await rateLimiter.checkLimit('plants.getPlants');

      final snapshot = await _getPlantsCollection(
        userId,
      ).where('isDeleted', isEqualTo: false).get();

      final plants = snapshot.docs
          .map(
            (doc) => PlantModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
      plants.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate); // descending order
      });

      return plants;
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao buscar plantas: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erro inesperado ao buscar plantas: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel> getPlantById(String id, String userId) async {
    try {
      await rateLimiter.checkLimit('plants.getPlantById');

      final doc = await _getPlantsCollection(userId).doc(id).get();

      if (!doc.exists) {
        throw const ServerFailure('Planta não encontrada');
      }

      final data = doc.data() as Map<String, dynamic>;
      final plant = PlantModel.fromJson({...data, 'id': doc.id});

      if (plant.isDeleted) {
        throw const ServerFailure('Planta não encontrada');
      }

      return plant;
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao buscar planta: ${e.message}');
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Erro inesperado ao buscar planta: ${e.toString()}');
    }
  }

  @override
  Future<PlantModel> addPlant(PlantModel plant, String userId) async {
    try {
      await rateLimiter.checkLimit('plants.addPlant');

      final plantData = plant.toJson();
      plantData.remove('id'); // Remove ID from data, it will be the document ID

      final docRef = await _getPlantsCollection(userId).add(plantData);
      return plant.copyWith(id: docRef.id, isDirty: false);
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao adicionar planta: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao adicionar planta: ${e.toString()}',
      );
    }
  }

  @override
  Future<PlantModel> updatePlant(PlantModel plant, String userId) async {
    try {
      await rateLimiter.checkLimit('plants.updatePlant');

      final plantData = plant.toJson();
      plantData.remove('id'); // Remove ID from data

      await _getPlantsCollection(userId).doc(plant.id).update(plantData);

      return plant.copyWith(isDirty: false);
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao atualizar planta: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao atualizar planta: ${e.toString()}',
      );
    }
  }

  /// Batch sync multiple plants for better performance
  Future<void> batchSyncPlants(List<PlantModel> plants, String userId) async {
    if (plants.isEmpty) return;

    try {
      const batchSize = 50; // Firebase batch size limit
      final collection = _getPlantsCollection(userId);

      for (int i = 0; i < plants.length; i += batchSize) {
        final batch = plants.skip(i).take(batchSize).toList();
        final writeBatch = FirebaseFirestore.instance.batch();

        for (final plant in batch) {
          final plantData = plant.toJson();
          plantData.remove('id'); // Remove ID from data

          final docRef = collection.doc(plant.id);
          writeBatch.set(docRef, plantData, SetOptions(merge: true));
        }

        await writeBatch.commit();

        if (kDebugMode) {
          print('✅ Batch sync: ${batch.length} plants committed');
        }
      }
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro no batch sync de plantas: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado no batch sync de plantas: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePlant(String id, String userId) async {
    try {
      await rateLimiter.checkLimit('plants.deletePlant');

      await _getPlantsCollection(userId).doc(id).update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
        'needsSync': false,
      });
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao deletar planta: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erro inesperado ao deletar planta: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantModel>> searchPlants(String query, String userId) async {
    try {
      final allPlants = await getPlants(userId);
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
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Erro inesperado ao buscar plantas: ${e.toString()}');
    }
  }

  @override
  Future<List<PlantModel>> getPlantsBySpace(
    String spaceId,
    String userId,
  ) async {
    try {
      await rateLimiter.checkLimit('plants.getPlantsBySpace');

      final snapshot = await _getPlantsCollection(userId)
          .where('isDeleted', isEqualTo: false)
          .where('spaceId', isEqualTo: spaceId)
          .get();

      final plants = snapshot.docs
          .map(
            (doc) => PlantModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
      plants.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate); // descending order
      });

      return plants;
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao buscar plantas por espaço: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao buscar plantas por espaço: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> syncPlants(List<PlantModel> plants, String userId) async {
    try {
      await rateLimiter.checkLimit('plants.syncPlants');

      final batch = firestore.batch();
      final collection = _getPlantsCollection(userId);

      for (final plant in plants) {
        if (plant.needsSync) {
          final plantData = plant.toJson();
          plantData.remove('id');
          plantData['needsSync'] = false;

          final docRef = collection.doc(plant.id);
          batch.set(docRef, plantData, SetOptions(merge: true));
        }
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao sincronizar plantas: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao sincronizar plantas: ${e.toString()}',
      );
    }
  }
}
