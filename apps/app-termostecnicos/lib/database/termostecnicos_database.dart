import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'daos/comentario_dao.dart';
import 'tables/comentarios_table.dart';

part 'termostecnicos_database.g.dart';

/// ============================================================================
/// TERMOS TECNICOS DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-termostecnicos usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Injectable com @lazySingleton para DI
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (1 total):**
/// 1. Comentarios - Comentários sobre termos técnicos
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(tables: [Comentarios], daos: [ComentarioDao])
@lazySingleton
class TermosTecnicosDatabase extends _$TermosTecnicosDatabase
    with BaseDriftDatabase {
  TermosTecnicosDatabase(QueryExecutor e) : super(e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para injeção de dependência (GetIt/Injectable)
  @factoryMethod
  factory TermosTecnicosDatabase.injectable() {
    return TermosTecnicosDatabase.production();
  }

  /// Factory constructor para ambiente de produção
  factory TermosTecnicosDatabase.production() {
    return TermosTecnicosDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'termostecnicos_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory TermosTecnicosDatabase.development() {
    return TermosTecnicosDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'termostecnicos_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory TermosTecnicosDatabase.test() {
    return TermosTecnicosDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  factory TermosTecnicosDatabase.withPath(String path) {
    return TermosTecnicosDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'termostecnicos_drift.db',
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
