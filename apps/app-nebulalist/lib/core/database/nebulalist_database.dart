import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'daos/item_dao.dart';
import 'daos/list_dao.dart';
import 'tables/items_table.dart';
import 'tables/lists_table.dart';

part 'nebulalist_database.g.dart';

/// ============================================================================
/// NEBULALIST DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-nebulalist usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Injectable com @lazySingleton para DI
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (2 total):**
/// 1. Lists - Listas de tarefas/itens do usuário
/// 2. Items - Itens individuais dentro das listas
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(
  tables: [Lists, Items],
  daos: [ListDao, ItemDao],
)
@lazySingleton
class NebulalistDatabase extends _$NebulalistDatabase with BaseDriftDatabase {
  NebulalistDatabase(QueryExecutor e) : super(e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para injeção de dependência (GetIt/Injectable)
  @factoryMethod
  factory NebulalistDatabase.injectable() {
    return NebulalistDatabase.production();
  }

  /// Factory constructor para ambiente de produção
  factory NebulalistDatabase.production() {
    return NebulalistDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nebulalist_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory NebulalistDatabase.development() {
    return NebulalistDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nebulalist_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory NebulalistDatabase.test() {
    return NebulalistDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  factory NebulalistDatabase.withPath(String path) {
    return NebulalistDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'nebulalist_drift.db',
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
