import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import 'package:drift/drift.dart';

import 'tables/plantis_tables.dart';

part 'plantis_database.g.dart';

/// ============================================================================
/// PLANTIS DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-plantis usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (8 total):**
/// 1. Spaces - Ambientes/locais das plantas
/// 2. Plants - Informações das plantas
/// 3. PlantConfigs - Configurações de cuidados (1:1 com Plants)
/// 4. PlantTasks - Tarefas de plantas (sistema antigo)
/// 5. Tasks - Tarefas completas (sistema novo)
/// 6. Comments - Comentários sobre plantas
/// 7. ConflictHistory - Histórico de conflitos de sync
/// 8. SyncQueue - Fila de operações pendentes de sincronização
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(
  tables: [
    Spaces,
    Plants,
    PlantConfigs,
    PlantTasks,
    Tasks,
    Comments,
    ConflictHistory,
    PlantImages,
    PlantsSyncQueue,
    UserSubscriptions,
  ],
)
class PlantisDatabase extends _$PlantisDatabase with BaseDriftDatabase {
  PlantisDatabase(super.e);

  /// Versão do schema do banco de dados
  ///
  /// Incrementar quando houver mudanças estruturais nas tabelas
  @override
  int get schemaVersion => 4;

  /// Factory constructor para ambiente de produção
  ///
  /// Usa configuração padrão do DriftDatabaseConfig:
  /// - Nome: plantis_drift.db
  /// - logStatements: false (performance)
  factory PlantisDatabase.production() {
    return PlantisDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'plantis_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  ///
  /// Diferenças vs production:
  /// - Nome: plantis_drift_dev.db (isolado)
  /// - logStatements: true (debugging)
  factory PlantisDatabase.development() {
    return PlantisDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'plantis_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  ///
  /// Características:
  /// - In-memory database (não persiste no disco)
  /// - logStatements: true (debugging de testes)
  /// - Rápido e isolado
  factory PlantisDatabase.test() {
    return PlantisDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Estratégia de migração do banco de dados
  ///
  /// **onCreate:** Executado na primeira criação do banco
  /// **beforeOpen:** Executado toda vez antes de abrir o banco
  /// **onUpgrade:** Executado quando schemaVersion aumenta
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      if (kDebugMode) {
        debugPrint('📦 Creating Plantis Database schema v$schemaVersion...');
      }

      // Cria todas as tabelas definidas em @DriftDatabase
      await m.createAll();

      if (kDebugMode) {
        debugPrint('✅ Plantis Database schema created successfully!');
      }
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (kDebugMode) {
        debugPrint('🔄 Migrating Plantis Database from v$from to v$to...');
      }

      if (from < 2) {
        // Migração v1 -> v2: Adiciona tabela PlantImages
        if (kDebugMode) {
          debugPrint('📦 Adding PlantImages table...');
        }
        await m.createTable(plantImages);
      }

      if (from < 3) {
        // Migração v2 -> v3: Adiciona tabela UserSubscriptions
        if (kDebugMode) {
          debugPrint('📦 Adding UserSubscriptions table...');
        }
        await m.createTable(userSubscriptions);
      }

      // ========== MIGRAÇÃO v3 → v4: Alterar PlantImages de BLOB para Base64 ==========
      if (from < 4) {
        if (kDebugMode) {
          debugPrint('📸 Migration v3→v4: Convertendo imagens para Base64...');
        }
        
        // Recriar tabela plant_images com Base64
        await customStatement('DROP TABLE IF EXISTS plant_images;');
        await customStatement('''
          CREATE TABLE plant_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebase_id TEXT,
            user_id TEXT,
            module_name TEXT NOT NULL DEFAULT 'plantis',
            created_at INTEGER,
            updated_at INTEGER,
            last_sync_at INTEGER,
            is_dirty INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            version INTEGER NOT NULL DEFAULT 1,
            plant_id INTEGER NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
            image_base64 TEXT NOT NULL,
            file_name TEXT,
            mime_type TEXT NOT NULL DEFAULT 'image/jpeg',
            size_bytes INTEGER,
            width INTEGER,
            height INTEGER,
            is_primary INTEGER NOT NULL DEFAULT 0,
            sort_order INTEGER NOT NULL DEFAULT 0,
            UNIQUE(firebase_id)
          );
        ''');

        if (kDebugMode) {
          debugPrint('✅ Migration v3→v4: Tabela PlantImages atualizada para Base64');
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Migration completed successfully!');
      }
    },
    beforeOpen: (details) async {
      // CRÍTICO: Habilita foreign keys no SQLite
      await customStatement('PRAGMA foreign_keys = ON');

      if (details.wasCreated) {
        if (kDebugMode) {
          debugPrint('🎉 Plantis Database criado com sucesso!');
        }
        if (kDebugMode) {
          debugPrint(
            '📊 Tabelas: Spaces, Plants, PlantConfigs, PlantTasks, Tasks, Comments, ConflictHistory, PlantImages, PlantsSyncQueue',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('🔄 Plantis Database aberto (versão $schemaVersion)');
        }
      }
    },
  );

  // =========================================================================
  // MÉTODOS AUXILIARES PARA QUERIES COMUNS
  // =========================================================================

  /// Retorna todas as plantas ativas (não deletadas)
  Future<List<Plant>> getActivePlants() async {
    return (select(plants)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Retorna todas as plantas de um espaço específico
  Future<List<Plant>> getPlantsBySpace(int spaceId) async {
    return (select(plants)
          ..where((p) => p.spaceId.equals(spaceId) & p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Retorna configuração de uma planta específica
  Future<PlantConfig?> getPlantConfig(int plantId) async {
    return (select(
      plantConfigs,
    )..where((c) => c.plantId.equals(plantId))).getSingleOrNull();
  }

  /// Retorna todas as tarefas pendentes
  Future<List<Task>> getPendingTasks() async {
    return (select(tasks)
          ..where((t) => t.status.equals('pending') & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Retorna itens da fila de sincronização pendentes
  Future<List<PlantsSyncQueueData>> getPendingSyncItems() async {
    return (select(plantsSyncQueue)
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)]))
        .get();
  }

  // =========================================================================
  // MÉTODOS PARA ESTATÍSTICAS
  // =========================================================================

  /// Conta total de plantas ativas
  Future<int> countActivePlants() async {
    final count = countAll();
    final query = selectOnly(plants)
      ..addColumns([count])
      ..where(plants.isDeleted.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Conta total de tarefas pendentes
  Future<int> countPendingTasks() async {
    final count = countAll();
    final query = selectOnly(tasks)
      ..addColumns([count])
      ..where(tasks.status.equals('pending') & tasks.isDeleted.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Conta total de registros sujos (precisando sync)
  Future<int> countDirtyRecords() async {
    // Soma registros sujos de todas as tabelas principais
    int total = 0;

    // Plants
    final plantsCount = countAll();
    final plantsQuery = selectOnly(plants)
      ..addColumns([plantsCount])
      ..where(plants.isDirty.equals(true));
    total += await plantsQuery.map((row) => row.read(plantsCount)!).getSingle();

    // Spaces
    final spacesCount = countAll();
    final spacesQuery = selectOnly(spaces)
      ..addColumns([spacesCount])
      ..where(spaces.isDirty.equals(true));
    total += await spacesQuery.map((row) => row.read(spacesCount)!).getSingle();

    // Tasks
    final tasksCount = countAll();
    final tasksQuery = selectOnly(tasks)
      ..addColumns([tasksCount])
      ..where(tasks.isDirty.equals(true));
    total += await tasksQuery.map((row) => row.read(tasksCount)!).getSingle();

    return total;
  }
}
