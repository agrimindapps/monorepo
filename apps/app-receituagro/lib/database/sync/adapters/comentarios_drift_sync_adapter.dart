import 'package:core/core.dart' hide Column;
import 'package:drift/drift.dart';

import '../../../features/comentarios/domain/entities/comentario_sync_entity.dart';
import '../../receituagro_database.dart';
import '../../tables/receituagro_tables.dart';

/// Adapter de sincronização para Comentários
///
/// Gerencia a sincronização bidirecional da tabela [Comentarios] com a coleção 'comentarios' no Firestore.
class ComentariosDriftSyncAdapter
    extends DriftSyncAdapterBase<ComentarioSyncEntity, Comentario> {
  ComentariosDriftSyncAdapter(
      ReceituagroDatabase db, FirebaseFirestore firestore)
      : super(db, firestore);

  ReceituagroDatabase get localDb => db as ReceituagroDatabase;

  @override
  String get collectionName => 'comentarios';

  @override
  TableInfo<Comentarios, Comentario> get table => localDb.comentarios;

  @override
  Future<Either<Failure, List<ComentarioSyncEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      final query = localDb.select(localDb.comentarios)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.isDirty.equals(true));

      final results = await query.get();

      final entities = results.map((row) {
        return driftToEntity(row);
      }).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar comentários dirty: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  }) async {
    try {
      int id;
      if (localId.startsWith('temp_')) {
        id = int.parse(localId.substring(5));
      } else {
        id = int.tryParse(localId) ?? 0;
      }

      if (id == 0) return Left(CacheFailure('ID local inválido: $localId'));

      await (localDb.update(
        localDb.comentarios,
      )..where((tbl) => tbl.id.equals(id)))
          .write(
        ComentariosCompanion(
          isDirty: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          firebaseId:
              firebaseId != null ? Value(firebaseId) : const Value.absent(),
          // syncError: const Value(null), // TODO: Uncomment after build_runner
          // retryCount: const Value(0),
          // syncStatus: const Value(0), // Synced
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao marcar comentário como sincronizado: $e'),
      );
    }
  }

  @override
  ComentarioSyncEntity driftToEntity(Comentario row) {
    return ComentarioSyncEntity(
      id: row.firebaseId ?? 'temp_${row.id}',
      idReg:
          row.id.toString(), // Usando ID local como idReg se não houver outro
      titulo: '', // Tabela não tem título
      conteudo: row.texto,
      ferramenta: row.moduleName,
      pkIdentificador: row.itemId,
      status: !row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt ?? row.createdAt,
      lastSyncAt: row.lastSyncAt,
      isDirty: row.isDirty,
      isDeleted: row.isDeleted,
      version: row.version,
      userId: row.userId,
      moduleName: row.moduleName,
    );
  }

  @override
  ComentariosCompanion entityToCompanion(ComentarioSyncEntity entity) {
    return ComentariosCompanion(
      firebaseId: Value(entity.id),
      itemId: Value(entity.pkIdentificador),
      texto: Value(entity.conteudo),
      moduleName: Value(entity.ferramenta),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt),
      userId: Value(entity.userId ?? ''),
      isDeleted: Value(entity.isDeleted),
      isDirty: const Value(false),
      lastSyncAt: Value(DateTime.now()),
    );
  }

  @override
  ComentarioSyncEntity fromFirestoreDoc(Map<String, dynamic> data) {
    return ComentarioSyncEntity(
      id: data['id'] as String? ?? '',
      idReg: data['idReg'] as String? ?? '',
      titulo: data['titulo'] as String? ?? '',
      conteudo: data['conteudo'] as String? ?? '',
      ferramenta: data['ferramenta'] as String? ?? 'receituagro',
      pkIdentificador: data['pkIdentificador'] as String? ?? '',
      status: data['status'] as bool? ?? true,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastSyncAt: (data['lastSyncAt'] is Timestamp)
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
      isDirty: false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      version: data['version'] as int? ?? 1,
      userId: data['userId'] as String? ?? '',
      moduleName: data['moduleName'] as String? ?? 'receituagro',
    );
  }

  @override
  Map<String, dynamic> toFirestoreMap(ComentarioSyncEntity entity) {
    return entity.toFirebaseMap();
  }

  Future<Either<Failure, ComentarioSyncEntity?>> getLocalByFirebaseId(
    String firebaseId,
  ) async {
    try {
      final query = localDb.select(localDb.comentarios)
        ..where((tbl) => tbl.firebaseId.equals(firebaseId));

      final result = await query.getSingleOrNull();

      if (result == null) {
        return const Right(null);
      }

      return Right(driftToEntity(result));
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar comentário local por firebaseId: $e'),
      );
    }
  }
}
