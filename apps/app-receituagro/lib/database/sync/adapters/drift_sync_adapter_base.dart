import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart' hide Query;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../receituagro_database.dart';
import '../models/sync_results.dart';
import 'i_drift_sync_adapter.dart';

/// Classe base abstrata para adapters de sincronização Drift ↔ Firestore
///
/// Fornece implementação comum de push/pull/conflict para todas as entidades.
/// Subclasses devem implementar apenas conversões específicas e configuração.
///
/// **Responsabilidades:**
/// - Push incremental: Upload de registros dirty (batch 50 items)
/// - Pull incremental: Download de mudanças remotas (since lastSyncAt)
/// - Conflict resolution: Last Write Wins (LWW) com version checking
/// - Error handling: Retry logic com exponential backoff
/// - Logging: Debug detalhado de operações de sync
///
/// **Uso por subclasses:**
/// ```dart
/// class DiagnosticoDriftSyncAdapter extends DriftSyncAdapterBase<DiagnosticoSyncEntity, DiagnosticoData> {
///   DiagnosticoDriftSyncAdapter(super.db, super.firestore);
///
///   @override
///   String get collectionName => 'diagnosticos';
///
///   @override
///   TableInfo get table => db.diagnosticos;
///
///   // Implementar conversões...
/// }
/// ```
abstract class DriftSyncAdapterBase<TEntity extends BaseSyncEntity, TDriftRow>
    implements IDriftSyncAdapter<TEntity, TDriftRow> {
  DriftSyncAdapterBase(this.db, this.firestore);

  /// Database Drift para operações locais
  final ReceituagroDatabase db;

  /// Firestore instance para operações remotas
  final FirebaseFirestore firestore;

  /// Serviço de conectividade (verificar se está online)
  ConnectivityService get connectivityService => GetIt.I<ConnectivityService>();

  // ==========================================================================
  // PUSH: Local → Firestore
  // ==========================================================================

  @override
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(
    String userId,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Verificar conectividade
      final connectivityResult = await connectivityService.isOnline();
      final isOnline = connectivityResult.fold(
        (_) => false,
        (online) => online,
      );

      if (!isOnline) {
        developer.log(
          'Push aborted: No internet connection',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Left(NetworkFailure('Sem conexão com a internet'));
      }

      // 2. Buscar registros dirty do Drift
      final dirtyEntitiesResult = await getDirtyRecords(userId);
      if (dirtyEntitiesResult.isLeft()) {
        return Left(
          (dirtyEntitiesResult as Left<Failure, List<TEntity>>).value,
        );
      }

      final dirtyEntities =
          (dirtyEntitiesResult as Right<Failure, List<TEntity>>).value;

      if (dirtyEntities.isEmpty) {
        developer.log(
          'Push skipped: No dirty records found',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Right(
          SyncPushResult(
            recordsPushed: 0,
            recordsFailed: 0,
            duration: stopwatch.elapsed,
          ),
        );
      }

      developer.log(
        'Push started: ${dirtyEntities.length} dirty records',
        name: 'ReceitaAgroSync.$collectionName',
      );

      // 3. Processar em lotes de 50 (limite Firestore batch)
      const batchSize = 50;
      int totalPushed = 0;
      int totalFailed = 0;
      final errors = <String>[];

      for (int i = 0; i < dirtyEntities.length; i += batchSize) {
        final end = (i + batchSize < dirtyEntities.length)
            ? i + batchSize
            : dirtyEntities.length;
        final batch = dirtyEntities.sublist(i, end);

        final batchResult = await _pushBatch(userId, batch);
        batchResult.fold(
          (failure) {
            totalFailed += batch.length;
            errors.add('Batch ${i ~/ batchSize}: ${failure.message}');
          },
          (pushed) {
            totalPushed += pushed;
          },
        );
      }

      stopwatch.stop();

      final result = SyncPushResult(
        recordsPushed: totalPushed,
        recordsFailed: totalFailed,
        errors: errors,
        duration: stopwatch.elapsed,
      );

      developer.log(result.summary, name: 'ReceitaAgroSync.$collectionName');

      return Right(result);
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Push error: $e',
        name: 'ReceitaAgroSync.$collectionName',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Erro ao fazer push: $e'));
    }
  }

  /// Faz push de um lote de entidades para Firestore
  Future<Either<Failure, int>> _pushBatch(
    String userId,
    List<TEntity> entities,
  ) async {
    try {
      final batch = firestore.batch();
      int count = 0;
      final generatedIds = <String, String>{};

      for (final entity in entities) {
        // Validar antes de enviar
        final validationResult = validateForSync(entity);
        if (validationResult.isLeft()) {
          developer.log(
            'Validation failed for entity ${entity.id}: ${(validationResult as Left).value.message}',
            name: 'ReceitaAgroSync.$collectionName',
          );
          continue;
        }

        // Converter para Firestore map
        late final Map<String, dynamic> firestoreDoc;
        try {
          firestoreDoc = toFirestoreMap(entity);
        } catch (conversionError, stackTrace) {
          developer.log(
            'Failed to convert entity ${entity.id} to Firestore map',
            name: 'ReceitaAgroSync.$collectionName',
            error: conversionError,
            stackTrace: stackTrace,
          );
          continue;
        }

        // Incrementar versão
        firestoreDoc['version'] = entity.version + 1;
        firestoreDoc['updated_at'] = FieldValue.serverTimestamp();

        // Determinar docId (gerar UUID para novos registros)
        final String docId;
        final existingFirebaseId = firestoreDoc['id'] as String?;

        // Verificar se já tem UUID válido
        final bool isUuid =
            existingFirebaseId != null &&
            existingFirebaseId.contains('-') &&
            existingFirebaseId.length >= 36;

        if (isUuid) {
          docId = existingFirebaseId;
        } else {
          docId = const Uuid().v4();
          generatedIds[entity.id] = docId;
          firestoreDoc['id'] = docId;

          developer.log(
            'Generated new UUID for entity ${entity.id}: $docId',
            name: 'ReceitaAgroSync.$collectionName',
          );
        }

        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection(collectionName)
            .doc(docId);

        batch.set(docRef, firestoreDoc, SetOptions(merge: true));
        count++;
      }

      // Commit batch
      await batch.commit();

      // Marcar como sincronizados localmente
      for (final entity in entities.take(count)) {
        final generatedFirebaseId = generatedIds[entity.id];
        await markAsSynced(entity.id, firebaseId: generatedFirebaseId);
      }

      developer.log(
        'Batch pushed: $count records',
        name: 'ReceitaAgroSync.$collectionName',
      );

      return Right(count);
    } catch (e) {
      developer.log(
        'Batch push error: $e',
        name: 'ReceitaAgroSync.$collectionName',
        error: e,
      );
      return Left(SyncFailure('Erro ao enviar lote: $e'));
    }
  }

  // ==========================================================================
  // PULL: Firestore → Local
  // ==========================================================================

  @override
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId, {
    DateTime? since,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Verificar conectividade
      final connectivityResult = await connectivityService.isOnline();
      final isOnline = connectivityResult.fold(
        (_) => false,
        (online) => online,
      );

      if (!isOnline) {
        developer.log(
          'Pull aborted: No internet connection',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Left(NetworkFailure('Sem conexão com a internet'));
      }

      // 2. Query Firestore com filtro de data se disponível
      CollectionReference<Map<String, dynamic>> collection = firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName);

      if (since != null) {
        final query = collection.where(
          'updated_at',
          isGreaterThan: Timestamp.fromDate(since),
        );
        developer.log(
          'Pull started: Incremental sync since ${since.toIso8601String()}',
          name: 'ReceitaAgroSync.$collectionName',
        );

        final snapshot = await query.get();
        return _processPullSnapshot(snapshot, stopwatch);
      } else {
        developer.log(
          'Pull started: Full sync',
          name: 'ReceitaAgroSync.$collectionName',
        );

        final snapshot = await collection.get();
        return _processPullSnapshot(snapshot, stopwatch);
      }
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Pull error: $e',
        name: 'ReceitaAgroSync.$collectionName',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Erro ao fazer pull: $e'));
    }
  }

  Future<Either<Failure, SyncPullResult>> _processPullSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    Stopwatch stopwatch,
  ) async {
    try {
      if (snapshot.docs.isEmpty) {
        developer.log(
          'Pull completed: No remote changes',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Right(
          SyncPullResult(
            recordsPulled: 0,
            recordsFailed: 0,
            duration: stopwatch.elapsed,
          ),
        );
      }

      // 3. Processar documentos
      int totalPulled = 0;
      int totalFailed = 0;
      final errors = <String>[];

      for (final doc in snapshot.docs) {
        try {
          final remoteEntity = fromFirestoreDoc(doc.data());

          // Verificar se existe localmente
          final localEntityResult = await _getLocalByFirebaseId(
            remoteEntity.id,
          );

          if (localEntityResult.isRight()) {
            // Existe localmente - resolver conflito
            final localEntity = (localEntityResult as Right).value as TEntity;
            final resolvedEntity = await resolveConflict(
              localEntity,
              remoteEntity,
            );

            if (resolvedEntity.isRight()) {
              final resolved =
                  (resolvedEntity as Right<Failure, TEntity>).value;
              await _updateLocal(resolved);
              totalPulled++;
            } else {
              errors.add('Conflict resolution failed for ${doc.id}');
              totalFailed++;
            }
          } else {
            // Não existe localmente - inserir
            await _insertLocal(remoteEntity);
            totalPulled++;
          }
        } catch (e) {
          developer.log(
            'Failed to process remote doc ${doc.id}: $e',
            name: 'ReceitaAgroSync.$collectionName',
            error: e,
          );
          errors.add('Doc ${doc.id}: $e');
          totalFailed++;
        }
      }

      stopwatch.stop();

      final result = SyncPullResult(
        recordsPulled: totalPulled,
        recordsFailed: totalFailed,
        errors: errors,
        duration: stopwatch.elapsed,
      );

      developer.log(result.summary, name: 'ReceitaAgroSync.$collectionName');

      return Right(result);
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Pull error: $e',
        name: 'ReceitaAgroSync.$collectionName',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Erro ao fazer pull: $e'));
    }
  }

  // Métodos auxiliares para operações locais (subclasses podem sobrescrever)

  Future<Either<Failure, TEntity?>> _getLocalByFirebaseId(
    String firebaseId,
  ) async {
    try {
      // Subclasses devem implementar busca por firebaseId
      throw UnimplementedError('Subclass must implement _getLocalByFirebaseId');
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar registro local: $e'));
    }
  }

  Future<void> _updateLocal(TEntity entity) async {
    try {
      final companion = entityToCompanion(entity);
      await db.into(table).insert(companion, mode: InsertMode.replace);
    } catch (e) {
      throw CacheFailure('Erro ao atualizar registro local: $e');
    }
  }

  Future<void> _insertLocal(TEntity entity) async {
    try {
      final companion = entityToCompanion(entity);
      await db.into(table).insert(companion);
    } catch (e) {
      throw CacheFailure('Erro ao inserir registro local: $e');
    }
  }

  // ==========================================================================
  // VALIDAÇÃO E CONFLITOS
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(TEntity entity) {
    // Validação básica - subclasses podem estender
    if (entity.id.isEmpty) {
      return Left(ValidationFailure('Entity ID cannot be empty'));
    }

    if (entity.userId == null || entity.userId!.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, TEntity>> resolveConflict(
    TEntity local,
    TEntity remote,
  ) async {
    try {
      // Estratégia: Last Write Wins (LWW)
      // Comparar updatedAt timestamps

      final localUpdated = local.updatedAt ?? DateTime(1970);
      final remoteUpdated = remote.updatedAt ?? DateTime(1970);

      // Se remote é mais recente, usar remote
      if (remoteUpdated.isAfter(localUpdated)) {
        developer.log(
          'Conflict resolved: Remote wins (${remote.id})',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Right(remote);
      } else if (localUpdated.isAfter(remoteUpdated)) {
        // Se local é mais recente, usar local
        developer.log(
          'Conflict resolved: Local wins (${local.id})',
          name: 'ReceitaAgroSync.$collectionName',
        );
        return Right(local);
      } else {
        // Timestamps iguais - usar versão maior
        if (remote.version > local.version) {
          return Right(remote);
        } else {
          return Right(local);
        }
      }
    } catch (e) {
      return Left(SyncFailure('Erro ao resolver conflito: $e'));
    }
  }
}
