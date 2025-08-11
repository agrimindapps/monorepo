import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import '../../models/space_model.dart';

abstract class SpacesRemoteDatasource {
  Future<List<SpaceModel>> getSpaces(String userId);
  Future<SpaceModel> getSpaceById(String userId, String id);
  Future<List<SpaceModel>> searchSpaces(String userId, String query);
  Future<SpaceModel> addSpace(String userId, SpaceModel space);
  Future<SpaceModel> updateSpace(String userId, SpaceModel space);
  Future<void> deleteSpace(String userId, String id);
  Future<int> getPlantCountBySpace(String userId, String spaceId);
}

class SpacesRemoteDatasourceImpl implements SpacesRemoteDatasource {
  final FirebaseFirestore firestore;
  
  SpacesRemoteDatasourceImpl({required this.firestore});

  CollectionReference _getUserSpacesCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('spaces');
  }

  CollectionReference _getUserPlantsCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('plants');
  }

  @override
  Future<List<SpaceModel>> getSpaces(String userId) async {
    try {
      final snapshot = await _getUserSpacesCollection(userId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => SpaceModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      throw const ServerFailure('Erro ao buscar espaços');
    }
  }

  @override
  Future<SpaceModel> getSpaceById(String userId, String id) async {
    try {
      final doc = await _getUserSpacesCollection(userId).doc(id).get();
      
      if (!doc.exists) {
        throw const NotFoundFailure('Espaço não encontrado');
      }

      return SpaceModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw const ServerFailure('Erro ao buscar espaço');
    }
  }

  @override
  Future<List<SpaceModel>> searchSpaces(String userId, String query) async {
    try {
      final snapshot = await _getUserSpacesCollection(userId)
          .orderBy('name')
          .startAt([query.toLowerCase()])
          .endAt([query.toLowerCase() + '\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => SpaceModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      // Fallback to client-side search if Firestore query fails
      final allSpaces = await getSpaces(userId);
      final queryLower = query.toLowerCase();
      
      return allSpaces.where((space) {
        return space.name.toLowerCase().contains(queryLower) ||
               (space.description?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    }
  }

  @override
  Future<SpaceModel> addSpace(String userId, SpaceModel space) async {
    try {
      final docRef = _getUserSpacesCollection(userId).doc(space.id);
      final spaceData = space.toJson();
      spaceData.remove('id'); // Remove id from data as it's the document ID
      
      await docRef.set(spaceData);
      
      return space.copyWith(isDirty: false) as SpaceModel;
    } catch (e) {
      throw const ServerFailure('Erro ao adicionar espaço');
    }
  }

  @override
  Future<SpaceModel> updateSpace(String userId, SpaceModel space) async {
    try {
      final docRef = _getUserSpacesCollection(userId).doc(space.id);
      final spaceData = space.toJson();
      spaceData.remove('id'); // Remove id from data as it's the document ID
      
      await docRef.update(spaceData);
      
      return space.copyWith(isDirty: false) as SpaceModel;
    } catch (e) {
      throw const ServerFailure('Erro ao atualizar espaço');
    }
  }

  @override
  Future<void> deleteSpace(String userId, String id) async {
    try {
      await _getUserSpacesCollection(userId).doc(id).delete();
    } catch (e) {
      throw const ServerFailure('Erro ao deletar espaço');
    }
  }

  @override
  Future<int> getPlantCountBySpace(String userId, String spaceId) async {
    try {
      final snapshot = await _getUserPlantsCollection(userId)
          .where('spaceId', isEqualTo: spaceId)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw const ServerFailure('Erro ao contar plantas do espaço');
    }
  }
}