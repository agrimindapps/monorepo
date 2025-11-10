import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../gasometer_database.dart';
import '../tables/gasometer_tables.dart';

/// Repositório de Manutenções usando Drift
///
/// Gerencia operações de CRUD e queries para manutenções de veículos
@lazySingleton
class MaintenanceRepository
    extends BaseDriftRepositoryImpl<MaintenanceData, Maintenance> {
  MaintenanceRepository(this._db);

  final GasometerDatabase _db;

  @override
  TableInfo<Maintenances, Maintenance> get table => _db.maintenances;

  @override
  GeneratedDatabase get database => _db;

  @override
  MaintenanceData fromData(Maintenance data) {
    return MaintenanceData(
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
      tipo: data.tipo,
      descricao: data.descricao,
      valor: data.valor,
      data: data.data,
      odometro: data.odometro,
      proximaRevisao: data.proximaRevisao,
      concluida: data.concluida,
      receiptImageUrl: data.receiptImageUrl,
      receiptImagePath: data.receiptImagePath,
    );
  }

  @override
  Insertable<Maintenance> toCompanion(MaintenanceData entity) {
    return MaintenancesCompanion(
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
      tipo: Value(entity.tipo),
      descricao: Value(entity.descricao),
      valor: Value(entity.valor),
      data: Value(entity.data),
      odometro: Value(entity.odometro),
      proximaRevisao: Value(entity.proximaRevisao),
      concluida: Value(entity.concluida),
      receiptImageUrl: Value(entity.receiptImageUrl),
      receiptImagePath: Value(entity.receiptImagePath),
    );
  }

  @override
  Expression<int> idColumn(Maintenances tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca manutenções de um veículo
  Future<List<MaintenanceData>> findByVehicleId(int vehicleId) async {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de manutenções de um veículo
  Stream<List<MaintenanceData>> watchByVehicleId(int vehicleId) {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca manutenções pendentes (não concluídas)
  Future<List<MaintenanceData>> findPendingByVehicleId(int vehicleId) async {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.concluida.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.data)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de manutenções pendentes
  Stream<List<MaintenanceData>> watchPendingByVehicleId(int vehicleId) {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.concluida.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.data)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca manutenções concluídas
  Future<List<MaintenanceData>> findCompletedByVehicleId(int vehicleId) async {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.concluida.equals(true) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca manutenções por tipo
  Future<List<MaintenanceData>> findByType(int vehicleId, String tipo) async {
    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.tipo.equals(tipo) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca manutenções em um período
  Future<List<MaintenanceData>> findByPeriod(
    int vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    final query = _db.select(_db.maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.data.isBiggerOrEqualValue(startMs) &
            tbl.data.isSmallerOrEqualValue(endMs) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Calcula total gasto em manutenções
  Future<double> calculateTotalCost(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.selectOnly(_db.maintenances)
      ..addColumns([_db.maintenances.valor.sum()])
      ..where(
        _db.maintenances.vehicleId.equals(vehicleId) &
            _db.maintenances.isDeleted.equals(false),
      );

    if (startDate != null) {
      query = query
        ..where(
          _db.maintenances.data.isBiggerOrEqualValue(
            startDate.millisecondsSinceEpoch,
          ),
        );
    }
    if (endDate != null) {
      query = query
        ..where(
          _db.maintenances.data.isSmallerOrEqualValue(
            endDate.millisecondsSinceEpoch,
          ),
        );
    }

    final result = await query.getSingle();
    return result.read(_db.maintenances.valor.sum()) ?? 0.0;
  }

  /// Conta total de manutenções de um veículo
  Future<int> countByVehicleId(int vehicleId) async {
    final query = _db.selectOnly(_db.maintenances)
      ..addColumns([_db.maintenances.id.count()])
      ..where(
        _db.maintenances.vehicleId.equals(vehicleId) &
            _db.maintenances.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.maintenances.id.count()) ?? 0;
  }

  /// Conta manutenções pendentes
  Future<int> countPendingByVehicleId(int vehicleId) async {
    final query = _db.selectOnly(_db.maintenances)
      ..addColumns([_db.maintenances.id.count()])
      ..where(
        _db.maintenances.vehicleId.equals(vehicleId) &
            _db.maintenances.concluida.equals(false) &
            _db.maintenances.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.maintenances.id.count()) ?? 0;
  }

  /// Marca uma manutenção como concluída
  Future<bool> markAsCompleted(int maintenanceId) async {
    final rowsAffected =
        await (_db.update(
          _db.maintenances,
        )..where((tbl) => tbl.id.equals(maintenanceId))).write(
          MaintenancesCompanion(
            concluida: const Value(true),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Busca tipos de manutenção distintos
  Future<List<String>> findDistinctTypes(int vehicleId) async {
    final query = _db.selectOnly(_db.maintenances, distinct: true)
      ..addColumns([_db.maintenances.tipo])
      ..where(
        _db.maintenances.vehicleId.equals(vehicleId) &
            _db.maintenances.isDeleted.equals(false),
      )
      ..orderBy([OrderingTerm.asc(_db.maintenances.tipo)]);

    final results = await query.get();
    return results
        .map((row) => row.read(_db.maintenances.tipo))
        .where((tipo) => tipo != null && tipo.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Busca manutenções que precisam ser sincronizadas
  Future<List<MaintenanceData>> findDirtyRecords() async {
    final query = _db.select(_db.maintenances)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> maintenanceIds) async {
    await _db.executeTransaction(() async {
      for (final id in maintenanceIds) {
        await (_db.update(
          _db.maintenances,
        )..where((tbl) => tbl.id.equals(id))).write(
          MaintenancesCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark maintenances as synced');
  }

  /// Soft delete de uma manutenção
  Future<bool> softDelete(int maintenanceId) async {
    final rowsAffected =
        await (_db.update(
          _db.maintenances,
        )..where((tbl) => tbl.id.equals(maintenanceId))).write(
          MaintenancesCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }
}

/// Classe auxiliar para transferência de dados de manutenções
class MaintenanceData {
  const MaintenanceData({
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
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.odometro,
    this.proximaRevisao,
    required this.concluida,
    this.receiptImageUrl,
    this.receiptImagePath,
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
  final String tipo;
  final String descricao;
  final double valor;
  final int data;
  final int odometro;
  final int? proximaRevisao;
  final bool concluida;
  final String? receiptImageUrl;
  final String? receiptImagePath;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(data);

  MaintenanceData copyWith({
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
    String? tipo,
    String? descricao,
    double? valor,
    int? data,
    int? odometro,
    int? proximaRevisao,
    bool? concluida,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    return MaintenanceData(
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
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      proximaRevisao: proximaRevisao ?? this.proximaRevisao,
      concluida: concluida ?? this.concluida,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
