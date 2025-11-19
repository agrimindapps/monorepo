import 'package:core/core.dart' hide Column;

import '../../../../../core/services/rate_limiter_service.dart';
import '../../models/space_model.dart';

abstract class SpacesRemoteDatasource {
  Future<List<SpaceModel>> getSpaces(String userId);
  Future<SpaceModel> getSpaceById(String id, String userId);
  Future<SpaceModel> addSpace(SpaceModel space, String userId);
  Future<SpaceModel> updateSpace(SpaceModel space, String userId);
  Future<void> deleteSpace(String id, String userId);
  Future<void> syncSpaces(List<SpaceModel> spaces, String userId);
}

@LazySingleton(as: SpacesRemoteDatasource)
class SpacesRemoteDatasourceImpl implements SpacesRemoteDatasource {
  final FirebaseFirestore firestore;
  final RateLimiterService rateLimiter;

  SpacesRemoteDatasourceImpl({
    required this.firestore,
    required this.rateLimiter,
  });

  String _getUserSpacesPath(String userId) => 'users/$userId/spaces';

  CollectionReference _getSpacesCollection(String userId) {
    return firestore.collection(_getUserSpacesPath(userId));
  }

  @override
  Future<List<SpaceModel>> getSpaces(String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.getSpaces');

      final snapshot =
          await _getSpacesCollection(userId)
              .where('isDeleted', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) => SpaceModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao buscar espaços: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erro inesperado ao buscar espaços: ${e.toString()}');
    }
  }

  @override
  Future<SpaceModel> getSpaceById(String id, String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.getSpaceById');

      final doc = await _getSpacesCollection(userId).doc(id).get();

      if (!doc.exists) {
        throw const ServerFailure('Espaço não encontrado');
      }

      final data = doc.data() as Map<String, dynamic>;
      final space = SpaceModel.fromJson({...data, 'id': doc.id});

      if (space.isDeleted) {
        throw const ServerFailure('Espaço não encontrado');
      }

      return space;
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao buscar espaço: ${e.message}');
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Erro inesperado ao buscar espaço: ${e.toString()}');
    }
  }

  @override
  Future<SpaceModel> addSpace(SpaceModel space, String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.addSpace');

      final spaceData = space.toJson();
      spaceData.remove('id'); // Remove ID from data, it will be the document ID

      final docRef = await _getSpacesCollection(userId).add(spaceData);
      return space.copyWith(id: docRef.id, isDirty: false);
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao adicionar espaço: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao adicionar espaço: ${e.toString()}',
      );
    }
  }

  @override
  Future<SpaceModel> updateSpace(SpaceModel space, String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.updateSpace');

      final spaceData = space.toJson();
      spaceData.remove('id'); // Remove ID from data

      await _getSpacesCollection(userId).doc(space.id).update(spaceData);

      return space.copyWith(isDirty: false);
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao atualizar espaço: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao atualizar espaço: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteSpace(String id, String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.deleteSpace');

      await _getSpacesCollection(userId).doc(id).update({
        'isDeleted': true,
        'updatedAt': Timestamp.now(),
        'needsSync': false,
      });
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao deletar espaço: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erro inesperado ao deletar espaço: ${e.toString()}');
    }
  }

  @override
  Future<void> syncSpaces(List<SpaceModel> spaces, String userId) async {
    try {
      await rateLimiter.checkLimit('spaces.syncSpaces');

      final batch = firestore.batch();
      final collection = _getSpacesCollection(userId);

      for (final space in spaces) {
        if (space.needsSync) {
          final spaceData = space.toJson();
          spaceData.remove('id');
          spaceData['needsSync'] = false;

          final docRef = collection.doc(space.id);
          batch.set(docRef, spaceData, SetOptions(merge: true));
        }
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerFailure('Erro ao sincronizar espaços: ${e.message}');
    } catch (e) {
      throw ServerFailure(
        'Erro inesperado ao sincronizar espaços: ${e.toString()}',
      );
    }
  }
}
