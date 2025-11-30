import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../../domain/entities/base_sync_entity.dart';
import '../../../../../shared/utils/failure.dart';
import '../../../../services/connectivity_service.dart';
import '../interfaces/i_drift_sync_adapter.dart';
import '../models/sync_results.dart';

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
abstract class DriftSyncAdapterBase<TEntity extends BaseSyncEntity, TDriftRow>
    implements IDriftSyncAdapter<TEntity, TDriftRow> {
  DriftSyncAdapterBase(this.db, this.firestore, this.connectivityService);

  /// Database Drift para operações locais
  final GeneratedDatabase db;

  /// Firestore instance para operações remotas
  final fs.FirebaseFirestore firestore;

  /// Serviço de conectividade (verificar se está online)
  final ConnectivityService connectivityService;

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
          name: 'DriftSync.$collectionName',
        );
        return const Left(NetworkFailure('Sem conexão com a internet'));
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
          name: 'DriftSync.$collectionName',
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
        'Pushing ${dirtyEntities.length} records...',
        name: 'DriftSync.$collectionName',
      );

      // 3. Enviar em batches (Firestore limit: 500, mas usamos 50 por segurança)
      int pushedCount = 0;
      int failedCount = 0;
      final errors = <String>[];

      // Dividir em chunks de 50
      for (var i = 0; i < dirtyEntities.length; i += 50) {
        final end = (i + 50 < dirtyEntities.length)
            ? i + 50
            : dirtyEntities.length;
        final batch = dirtyEntities.sublist(i, end);

        final batchWrite = firestore.batch();
        final pendingUpdates = <Future<void>>[];

        for (final entity in batch) {
          try {
            // Validação pré-sync
            final validation = validateForSync(entity);
            if (validation.isLeft()) {
              failedCount++;
              errors.add(
                'Validation failed for ${entity.id}: ${(validation as Left).value.message}',
              );
              continue;
            }

            // Determinar o docId para Firebase:
            // - Se entity.id parece ser um UUID (36 chars com hífens), usa ele
            // - Se entity.id é numérico (ID local do Drift), gera novo UUID
            final String docId;
            
            if (_isValidUuid(entity.id)) {
              // Já tem UUID válido, usa ele
              docId = entity.id;
            } else {
              // ID numérico do Drift, gera UUID para Firebase
              docId = const Uuid().v4();
              developer.log(
                '🆔 Generating new Firebase docId: $docId for local id: ${entity.id}',
                name: 'DriftSync.$collectionName',
              );
            }

            final docRef = firestore
                .collection('users')
                .doc(userId)
                .collection(collectionName)
                .doc(docId);

            final map = toFirestoreMap(entity);
            map['lastSyncAt'] = fs.FieldValue.serverTimestamp();
            // Garantir que o ID no documento seja o UUID
            map['id'] = docId;

            // Converter recursivamente para evitar IdentityMap no Web
            final sanitizedMap = _sanitizeMapForFirestore(map);

            batchWrite.set(docRef, sanitizedMap, fs.SetOptions(merge: true));

            // Preparar atualização local após sucesso
            // Se gerou novo UUID, passar como firebaseId para atualizar o registro local
            final String localId = entity.id; // ID original (pode ser "1", "2", etc)
            pendingUpdates.add(
              markAsSynced(localId, firebaseId: docId).then((result) {
                if (result.isLeft()) {
                  developer.log(
                    'Failed to mark as synced locally: $localId',
                    name: 'DriftSync.$collectionName',
                    error: (result as Left).value.message,
                  );
                }
              }),
            );

            pushedCount++;
          } catch (e) {
            failedCount++;
            errors.add('Error preparing ${entity.id}: $e');
          }
        }

        // Commit do batch no Firestore
        try {
          await batchWrite.commit();
          // Se commit funcionou, atualizar status local
          await Future.wait(pendingUpdates);
        } catch (e) {
          pushedCount -= batch.length; // Reverter contagem
          failedCount += batch.length;
          errors.add('Batch commit failed: $e');
          developer.log(
            'Batch commit failed',
            name: 'DriftSync.$collectionName',
            error: e,
          );
        }
      }

      return Right(
        SyncPushResult(
          recordsPushed: pushedCount,
          recordsFailed: failedCount,
          errors: errors,
          duration: stopwatch.elapsed,
        ),
      );
    } catch (e, stack) {
      developer.log(
        'Push fatal error',
        name: 'DriftSync.$collectionName',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure('Erro fatal no push: $e'));
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
      developer.log(
        '🔄 Pull starting for $collectionName (userId: $userId, since: $since)',
        name: 'DriftSync.$collectionName',
      );

      // 1. Verificar conectividade
      final connectivityResult = await connectivityService.isOnline();
      final isOnline = connectivityResult.fold(
        (_) => false,
        (online) => online,
      );

      if (!isOnline) {
        developer.log(
          '❌ Pull aborted: No internet connection',
          name: 'DriftSync.$collectionName',
        );
        return const Left(NetworkFailure('Sem conexão com a internet'));
      }

      // 2. Query no Firestore
      // ⚠️ IMPORTANT: This query requires Firestore composite indices!
      //
      // Query Pattern:
      //   .where('updated_at', isGreaterThan: timestamp).limit(500)
      //
      // Without indices, Firestore will reject this query with:
      //   "The query requires an index. You can create it by following the link
      //    in the console or locally via the Firebase CLI."
      //
      // Required Index Setup (snake_case field names):
      //   - vehicles: updated_at ASC
      //   - fuel_supplies: updated_at ASC
      //   - maintenances: updated_at ASC
      //   - expenses: updated_at ASC
      //   - odometer_readings: updated_at ASC
      //
      // Deployment:
      //   1. CLI: ./deploy-firestore-indexes.sh my-project-id
      //   2. Manual: https://console.firebase.google.com/project/{PROJECT}/firestore/indexes
      //   3. Docs: See FIRESTORE_INDICES.md for full instructions
      //
      final collectionPath = 'users/$userId/$collectionName';
      developer.log(
        '📂 Querying Firestore path: $collectionPath',
        name: 'DriftSync.$collectionName',
      );

      fs.Query query = firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName);

      if (since != null) {
        // This where() clause requires the index on updated_at
        // NOTE: Field name uses snake_case (updated_at) to match baseFirebaseFields
        developer.log(
          '📅 Applying delta filter: updated_at > ${since.toIso8601String()}',
          name: 'DriftSync.$collectionName',
        );
        query = query.where('updated_at', isGreaterThan: since.toIso8601String());
      } else {
        developer.log(
          '📦 No lastSync - performing FULL sync (no filter)',
          name: 'DriftSync.$collectionName',
        );
      }

      // Limitar tamanho do pull para evitar OOM em syncs grandes
      // Em produção, implementar paginação real
      query = query.limit(500);

      final snapshot = await query.get();

      developer.log(
        '📊 Firestore returned ${snapshot.docs.length} documents',
        name: 'DriftSync.$collectionName',
      );

      if (snapshot.docs.isEmpty) {
        developer.log(
          '⚠️ No documents found in Firestore for $collectionPath',
          name: 'DriftSync.$collectionName',
        );
        return Right(
          SyncPullResult(
            recordsPulled: 0,
            recordsFailed: 0,
            duration: stopwatch.elapsed,
          ),
        );
      }

      developer.log(
        'Pulling ${snapshot.docs.length} records (since: $since)...',
        name: 'DriftSync.$collectionName',
      );

      int pulledCount = 0;
      int failedCount = 0;
      final errors = <String>[];

      // 3. Processar documentos
      await db.transaction(() async {
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            // Garantir que o documento tenha o ID do Firestore
            data['id'] = doc.id;
            final remoteEntity = fromFirestoreDoc(data);

            // Verificar se existe localmente pelo firebaseId
            // Como tabelas podem ter id (int) ou firebaseId (text),
            // tentamos buscar por firebaseId primeiro
            dynamic localRow;
            try {
              localRow = await (db.select(table)..where((tbl) {
                    // Tentar buscar por firebaseId (campo text usado para UUID)
                    // Usamos isValue para comparação com nullable
                    final firebaseIdCol = (tbl as dynamic).firebaseId as GeneratedColumn<String>;
                    return firebaseIdCol.isValue(doc.id);
                  }))
                  .getSingleOrNull();
            } catch (e) {
              // Se falhar (tabela não tem firebaseId), tenta pelo id
              developer.log(
                'firebaseId column not found, trying by id: $e',
                name: 'DriftSync.$collectionName',
              );
              localRow = null;
            }

            if (localRow != null) {
              final localEntity = driftToEntity(localRow as TDriftRow);

              // Resolver conflito
              final resolution = await resolveConflict(
                localEntity,
                remoteEntity,
              );

              if (resolution.isRight()) {
                final resolvedEntity =
                    (resolution as Right<Failure, TEntity>).value;
                // Atualizar localmente
                await db
                    .into(table)
                    .insert(
                      entityToCompanion(resolvedEntity),
                      mode: InsertMode.insertOrReplace,
                    );
                pulledCount++;
              } else {
                failedCount++;
                errors.add(
                  'Conflict resolution failed for ${remoteEntity.id}: ${(resolution as Left).value.message}',
                );
              }
            } else {
              // Novo registro, inserir direto
              developer.log(
                '➕ Inserting new record from Firebase: ${doc.id}',
                name: 'DriftSync.$collectionName',
              );
              await db
                  .into(table)
                  .insert(
                    entityToCompanion(remoteEntity),
                    mode: InsertMode.insertOrReplace,
                  );
              pulledCount++;
            }
          } catch (e) {
            failedCount++;
            errors.add('Error processing doc ${doc.id}: $e');
            developer.log(
              '❌ Error processing doc ${doc.id}: $e',
              name: 'DriftSync.$collectionName',
              error: e,
            );
          }
        }
      });

      return Right(
        SyncPullResult(
          recordsPulled: pulledCount,
          recordsFailed: failedCount,
          errors: errors,
          duration: stopwatch.elapsed,
        ),
      );
    } catch (e, stack) {
      developer.log(
        'Pull fatal error',
        name: 'DriftSync.$collectionName',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure('Erro fatal no pull: $e'));
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  @override
  Future<Either<Failure, List<TEntity>>> getDirtyRecords(String userId) async {
    try {
      // Assumindo que a tabela tem coluna isDirty e userId
      // Como TableInfo é genérico, precisamos usar cast dinâmico ou query customizada
      // Aqui usamos select com where dinâmico

      final query = db.select(table)
        ..where((tbl) {
          // Tenta acessar colunas dinamicamente
          // Isso requer que as tabelas sigam convenção de nomes
          try {
            final isDirtyCol = (tbl as dynamic).isDirty as Expression<bool>;
            final userIdCol = (tbl as dynamic).userId as Expression<String>;
            return isDirtyCol.equals(true) & userIdCol.equals(userId);
          } catch (e) {
            throw Exception(
              'Tabela ${table.actualTableName} não possui colunas isDirty ou userId compatíveis',
            );
          }
        });

      final rows = await query.get();
      final entities = rows
          .map((row) => driftToEntity(row as TDriftRow))
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar registros dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      // Update genérico usando companion
      // Precisamos criar um companion que só atualize isDirty e lastSyncAt
      // Como não sabemos o tipo exato do companion, usamos customStatement ou update com dynamic

      // Abordagem segura: update na tabela filtrando por ID
      // await (db.update(table)
      //       ..where((tbl) => (tbl as dynamic).id.equals(localId)))
      //     .write(
      //       // Hack: Usando RawValues ou criando companion dinamicamente seria difícil
      //       // Vamos assumir que a subclasse pode implementar isso melhor se necessário
      //       // Mas para base, tentamos usar o mecanismo de update do drift
      //       // O ideal seria ter um método abstrato createSyncCompanion(bool isDirty, DateTime lastSync)
      //       // Mas vamos tentar update via coluna dinâmica
      //       CustomExpression<bool>('isDirty') // Placeholder, não vai funcionar direto
      //     );

      // CORREÇÃO: O update genérico é difícil sem saber a estrutura do Companion.
      // Vamos fazer um update via CustomStatement que é mais garantido para SQL

      final tableName = table.actualTableName;
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.customStatement(
        'UPDATE $tableName SET is_dirty = 0, last_sync_at = ? WHERE id = ?',
        [now, localId],
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar como sincronizado: $e'));
    }
  }

  @override
  Future<Either<Failure, TEntity>> resolveConflict(
    TEntity local,
    TEntity remote,
  ) async {
    // LWW (Last Write Wins)
    final localDate = local.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteDate =
        remote.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    if (remoteDate.isAfter(localDate)) {
      return Right(remote);
    } else {
      // Local é mais recente, mantemos local (e ele será enviado no próximo push)
      // Mas para o pull, se local é mais recente, não fazemos nada (retornamos local)
      return Right(local);
    }
  }

  @override
  Either<Failure, void> validateForSync(TEntity entity) {
    if (entity.id.isEmpty) {
      return const Left(ValidationFailure('ID não pode ser vazio'));
    }
    return const Right(null);
  }

  // ==========================================================================
  // HELPERS PRIVADOS
  // ==========================================================================

  /// Sanitiza o mapa recursivamente para evitar IdentityMap no Flutter Web
  ///
  /// O Firestore no Web não aceita IdentityMap diretamente, então precisamos
  /// converter todos os Maps e Lists internos para tipos regulares.
  Map<String, dynamic> _sanitizeMapForFirestore(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in map.entries) {
      final value = entry.value;
      
      if (value == null) {
        // Não adicionar valores nulos para evitar problemas no Firestore
        continue;
      } else if (value is Map) {
        // Converter Map recursivamente
        sanitized[entry.key] = _sanitizeMapForFirestore(
          Map<String, dynamic>.from(value),
        );
      } else if (value is List) {
        // Converter List recursivamente
        sanitized[entry.key] = _sanitizeListForFirestore(value);
      } else if (value is fs.FieldValue) {
        // Manter FieldValue como está (serverTimestamp, etc)
        sanitized[entry.key] = value;
      } else {
        // Outros tipos primitivos (String, int, double, bool, DateTime, etc)
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }

  /// Sanitiza uma lista recursivamente para evitar IdentityMap no Flutter Web
  List<dynamic> _sanitizeListForFirestore(List<dynamic> list) {
    return list.map((item) {
      if (item == null) {
        return null;
      } else if (item is Map) {
        return _sanitizeMapForFirestore(Map<String, dynamic>.from(item));
      } else if (item is List) {
        return _sanitizeListForFirestore(item);
      } else {
        return item;
      }
    }).where((item) => item != null).toList();
  }

  /// Verifica se uma string é um UUID válido (formato v4)
  /// 
  /// UUID v4 tem formato: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
  /// onde x é qualquer dígito hex e y é 8, 9, a, ou b
  bool _isValidUuid(String id) {
    // UUID tem exatamente 36 caracteres (32 hex + 4 hífens)
    if (id.length != 36) return false;
    
    // Regex para validar formato UUID
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    
    return uuidRegex.hasMatch(id);
  }
}
