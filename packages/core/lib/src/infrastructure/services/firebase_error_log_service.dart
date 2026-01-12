import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/error_log_entity.dart';
import '../../domain/repositories/i_error_log_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação do repositório de logs de erro usando Firebase Firestore
/// 
/// Collection: `error_logs`
/// 
/// Regras de segurança:
/// - CREATE: Qualquer usuário (erros automáticos, mesmo não autenticado)
/// - READ/UPDATE/DELETE: Apenas admin autenticado
class FirebaseErrorLogService implements IErrorLogRepository {
  FirebaseErrorLogService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Nome da collection no Firestore
  static const String _collectionName = 'error_logs';

  /// Referência para a collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<Either<Failure, String>> logError(ErrorLogEntity error) async {
    try {
      final docRef = await _collection.add(error.toMap());
      return Right(docRef.id);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao registrar log: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementOccurrences(String errorHash) async {
    try {
      final snapshot = await _collection
          .where('errorHash', isEqualTo: errorHash)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'occurrences': FieldValue.increment(1),
          'lastOccurrence': FieldValue.serverTimestamp(),
        });
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao incrementar ocorrências: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ErrorLogEntity?>> getErrorByHash(String errorHash) async {
    try {
      final snapshot = await _collection
          .where('errorHash', isEqualTo: errorHash)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      final doc = snapshot.docs.first;
      return Right(ErrorLogEntity.fromMap(doc.data(), doc.id));
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar erro por hash: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ErrorLogEntity>>> getErrors({
    ErrorStatus? status,
    ErrorType? type,
    ErrorSeverity? severity,
    String? calculatorId,
    int limit = 50,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.firestoreName);
      }

      if (type != null) {
        query = query.where('errorType', isEqualTo: type.name);
      }

      if (severity != null) {
        query = query.where('severity', isEqualTo: severity.name);
      }

      if (calculatorId != null) {
        query = query.where('calculatorId', isEqualTo: calculatorId);
      }

      if (lastDocumentId != null) {
        final lastDoc = await _collection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final errors = snapshot.docs
          .map((doc) => ErrorLogEntity.fromMap(doc.data(), doc.id))
          .toList();

      return Right(errors);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ErrorLogEntity>> getErrorById(String id) async {
    try {
      final doc = await _collection.doc(id).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Erro não encontrado'));
      }

      return Right(ErrorLogEntity.fromMap(doc.data()!, doc.id));
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao buscar log: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateErrorStatus(
    String id,
    ErrorStatus status, {
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.firestoreName,
      };

      if (status == ErrorStatus.fixed || status == ErrorStatus.wontFix) {
        updates['resolvedAt'] = FieldValue.serverTimestamp();
      }

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      await _collection.doc(id).update(updates);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao atualizar status: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateErrorSeverity(
    String id,
    ErrorSeverity severity,
  ) async {
    try {
      await _collection.doc(id).update({
        'severity': severity.name,
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao atualizar severidade: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteError(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao deletar erro: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteErrors(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_collection.doc(id));
      }
      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao deletar erros: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ErrorLogEntity>>> watchErrors({
    ErrorStatus? status,
    ErrorType? type,
    ErrorSeverity? severity,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> query = _collection
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.firestoreName);
    }

    if (type != null) {
      query = query.where('errorType', isEqualTo: type.name);
    }

    if (severity != null) {
      query = query.where('severity', isEqualTo: severity.name);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      try {
        final errors = snapshot.docs
            .map((doc) => ErrorLogEntity.fromMap(doc.data(), doc.id))
            .toList();
        return Right(errors);
      } catch (e) {
        return Left(ServerFailure('Erro ao processar logs: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, Map<ErrorStatus, int>>> getErrorCounts() async {
    try {
      final counts = <ErrorStatus, int>{};

      for (final status in ErrorStatus.values) {
        final snapshot = await _collection
            .where('status', isEqualTo: status.firestoreName)
            .count()
            .get();
        counts[status] = snapshot.count ?? 0;
      }

      return Right(counts);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao contar logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<ErrorType, int>>> getErrorCountsByType() async {
    try {
      final counts = <ErrorType, int>{};

      for (final type in ErrorType.values) {
        final snapshot = await _collection
            .where('errorType', isEqualTo: type.name)
            .count()
            .get();
        counts[type] = snapshot.count ?? 0;
      }

      return Right(counts);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao contar logs por tipo: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getErrorsByCalculator() async {
    try {
      // Busca todos os erros com calculatorId não nulo
      final snapshot = await _collection
          .where('calculatorId', isNull: false)
          .get();

      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final calcId = data['calculatorId'] as String?;
        final calcName = data['calculatorName'] as String? ?? calcId ?? 'Desconhecido';
        
        if (calcName.isNotEmpty) {
          counts[calcName] = (counts[calcName] ?? 0) + 1;
        }
      }

      return Right(counts);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao agrupar por calculadora: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> cleanupOldErrors(int days) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      // Busca erros resolvidos ou ignorados mais antigos que o período
      final snapshot = await _collection
          .where('status', whereIn: [
            ErrorStatus.fixed.firestoreName,
            ErrorStatus.ignored.firestoreName,
            ErrorStatus.wontFix.firestoreName,
          ])
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(0);
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return Right(snapshot.docs.length);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Erro ao limpar logs antigos: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
}
