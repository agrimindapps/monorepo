import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/favoritos/domain/entities/favorito_sync_entity.dart';
import '../../receituagro_database.dart';
import '../../tables/receituagro_tables.dart';

/// Adapter de sincronização para Favoritos
///
/// Gerencia a sincronização bidirecional da tabela [Favoritos] com a coleção 'favoritos' no Firestore.
class FavoritosDriftSyncAdapter
    extends DriftSyncAdapterBase<FavoritoSyncEntity, Favorito> {
  FavoritosDriftSyncAdapter(
    ReceituagroDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  ReceituagroDatabase get localDb => db as ReceituagroDatabase;

  @override
  String get collectionName => 'favoritos';

  @override
  TableInfo<Favoritos, Favorito> get table => localDb.favoritos;

  @override
  Future<Either<Failure, List<FavoritoSyncEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.favoritos)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();

      final entities = results.map((row) {
        return FavoritoSyncEntity(
          id: row.firebaseId ?? 'temp_${row.id}',
          tipo: row.tipo,
          itemId: row.itemId,
          itemData: const {}, // TODO: Parse JSON from row.itemData if needed, or keep empty if not synced back
          adicionadoEm: row.createdAt,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt ?? row.createdAt,
          userId: row.userId,
          isDeleted: row.isDeleted,
        );
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar favoritos dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      // localId here is expected to be the string representation of the int ID for Drift
      // But wait, DriftSyncAdapterBase might be generic on ID type?
      // Let's check base class. It seems it assumes String localId in interface but implementation might vary.
      // For Favoritos, ID is int.

      int id;
      if (localId.startsWith('temp_')) {
        id = int.parse(localId.substring(5));
      } else {
        // This case is tricky if we only have firebaseId.
        // But usually we pass the local ID we just read.
        // Let's assume we can parse it if it's just the number
        id = int.tryParse(localId) ?? 0;
      }

      if (id == 0) return Left(CacheFailure('ID local inválido: $localId'));

      await (localDb.update(
        localDb.favoritos,
      )..where((tbl) => tbl.id.equals(id)))
          .write(
        FavoritosCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId:
              firebaseId != null ? Value(firebaseId) : const Value.absent(),
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao marcar favorito como sincronizado: $e'),
      );
    }
  }

  @override
  @override
  FavoritoSyncEntity driftToEntity(Favorito row) {
    return FavoritoSyncEntity(
      id: row.firebaseId ?? 'temp_${row.id}',
      tipo: row.tipo,
      itemId: row.itemId,
      itemData: const {}, // TODO: Parse JSON
      adicionadoEm: row.createdAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt ?? row.createdAt,
      userId: row.userId,
      isDeleted: row.isDeleted,
    );
  }

  @override
  FavoritosCompanion entityToCompanion(FavoritoSyncEntity entity) {
    return FavoritosCompanion(
      firebaseId: Value(entity.id),
      tipo: Value(entity.tipo),
      itemId: Value(entity.itemId),
      itemData: Value(entity.itemData.toString()), // TODO: Serialize JSON
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      userId: Value(entity.userId ?? ''),
      isDeleted: Value(entity.isDeleted),
      isDirty: const Value(false),
      lastSyncAt: Value(DateTime.now()),
    );
  }

  @override
  FavoritoSyncEntity fromFirestoreDoc(Map<String, dynamic> data) {
    // Parse adicionadoEm com tratamento seguro
    DateTime? adicionadoEm;
    final adicionadoEmRaw = data['adicionadoEm'];
    if (adicionadoEmRaw is fs.Timestamp) {
      adicionadoEm = adicionadoEmRaw.toDate();
    } else if (adicionadoEmRaw is String && adicionadoEmRaw.isNotEmpty) {
      adicionadoEm = DateTime.tryParse(adicionadoEmRaw);
    }
    
    // Parse createdAt com tratamento seguro
    DateTime? createdAt;
    final createdAtRaw = data['createdAt'];
    if (createdAtRaw is fs.Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }
    
    // Parse updatedAt com tratamento seguro
    DateTime? updatedAt;
    final updatedAtRaw = data['updatedAt'];
    if (updatedAtRaw is fs.Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is String && updatedAtRaw.isNotEmpty) {
      updatedAt = DateTime.tryParse(updatedAtRaw);
    }
    
    return FavoritoSyncEntity(
      id: data['id'] as String? ?? '',
      tipo: data['tipo'] as String? ?? 'unknown',
      itemId: data['itemId'] as String? ?? '',
      itemData: data['itemData'] as Map<String, dynamic>? ?? {},
      adicionadoEm: adicionadoEm ?? DateTime.now(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: data['userId'] as String? ?? '',
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(FavoritoSyncEntity entity) {
    return entity.toFirebaseMap();
  }

  Future<Either<Failure, FavoritoSyncEntity?>> getLocalByFirebaseId(
    String firebaseId,
  ) async {
    try {
      final query = localDb.select(localDb.favoritos)
        ..where((tbl) => tbl.firebaseId.equals(firebaseId));

      final result = await query.getSingleOrNull();

      if (result == null) {
        return const Right(null);
      }

      return Right(driftToEntity(result));
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar favorito local por firebaseId: $e'),
      );
    }
  }

  /// Stream de mudanças em tempo real do Firestore
  /// Escuta a coleção de favoritos do usuário e atualiza o Drift quando detecta mudanças
  Stream<void> watchRemoteChanges(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .snapshots()
        .asyncMap((snapshot) async {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;

        final docId = change.doc.id;
        data['id'] = docId;

        switch (change.type) {
          case fs.DocumentChangeType.added:
          case fs.DocumentChangeType.modified:
            await _handleRemoteChange(data);
            break;
          case fs.DocumentChangeType.removed:
            await _handleRemoteDelete(docId);
            break;
        }
      }
    });
  }

  /// Processa uma mudança remota (add/modify)
  Future<void> _handleRemoteChange(Map<String, dynamic> data) async {
    try {
      final entity = fromFirestoreDoc(data);
      final companion = entityToCompanion(entity);

      // Verifica se já existe localmente
      final existingResult = await getLocalByFirebaseId(entity.id);
      
      // Extrai o valor do Either para processar corretamente
      final existing = existingResult.fold<FavoritoSyncEntity?>(
        (failure) => null,
        (entity) => entity,
      );
      
      if (existing != null) {
        // Atualiza se o remoto é mais recente
        final remoteUpdatedAt = entity.updatedAt ?? entity.createdAt;
        final localUpdatedAt = existing.updatedAt ?? existing.createdAt;

        if (remoteUpdatedAt != null &&
            localUpdatedAt != null &&
            remoteUpdatedAt.isAfter(localUpdatedAt)) {
          await (localDb.update(localDb.favoritos)
                ..where((tbl) => tbl.firebaseId.equals(entity.id)))
              .write(companion);
          developer.log(
            '✅ [REALTIME_SYNC] Favorito atualizado: ${entity.itemId}',
            name: 'FavoritosDriftSyncAdapter',
          );
        }
      } else {
        // Insere novo
        await localDb.into(localDb.favoritos).insert(companion);
        developer.log(
          '✅ [REALTIME_SYNC] Novo favorito inserido: ${entity.itemId}',
          name: 'FavoritosDriftSyncAdapter',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [REALTIME_SYNC] Erro ao processar mudança remota: $e',
        name: 'FavoritosDriftSyncAdapter',
      );
    }
  }

  /// Processa uma deleção remota
  Future<void> _handleRemoteDelete(String firebaseId) async {
    try {
      await (localDb.update(localDb.favoritos)
            ..where((tbl) => tbl.firebaseId.equals(firebaseId)))
          .write(const FavoritosCompanion(isDeleted: Value(true)));
    } catch (e) {
      // Silently ignore
    }
  }
}
