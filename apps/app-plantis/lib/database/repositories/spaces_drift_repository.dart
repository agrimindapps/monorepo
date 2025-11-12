import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';

import '../../core/data/models/espaco_model.dart';
import '../plantis_database.dart';

/// ============================================================================
/// SPACES DRIFT REPOSITORY
/// ============================================================================
///
/// Repository Drift para gerenciar espaços/ambientes das plantas.
///
/// **RESPONSABILIDADES:**
/// - CRUD completo de espaços
/// - Conversão EspacoModel ↔ Drift Space entity
/// - Soft delete (isDeleted) e hard delete
/// - Streams reativos para UI
/// - Helpers para sincronização (isDirty, lastSyncAt)
///
/// **PADRÃO:**
/// - firebaseId como chave de negócio (String)
/// - id INTEGER como PK técnica do SQLite
/// - Conversão via _spaceDriftToModel() e companions
/// ============================================================================

@lazySingleton
class SpacesDriftRepository {
  final PlantisDatabase _db;

  SpacesDriftRepository(this._db);

  // ==================== CREATE ====================

  /// Insere novo espaço no banco Drift
  ///
  /// Retorna o ID local (INTEGER) gerado pelo SQLite
  Future<int> insertSpace(EspacoModel model) async {
    final companion = SpacesCompanion.insert(
      firebaseId: Value(model.id), // String ID do Firebase
      name: model.nome,
      description: Value(model.descricao),
      lightCondition: const Value(null),
      humidity: const Value(null),
      averageTemperature: const Value(null),
      createdAt: Value(
        model.createdAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(model.createdAtMs!)
            : DateTime.now(),
      ),
      updatedAt: Value(
        model.updatedAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(model.updatedAtMs!)
            : DateTime.now(),
      ),
      lastSyncAt: Value(
        model.lastSyncAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(model.lastSyncAtMs!)
            : null,
      ),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      userId: Value(model.userId),
      moduleName: Value(model.moduleName ?? 'plantis'),
    );

    return await _db.into(_db.spaces).insert(companion);
  }

  // ==================== READ ====================

  /// Retorna todos os espaços ativos (não deletados)
  Future<List<EspacoModel>> getAllSpaces() async {
    final spaces = await (_db.select(_db.spaces)
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([
            (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .get();

    return spaces.map(_spaceDriftToModel).toList();
  }

  /// Retorna espaço pelo firebaseId (String)
  Future<EspacoModel?> getSpaceById(String firebaseId) async {
    final space = await (_db.select(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

    return space != null ? _spaceDriftToModel(space) : null;
  }

  /// Retorna espaço pelo ID local (INTEGER)
  Future<EspacoModel?> getSpaceByLocalId(int id) async {
    final space = await (_db.select(_db.spaces)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();

    return space != null ? _spaceDriftToModel(space) : null;
  }

  // ==================== UPDATE ====================

  /// Atualiza espaço existente
  ///
  /// Usa firebaseId para localizar o registro
  /// Retorna true se atualizou com sucesso
  Future<bool> updateSpace(EspacoModel model) async {
    final localId = await _getLocalIdByFirebaseId(model.id);
    if (localId == null) return false;

    final companion = SpacesCompanion(
      id: Value(localId),
      firebaseId: Value(model.id),
      name: Value(model.nome),
      description: Value(model.descricao),
      updatedAt: Value(DateTime.now()),
      isDirty: Value(model.isDirty),
      isDeleted: Value(model.isDeleted),
      version: Value(model.version),
      userId: Value(model.userId),
    );

    final updated = await (_db.update(_db.spaces)
          ..where((s) => s.id.equals(localId)))
        .write(companion);

    return updated > 0;
  }

  // ==================== DELETE ====================

  /// Soft delete - marca como deletado mas mantém no banco
  Future<bool> deleteSpace(String firebaseId) async {
    final updated = await (_db.update(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .write(
      SpacesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return updated > 0;
  }

  /// Hard delete - remove fisicamente do banco
  Future<bool> hardDeleteSpace(String firebaseId) async {
    final deleted = await (_db.delete(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .go();

    return deleted > 0;
  }

  /// Limpa todos os espaços (apenas para testes/reset)
  Future<void> clearAll() async {
    await _db.delete(_db.spaces).go();
  }

  // ==================== STREAMS ====================

  /// Watch todos os espaços ativos (reativo)
  Stream<List<EspacoModel>> watchSpaces() {
    return (_db.select(_db.spaces)
          ..where((s) => s.isDeleted.equals(false))
          ..orderBy([
            (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((spaces) => spaces.map(_spaceDriftToModel).toList());
  }

  /// Watch espaço específico por firebaseId
  Stream<EspacoModel?> watchSpaceById(String firebaseId) {
    return (_db.select(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .watchSingleOrNull()
        .map((space) => space != null ? _spaceDriftToModel(space) : null);
  }

  // ==================== SYNC HELPERS ====================

  /// Retorna espaços marcados como dirty (precisam sync)
  Future<List<EspacoModel>> getDirtySpaces() async {
    final spaces = await (_db.select(_db.spaces)
          ..where((s) => s.isDirty.equals(true)))
        .get();

    return spaces.map(_spaceDriftToModel).toList();
  }

  /// Marca espaço como sincronizado
  Future<void> markAsSynced(String firebaseId) async {
    await (_db.update(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .write(
      SpacesCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== CONVERTERS ====================

  /// Converte Drift Space entity → EspacoModel
  EspacoModel _spaceDriftToModel(Space space) {
    return EspacoModel(
      id: space.firebaseId ?? space.id.toString(),
      createdAtMs: space.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: space.updatedAt?.millisecondsSinceEpoch,
      lastSyncAtMs: space.lastSyncAt?.millisecondsSinceEpoch,
      isDirty: space.isDirty,
      isDeleted: space.isDeleted,
      version: space.version,
      userId: space.userId,
      moduleName: space.moduleName,
      nome: space.name,
      descricao: space.description,
      ativo: true, // EspacoModel não tem campo active em Spaces table
      dataCriacao: space.createdAt,
    );
  }

  /// Helper para obter ID local (INTEGER) a partir do firebaseId (String)
  Future<int?> _getLocalIdByFirebaseId(String firebaseId) async {
    final space = await (_db.select(_db.spaces)
          ..where((s) => s.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

    return space?.id;
  }

  // ==================== STATISTICS ====================

  /// Conta total de espaços ativos
  Future<int> countActiveSpaces() async {
    final count = _db.spaces.id.count();
    final query = _db.selectOnly(_db.spaces)
      ..addColumns([count])
      ..where(_db.spaces.isDeleted.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }
}
