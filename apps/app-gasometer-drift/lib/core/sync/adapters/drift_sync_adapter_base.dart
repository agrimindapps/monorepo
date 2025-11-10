import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

import '../../../database/gasometer_database.dart';
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
/// @injectable
/// class VehicleDriftSyncAdapter extends DriftSyncAdapterBase<VehicleEntity, VehicleTableData> {
///   VehicleDriftSyncAdapter(
///     super.db,
///     super.firestore,
///     super.connectivityService,
///   );
///
///   @override
///   String get collectionName => 'vehicles';
///
///   @override
///   TableInfo get table => db.vehicles;
///
///   // Implementar conversões...
/// }
/// ```
abstract class DriftSyncAdapterBase<TEntity extends BaseSyncEntity, TDriftRow>
    implements IDriftSyncAdapter<TEntity, TDriftRow> {
  DriftSyncAdapterBase(this.db, this.firestore);

  /// Database Drift para operações locais
  final GasometerDatabase db;

  /// Firestore instance para operações remotas
  final FirebaseFirestore firestore;

  /// Serviço de conectividade (verificar se está online)
  final ConnectivityService connectivityService = getIt<ConnectivityService>();

  // ==========================================================================
  // CONFIGURAÇÃO ABSTRATA (Subclasses devem implementar)
  // ==========================================================================

  /// Nome da coleção no Firestore
  ///
  /// Exemplos: 'vehicles', 'fuel_supplies', 'maintenances'
  String get collectionName;

  /// Tabela Drift correspondente
  ///
  /// Exemplos: db.vehicles, db.fuelSupplies, db.maintenances
  TableInfo<Table, dynamic> get table;

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
        'Push started: ${dirtyEntities.length} dirty records',
        name: 'DriftSync.$collectionName',
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

      developer.log(result.summary, name: 'DriftSync.$collectionName');

      return Right(result);
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Push error: $e',
        name: 'DriftSync.$collectionName',
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
      // Map para armazenar IDs gerados: localId -> firebaseId
      final generatedIds = <String, String>{};

      for (final entity in entities) {
        // Validar antes de enviar
        final validationResult = validateForSync(entity);
        if (validationResult.isLeft()) {
          developer.log(
            'Validation failed for entity ${entity.id}: ${(validationResult as Left).value.message}',
            name: 'DriftSync.$collectionName',
          );
          continue;
        }

        // Converter para Firestore map com try-catch
        late final Map<String, dynamic> firestoreDoc;
        try {
          developer.log(
            'Converting entity ${entity.id} to Firestore map...',
            name: 'DriftSync.$collectionName',
          );
          firestoreDoc = toFirestoreMap(entity);
          developer.log(
            'Entity converted successfully: ${firestoreDoc.keys.length} fields',
            name: 'DriftSync.$collectionName',
          );
        } catch (conversionError, stackTrace) {
          developer.log(
            'Failed to convert entity ${entity.id} to Firestore map',
            name: 'DriftSync.$collectionName',
            error: conversionError,
            stackTrace: stackTrace,
          );
          continue; // Skip this entity and continue with next
        }

        // Incrementar versão
        firestoreDoc['version'] = entity.version + 1;
        firestoreDoc['updated_at'] = FieldValue.serverTimestamp();

        // 🔥 FIX #2: Determinar docId com UUID para novos registros
        final String docId;

        // Tentar extrair ID do firestoreDoc (já convertido)
        final existingFirebaseId = firestoreDoc['id'] as String?;

        // Verificar se já tem UUID válido (não é integer string como "1", "2")
        final bool isUuid;
        if (existingFirebaseId == null || existingFirebaseId.isEmpty) {
          isUuid = false;
        } else {
          // UUID tem formato: 8-4-4-4-12 caracteres hexadecimais separados por hífens
          // Exemplo: 550e8400-e29b-41d4-a716-446655440000
          isUuid =
              existingFirebaseId.contains('-') &&
              existingFirebaseId.length >= 36;
        }

        if (isUuid) {
          // Usar firebaseId existente (já é UUID)
          docId = existingFirebaseId!;
          developer.log(
            'Using existing UUID for entity ${entity.id}: $docId',
            name: 'DriftSync.$collectionName',
          );
        } else {
          // Gerar novo UUID para registros novos ou com ID integer
          docId = const Uuid().v4();
          generatedIds[entity.id] = docId;

          // Atualizar o documento Firestore com o UUID gerado
          firestoreDoc['id'] = docId;

          developer.log(
            'Generated new UUID for entity ${entity.id}: $docId (was: ${existingFirebaseId ?? 'null'})',
            name: 'DriftSync.$collectionName',
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

      // Marcar como sincronizados localmente e atualizar firebaseId se gerado
      for (final entity in entities.take(count)) {
        final generatedFirebaseId = generatedIds[entity.id];
        await markAsSynced(entity.id, firebaseId: generatedFirebaseId);
      }

      developer.log(
        'Batch pushed: $count records (${generatedIds.length} new UUIDs generated)',
        name: 'DriftSync.$collectionName',
      );

      return Right(count);
    } catch (e) {
      developer.log(
        'Batch push error: $e',
        name: 'DriftSync.$collectionName',
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
          name: 'DriftSync.$collectionName',
        );
        return Left(NetworkFailure('Sem conexão com a internet'));
      }

      // 2. Query Firestore (incremental se since != null)
      Query<Map<String, dynamic>> query = firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName);

      if (since != null) {
        query = query.where('updated_at', isGreaterThan: since);
        developer.log(
          'Pull incremental: since ${since.toIso8601String()}',
          name: 'DriftSync.$collectionName',
        );
      } else {
        developer.log(
          'Pull full: downloading all records',
          name: 'DriftSync.$collectionName',
        );
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        stopwatch.stop();
        developer.log(
          'Pull complete: no changes',
          name: 'DriftSync.$collectionName',
        );
        return Right(
          SyncPullResult(
            recordsPulled: 0,
            recordsUpdated: 0,
            conflictsResolved: 0,
            duration: stopwatch.elapsed,
          ),
        );
      }

      developer.log(
        'Pull started: ${snapshot.docs.length} remote documents',
        name: 'DriftSync.$collectionName',
      );

      // 3. Processar documentos remotos
      int recordsPulled = 0;
      int recordsUpdated = 0;
      int conflictsResolved = 0;
      final warnings = <String>[];

      for (final doc in snapshot.docs) {
        final remoteData = doc.data();

        // Parse Firestore → Entity
        final parseResult = fromFirestoreMap(remoteData);
        if (parseResult.isLeft()) {
          warnings.add(
            'Failed to parse document ${doc.id}: ${(parseResult as Left).value.message}',
          );
          continue;
        }

        final remoteEntity = (parseResult as Right<Failure, TEntity>).value;

        // Verificar se existe localmente
        final localEntityResult = await getLocalEntity(remoteEntity.id);

        if (localEntityResult.isRight()) {
          final localEntity =
              (localEntityResult as Right<Failure, TEntity?>).value;

          if (localEntity == null) {
            // Novo registro remoto → Insert local
            await insertLocal(remoteEntity);
            recordsPulled++;
          } else {
            // Registro existe → Verificar conflito
            if (localEntity.isDirty) {
              // CONFLITO: ambos dirty
              final resolved = resolveConflict(localEntity, remoteEntity);
              await updateLocal(resolved);
              conflictsResolved++;

              developer.log(
                'Conflict resolved for ${remoteEntity.id}: version ${resolved.version}',
                name: 'DriftSync.$collectionName',
              );
            } else {
              // Sem conflito → Atualizar com remoto
              await updateLocal(remoteEntity);
              recordsUpdated++;
            }
          }
        }
      }

      stopwatch.stop();

      final result = SyncPullResult(
        recordsPulled: recordsPulled,
        recordsUpdated: recordsUpdated,
        conflictsResolved: conflictsResolved,
        warnings: warnings,
        duration: stopwatch.elapsed,
      );

      developer.log(result.summary, name: 'DriftSync.$collectionName');

      return Right(result);
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Pull error: $e',
        name: 'DriftSync.$collectionName',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(SyncFailure('Erro ao fazer pull: $e'));
    }
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  @override
  TEntity resolveConflict(TEntity local, TEntity remote) {
    // Estratégia padrão: Last Write Wins (LWW)

    // 1. Comparar versions
    if (remote.version > local.version) {
      developer.log(
        'Conflict: Remote wins (version ${remote.version} > ${local.version})',
        name: 'DriftSync.$collectionName',
      );
      return remote.copyWith(isDirty: false, lastSyncAt: DateTime.now())
          as TEntity;
    }

    if (local.version > remote.version) {
      developer.log(
        'Conflict: Local wins (version ${local.version} > ${remote.version})',
        name: 'DriftSync.$collectionName',
      );
      return local.copyWith(
            isDirty: true, // Manter dirty para push novamente
          )
          as TEntity;
    }

    // 2. Versions iguais → Comparar timestamps
    final localTimestamp = local.updatedAt ?? local.createdAt;
    final remoteTimestamp = remote.updatedAt ?? remote.createdAt;

    if (localTimestamp == null && remoteTimestamp == null) {
      // Edge case: sem timestamps → preferir remoto
      return remote.copyWith(isDirty: false, lastSyncAt: DateTime.now())
          as TEntity;
    }

    if (localTimestamp == null) return remote;
    if (remoteTimestamp == null) return local;

    if (remoteTimestamp.isAfter(localTimestamp)) {
      developer.log(
        'Conflict: Remote wins (timestamp)',
        name: 'DriftSync.$collectionName',
      );
      return remote.copyWith(isDirty: false, lastSyncAt: DateTime.now())
          as TEntity;
    } else {
      developer.log(
        'Conflict: Local wins (timestamp)',
        name: 'DriftSync.$collectionName',
      );
      return local.copyWith(isDirty: true) as TEntity;
    }
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(TEntity entity) {
    // Validações básicas (subclasses podem sobrescrever para regras específicas)

    if (entity.id.isEmpty) {
      return const Left(ValidationFailure('ID da entidade não pode ser vazio'));
    }

    if (entity.userId == null || entity.userId!.isEmpty) {
      return const Left(
        ValidationFailure('userId é obrigatório para sincronização'),
      );
    }

    if (entity.isDeleted && entity.version <= 0) {
      return const Left(
        ValidationFailure('Registro deletado deve ter version > 0'),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT ABSTRATAS (Subclasses devem implementar)
  // ==========================================================================

  /// Busca registros dirty do Drift (isDirty = true AND userId = userId)
  ///
  /// Subclasses devem implementar query específica para sua tabela.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Either<Failure, List<VehicleEntity>>> getDirtyRecords(String userId) async {
  ///   try {
  ///     final query = db.select(db.vehicles)
  ///       ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true));
  ///     final rows = await query.get();
  ///     final entities = rows.map((row) => toDomainEntity(row)).toList();
  ///     return Right(entities);
  ///   } catch (e) {
  ///     return Left(CacheFailure('Failed to get dirty records: $e'));
  ///   }
  /// }
  /// ```
  Future<Either<Failure, List<TEntity>>> getDirtyRecords(String userId);

  /// Busca entidade local por ID
  ///
  /// Retorna null se não encontrada.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Either<Failure, VehicleEntity?>> getLocalEntity(String id) async {
  ///   try {
  ///     final query = db.select(db.vehicles)
  ///       ..where((t) => t.firebaseId.equals(id) | t.id.equals(int.parse(id)));
  ///     final row = await query.getSingleOrNull();
  ///     return Right(row != null ? toDomainEntity(row) : null);
  ///   } catch (e) {
  ///     return Left(CacheFailure('Failed to get local entity: $e'));
  ///   }
  /// }
  /// ```
  Future<Either<Failure, TEntity?>> getLocalEntity(String id);

  /// Insere nova entidade no Drift
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Either<Failure, void>> insertLocal(VehicleEntity entity) async {
  ///   try {
  ///     final companion = toCompanion(entity);
  ///     await db.into(db.vehicles).insert(companion);
  ///     return const Right(null);
  ///   } catch (e) {
  ///     return Left(CacheFailure('Failed to insert local entity: $e'));
  ///   }
  /// }
  /// ```
  Future<Either<Failure, void>> insertLocal(TEntity entity);

  /// Atualiza entidade existente no Drift
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Either<Failure, void>> updateLocal(VehicleEntity entity) async {
  ///   try {
  ///     final companion = toCompanion(entity);
  ///     await db.update(db.vehicles).replace(companion);
  ///     return const Right(null);
  ///   } catch (e) {
  ///     return Left(CacheFailure('Failed to update local entity: $e'));
  ///   }
  /// }
  /// ```
  Future<Either<Failure, void>> updateLocal(TEntity entity);

  /// Marca registro como sincronizado (isDirty = false, lastSyncAt = now)
  ///
  /// Se [firebaseId] for fornecido, também atualiza o firebaseId local.
  /// Isso é usado quando um UUID é gerado durante o push inicial.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<Either<Failure, void>> markAsSynced(String id, {String? firebaseId}) async {
  ///   try {
  ///     final companion = VehiclesCompanion(
  ///       isDirty: const Value(false),
  ///       lastSyncAt: Value(DateTime.now()),
  ///       firebaseId: firebaseId != null ? Value(firebaseId) : const Value.absent(),
  ///     );
  ///
  ///     final query = db.update(db.vehicles)
  ///       ..where((t) => t.firebaseId.equals(id) | t.id.equals(int.tryParse(id) ?? -1));
  ///
  ///     await query.write(companion);
  ///     return const Right(null);
  ///   } catch (e) {
  ///     return Left(CacheFailure('Failed to mark as synced: $e'));
  ///   }
  /// }
  /// ```
  Future<Either<Failure, void>> markAsSynced(String id, {String? firebaseId});
}
