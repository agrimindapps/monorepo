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
  Future<Either<Failure, int>> insert(EquinesCompanion equine) async {
    try {
      final rowsAffected = await _db.into(_db.equines).insert(equine);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(EquinesCompanion equine) async {
    try {
      final rowsAffected =
          await _db.into(_db.equines).insertOnConflictUpdate(equine);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== READ ====================

  /// Busca equino por ID
  Future<Either<Failure, Equine?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.equines)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca todos os equinos ativos
  Future<Either<Failure, List<Equine>>> getAll() async {
    try {
      final results = await (_db.select(_db.equines)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca equinos por temperamento
  Future<Either<Failure, List<Equine>>> getByTemperament(int temperament) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) =>
                  t.isActive.equals(true) & t.temperament.equals(temperament),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca equinos por pelagem
  Future<Either<Failure, List<Equine>>> getByCoat(int coat) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) => t.isActive.equals(true) & t.coat.equals(coat),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca equinos por uso primário
  Future<Either<Failure, List<Equine>>> getByPrimaryUse(int primaryUse) async {
    try {
      final results = await (_db.select(_db.equines)
            ..where(
              (t) => t.isActive.equals(true) & t.primaryUse.equals(primaryUse),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.commonName)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca por nome (like)
  Future<Either<Failure, List<Equine>>> searchByName(String query) async {
    try {
      final results = await (_db.select(_db.equines)
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
  Future<Either<Failure, int>> update(String id, EquinesCompanion equine) async {
    try {
      final updated = await (_db.update(_db.equines)
            ..where((t) => t.id.equals(id)))
          .write(equine);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Either<Failure, int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.equines)
            ..where((t) => t.id.equals(id)))
          .write(
        EquinesCompanion(
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
          await (_db.delete(_db.equines)..where((t) => t.id.equals(id))).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Limpa todos os equinos
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.equines).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta equinos ativos
  Future<Either<Failure, int>> countActive() async {
    try {
      final count = _db.equines.id.count();
      final query = _db.selectOnly(_db.equines)
        ..addColumns([count])
        ..where(_db.equines.isActive.equals(true));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Conta equinos por uso primário
  Future<Either<Failure, Map<int, int>>> countByPrimaryUse() async {
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

      return Right(counts);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }
}
