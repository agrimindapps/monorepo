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
  Future<Result<int>> insert(RainGaugesCompanion rainGauge) async {
    try {
      final rowsAffected = await _db.into(_db.rainGauges).insert(rainGauge);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(RainGaugesCompanion rainGauge) async {
    try {
      final rowsAffected =
          await _db.into(_db.rainGauges).insertOnConflictUpdate(rainGauge);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca pluviômetro por ID
  Future<Result<RainGauge?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todos os pluviômetros ativos
  Future<Result<List<RainGauge>>> getAll() async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca pluviômetros por grupo
  Future<Result<List<RainGauge>>> getByGroup(String groupId) async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where(
              (t) => t.isActive.equals(true) & t.groupId.equals(groupId),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca pluviômetros com localização GPS
  Future<Result<List<RainGauge>>> getWithLocation() async {
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
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca por descrição (like)
  Future<Result<List<RainGauge>>> searchByDescription(String query) async {
    try {
      final results = await (_db.select(_db.rainGauges)
            ..where(
              (t) => t.isActive.equals(true) & t.description.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.description)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
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
  Future<Result<int>> update(String id, RainGaugesCompanion rainGauge) async {
    try {
      final updated = await (_db.update(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .write(rainGauge);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Soft delete (marca como inativo)
  Future<Result<int>> softDelete(String id) async {
    try {
      final updated = await (_db.update(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .write(
        RainGaugesCompanion(
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
      final deleted = await (_db.delete(_db.rainGauges)
            ..where((t) => t.id.equals(id)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todos os pluviômetros
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.rainGauges).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta pluviômetros ativos
  Future<Result<int>> countActive() async {
    try {
      final count = _db.rainGauges.id.count();
      final query = _db.selectOnly(_db.rainGauges)
        ..addColumns([count])
        ..where(_db.rainGauges.isActive.equals(true));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta pluviômetros por grupo
  Future<Result<Map<String, int>>> countByGroup() async {
    try {
      final counts = <String, int>{};

      final results = await (_db.select(_db.rainGauges)
            ..where((t) => t.isActive.equals(true) & t.groupId.isNotNull()))
          .get();

      for (final gauge in results) {
        final group = gauge.groupId ?? 'sem_grupo';
        counts[group] = (counts[group] ?? 0) + 1;
      }

      return Result.success(counts);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
