import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../agrihurbi_database.dart';

/// ============================================================================
/// RAINFALL MEASUREMENT REPOSITORY - Padrão Agrihurbi (String ID)
/// ============================================================================
///
/// Repository de RainfallMeasurements (medições pluviométricas) usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Filtros por período, pluviômetro, etc.
/// - Estatísticas agregadas
/// ============================================================================

class RainfallMeasurementRepository {
  RainfallMeasurementRepository(this._db);

  final AgrihurbiDatabase _db;

  String get tableName => 'rainfall_measurements';

  // ==================== CREATE ====================

  /// Insere uma nova medição
  Future<Either<Failure, int>> insert(RainfallMeasurementsCompanion measurement) async {
    try {
      final rowsAffected =
          await _db.into(_db.rainfallMeasurements).insert(measurement);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(RainfallMeasurementsCompanion measurement) async {
    try {
      final rowsAffected = await _db
          .into(_db.rainfallMeasurements)
          .insertOnConflictUpdate(measurement);
      return Right(rowsAffected);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== READ ====================

  /// Busca medição por ID
  Future<Either<Failure, RainfallMeasurement?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca todas as medições ativas
  Future<Either<Failure, List<RainfallMeasurement>>> getAll() async {
    try {
      final results = await (_db.select(_db.rainfallMeasurements)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca medições por pluviômetro
  Future<Either<Failure, List<RainfallMeasurement>>> getByRainGauge(
    String rainGaugeId,
  ) async {
    try {
      final results = await (_db.select(_db.rainfallMeasurements)
            ..where(
              (t) =>
                  t.isActive.equals(true) & t.rainGaugeId.equals(rainGaugeId),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca medições por período
  Future<Either<Failure, List<RainfallMeasurement>>> getByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final results = await (_db.select(_db.rainfallMeasurements)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  t.measurementDate.isBiggerOrEqualValue(start) &
                  t.measurementDate.isSmallerOrEqualValue(end),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca medições por pluviômetro e período
  Future<Either<Failure, List<RainfallMeasurement>>> getByRainGaugeAndPeriod(
    String rainGaugeId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final results = await (_db.select(_db.rainfallMeasurements)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  t.rainGaugeId.equals(rainGaugeId) &
                  t.measurementDate.isBiggerOrEqualValue(start) &
                  t.measurementDate.isSmallerOrEqualValue(end),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
          .get();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Busca medições do mês atual
  Future<Either<Failure, List<RainfallMeasurement>>> getCurrentMonthMeasurements() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getByPeriod(start, end);
  }

  /// Busca medições do ano atual
  Future<Either<Failure, List<RainfallMeasurement>>> getCurrentYearMeasurements() async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    return getByPeriod(start, end);
  }

  // ==================== STREAMS ====================

  /// Stream de todas as medições ativas
  Stream<List<RainfallMeasurement>> watchAll() {
    return (_db.select(_db.rainfallMeasurements)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
        .watch();
  }

  /// Stream de uma medição específica
  Stream<RainfallMeasurement?> watchById(String id) {
    return (_db.select(_db.rainfallMeasurements)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Stream de medições por pluviômetro
  Stream<List<RainfallMeasurement>> watchByRainGauge(String rainGaugeId) {
    return (_db.select(_db.rainfallMeasurements)
          ..where(
            (t) => t.isActive.equals(true) & t.rainGaugeId.equals(rainGaugeId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
        .watch();
  }

  // ==================== UPDATE ====================

  /// Atualiza medição
  Future<Either<Failure, int>> update(
    String id,
    RainfallMeasurementsCompanion measurement,
  ) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .write(measurement);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Either<Failure, int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .write(
        RainfallMeasurementsCompanion(
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
      final deleted = await (_db.delete(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Limpa todas as medições
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.rainfallMeasurements).go();
      return Right(deleted);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Remove medições de um pluviômetro (soft delete em cascade)
  Future<Either<Failure, int>> softDeleteByRainGauge(String rainGaugeId) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.rainGaugeId.equals(rainGaugeId)))
          .write(
        RainfallMeasurementsCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  // ==================== ESTATÍSTICAS ====================

  /// Total acumulado de chuva em um período
  Future<Either<Failure, double>> getTotalByPeriod(DateTime start, DateTime end) async {
    try {
      final sum = _db.rainfallMeasurements.amount.sum();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([sum])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.measurementDate
                  .isBiggerOrEqualValue(start) &
              _db.rainfallMeasurements.measurementDate
                  .isSmallerOrEqualValue(end),
        );

      final result = await query.getSingle();
      return Right(result.read(sum) ?? 0.0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Total acumulado por pluviômetro em um período
  Future<Either<Failure, double>> getTotalByRainGaugeAndPeriod(
    String rainGaugeId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final sum = _db.rainfallMeasurements.amount.sum();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([sum])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.rainGaugeId.equals(rainGaugeId) &
              _db.rainfallMeasurements.measurementDate
                  .isBiggerOrEqualValue(start) &
              _db.rainfallMeasurements.measurementDate
                  .isSmallerOrEqualValue(end),
        );

      final result = await query.getSingle();
      return Right(result.read(sum) ?? 0.0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Média de chuva em um período
  Future<Either<Failure, double>> getAverageByPeriod(DateTime start, DateTime end) async {
    try {
      final avg = _db.rainfallMeasurements.amount.avg();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([avg])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.measurementDate
                  .isBiggerOrEqualValue(start) &
              _db.rainfallMeasurements.measurementDate
                  .isSmallerOrEqualValue(end),
        );

      final result = await query.getSingle();
      return Right(result.read(avg) ?? 0.0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Máximo de chuva em um período
  Future<Either<Failure, double>> getMaxByPeriod(DateTime start, DateTime end) async {
    try {
      final max = _db.rainfallMeasurements.amount.max();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([max])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.measurementDate
                  .isBiggerOrEqualValue(start) &
              _db.rainfallMeasurements.measurementDate
                  .isSmallerOrEqualValue(end),
        );

      final result = await query.getSingle();
      return Right(result.read(max) ?? 0.0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Mínimo de chuva em um período (excluindo zeros)
  Future<Either<Failure, double>> getMinByPeriod(DateTime start, DateTime end) async {
    try {
      final min = _db.rainfallMeasurements.amount.min();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([min])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.amount.isBiggerThanValue(0) &
              _db.rainfallMeasurements.measurementDate
                  .isBiggerOrEqualValue(start) &
              _db.rainfallMeasurements.measurementDate
                  .isSmallerOrEqualValue(end),
        );

      final result = await query.getSingle();
      return Right(result.read(min) ?? 0.0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Conta medições ativas
  Future<Either<Failure, int>> countActive() async {
    try {
      final count = _db.rainfallMeasurements.id.count();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([count])
        ..where(_db.rainfallMeasurements.isActive.equals(true));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Conta medições por pluviômetro
  Future<Either<Failure, int>> countByRainGauge(String rainGaugeId) async {
    try {
      final count = _db.rainfallMeasurements.id.count();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([count])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.rainGaugeId.equals(rainGaugeId),
        );

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Totais mensais de um ano específico
  Future<Either<Failure, Map<int, double>>> getMonthlyTotals(int year) async {
    try {
      final monthlyTotals = <int, double>{};

      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0, 23, 59, 59);
        final result = await getTotalByPeriod(start, end);
        result.fold(
          (failure) => monthlyTotals[month] = 0.0,
          (total) => monthlyTotals[month] = total,
        );
      }

      return Right(monthlyTotals);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  /// Total anual por ano
  Future<Either<Failure, Map<int, double>>> getYearlyTotals({
    int startYear = 2020,
    int? endYear,
  }) async {
    try {
      final yearlyTotals = <int, double>{};
      final end = endYear ?? DateTime.now().year;

      for (int year = startYear; year <= end; year++) {
        final start = DateTime(year, 1, 1);
        final yearEnd = DateTime(year, 12, 31, 23, 59, 59);
        final result = await getTotalByPeriod(start, yearEnd);
        result.fold(
          (failure) => yearlyTotals[year] = 0.0,
          (total) => yearlyTotals[year] = total,
        );
      }

      return Right(yearlyTotals);
    } catch (e) {
      return Left(ServerFailure('Operation failed: $e'));
    }
  }
}
