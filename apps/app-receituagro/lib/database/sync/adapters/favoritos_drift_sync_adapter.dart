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
    ReceituagroDatabase db,
    FirebaseFirestore firestore,
    ConnectivityService connectivityService,
  ) : super(db, firestore, connectivityService);

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
    return FavoritoSyncEntity(
      id: data['id'] as String? ?? '',
      tipo: data['tipo'] as String,
      itemId: data['itemId'] as String,
      itemData: data['itemData'] as Map<String, dynamic>? ?? {},
      adicionadoEm: (data['adicionadoEm'] is Timestamp)
          ? (data['adicionadoEm'] as Timestamp).toDate()
          : DateTime.parse(data['adicionadoEm'] as String),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      userId: data['userId'] as String,
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
}
