import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../agrihurbi_database.dart';

/// ============================================================================
/// RAIN GAUGE REPOSITORY - Padrão Agrihurbi (String ID)
/// ============================================================================
///
/// Repository de RainGauges (pluviômetros) usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Filtros por grupo, localização, etc.
/// ============================================================================

class RainGaugeRepository {
  RainGaugeRepository(this._db);

  final AgrihurbiDatabase _db;

  String get tableName => 'rain_gauges';

  // ==================== CREATE ====================

  /// Insere um novo pluviômetro
  Future<Either<Failure, int>> insert(RainGaugesCompanion rainGauge) async {
    try {
      final rowsAffected = await _db.into(_db.rainGauges).insert(rainGauge);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(RainGaugesCompanion rainGauge) async {
    try {
      final rowsAffected =
          await _db.into(_db.rainGauges).insertOnConflictUpdate(rainGauge);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== READ ====================

  /// Busca pluviômetro por ID
  Future<Either<Failure, RainGauge?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca todos os pluviômetros ativos
  Future<Either<Failure, List<RainGauge>>> getAll() async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca pluviômetros por grupo
  Future<Either<Failure, List<RainGauge>>> getByGroup(String groupId) async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where(
              (t) => t.isActive.equals(true) & t.groupId.equals(groupId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca pluviômetros com localização GPS
  Future<Either<Failure, List<RainGauge>>> getWithLocation() async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  t.latitude.isNotNull() &
                  t.longitude.isNotNull(),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca por descrição (like)
  Future<Either<Failure, List<RainGauge>>> searchByDescription(String query) async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where(
              (t) => t.isActive.equals(true) & t.description.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== STREAMS ====================

  /// Stream de todos os pluviômetros ativos
  Stream<List<RainGauge>> watchAll() {
    return (_db.select(_db.rainGauges)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.description)]))
        .watch();
  }

  /// Stream de um pluviômetro específico
  Stream<RainGauge?> watchById(String id) {
    return (_db.select(_db.rainGauges)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Stream de pluviômetros por grupo
  Stream<List<RainGauge>> watchByGroup(String groupId) {
    return (_db.select(_db.rainGauges)
          ..where(
            (t) => t.isActive.equals(true) & t.groupId.equals(groupId),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.description)]))
        .watch();
  }

  // ==================== UPDATE ====================

  /// Atualiza pluviômetro
  Future<Either<Failure, int>> update(String id, RainGaugesCompanion rainGauge) async {
    try {
      final updated = await (_db.update(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .write(rainGauge);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Either<Failure, int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .write(
        RainGaugesCompanion(
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
      final deleted = await (_db.delete(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Limpa todos os pluviômetros
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.rainGauges).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta pluviômetros ativos
  Future<Either<Failure, int>> countActive() async {
    try {
      final count = _db.rainGauges.id.count();
      final query = _db.selectOnly(_db.rainGauges)
        ..addColumns([count])
        ..where(_db.rainGauges.isActive.equals(true));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Conta pluviômetros por grupo
  Future<Either<Failure, Map<String, int>>> countByGroup() async {
    try {
      final counts = <String, int>{};

      final results = await (_db.select(_db.rainGauges)
            ..where((t) => t.isActive.equals(true) & t.groupId.isNotNull()))
          .get();

      for (final gauge in results) {
        final group = gauge.groupId ?? 'sem_grupo';
        counts[group] = (counts[group] ?? 0) + 1;
      }

      return Right(counts);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }
}
