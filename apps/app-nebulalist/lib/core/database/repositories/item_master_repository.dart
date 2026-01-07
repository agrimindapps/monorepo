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
  Future<Either<Failure, int>> insert(ItemMastersCompanion itemMaster) async {
    try {
      final rowsAffected = await _db.into(_db.itemMasters).insert(itemMaster);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(ItemMastersCompanion itemMaster) async {
    try {
      final rowsAffected =
          await _db.into(_db.itemMasters).insertOnConflictUpdate(itemMaster);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== READ ====================

  /// Busca item master por ID
  Future<Either<Failure, ItemMasterRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca todos os item masters
  Future<Either<Failure, List<ItemMasterRecord>>> getAll() async {
    try {
      final results = await _db.select(_db.itemMasters).get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca item masters do usuário
  Future<Either<Failure, List<ItemMasterRecord>>> getByOwner(String ownerId) async {
    try {
      final results = await (_db.select(_db.itemMasters)
            ..where((t) => t.ownerId.equals(ownerId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca item masters por categoria
  Future<Either<Failure, List<ItemMasterRecord>>> getByCategory(
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
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Pesquisa item masters por nome
  Future<Either<Failure, List<ItemMasterRecord>>> search(
    String ownerId,
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return Right([]);
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
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
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
  Future<Either<Failure, int>> update(String id, ItemMastersCompanion itemMaster) async {
    try {
      final updated = await (_db.update(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .write(itemMaster);
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Incrementa contador de uso
  Future<Either<Failure, int>> incrementUsageCount(String id) async {
    try {
      final item = await (_db.select(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (item == null) {
        return Right(0);
      }

      final updated = await (_db.update(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .write(
        ItemMastersCompanion(
          usageCount: Value(item.usageCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== DELETE ====================

  /// Deleta item master
  Future<Either<Failure, int>> delete(String id) async {
    try {
      final deleted = await (_db.delete(_db.itemMasters)
            ..where((t) => t.id.equals(id)))
          .go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Deleta todos os item masters do usuário
  Future<Either<Failure, int>> deleteAllByOwner(String ownerId) async {
    try {
      final deleted = await (_db.delete(_db.itemMasters)
            ..where((t) => t.ownerId.equals(ownerId)))
          .go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Limpa todos os item masters
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.itemMasters).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== CONTADORES ====================

  /// Conta item masters do usuário
  Future<Either<Failure, int>> countByOwner(String ownerId) async {
    try {
      final count = _db.itemMasters.id.count();
      final query = _db.selectOnly(_db.itemMasters)
        ..addColumns([count])
        ..where(_db.itemMasters.ownerId.equals(ownerId));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Conta item masters por categoria
  Future<Either<Failure, int>> countByCategory(String ownerId, String category) async {
    try {
      final count = _db.itemMasters.id.count();
      final query = _db.selectOnly(_db.itemMasters)
        ..addColumns([count])
        ..where(
          _db.itemMasters.ownerId.equals(ownerId) &
              _db.itemMasters.category.equals(category),
        );

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
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
