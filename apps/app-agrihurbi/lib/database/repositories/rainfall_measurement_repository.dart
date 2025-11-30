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
  Future<Result<int>> insert(RainfallMeasurementsCompanion measurement) async {
    try {
      final rowsAffected =
          await _db.into(_db.rainfallMeasurements).insert(measurement);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(RainfallMeasurementsCompanion measurement) async {
    try {
      final rowsAffected = await _db
          .into(_db.rainfallMeasurements)
          .insertOnConflictUpdate(measurement);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca medição por ID
  Future<Result<RainfallMeasurement?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todas as medições ativas
  Future<Result<List<RainfallMeasurement>>> getAll() async {
    try {
      final results = await (_db.select(_db.rainfallMeasurements)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.measurementDate)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca medições por pluviômetro
  Future<Result<List<RainfallMeasurement>>> getByRainGauge(
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
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca medições por período
  Future<Result<List<RainfallMeasurement>>> getByPeriod(
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
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca medições por pluviômetro e período
  Future<Result<List<RainfallMeasurement>>> getByRainGaugeAndPeriod(
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
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca medições do mês atual
  Future<Result<List<RainfallMeasurement>>> getCurrentMonthMeasurements() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getByPeriod(start, end);
  }

  /// Busca medições do ano atual
  Future<Result<List<RainfallMeasurement>>> getCurrentYearMeasurements() async {
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
  Future<Result<int>> update(
    String id,
    RainfallMeasurementsCompanion measurement,
  ) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .write(measurement);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Result<int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .write(
        RainfallMeasurementsCompanion(
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
      final deleted = await (_db.delete(_db.rainfallMeasurements)
            ..where((t) => t.id.equals(id)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todas as medições
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.rainfallMeasurements).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Remove medições de um pluviômetro (soft delete em cascade)
  Future<Result<int>> softDeleteByRainGauge(String rainGaugeId) async {
    try {
      final updated = await (_db.update(_db.rainfallMeasurements)
            ..where((t) => t.rainGaugeId.equals(rainGaugeId)))
          .write(
        RainfallMeasurementsCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== ESTATÍSTICAS ====================

  /// Total acumulado de chuva em um período
  Future<Result<double>> getTotalByPeriod(DateTime start, DateTime end) async {
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
      return Result.success(result.read(sum) ?? 0.0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Total acumulado por pluviômetro em um período
  Future<Result<double>> getTotalByRainGaugeAndPeriod(
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
      return Result.success(result.read(sum) ?? 0.0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Média de chuva em um período
  Future<Result<double>> getAverageByPeriod(DateTime start, DateTime end) async {
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
      return Result.success(result.read(avg) ?? 0.0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Máximo de chuva em um período
  Future<Result<double>> getMaxByPeriod(DateTime start, DateTime end) async {
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
      return Result.success(result.read(max) ?? 0.0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Mínimo de chuva em um período (excluindo zeros)
  Future<Result<double>> getMinByPeriod(DateTime start, DateTime end) async {
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
      return Result.success(result.read(min) ?? 0.0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta medições ativas
  Future<Result<int>> countActive() async {
    try {
      final count = _db.rainfallMeasurements.id.count();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([count])
        ..where(_db.rainfallMeasurements.isActive.equals(true));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta medições por pluviômetro
  Future<Result<int>> countByRainGauge(String rainGaugeId) async {
    try {
      final count = _db.rainfallMeasurements.id.count();
      final query = _db.selectOnly(_db.rainfallMeasurements)
        ..addColumns([count])
        ..where(
          _db.rainfallMeasurements.isActive.equals(true) &
              _db.rainfallMeasurements.rainGaugeId.equals(rainGaugeId),
        );

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Totais mensais de um ano específico
  Future<Result<Map<int, double>>> getMonthlyTotals(int year) async {
    try {
      final monthlyTotals = <int, double>{};
      
      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0, 23, 59, 59);
        final result = await getTotalByPeriod(start, end);
        if (result.isSuccess && result.data != null) {
          monthlyTotals[month] = result.data!;
        } else {
          monthlyTotals[month] = 0.0;
        }
      }

      return Result.success(monthlyTotals);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Total anual por ano
  Future<Result<Map<int, double>>> getYearlyTotals({
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
        if (result.isSuccess && result.data != null) {
          yearlyTotals[year] = result.data!;
        } else {
          yearlyTotals[year] = 0.0;
        }
      }

      return Result.success(yearlyTotals);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
