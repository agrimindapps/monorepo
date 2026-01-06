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
  Future<Either<Failure, int>> insert(BovinesCompanion bovine) async {
    try {
      final rowsAffected = await _db.into(_db.bovines).insert(bovine);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(BovinesCompanion bovine) async {
    try {
      final rowsAffected =
          await _db.into(_db.bovines).insertOnConflictUpdate(bovine);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== READ ====================

  /// Busca bovino por ID
  Future<Either<Failure, Bovine?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca todos os bovinos ativos
  Future<Either<Failure, List<Bovine>>> getAll() async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca bovinos por aptidão (0=dairy, 1=beef, 2=mixed)
  Future<Either<Failure, List<Bovine>>> getByAptitude(int aptitude) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where(
              (t) => t.isActive.equals(true) & t.aptitude.equals(aptitude),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca bovinos por sistema de criação (0=extensive, 1=intensive, 2=semiIntensive)
  Future<Either<Failure, List<Bovine>>> getByBreedingSystem(int breedingSystem) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  t.breedingSystem.equals(breedingSystem),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca bovinos por raça
  Future<Either<Failure, List<Bovine>>> getByBreed(String breed) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where((t) => t.isActive.equals(true) & t.breed.equals(breed))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca por nome (like)
  Future<Either<Failure, List<Bovine>>> searchByName(String query) async {
    try {
      final results = await (_db.select(_db.bovines)
            ..where(
              (t) => t.isActive.equals(true) & t.commonName.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
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
  Future<Either<Failure, int>> update(String id, BovinesCompanion bovine) async {
    try {
      final updated = await (_db.update(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .write(bovine);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Either<Failure, int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.bovines)
            ..where((t) => t.id.equals(id)))
          .write(
        BovinesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Hard delete
  Future<Either<Failure, int>> delete(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.bovines)..where((t) => t.id.equals(id))).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Limpa todos os bovinos
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.bovines).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta bovinos ativos
  Future<Either<Failure, int>> countActive() async {
    try {
      final count = _db.bovines.id.count();
      final query = _db.selectOnly(_db.bovines)
        ..addColumns([count])
        ..where(_db.bovines.isActive.equals(true));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Conta bovinos por aptidão
  Future<Either<Failure, Map<int, int>>> countByAptitude() async {
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

      return Right(counts);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }
}
