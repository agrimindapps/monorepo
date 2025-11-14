import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

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
class NutitutiDatabase extends _$NutitutiDatabase with BaseDriftDatabase {
  NutitutiDatabase(QueryExecutor e) : super(e);

  /// Factory constructor para Injectable (DI)
  @factoryMethod
  factory NutitutiDatabase.injectable() {
    print('🏭 Creating NutitutiDatabase via injectable factory');
    final db = NutitutiDatabase.production();
    print('✅ NutitutiDatabase created successfully: ${db.hashCode}');
    return db;
  }

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para ambiente de produção
  factory NutitutiDatabase.production() {
    return NutitutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift.db',
        logStatements: false,
      ),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory NutitutiDatabase.development() {
    return NutitutiDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'nutrituti_drift_dev.db',
        logStatements: true,
      ),
    );
  }

  /// Factory constructor para testes
  factory NutitutiDatabase.test() {
    return NutitutiDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }
}
