import 'package:injectable/injectable.dart';
import '../../../drift_database/nutrituti_database.dart';
import '../../../drift_database/daos/agua_dao.dart';
import '../../../drift_database/daos/comentario_dao.dart';
import '../../../drift_database/daos/exercicio_dao.dart';
import '../../../drift_database/daos/perfil_dao.dart';
import '../../../drift_database/daos/peso_dao.dart';
import '../../../drift_database/daos/water_dao.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  AguaDao getAguaDao(NutritutiDatabase db) => db.aguaDao;

  @lazySingleton
  ComentarioDao getComentarioDao(NutritutiDatabase db) => db.comentarioDao;

  @lazySingleton
  ExercicioDao getExercicioDao(NutritutiDatabase db) => db.exercicioDao;

  @lazySingleton
  PerfilDao getPerfilDao(NutritutiDatabase db) => db.perfilDao;

  @lazySingleton
  PesoDao getPesoDao(NutritutiDatabase db) => db.pesoDao;

  @lazySingleton
  WaterDao getWaterDao(NutritutiDatabase db) => db.waterDao;
}
