import 'package:core/core.dart';
import 'package:drift/drift.dart';
import '../receituagro_database.dart';
import '../tables/receituagro_tables.dart';

/// Repositório de Comentários usando Drift
///
/// Gerencia comentários dos usuários vinculados a items

class ComentarioRepository
    extends BaseDriftRepositoryImpl<ComentarioData, Comentario> {
  ComentarioRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Comentarios, Comentario> get table => _db.comentarios;

  @override
  GeneratedDatabase get database => _db;

  @override
  ComentarioData fromData(Comentario data) {
    return ComentarioData(
      id: data.id,
      firebaseId: data.firebaseId,
      userId: data.userId,
      moduleName: data.moduleName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      itemId: data.itemId,
      texto: data.texto,
    );
  }

  @override
  Insertable<Comentario> toCompanion(ComentarioData entity) {
    return ComentariosCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      itemId: Value(entity.itemId),
      texto: Value(entity.texto),
    );
  }

  @override
  Expression<int> idColumn(Comentarios tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca comentários de um item
  Future<List<ComentarioData>> findByItem(String itemId) async {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de comentários de um item
  Stream<List<ComentarioData>> watchByItem(String itemId) {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query
        .watch()
        .map((dataList) => dataList.map((data) => fromData(data)).toList());
  }

  /// Busca comentários do usuário
  Future<List<ComentarioData>> findByUserId(String userId) async {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de comentários do usuário
  Stream<List<ComentarioData>> watchByUserId(String userId) {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query
        .watch()
        .map((dataList) => dataList.map((data) => fromData(data)).toList());
  }

  /// Conta comentários de um item
  Future<int> countByItem(String itemId) async {
    final query = _db.selectOnly(_db.comentarios)
      ..addColumns([_db.comentarios.id.count()])
      ..where(
        _db.comentarios.itemId.equals(itemId) &
            _db.comentarios.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.comentarios.id.count()) ?? 0;
  }

  /// Conta comentários do usuário
  Future<int> countByUserId(String userId) async {
    final query = _db.selectOnly(_db.comentarios)
      ..addColumns([_db.comentarios.id.count()])
      ..where(
        _db.comentarios.userId.equals(userId) &
            _db.comentarios.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.comentarios.id.count()) ?? 0;
  }

  /// Soft delete de um comentário
  Future<bool> softDelete(int comentarioId) async {
    final rowsAffected =
        await (_db.update(_db.comentarios)
              ..where((tbl) => tbl.id.equals(comentarioId)))
            .write(
      ComentariosCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsAffected > 0;
  }

  /// Verifica se o comentário pertence ao usuário
  Future<bool> belongsToUser(int comentarioId, String userId) async {
    final query = _db.selectOnly(_db.comentarios)
      ..addColumns([_db.comentarios.id.count()])
      ..where(
        _db.comentarios.id.equals(comentarioId) &
            _db.comentarios.userId.equals(userId),
      );

    final result = await query.getSingle();
    return (result.read(_db.comentarios.id.count()) ?? 0) > 0;
  }

  /// Busca registros que precisam ser sincronizados
  Future<List<ComentarioData>> findDirtyRecords() async {
    final query = _db.select(_db.comentarios)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> comentarioIds) async {
    await _db.executeTransaction(() async {
      for (final id in comentarioIds) {
        await (_db.update(_db.comentarios)..where((tbl) => tbl.id.equals(id)))
            .write(
          ComentariosCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark comentarios as synced');
  }

  /// Busca comentários recentes do usuário (últimos N)
  Future<List<ComentarioData>> findRecentByUser(
    String userId, {
    int limit = 10,
  }) async {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca comentários recentes de um item (últimos N)
  Future<List<ComentarioData>> findRecentByItem(
    String itemId, {
    int limit = 10,
  }) async {
    final query = _db.select(_db.comentarios)
      ..where(
        (tbl) => tbl.itemId.equals(itemId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Atualiza o texto de um comentário
  Future<bool> updateTexto(int comentarioId, String novoTexto) async {
    final rowsAffected =
        await (_db.update(_db.comentarios)
              ..where((tbl) => tbl.id.equals(comentarioId)))
            .write(
      ComentariosCompanion(
        texto: Value(novoTexto),
        updatedAt: Value(DateTime.now()),
        isDirty: const Value(true),
      ),
    );
    return rowsAffected > 0;
  }
}

/// Classe para transferência de dados de comentários
class ComentarioData {
  const ComentarioData({
    required this.id,
    this.firebaseId,
    required this.userId,
    required this.moduleName,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
    required this.isDirty,
    required this.isDeleted,
    required this.version,
    required this.itemId,
    required this.texto,
  });

  final int id;
  final String? firebaseId;
  final String userId;
  final String moduleName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final String itemId;
  final String texto;

  /// Cria uma cópia com campos modificados
  ComentarioData copyWith({
    int? id,
    String? firebaseId,
    String? userId,
    String? moduleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? itemId,
    String? texto,
  }) {
    return ComentarioData(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      itemId: itemId ?? this.itemId,
      texto: texto ?? this.texto,
    );
  }
}
