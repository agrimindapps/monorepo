import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/animal_model.dart';

abstract class AnimalRemoteDataSource {
  Future<List<AnimalModel>> getAnimals(String userId);
  Future<AnimalModel?> getAnimalById(String userId, String id);
  Future<void> addAnimal(String userId, AnimalModel animal);
  Future<void> updateAnimal(String userId, AnimalModel animal);
  Future<void> deleteAnimal(String userId, String id);
}

class AnimalRemoteDataSourceImpl implements AnimalRemoteDataSource {
  final FirebaseFirestore firestore;
  
  AnimalRemoteDataSourceImpl({required this.firestore});
  
  CollectionReference _getUserAnimalsCollection(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('animals');
  }

  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    try {
      final querySnapshot = await _getUserAnimalsCollection(userId)
          .where('is_deleted', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AnimalModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar animais: $e');
    }
  }

  @override
  Future<AnimalModel?> getAnimalById(String userId, String id) async {
    try {
      final docSnapshot = await _getUserAnimalsCollection(userId)
          .doc(id)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data['is_deleted'] == false) {
          return AnimalModel.fromJson({
            ...data,
            'id': docSnapshot.id,
          });
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar animal: $e');
    }
  }

  @override
  Future<void> addAnimal(String userId, AnimalModel animal) async {
    try {
      await _getUserAnimalsCollection(userId)
          .doc(animal.id)
          .set(animal.toJson());
    } catch (e) {
      throw Exception('Erro ao adicionar animal: $e');
    }
  }

  @override
  Future<void> updateAnimal(String userId, AnimalModel animal) async {
    try {
      await _getUserAnimalsCollection(userId)
          .doc(animal.id)
          .update(animal.toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar animal: $e');
    }
  }

  @override
  Future<void> deleteAnimal(String userId, String id) async {
    try {
      await _getUserAnimalsCollection(userId)
          .doc(id)
          .update({
            'is_deleted': true,
            'updated_at': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Erro ao deletar animal: $e');
    }
  }
}