import 'package:drift/drift.dart';
import '../../../core/drift_exports.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../gasometer_database.dart';
import '../tables/gasometer_tables.dart';

/// Repositório de Veículos usando Drift
///
/// Gerencia todas as operações de CRUD e queries relacionadas a veículos
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class VehicleRepository extends BaseDriftRepositoryImpl<VehicleData, Vehicle> {
  VehicleRepository(this._db);

  final GasometerDatabase _db;

  @override
  TableInfo<Vehicles, Vehicle> get table => _db.vehicles;

  @override
  GeneratedDatabase get database => _db;

  @override
  VehicleData fromData(Vehicle data) {
    return VehicleData(
      id: data.id,
      userId: data.userId,
      moduleName: data.moduleName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      marca: data.marca,
      modelo: data.modelo,
      ano: data.ano,
      placa: data.placa,
      odometroInicial: data.odometroInicial,
      odometroAtual: data.odometroAtual,
      combustivel: data.combustivel,
      renavan: data.renavan,
      chassi: data.chassi,
      cor: data.cor,
      foto: data.foto,
      vendido: data.vendido,
      valorVenda: data.valorVenda,
    );
  }

  @override
  Insertable<Vehicle> toCompanion(VehicleData entity) {
    return VehiclesCompanion(
      // id é autoIncrement, não deve ser especificado no insert
      id: entity.id > 0 ? Value(entity.id) : Value.absent(),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      marca: Value(entity.marca),
      modelo: Value(entity.modelo),
      ano: Value(entity.ano),
      placa: Value(entity.placa),
      odometroInicial: Value(entity.odometroInicial),
      odometroAtual: Value(entity.odometroAtual),
      combustivel: Value(entity.combustivel),
      renavan: Value(entity.renavan),
      chassi: Value(entity.chassi),
      cor: Value(entity.cor),
      foto: Value(entity.foto),
      vendido: Value(entity.vendido),
      valorVenda: Value(entity.valorVenda),
    );
  }

  @override
  Expression<int> idColumn(Vehicles tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca veículos do usuário que não foram deletados
  Future<List<VehicleData>> findByUserId(String userId) async {
    final query = _db.select(_db.vehicles)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de veículos do usuário
  Stream<List<VehicleData>> watchByUserId(String userId) {
    final query = _db.select(_db.vehicles)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca veículo pela placa
  Future<VehicleData?> findByPlate(String userId, String placa) async {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.placa.equals(placa) &
            tbl.isDeleted.equals(false),
      )
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Busca veículos vendidos
  Future<List<VehicleData>> findSoldVehicles(String userId) async {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.vendido.equals(true) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca veículos ativos (não vendidos)
  Future<List<VehicleData>> findActiveVehicles(String userId) async {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.vendido.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de veículos ativos
  Stream<List<VehicleData>> watchActiveVehicles(String userId) {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.vendido.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Conta veículos ativos do usuário
  Future<int> countActiveVehicles(String userId) async {
    final query = _db.selectOnly(_db.vehicles)
      ..addColumns([_db.vehicles.id.count()])
      ..where(
        _db.vehicles.userId.equals(userId) &
            _db.vehicles.vendido.equals(false) &
            _db.vehicles.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.vehicles.id.count()) ?? 0;
  }

  /// Atualiza o odômetro atual de um veículo
  Future<bool> updateOdometer(int vehicleId, double newOdometer) async {
    final rowsAffected =
        await (_db.update(
          _db.vehicles,
        )..where((tbl) => tbl.id.equals(vehicleId))).write(
          VehiclesCompanion(
            odometroAtual: Value(newOdometer),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Marca um veículo como vendido
  Future<bool> markAsSold(int vehicleId, double saleValue) async {
    final rowsAffected =
        await (_db.update(
          _db.vehicles,
        )..where((tbl) => tbl.id.equals(vehicleId))).write(
          VehiclesCompanion(
            vendido: const Value(true),
            valorVenda: Value(saleValue),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Soft delete de um veículo
  Future<bool> softDelete(int vehicleId) async {
    final rowsAffected =
        await (_db.update(
          _db.vehicles,
        )..where((tbl) => tbl.id.equals(vehicleId))).write(
          VehiclesCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// Busca veículos que precisam ser sincronizados
  Future<List<VehicleData>> findDirtyRecords() async {
    final query = _db.select(_db.vehicles)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> vehicleIds) async {
    await _db.executeTransaction(() async {
      for (final id in vehicleIds) {
        await (_db.update(
          _db.vehicles,
        )..where((tbl) => tbl.id.equals(id))).write(
          VehiclesCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark vehicles as synced');
  }

  /// Busca veículos por ano
  Future<List<VehicleData>> findByYear(String userId, int year) async {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.ano.equals(year) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca veículos por marca
  Future<List<VehicleData>> findByBrand(String userId, String marca) async {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.marca.equals(marca) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca todas as marcas distintas do usuário
  Future<List<String>> findDistinctBrands(String userId) async {
    final query = _db.selectOnly(_db.vehicles, distinct: true)
      ..addColumns([_db.vehicles.marca])
      ..where(
        _db.vehicles.userId.equals(userId) &
            _db.vehicles.isDeleted.equals(false),
      )
      ..orderBy([OrderingTerm.asc(_db.vehicles.marca)]);

    final results = await query.get();
    return results
        .map((row) => row.read(_db.vehicles.marca))
        .where((marca) => marca != null && marca.isNotEmpty)
        .cast<String>()
        .toList();
  }
}

/// Classe auxiliar para transferência de dados de veículos
///
/// Esta classe serve como intermediária entre o Drift e a camada de domínio,
/// permitindo uma transição gradual do Hive para o Drift
class VehicleData {
  const VehicleData({
    required this.id,
    required this.userId,
    required this.moduleName,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
    required this.isDirty,
    required this.isDeleted,
    required this.version,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.odometroInicial,
    required this.odometroAtual,
    required this.combustivel,
    required this.renavan,
    required this.chassi,
    required this.cor,
    this.foto,
    required this.vendido,
    required this.valorVenda,
  });

  final int id;
  final String userId;
  final String moduleName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final String marca;
  final String modelo;
  final int ano;
  final String placa;
  final double odometroInicial;
  final double odometroAtual;
  final int combustivel;
  final String renavan;
  final String chassi;
  final String cor;
  final String? foto;
  final bool vendido;
  final double valorVenda;

  /// Cria uma cópia com campos modificados
  VehicleData copyWith({
    int? id,
    String? userId,
    String? moduleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? marca,
    String? modelo,
    int? ano,
    String? placa,
    double? odometroInicial,
    double? odometroAtual,
    int? combustivel,
    String? renavan,
    String? chassi,
    String? cor,
    String? foto,
    bool? vendido,
    double? valorVenda,
  }) {
    return VehicleData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      odometroInicial: odometroInicial ?? this.odometroInicial,
      odometroAtual: odometroAtual ?? this.odometroAtual,
      combustivel: combustivel ?? this.combustivel,
      renavan: renavan ?? this.renavan,
      chassi: chassi ?? this.chassi,
      cor: cor ?? this.cor,
      foto: foto ?? this.foto,
      vendido: vendido ?? this.vendido,
      valorVenda: valorVenda ?? this.valorVenda,
    );
  }
}
