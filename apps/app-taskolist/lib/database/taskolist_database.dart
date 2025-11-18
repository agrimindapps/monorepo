import 'package:drift/drift.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

// Tables
import 'tables/tasks_table.dart';
import 'tables/users_table.dart';

// DAOs
import 'daos/task_dao.dart';
import 'daos/user_dao.dart';

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
/// **TABELAS (2 total):**
/// 1. Tasks - Tarefas e gerenciamento
/// 2. Users - Usuários e preferências
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(tables: [Tasks, Users], daos: [TaskDao, UserDao])
@lazySingleton
class TaskolistDatabase extends _$TaskolistDatabase with BaseDriftDatabase {
  TaskolistDatabase(QueryExecutor e) : super(e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para injeção de dependência (GetIt/Injectable)
  @factoryMethod
  factory TaskolistDatabase.injectable() {
    return TaskolistDatabase.production();
  }

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
      // Future schema migrations will go here
    },
  );
}
