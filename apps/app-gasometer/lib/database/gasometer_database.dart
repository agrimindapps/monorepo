import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../core/drift_exports.dart';
import 'tables/gasometer_tables.dart';

part 'gasometer_database.g.dart';

/// Banco de dados principal do Gasometer Drift
///
/// Este banco de dados gerencia todas as tabelas relacionadas ao controle
/// de veículos, incluindo abastecimentos, manutenções, despesas e leituras de odômetro.
///
/// **Funcionalidades:**
/// - Armazenamento local com SQLite
/// - Sincronização com Firebase
/// - Streams reativos para UI
/// - Controle de versão e conflitos
/// - Soft deletes
/// - Foreign keys com cascade
///
/// **Uso:**
/// ```dart
/// // Inicializar
/// final db = GasometerDatabase.production();
///
/// // Usar em repositórios
/// final vehicleRepo = VehicleRepository(db);
///
/// // Observar mudanças
/// db.select(db.vehicles).watch().listen((vehicles) {
///   print('Veículos atualizados: ${vehicles.length}');
/// });
/// ```
@DriftDatabase(
  tables: [
    Vehicles,
    FuelSupplies,
    Maintenances,
    Expenses,
    OdometerReadings,
    VehicleImages,
    ReceiptImages,
    AuditTrail,
  ],
)

class GasometerDatabase extends _$GasometerDatabase with BaseDriftDatabase {
  GasometerDatabase(super.e); // Incrementado para adicionar firebaseId

