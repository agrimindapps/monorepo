import 'package:drift/drift.dart';
import '../../../core/drift_exports.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../gasometer_database.dart';
import '../tables/gasometer_tables.dart';

/// Repositório de Abastecimentos usando Drift
///
/// Gerencia operações de CRUD e queries para abastecimentos de combustível
class FuelSupplyRepository
    extends BaseDriftRepositoryImpl<FuelSupplyData, FuelSupply> {
  FuelSupplyRepository(this._db);

  final GasometerDatabase? _db;

  @override
  TableInfo<FuelSupplies, FuelSupply> get table {
    if (_db == null) {
      throw UnsupportedError('Drift database is not available on web.');
    }
    return _db!.fuelSupplies;
  }

  @override
  GeneratedDatabase get database {
    if (_db == null) {
      throw UnsupportedError('Drift database is not available on web.');
    }
    return _db!;
  }

  @override
  FuelSupplyData fromData(FuelSupply data) {
    return FuelSupplyData(
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
      date: data.date,
      odometer: data.odometer,
      liters: data.liters,
      pricePerLiter: data.pricePerLiter,
      totalPrice: data.totalPrice,
      fullTank: data.fullTank,
      fuelType: data.fuelType,
      gasStationName: data.gasStationName,
      notes: data.notes,
      receiptImageUrl: data.receiptImageUrl,
      receiptImagePath: data.receiptImagePath,
    );
  }

  @override
  Insertable<FuelSupply> toCompanion(FuelSupplyData entity) {
    return FuelSuppliesCompanion(
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
      date: Value(entity.date),
      odometer: Value(entity.odometer),
      liters: Value(entity.liters),
      pricePerLiter: Value(entity.pricePerLiter),
      totalPrice: Value(entity.totalPrice),
      fullTank: Value(entity.fullTank),
      fuelType: Value(entity.fuelType),
      gasStationName: Value(entity.gasStationName),
      notes: Value(entity.notes),
      receiptImageUrl: Value(entity.receiptImageUrl),
      receiptImagePath: Value(entity.receiptImagePath),
    );
  }

  @override
  Expression<int> idColumn(FuelSupplies tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca abastecimentos de um veículo
  Future<List<FuelSupplyData>> findByVehicleId(
    int vehicleId, {
    int? limit,
  }) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    if (limit != null) {
      query.limit(limit);
    }

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de abastecimentos de um veículo
  Stream<List<FuelSupplyData>> watchByVehicleId(int vehicleId) {
    if (_db == null) return Stream.empty();
    final query = _db!.select(_db!.fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca último abastecimento de um veículo
  Future<FuelSupplyData?> findLastByVehicleId(int vehicleId) async {
    if (_db == null) return null;
    final query = _db!.select(_db!.fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Busca abastecimentos em um período
  Future<List<FuelSupplyData>> findByPeriod(
    int vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_db == null) return [];
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    final query = _db!.select(_db!.fuelSupplies)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.date.isBiggerOrEqualValue(startMs) &
            tbl.date.isSmallerOrEqualValue(endMs) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca abastecimentos com tanque cheio (para cálculo de consumo)
  Future<List<FuelSupplyData>> findFullTankByVehicleId(int vehicleId) async {
    if (_db == null) return [];
    final query = _db!.select(_db!.fuelSupplies)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.fullTank.equals(true) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Calcula total gasto em combustível de um veículo
  Future<double> calculateTotalSpent(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_db == null) return 0.0;
    var query = _db!.selectOnly(_db!.fuelSupplies)
      ..addColumns([_db!.fuelSupplies.totalPrice.sum()])
      ..where(
        _db!.fuelSupplies.vehicleId.equals(vehicleId) &
            _db!.fuelSupplies.isDeleted.equals(false),
      );

    if (startDate != null) {
      query = query
        ..where(
          _db!.fuelSupplies.date.isBiggerOrEqualValue(
            startDate.millisecondsSinceEpoch,
          ),
        );
    }
    if (endDate != null) {
      query = query
        ..where(
          _db!.fuelSupplies.date.isSmallerOrEqualValue(
            endDate.millisecondsSinceEpoch,
          ),
        );
    }

    final result = await query.getSingle();
    return result.read(_db!.fuelSupplies.totalPrice.sum()) ?? 0.0;
  }

  /// Calcula total de litros abastecidos
  Future<double> calculateTotalLiters(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_db == null) return 0.0;
    var query = _db!.selectOnly(_db!.fuelSupplies)
      ..addColumns([_db!.fuelSupplies.liters.sum()])
      ..where(
        _db!.fuelSupplies.vehicleId.equals(vehicleId) &
            _db!.fuelSupplies.isDeleted.equals(false),
      );

    if (startDate != null) {
      query = query
        ..where(
          _db!.fuelSupplies.date.isBiggerOrEqualValue(
            startDate.millisecondsSinceEpoch,
          ),
        );
    }
    if (endDate != null) {
      query = query
        ..where(
          _db!.fuelSupplies.date.isSmallerOrEqualValue(
            endDate.millisecondsSinceEpoch,
          ),
        );
    }

    final result = await query.getSingle();
    return result.read(_db!.fuelSupplies.liters.sum()) ?? 0.0;
  }

  /// Calcula preço médio por litro
  Future<double> calculateAveragePricePerLiter(int vehicleId) async {
    if (_db == null) return 0.0;
    final query = _db!.selectOnly(_db!.fuelSupplies)
      ..addColumns([_db!.fuelSupplies.pricePerLiter.avg()])
      ..where(
        _db!.fuelSupplies.vehicleId.equals(vehicleId) &
            _db!.fuelSupplies.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db!.fuelSupplies.pricePerLiter.avg()) ?? 0.0;
  }

  /// Conta total de abastecimentos de um veículo
  Future<int> countByVehicleId(int vehicleId) async {
    if (_db == null) return 0;
    final query = _db!.selectOnly(_db!.fuelSupplies)
      ..addColumns([_db!.fuelSupplies.id.count()])
      ..where(
        _db!.fuelSupplies.vehicleId.equals(vehicleId) &
            _db!.fuelSupplies.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db!.fuelSupplies.id.count()) ?? 0;
  }

  /// Busca abastecimentos que precisam ser sincronizados
  Future<List<FuelSupplyData>> findDirtyRecords() async {
    if (_db == null) return [];
    final query = _db!.select(_db!.fuelSupplies)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> supplyIds) async {
    if (_db == null) return;
    await _db!.executeTransaction(() async {
      for (final id in supplyIds) {
        await (_db!.update(
          _db!.fuelSupplies,
        )..where((tbl) => tbl.id.equals(id))).write(
          FuelSuppliesCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark fuel supplies as synced');
  }

  /// Soft delete de um abastecimento
  Future<bool> softDelete(int supplyId) async {
    if (_db == null) return false;
    final rowsAffected =
        await (_db!.update(
          _db!.fuelSupplies,
        )..where((tbl) => tbl.id.equals(supplyId))).write(
          FuelSuppliesCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }
}

/// Classe auxiliar para transferência de dados de abastecimentos
class FuelSupplyData {
  const FuelSupplyData({
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
    required this.date,
    required this.odometer,
    required this.liters,
    required this.pricePerLiter,
    required this.totalPrice,
    this.fullTank,
    required this.fuelType,
    this.gasStationName,
    this.notes,
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
  final int date;
  final double odometer;
  final double liters;
  final double pricePerLiter;
  final double totalPrice;
  final bool? fullTank;
  final int fuelType;
  final String? gasStationName;
  final String? notes;
  final String? receiptImageUrl;
  final String? receiptImagePath;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  FuelSupplyData copyWith({
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
    int? date,
    double? odometer,
    double? liters,
    double? pricePerLiter,
    double? totalPrice,
    bool? fullTank,
    int? fuelType,
    String? gasStationName,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    return FuelSupplyData(
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
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalPrice: totalPrice ?? this.totalPrice,
      fullTank: fullTank ?? this.fullTank,
      fuelType: fuelType ?? this.fuelType,
      gasStationName: gasStationName ?? this.gasStationName,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
