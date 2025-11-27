import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../agrihurbi_database.dart';

/// ============================================================================
/// EQUINE REPOSITORY - Padrão Agrihurbi (String ID)
/// ============================================================================
///
/// Repository de Equines (cavalos) usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Filtros por temperamento, pelagem, uso primário, etc.
/// ============================================================================

class EquineRepository {
  EquineRepository(this._db);

  final AgrihurbiDatabase _db;

  String get tableName => 'equines';

  // ==================== CREATE ====================

  /// Insere um novo equino
  Future<Result<int>> insert(EquinesCompanion equine) async {
    try {
      final rowsAffected = await _db.into(_db.equines).insert(equine);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(EquinesCompanion equine) async {
    try {
      final rowsAffected =
          await _db.into(_db.equines).insertOnConflictUpdate(equine);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca equino por ID
  Future<Result<Equine?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.equines)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todos os equinos ativos
  Future<Result<List<Equine>>> getAll() async {
    try {
      final results = await (_db.select(_db.equines)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca equinos por temperamento
  Future<Result<List<Equine>>> getByTemperament(int temperament) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) =>
                  t.isActive.equals(true) & t.temperament.equals(temperament),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca equinos por pelagem
  Future<Result<List<Equine>>> getByCoat(int coat) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) => t.isActive.equals(true) & t.coat.equals(coat),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca equinos por uso primário
  Future<Result<List<Equine>>> getByPrimaryUse(int primaryUse) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) => t.isActive.equals(true) & t.primaryUse.equals(primaryUse),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca por nome (like)
  Future<Result<List<Equine>>> searchByName(String query) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) => t.isActive.equals(true) & t.commonName.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== STREAMS ====================

  /// Stream de todos os equinos ativos
  Stream<List<Equine>> watchAll() {
    return (_db.select(_db.equines)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
        .watch();
  }

  /// Stream de um equino específico
  Stream<Equine?> watchById(String id) {
    return (_db.select(_db.equines)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Stream de equinos por uso primário
  Stream<List<Equine>> watchByPrimaryUse(int primaryUse) {
    return (_db.select(_db.equines)
          ..where(
            (t) => t.isActive.equals(true) & t.primaryUse.equals(primaryUse),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
        .watch();
  }

  // ==================== UPDATE ====================

  /// Atualiza equino
  Future<Result<int>> update(String id, EquinesCompanion equine) async {
    try {
      final updated = await (_db.update(_db.equines)
            ..where((t) => t.id.equals(id)))
          .write(equine);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Result<int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.equines)
            ..where((t) => t.id.equals(id)))
          .write(
        EquinesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Hard delete
  Future<Result<int>> delete(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.equines)..where((t) => t.id.equals(id))).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todos os equinos
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.equines).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta equinos ativos
  Future<Result<int>> countActive() async {
    try {
      final count = _db.equines.id.count();
      final query = _db.selectOnly(_db.equines)
        ..addColumns([count])
        ..where(_db.equines.isActive.equals(true));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta equinos por uso primário
  Future<Result<Map<int, int>>> countByPrimaryUse() async {
    try {
      final counts = <int, int>{};

      for (int use = 0; use <= 5; use++) {
        final count = _db.equines.id.count();
        final query = _db.selectOnly(_db.equines)
          ..addColumns([count])
          ..where(
            _db.equines.isActive.equals(true) &
                _db.equines.primaryUse.equals(use),
          );

        final result = await query.getSingle();
        counts[use] = result.read(count) ?? 0;
      }

      return Result.success(counts);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
