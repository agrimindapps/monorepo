import 'package:drift/drift.dart';
import '../../core/drift_exports.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../gasometer_database.dart';
import '../tables/gasometer_tables.dart';

/// Repositório de Leituras de Odômetro usando Drift
///
/// Gerencia operações de CRUD e queries para registros de odômetro
@lazySingleton
class OdometerReadingRepository
    extends BaseDriftRepositoryImpl<OdometerReadingData, OdometerReading> {
  OdometerReadingRepository(this._db);

  final GasometerDatabase _db;

  @override
  TableInfo<OdometerReadings, OdometerReading> get table {
    return _db.odometerReadings;
  }

  @override
  GeneratedDatabase get database {
    return _db;
  }

  @override
  OdometerReadingData fromData(OdometerReading data) {
    return OdometerReadingData(
      id: data.id,
      userId: data.userId,
      moduleName: data.moduleName,
      vehicleId: data.vehicleId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      reading: data.reading,
      date: data.date,
      notes: data.notes,
    );
  }

  @override
  Insertable<OdometerReading> toCompanion(OdometerReadingData entity) {
    return OdometerReadingsCompanion(
      // id é autoIncrement, não deve ser especificado no insert
      id: entity.id > 0 ? Value(entity.id) : Value.absent(),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      vehicleId: Value(entity.vehicleId),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      reading: Value(entity.reading),
      date: Value(entity.date),
      notes: Value(entity.notes),
    );
  }

  @override
  Expression<int> idColumn(OdometerReadings tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca leituras de odômetro de um veículo
  Future<List<OdometerReadingData>> findByVehicleId(int vehicleId) async {
    if (_db == null) return [];
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de leituras de odômetro de um veículo
  Stream<List<OdometerReadingData>> watchByVehicleId(int vehicleId) {
    if (_db == null) return Stream.empty();
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca última leitura de odômetro
  Future<OdometerReadingData?> findLatestByVehicleId(int vehicleId) async {
    if (_db == null) return null;
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Stream da última leitura de odômetro
  Stream<OdometerReadingData?> watchLatestByVehicleId(int vehicleId) {
    if (_db == null) return Stream.value(null);
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(1);

    return query.watch().map((dataList) {
      return dataList.isEmpty ? null : fromData(dataList.first);
    });
  }

  /// Busca leituras em um período
  Future<List<OdometerReadingData>> findByPeriod(
    int vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_db == null) return [];
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.date.isBiggerOrEqualValue(startMs) &
            tbl.date.isSmallerOrEqualValue(endMs) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca primeira leitura de odômetro
  Future<OdometerReadingData?> findFirstByVehicleId(int vehicleId) async {
    if (_db == null) return null;
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)])
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Calcula distância percorrida total
  Future<double> calculateTotalDistance(int vehicleId) async {
    final first = await findFirstByVehicleId(vehicleId);
    final latest = await findLatestByVehicleId(vehicleId);

    if (first == null || latest == null) return 0.0;

    return (latest.reading - first.reading);
  }

  /// Calcula distância percorrida em um período
  Future<double> calculateDistanceInPeriod(
    int vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final readings = await findByPeriod(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );

    if (readings.length < 2) return 0.0;

    final firstReading = readings.first;
    final lastReading = readings.last;

    return (lastReading.reading - firstReading.reading);
  }

  /// Calcula odômetro médio por mês
  Future<Map<String, double>> getAverageOdometerByMonth(int vehicleId) async {
    if (_db == null) return {};
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);

    final results = await query.get();
    final map = <String, List<double>>{};

    for (final reading in results) {
      final date = DateTime.fromMillisecondsSinceEpoch(reading.date);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      map.putIfAbsent(key, () => []).add(reading.reading);
    }

    // Calcula a média para cada mês
    return map.map((key, values) {
      final average = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, average);
    });
  }

  /// Conta total de leituras de um veículo
  Future<int> countByVehicleId(int vehicleId) async {
    if (_db == null) return 0;
    final query = _db.selectOnly(_db.odometerReadings)
      ..addColumns([_db.odometerReadings.id.count()])
      ..where(
        _db.odometerReadings.vehicleId.equals(vehicleId) &
            _db.odometerReadings.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.odometerReadings.id.count()) ?? 0;
  }

  /// Busca leituras mais recentes
  Future<List<OdometerReadingData>> findRecent(
    int vehicleId, {
    int limit = 10,
  }) async {
    if (_db == null) return [];
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Verifica se existe leitura duplicada
  Future<bool> existsDuplicateReading(
    int vehicleId,
    double reading,
    int date,
  ) async {
    if (_db == null) return false;
    final query = _db.select(_db.odometerReadings)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.reading.equals(reading) &
            tbl.date.equals(date) &
            tbl.isDeleted.equals(false),
      )
      ..limit(1);

    final results = await query.get();
    return results.isNotEmpty;
  }

  /// Busca leituras que precisam ser sincronizadas
  Future<List<OdometerReadingData>> findDirtyRecords() async {
    if (_db == null) return [];
    final query = _db.select(_db.odometerReadings)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> readingIds) async {
    if (_db == null) return;
    await _db.executeTransaction(() async {
      for (final id in readingIds) {
        await (_db.update(
          _db.odometerReadings,
        )..where((tbl) => tbl.id.equals(id))).write(
          OdometerReadingsCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark odometer readings as synced');
  }

  /// Soft delete de uma leitura
  Future<bool> softDelete(int readingId) async {
    if (_db == null) return false;
    final rowsAffected =
        await (_db.update(
          _db.odometerReadings,
        )..where((tbl) => tbl.id.equals(readingId))).write(
          OdometerReadingsCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }
}

/// Classe auxiliar para transferência de dados de leituras de odômetro
class OdometerReadingData {
  const OdometerReadingData({
    required this.id,
    required this.userId,
    required this.moduleName,
    required this.vehicleId,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
    required this.isDirty,
    required this.isDeleted,
    required this.version,
    required this.reading,
    required this.date,
    this.notes,
  });

  final int id;
  final String userId;
  final String moduleName;
  final int vehicleId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final double reading;
  final int date;
  final String? notes;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  OdometerReadingData copyWith({
    int? id,
    String? userId,
    String? moduleName,
    int? vehicleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    double? reading,
    int? date,
    String? notes,
  }) {
    return OdometerReadingData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      vehicleId: vehicleId ?? this.vehicleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      reading: reading ?? this.reading,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
