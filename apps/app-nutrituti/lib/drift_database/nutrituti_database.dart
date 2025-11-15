import 'package:core/core.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
@lazySingleton
class NutritutiDatabase extends _$NutritutiDatabase {
  NutritutiDatabase(super.e);

  /// Factory constructor para Injectable (DI)
  @factoryMethod
  factory NutritutiDatabase.injectable() {
    final db = NutritutiDatabase.production();
    return db;
  }

  /// Versão do schema do banco de dados
  @override
  int get schemaVersion => 1;

  /// Factory constructor para ambiente de produção
  factory NutritutiDatabase.production() {
    return NutritutiDatabase(
      LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'nutrituti_drift.db'));
        return NativeDatabase(file);
      }),
    );
  }

  /// Factory constructor para ambiente de desenvolvimento
  factory NutritutiDatabase.development() {
    return NutritutiDatabase(
      LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();
        final file = File(p.join(dbFolder.path, 'nutrituti_drift_dev.db'));
        return NativeDatabase(file, logStatements: true);
      }),
    );
  }

  /// Factory constructor para testes
  factory NutritutiDatabase.test() {
    return NutritutiDatabase(
      LazyDatabase(() async {
        return NativeDatabase.memory();
      }),
    );
  }
}
