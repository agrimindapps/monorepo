import 'package:core/core.dart';
import '../receituagro_database.dart';
import '../tables/receituagro_tables.dart';

/// Repositório de Favoritos usando Drift
///
/// Gerencia favoritos multi-tipo (defensivos, pragas, diagnosticos, culturas)
@lazySingleton
class FavoritoRepository
    extends BaseDriftRepositoryImpl<FavoritoData, Favorito> {
  FavoritoRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Favoritos, Favorito> get table => _db.favoritos;

  @override
  GeneratedDatabase get database => _db;

  @override
  FavoritoData fromData(Favorito data) {
    return FavoritoData(
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
      tipo: data.tipo,
      itemId: data.itemId,
      itemData: data.itemData,
    );
  }

  @override
  Insertable<Favorito> toCompanion(FavoritoData entity) {
    return FavoritosCompanion(
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
      tipo: Value(entity.tipo),
      itemId: Value(entity.itemId),
      itemData: Value(entity.itemData),
    );
  }

  @override
  Expression<int> idColumn(Favoritos tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca favoritos do usuário por tipo
  Future<List<FavoritoData>> findByUserAndType(
    String userId,
    String tipo,
  ) async {
    final query = _db.select(_db.favoritos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.tipo.equals(tipo) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca todos os favoritos do usuário
  Future<List<FavoritoData>> findByUserId(String userId) async {
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de favoritos do usuário
  Stream<List<FavoritoData>> watchByUserId(String userId) {
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Stream de favoritos por tipo
  Stream<List<FavoritoData>> watchByUserAndType(String userId, String tipo) {
    final query = _db.select(_db.favoritos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.tipo.equals(tipo) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Verifica se um item está favoritado
  Future<bool> isFavorited(String userId, String tipo, String itemId) async {
    final query = _db.selectOnly(_db.favoritos)
      ..addColumns([_db.favoritos.id.count()])
      ..where(
        _db.favoritos.userId.equals(userId) &
            _db.favoritos.tipo.equals(tipo) &
            _db.favoritos.itemId.equals(itemId) &
            _db.favoritos.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return (result.read(_db.favoritos.id.count()) ?? 0) > 0;
  }

  /// Busca um favorito específico
  Future<FavoritoData?> findByUserTypeAndItem(
    String userId,
    String tipo,
    String itemId,
  ) async {
    final query = _db.select(_db.favoritos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.tipo.equals(tipo) &
            tbl.itemId.equals(itemId) &
            tbl.isDeleted.equals(false),
      )
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Conta favoritos do usuário por tipo
  Future<Map<String, int>> countByType(String userId) async {
    final query = _db.selectOnly(_db.favoritos, distinct: true)
      ..addColumns([_db.favoritos.tipo, _db.favoritos.id.count()])
      ..where(
        _db.favoritos.userId.equals(userId) &
            _db.favoritos.isDeleted.equals(false),
      )
      ..groupBy([_db.favoritos.tipo]);

    final results = await query.get();
    return Map.fromEntries(
      results.map(
        (row) => MapEntry(
          row.read(_db.favoritos.tipo)!,
          row.read(_db.favoritos.id.count()) ?? 0,
        ),
      ),
    );
  }

  /// Conta total de favoritos do usuário
  Future<int> countByUserId(String userId) async {
    final query = _db.selectOnly(_db.favoritos)
      ..addColumns([_db.favoritos.id.count()])
      ..where(
        _db.favoritos.userId.equals(userId) &
            _db.favoritos.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.favoritos.id.count()) ?? 0;
  }

  /// Remove favorito (soft delete)
  Future<bool> removeFavorito(String userId, String tipo, String itemId) async {
    final favorito = await findByUserTypeAndItem(userId, tipo, itemId);
    if (favorito == null) return false;

    final rowsAffected =
        await (_db.update(
          _db.favoritos,
        )..where((tbl) => tbl.id.equals(favorito.id))).write(
          FavoritosCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }

  /// @deprecated Legacy method - remove favorito sem userId (busca qualquer user)
  Future<bool> removeFavoritoLegacy(String tipo, String itemId) async {
    final query = _db.delete(_db.favoritos)
      ..where((tbl) => tbl.tipo.equals(tipo) & tbl.itemId.equals(itemId));

    final rowsAffected = await query.go();
    return rowsAffected > 0;
  }

  /// Busca registros que precisam ser sincronizados
  Future<List<FavoritoData>> findDirtyRecords() async {
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> favoritoIds) async {
    await _db.executeTransaction(() async {
      for (final id in favoritoIds) {
        await (_db.update(
          _db.favoritos,
        )..where((tbl) => tbl.id.equals(id))).write(
          FavoritosCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark favoritos as synced');
  }

  /// Busca favoritos recentes (últimos N)
  Future<List<FavoritoData>> findRecent(String userId, {int limit = 10}) async {
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  // ============================================================================
  // MÉTODOS DE COMPATIBILIDADE LEGACY (Hive → Drift Migration)
  // ============================================================================

  /// @deprecated Legacy method - busca favoritos por tipo
  Future<List<FavoritoData>> getFavoritosByTipoAsync(String tipo) async {
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.tipo.equals(tipo) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// @deprecated Legacy method - adiciona favorito
  Future<int> addFavorito(String tipo, String itemId, String? itemData) async {
    final companion = FavoritosCompanion.insert(
      userId: '', // TODO: Obter userId do contexto
      tipo: tipo,
      itemId: itemId,
      itemData: itemData ?? '',
    );

    return await _db.into(_db.favoritos).insert(companion);
  }

  /// @deprecated Legacy method - verifica se é favorito
  Future<bool> isFavorito(String tipo, String itemId) async {
    final query = _db.select(_db.favoritos)
      ..where(
        (tbl) =>
            tbl.tipo.equals(tipo) &
            tbl.itemId.equals(itemId) &
            tbl.isDeleted.equals(false),
      )
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// @deprecated Legacy method - limpa favoritos por tipo
  Future<void> clearFavoritosByTipo(String tipo) async {
    await (_db.delete(
      _db.favoritos,
    )..where((tbl) => tbl.tipo.equals(tipo))).go();
  }

  /// @deprecated Legacy method - estatísticas de favoritos
  Future<Map<String, int>> getFavoritosStats() async {
    // Busca todos os favoritos não deletados
    final query = _db.select(_db.favoritos)
      ..where((tbl) => tbl.isDeleted.equals(false));

    final favoritos = await query.get();

    // Conta por tipo
    final stats = <String, int>{};
    for (final fav in favoritos) {
      stats[fav.tipo] = (stats[fav.tipo] ?? 0) + 1;
    }

    return stats;
  }
}

/// Classe para transferência de dados de favoritos
class FavoritoData {
  const FavoritoData({
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
    required this.tipo,
    required this.itemId,
    required this.itemData,
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
  final String tipo; // 'defensivos', 'pragas', 'diagnosticos', 'culturas'
  final String itemId;
  final String itemData; // JSON cache

  /// Cria uma cópia com campos modificados
  FavoritoData copyWith({
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
    String? tipo,
    String? itemId,
    String? itemData,
  }) {
    return FavoritoData(
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
      tipo: tipo ?? this.tipo,
      itemId: itemId ?? this.itemId,
      itemData: itemData ?? this.itemData,
    );
  }
}
