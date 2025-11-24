import 'package:core/core.dart';
import 'package:drift/drift.dart';

// Tables
import 'tables/perfis_table.dart';
import 'tables/pesos_table.dart';
import 'tables/agua_registros_table.dart';
import 'tables/water_records_table.dart';
import 'tables/water_achievements_table.dart';
import 'tables/exercicios_table.dart';
import 'tables/comentarios_table.dart';

// DAOs
import 'daos/perfil_dao.dart';
import 'daos/peso_dao.dart';
import 'daos/agua_dao.dart';
import 'daos/water_dao.dart';
import 'daos/exercicio_dao.dart';
import 'daos/comentario_dao.dart';

part 'nutrituti_database.g.dart';

/// ============================================================================
/// NUTRITUTI DATABASE - Drift Implementation
/// ============================================================================
///
/// Database principal do app-nutrituti usando Drift ORM.
///
/// **PADRÃO ESTABELECIDO (gasometer-drift):**
/// - Usa DriftDatabaseConfig do core para configuração unificada
/// - Factory methods: production(), development(), test()
/// - MigrationStrategy com onCreate e beforeOpen
/// - Extends BaseDriftDatabase do core (funcionalidades compartilhadas)
///
/// **TABELAS (7 total):**
/// 1. Perfis - Perfis de usuários
/// 2. Pesos - Registro de peso
/// 3. AguaRegistros - Registros de consumo de água (legacy)
/// 4. WaterRecords - Registros de água
/// 5. WaterAchievements - Conquistas de hidratação
/// 6. Exercicios - Exercícios físicos
/// 7. Comentarios - Comentários e notas
///
/// **SCHEMA VERSION:** 1 (inicial)
/// ============================================================================

@DriftDatabase(
  tables: [
    Perfis,
    Pesos,
    AguaRegistros,
    WaterRecords,
    WaterAchievements,
    Exercicios,
    Comentarios,
  ],
  daos: [PerfilDao, PesoDao, AguaDao, WaterDao, ExercicioDao, ComentarioDao],
)
class NutritutiDatabase extends _$NutritutiDatabase with BaseDriftDatabase {
  NutritutiDatabase(QueryExecutor e) : super(e);

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para ambiente de produção
  factory NutritutiDatabase.production() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory NutritutiDatabase.development() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory NutritutiDatabase.test() {
    return NutritutiDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Factory constructor com path customizado
  factory NutritutiDatabase.withPath(String path) {
    return NutritutiDatabase(
      DriftDatabaseConfig.createCustomExecutor(
        databaseName: 'nutrituti_drift.db',
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
