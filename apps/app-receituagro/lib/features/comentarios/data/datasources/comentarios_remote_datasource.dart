import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../comentario_model.dart';

/// Remote datasource for comentarios using Firebase Firestore
/// Follows app-plantis sync pattern (Gold Standard 10/10)
abstract class ComentariosRemoteDatasource {
  /// Fetch all comentarios for a user (excludes deleted)
  Future<List<ComentarioModel>> getComentarios(String userId);

  /// Fetch single comentario by ID
  Future<ComentarioModel> getComentarioById(String id, String userId);

  /// Add new comentario to Firebase
  Future<ComentarioModel> addComentario(ComentarioModel comentario, String userId);

  /// Update existing comentario in Firebase
  Future<ComentarioModel> updateComentario(ComentarioModel comentario, String userId);

  /// Soft delete comentario (sets status = false)
  Future<void> deleteComentario(String id, String userId);

  /// Fetch comentarios by context (pkIdentificador)
  Future<List<ComentarioModel>> getComentariosByContext(
    String pkIdentificador,
    String userId,
  );

  /// Fetch comentarios by tool (ferramenta)
  Future<List<ComentarioModel>> getComentariosByTool(
    String ferramenta,
    String userId,
  );

  /// Batch sync multiple comentarios for better performance
  Future<void> syncComentarios(List<ComentarioModel> comentarios, String userId);
}

@LazySingleton(as: ComentariosRemoteDatasource)
class ComentariosRemoteDatasourceImpl implements ComentariosRemoteDatasource {
  final FirebaseFirestore _firestore;

  ComentariosRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Firebase collection path: users/{userId}/comentarios
  String _getUserComentariosPath(String userId) => 'users/$userId/comentarios';

  CollectionReference _getComentariosCollection(String userId) {
    return _firestore.collection(_getUserComentariosPath(userId));
  }

  @override
  Future<List<ComentarioModel>> getComentarios(String userId) async {
    try {
      final snapshot = await _getComentariosCollection(userId)
          .where('status', isEqualTo: true) // Only active comments
          .orderBy('createdAt', descending: true)
          .get();

      final comentarios = snapshot.docs
          .map((doc) => ComentarioModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      if (kDebugMode) {
        print('✅ ComentariosRemoteDatasource: Fetched ${comentarios.length} comentarios');
      }

      return comentarios;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ ComentariosRemoteDatasource: Firebase error: ${e.message}');
      }
      throw Exception('Erro ao buscar comentários: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ ComentariosRemoteDatasource: Unexpected error: $e');
      }
      throw Exception('Erro inesperado ao buscar comentários: ${e.toString()}');
    }
  }

  @override
  Future<ComentarioModel> getComentarioById(String id, String userId) async {
    try {
      final doc = await _getComentariosCollection(userId).doc(id).get();

      if (!doc.exists) {
        throw Exception('Comentário não encontrado');
      }

      final data = doc.data() as Map<String, dynamic>;
      final comentario = ComentarioModel.fromJson({...data, 'id': doc.id});

      // Check if deleted (status = false)
      if (!comentario.status) {
        throw Exception('Comentário não encontrado');
      }

      return comentario;
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar comentário: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro inesperado ao buscar comentário: ${e.toString()}');
    }
  }

  @override
  Future<ComentarioModel> addComentario(
    ComentarioModel comentario,
    String userId,
  ) async {
    try {
      final comentarioData = comentario.toJson();
      comentarioData.remove('id'); // Remove ID, it will be the document ID

      final docRef = await _getComentariosCollection(userId).add(comentarioData);

      if (kDebugMode) {
        print('✅ ComentariosRemoteDatasource: Added comentario with ID ${docRef.id}');
      }

      return comentario.copyWith(
        id: docRef.id,
        synchronized: true,
        syncedAt: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      throw Exception('Erro ao adicionar comentário: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao adicionar comentário: ${e.toString()}');
    }
  }

  @override
  Future<ComentarioModel> updateComentario(
    ComentarioModel comentario,
    String userId,
  ) async {
    try {
      final comentarioData = comentario.toJson();
      comentarioData.remove('id'); // Remove ID from data

      await _getComentariosCollection(userId).doc(comentario.id).update(comentarioData);

      if (kDebugMode) {
        print('✅ ComentariosRemoteDatasource: Updated comentario ${comentario.id}');
      }

      return comentario.copyWith(
        synchronized: true,
        syncedAt: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      throw Exception('Erro ao atualizar comentário: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar comentário: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComentario(String id, String userId) async {
    try {
      // Soft delete: set status = false
      await _getComentariosCollection(userId).doc(id).update({
        'status': false,
        'updatedAt': Timestamp.now(),
      });

      if (kDebugMode) {
        print('✅ ComentariosRemoteDatasource: Soft deleted comentario $id');
      }
    } on FirebaseException catch (e) {
      throw Exception('Erro ao deletar comentário: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao deletar comentário: ${e.toString()}');
    }
  }

  @override
  Future<List<ComentarioModel>> getComentariosByContext(
    String pkIdentificador,
    String userId,
  ) async {
    try {
      final snapshot = await _getComentariosCollection(userId)
          .where('status', isEqualTo: true)
          .where('pkIdentificador', isEqualTo: pkIdentificador)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ComentarioModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar comentários por contexto: ${e.message}');
    } catch (e) {
      throw Exception(
        'Erro inesperado ao buscar comentários por contexto: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ComentarioModel>> getComentariosByTool(
    String ferramenta,
    String userId,
  ) async {
    try {
      final snapshot = await _getComentariosCollection(userId)
          .where('status', isEqualTo: true)
          .where('ferramenta', isEqualTo: ferramenta)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ComentarioModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Erro ao buscar comentários por ferramenta: ${e.message}');
    } catch (e) {
      throw Exception(
        'Erro inesperado ao buscar comentários por ferramenta: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> syncComentarios(
    List<ComentarioModel> comentarios,
    String userId,
  ) async {
    if (comentarios.isEmpty) return;

    try {
      const batchSize = 50; // Firebase batch size limit
      final collection = _getComentariosCollection(userId);

      for (int i = 0; i < comentarios.length; i += batchSize) {
        final batch = comentarios.skip(i).take(batchSize).toList();
        final writeBatch = _firestore.batch();

        for (final comentario in batch) {
          final comentarioData = comentario.toJson();
          comentarioData.remove('id');

          final docRef = collection.doc(comentario.id);
          writeBatch.set(docRef, comentarioData, SetOptions(merge: true));
        }

        await writeBatch.commit();

        if (kDebugMode) {
          print('✅ Batch sync: ${batch.length} comentarios committed');
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('Erro no batch sync de comentários: ${e.message}');
    } catch (e) {
      throw Exception(
        'Erro inesperado no batch sync de comentários: ${e.toString()}',
      );
    }
  }
}
