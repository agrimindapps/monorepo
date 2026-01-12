import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/feedback_entity.dart';
import '../../domain/repositories/i_feedback_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação do repositório de feedback usando Firebase Firestore
/// 
/// Collection: `feedback`
/// 
/// Regras de segurança:
/// - CREATE: Qualquer usuário (mesmo não autenticado)
/// - READ/UPDATE/DELETE: Apenas admin autenticado
class FirebaseFeedbackService implements IFeedbackRepository {
  FirebaseFeedbackService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Nome da collection no Firestore
  static const String _collectionName = 'feedback';

  /// Referência para a collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<Either<Failure, String>> submitFeedback(FeedbackEntity feedback) async {
    try {
      final docRef = await _collection.add(feedback.toMap());
      return Right(docRef.id);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao enviar feedback: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> getFeedbacks({
    FeedbackStatus? status,
    FeedbackType? type,
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _collection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final feedbacks = snapshot.docs
          .map((doc) => FeedbackEntity.fromMap(doc.data(), doc.id))
          .toList();

      return Right(feedbacks);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar feedbacks: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) {
        return const Left(NotFoundFailure('Feedback não encontrado'));
      }

      return Right(FeedbackEntity.fromMap(doc.data()!, doc.id));
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar feedback: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFeedbackStatus(
    String id,
    FeedbackStatus status, {
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'reviewedAt': FieldValue.serverTimestamp(),
      };

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      await _collection.doc(id).update(updates);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao atualizar feedback: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFeedback(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao deletar feedback: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<FeedbackEntity>>> watchFeedbacks({
    FeedbackStatus? status,
    FeedbackType? type,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _collection
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      try {
        final feedbacks = snapshot.docs
            .map((doc) => FeedbackEntity.fromMap(doc.data(), doc.id))
            .toList();
        return Right(feedbacks);
      } catch (e) {
        return Left(ServerFailure('Erro ao processar feedbacks: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, Map<FeedbackStatus, int>>> getFeedbackCounts() async {
    try {
      final counts = <FeedbackStatus, int>{};
      
      for (final status in FeedbackStatus.values) {
        final snapshot = await _collection
            .where('status', isEqualTo: status.name)
            .count()
            .get();
        counts[status] = snapshot.count ?? 0;
      }

      return Right(counts);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao contar feedbacks: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
}
