import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../agrihurbi_database.dart';

/// ============================================================================
/// BOVINE REPOSITORY - Padrão Agrihurbi (String ID)
/// ============================================================================
///
/// Repository de Bovines (gado) usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Filtros por aptidão, sistema de criação, etc.
/// ============================================================================

class BovineRepository {
  BovineRepository(this._db);

  final AgrihurbiDatabase _db;

  String get tableName => 'bovines';

  // ==================== CREATE ====================

  /// Insere um novo bovino
  Future<Result<int>> insert(BovinesCompanion bovine) async {
    try {
      final rowsAffected = await _db.into(_db.bovines).insert(bovine);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(BovinesCompanion bovine) async {
    try {
      final rowsAffected =
          await _db.into(_db.bovines).insertOnConflictUpdate(bovine);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca bovino por ID
  Future<Result<Bovine?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todos os bovinos ativos
  Future<Result<List<Bovine>>> getAll() async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca bovinos por aptidão (0=dairy, 1=beef, 2=mixed)
  Future<Result<List<Bovine>>> getByAptitude(int aptitude) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where(
              (t) => t.isActive.equals(true) & t.aptitude.equals(aptitude),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca bovinos por sistema de criação (0=extensive, 1=intensive, 2=semiIntensive)
  Future<Result<List<Bovine>>> getByBreedingSystem(int breedingSystem) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  t.breedingSystem.equals(breedingSystem),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca bovinos por raça
  Future<Result<List<Bovine>>> getByBreed(String breed) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where((t) => t.isActive.equals(true) & t.breed.equals(breed))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca por nome (like)
  Future<Result<List<Bovine>>> searchByName(String query) async {
    try {
      final results = await (_db.select(_db.bovines)
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

  /// Stream de todos os bovinos ativos
  Stream<List<Bovine>> watchAll() {
    return (_db.select(_db.bovines)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
        .watch();
  }

  /// Stream de um bovino específico
  Stream<Bovine?> watchById(String id) {
    return (_db.select(_db.bovines)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Stream de bovinos por aptidão
  Stream<List<Bovine>> watchByAptitude(int aptitude) {
    return (_db.select(_db.bovines)
          ..where(
            (t) => t.isActive.equals(true) & t.aptitude.equals(aptitude),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
        .watch();
  }

  // ==================== UPDATE ====================

  /// Atualiza bovino
  Future<Result<int>> update(String id, BovinesCompanion bovine) async {
    try {
      final updated = await (_db.update(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .write(bovine);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Result<int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .write(
        BovinesCompanion(
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
          await (_db.delete(_db.bovines)..where((t) => t.id.equals(id))).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todos os bovinos
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.bovines).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta bovinos ativos
  Future<Result<int>> countActive() async {
    try {
      final count = _db.bovines.id.count();
      final query = _db.selectOnly(_db.bovines)
        ..addColumns([count])
        ..where(_db.bovines.isActive.equals(true));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta bovinos por aptidão
  Future<Result<Map<int, int>>> countByAptitude() async {
    try {
      final counts = <int, int>{};

      for (int aptitude = 0; aptitude <= 2; aptitude++) {
        final count = _db.bovines.id.count();
        final query = _db.selectOnly(_db.bovines)
          ..addColumns([count])
          ..where(
            _db.bovines.isActive.equals(true) &
                _db.bovines.aptitude.equals(aptitude),
          );

        final result = await query.getSingle();
        counts[aptitude] = result.read(count) ?? 0;
      }

      return Result.success(counts);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