  /// Factory para ambiente de produção
  factory GasometerDatabase.production() {
    return GasometerDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'gasometer_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory para ambiente de desenvolvimento
  ///
  /// Habilita logging de SQL queries para debug
  factory GasometerDatabase.development() {
    return GasometerDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'gasometer_drift_dev.db',
        logStatements: true, // Log SQL queries
      ),
    );
  }

  /// Factory para testes
  ///
  /// Usa banco de dados em memória
  factory GasometerDatabase.test() {
    return GasometerDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory com path customizado
  ///
  /// Útil para backup/restore ou testes específicos
  factory GasometerDatabase.withPath(String path) {
    return GasometerDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'gasometer_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  @override
  int get schemaVersion => 3;

  /// Estratégia de migração do banco de dados
  ///
  /// Define como o banco deve ser criado e atualizado entre versões
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Criar todas as tabelas
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // ========== MIGRAÇÃO v1 → v2: Adicionar firebaseId ==========
      if (from < 2) {
        // Adicionar coluna firebaseId em todas as tabelas usando SQL direto
        await customStatement(
          'ALTER TABLE vehicles ADD COLUMN firebase_id TEXT;',
        );
        await customStatement(
          'ALTER TABLE fuel_supplies ADD COLUMN firebase_id TEXT;',
        );
        await customStatement(
          'ALTER TABLE maintenances ADD COLUMN firebase_id TEXT;',
        );
        await customStatement(
          'ALTER TABLE expenses ADD COLUMN firebase_id TEXT;',
        );
        await customStatement(
          'ALTER TABLE odometer_readings ADD COLUMN firebase_id TEXT;',
        );

        print('✅ Migration v1→v2: firebaseId adicionado a todas as tabelas');
      }

      // ========== MIGRAÇÃO v2 → v3: Adicionar tabelas de imagens ==========
      if (from < 3) {
        // Criar tabela vehicle_images
        await customStatement('''
          CREATE TABLE IF NOT EXISTS vehicle_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebase_id TEXT,
            user_id TEXT NOT NULL,
            module_name TEXT NOT NULL DEFAULT 'gasometer',
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            updated_at INTEGER,
            last_sync_at INTEGER,
            is_dirty INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            version INTEGER NOT NULL DEFAULT 1,
            vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
            image_data BLOB NOT NULL,
            file_name TEXT,
            mime_type TEXT NOT NULL DEFAULT 'image/jpeg',
            size_bytes INTEGER,
            storage_url TEXT,
            is_primary INTEGER NOT NULL DEFAULT 0,
            upload_status TEXT NOT NULL DEFAULT 'pending'
          );
        ''');

        // Criar tabela receipt_images
        await customStatement('''
          CREATE TABLE IF NOT EXISTS receipt_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebase_id TEXT,
            user_id TEXT NOT NULL,
            module_name TEXT NOT NULL DEFAULT 'gasometer',
            created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
            updated_at INTEGER,
            last_sync_at INTEGER,
            is_dirty INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            version INTEGER NOT NULL DEFAULT 1,
            entity_type TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            image_data BLOB NOT NULL,
            file_name TEXT,
            mime_type TEXT NOT NULL DEFAULT 'image/jpeg',
            size_bytes INTEGER,
            storage_url TEXT,
            upload_status TEXT NOT NULL DEFAULT 'pending'
          );
        ''');

        print('✅ Migration v2→v3: Tabelas de imagens criadas');
      }

      // Migrações futuras virão aqui
      // if (from < 3) {
      //   // Migração da versão 2 para 3
      //   await m.addColumn(vehicles, vehicles.newColumn);
      // }
    },
    beforeOpen: (details) async {
      // Habilitar foreign keys
      await customStatement('PRAGMA foreign_keys = ON');

      // Log da abertura do banco
      if (details.wasCreated) {
        print('✅ Gasometer Database criado com sucesso!');
      } else if (details.hadUpgrade) {
        print(
          '⬆️ Gasometer Database atualizado de v${details.versionBefore} para v${details.versionNow}',
        );
      }
    },
  );

  // ========== QUERIES ÚTEIS ==========

  /// Busca veículos do usuário ordenados por nome
  Future<List<Vehicle>> getVehiclesByUser(String userId) async {
    final query = select(vehicles)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);
    return await query.get();
  }

  /// Busca abastecimentos de um veículo ordenados por data (mais recente primeiro)
  Future<List<FuelSupply>> getFuelSuppliesByVehicle(
    int vehicleId, {
    int limit = 50,
  }) async {
    final query = select(fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(limit);
    return await query.get();
  }

  /// Stream de veículos do usuário
  Stream<List<Vehicle>> watchVehiclesByUser(String userId) {
    final query = select(vehicles)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);
    return query.watch();
  }

  /// Stream de abastecimentos de um veículo
  Stream<List<FuelSupply>> watchFuelSuppliesByVehicle(int vehicleId) {
    final query = select(fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    return query.watch();
  }

  /// Busca registros que precisam ser sincronizados (isDirty = true)
  Future<List<Vehicle>> getDirtyVehicles() async {
    final query = select(vehicles)..where((tbl) => tbl.isDirty.equals(true));
    return await query.get();
  }

  /// Busca manutenções pendentes (não concluídas) de um veículo
  Future<List<Maintenance>> getPendingMaintenances(int vehicleId) async {
    final query = select(maintenances)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.concluida.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.data)]);
    return await query.get();
  }

  /// Calcula o total de despesas de um veículo em um período
  Future<double> getTotalExpenses(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = selectOnly(maintenances)
      ..addColumns([maintenances.valor.sum()])
      ..where(
        maintenances.vehicleId.equals(vehicleId) &
            maintenances.isDeleted.equals(false),
      );

    if (startDate != null) {
      query = query
        ..where(
          maintenances.data.isBiggerOrEqualValue(
            startDate.millisecondsSinceEpoch,
          ),
        );
    }
    if (endDate != null) {
      query = query
        ..where(
          maintenances.data.isSmallerOrEqualValue(
            endDate.millisecondsSinceEpoch,
          ),
        );
    }

    final result = await query.getSingle();
    return result.read(maintenances.valor.sum()) ?? 0.0;
  }

  /// Calcula o consumo médio de combustível de um veículo
  Future<double?> getAverageConsumption(int vehicleId) async {
    final supplies =
        await (select(fuelSupplies)
              ..where(
                (tbl) =>
                    tbl.vehicleId.equals(vehicleId) &
                    tbl.fullTank.equals(true) &
                    tbl.isDeleted.equals(false),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
            .get();

    if (supplies.length < 2) return null;

    double totalKm = 0;
    double totalLiters = 0;

    for (int i = 1; i < supplies.length; i++) {
      final previous = supplies[i - 1];
      final current = supplies[i];

      final km = current.odometer - previous.odometer;
      final liters = current.liters;

      if (km > 0 && liters > 0) {
        totalKm += km;
        totalLiters += liters;
      }
    }

    return totalLiters > 0 ? totalKm / totalLiters : null;
  }

  // ========== OPERAÇÕES EM LOTE ==========

  /// Marca múltiplos registros como deletados (soft delete)
  Future<void> softDeleteVehicles(List<int> vehicleIds) async {
    await executeTransaction(() async {
      for (final id in vehicleIds) {
        await (update(vehicles)..where((tbl) => tbl.id.equals(id))).write(
          VehiclesCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Soft delete vehicles');
  }

  /// Limpa todos os dados de um usuário (hard delete)
  Future<void> clearUserData(String userId) async {
    await executeTransaction(() async {
      // Deletar em ordem devido a foreign keys
      // (cascade deveria lidar, mas por segurança fazemos manualmente)

      // 1. Buscar IDs dos veículos do usuário
      final userVehicles = await (select(
        vehicles,
      )..where((tbl) => tbl.userId.equals(userId))).get();
      final vehicleIds = userVehicles.map((v) => v.id).toList();

      // 2. Deletar registros relacionados
      for (final vehicleId in vehicleIds) {
        await (delete(
          fuelSupplies,
        )..where((tbl) => tbl.vehicleId.equals(vehicleId))).go();
        await (delete(
          maintenances,
        )..where((tbl) => tbl.vehicleId.equals(vehicleId))).go();
        await (delete(
          expenses,
        )..where((tbl) => tbl.vehicleId.equals(vehicleId))).go();
        await (delete(
          odometerReadings,
        )..where((tbl) => tbl.vehicleId.equals(vehicleId))).go();
      }

      // 3. Deletar veículos
      await (delete(vehicles)..where((tbl) => tbl.userId.equals(userId))).go();
    }, operationName: 'Clear user data');
  }

  /// Exporta dados do usuário para JSON
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final userVehicles = await (select(
      vehicles,
    )..where((tbl) => tbl.userId.equals(userId))).get();

    final data = <String, dynamic>{
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'vehicles': <Map<String, dynamic>>[],
    };

    for (final vehicle in userVehicles) {
      final vehicleData = <String, dynamic>{
        'vehicle': vehicle.toJson(),
        'fuel_supplies':
            await (select(fuelSupplies)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id)))
                .get()
                .then((list) => list.map((e) => e.toJson()).toList()),
        'maintenances':
            await (select(maintenances)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id)))
                .get()
                .then((list) => list.map((e) => e.toJson()).toList()),
        'expenses':
            await (select(expenses)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id)))
                .get()
                .then((list) => list.map((e) => e.toJson()).toList()),
        'odometer_readings':
            await (select(odometerReadings)
                  ..where((tbl) => tbl.vehicleId.equals(vehicle.id)))
                .get()
                .then((list) => list.map((e) => e.toJson()).toList()),
      };

      data['vehicles'].add(vehicleData);
    }

    return data;
  }
}
