import 'dart:convert';

import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../nebulalist_database.dart';

/// ============================================================================
/// ITEM MASTER REPOSITORY - Padrão Nebulalist (String ID)
/// ============================================================================
///
/// Repository de ItemMasters usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Queries tipadas type-safe
/// - ID é string (UUID)
/// ============================================================================

class ItemMasterDriftRepository {
  ItemMasterDriftRepository(this._db);

  final NebulalistDatabase _db;

  String get tableName => 'item_masters';

  // ==================== CREATE ====================

  /// Insere um novo item master
  Future<Result<int>> insert(ItemMastersCompanion itemMaster) async {
    try {
      final rowsAffected = await _db.into(_db.itemMasters).insert(itemMaster);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(ItemMastersCompanion itemMaster) async {
    try {
      final rowsAffected =
          await _db.into(_db.itemMasters).insertOnConflictUpdate(itemMaster);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca item master por ID
  Future<Result<ItemMasterRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todos os item masters
  Future<Result<List<ItemMasterRecord>>> getAll() async {
    try {
      final results = await _db.select(_db.itemMasters).get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca item masters do usuário
  Future<Result<List<ItemMasterRecord>>> getByOwner(String ownerId) async {
    try {
      final results = await (_db.select(_db.itemMasters)
            ..where((t) => t.ownerId.equals(ownerId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca item masters por categoria
  Future<Result<List<ItemMasterRecord>>> getByCategory(
    String ownerId,
    String category,
  ) async {
    try {
      final results = await (_db.select(_db.itemMasters)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.category.equals(category),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Pesquisa item masters por nome
  Future<Result<List<ItemMasterRecord>>> search(
    String ownerId,
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return Result.success([]);
    }

    try {
      final results = await (_db.select(_db.itemMasters)
            ..where(
              (t) =>
                  t.ownerId.equals(ownerId) &
                  t.name.lower().like('%${query.toLowerCase()}%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== STREAMS ====================

  /// Stream de todos os item masters do usuário
  Stream<List<ItemMasterRecord>> watchByOwner(String ownerId) {
    return (_db.select(_db.itemMasters)
          ..where((t) => t.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Stream de item masters por categoria
  Stream<List<ItemMasterRecord>> watchByCategory(
    String ownerId,
    String category,
  ) {
    return (_db.select(_db.itemMasters)
          ..where(
            (t) => t.ownerId.equals(ownerId) & t.category.equals(category),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Stream de um item master específico
  Stream<ItemMasterRecord?> watchById(String id) {
    return (_db.select(_db.itemMasters)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  // ==================== UPDATE ====================

  /// Atualiza item master
  Future<Result<int>> update(String id, ItemMastersCompanion itemMaster) async {
    try {
      final updated = await (_db.update(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .write(itemMaster);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Incrementa contador de uso
  Future<Result<int>> incrementUsageCount(String id) async {
    try {
      final item = await (_db.select(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (item == null) {
        return Result.success(0);
      }

      final updated = await (_db.update(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .write(
        ItemMastersCompanion(
          usageCount: Value(item.usageCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Deleta item master
  Future<Result<int>> delete(String id) async {
    try {
      final deleted = await (_db.delete(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Deleta todos os item masters do usuário
  Future<Result<int>> deleteAllByOwner(String ownerId) async {
    try {
      final deleted = await (_db.delete(_db.itemMasters)
            ..where((t) => t.ownerId.equals(ownerId)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todos os item masters
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.itemMasters).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta item masters do usuário
  Future<Result<int>> countByOwner(String ownerId) async {
    try {
      final count = _db.itemMasters.id.count();
      final query = _db.selectOnly(_db.itemMasters)
        ..addColumns([count])
        ..where(_db.itemMasters.ownerId.equals(ownerId));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta item masters por categoria
  Future<Result<int>> countByCategory(String ownerId, String category) async {
    try {
      final count = _db.itemMasters.id.count();
      final query = _db.selectOnly(_db.itemMasters)
        ..addColumns([count])
        ..where(
          _db.itemMasters.ownerId.equals(ownerId) &
              _db.itemMasters.category.equals(category),
        );

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}

/// Extension para converter ItemMasterRecord para/de models
extension ItemMasterRecordExtension on ItemMasterRecord {
  /// Converte tags JSON string para List<String>
  List<String> get tagsList {
    try {
      final decoded = jsonDecode(tags);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

/// Helper para criar ItemMastersCompanion a partir de dados
ItemMastersCompanion createItemMasterCompanion({
  required String id,
  required String ownerId,
  required String name,
  String description = '',
  List<String> tags = const [],
  String category = 'outros',
  String? photoUrl,
  double? estimatedPrice,
  String? preferredBrand,
  String? notes,
  int usageCount = 0,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  return ItemMastersCompanion(
    id: Value(id),
    ownerId: Value(ownerId),
    name: Value(name),
    description: Value(description),
    tags: Value(jsonEncode(tags)),
    category: Value(category),
    photoUrl: Value(photoUrl),
    estimatedPrice: Value(estimatedPrice),
    preferredBrand: Value(preferredBrand),
    notes: Value(notes),
    usageCount: Value(usageCount),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
