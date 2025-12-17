import 'package:core/core.dart';
import 'package:drift/drift.dart';

// DAOs
import 'daos/task_dao.dart';
import 'daos/user_dao.dart';
// Tables
import 'tables/my_day_tasks_table.dart';
import 'tables/tasks_table.dart';
import 'tables/users_table.dart';

part 'taskolist_database.g.dart';

/// ============================================================================
/// TASKOLIST DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-taskolist usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Injectable com @lazySingleton para DI
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (3 total):**
/// 1. Tasks - Tarefas e gerenciamento
/// 2. Users - Usuários e preferências
/// 3. MyDayTasks - Tarefas do planejador diário "Meu Dia"
///
/// **SCHEMA VERSION:** 2 (adicionado MyDayTasks)
/// ============================================================================

@DriftDatabase(tables: [Tasks, Users, MyDayTasks], daos: [TaskDao, UserDao])
class TaskolistDatabase extends _$TaskolistDatabase with BaseDriftDatabase {
  TaskolistDatabase(super.e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 2;

  /// Factory constructor para ambiente de produção
  factory TaskolistDatabase.production() {
    return TaskolistDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'taskolist_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory TaskolistDatabase.development() {
    return TaskolistDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'taskolist_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory TaskolistDatabase.test() {
    return TaskolistDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  factory TaskolistDatabase.withPath(String path) {
    return TaskolistDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'taskolist_drift.db',
        customPath: path,
        logStatements: false,
      ),
    );
  }

  /// Estratégia de migração do banco de dados
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migration from v1 to v2: Add MyDayTasks table
      if (from == 1 && to == 2) {
        await m.createTable(myDayTasks);
      }
    },
  );
}
