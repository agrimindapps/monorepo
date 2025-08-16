import '../models/plantas_inf_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para PlantasInfHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PlantasInfHiveRepository extends BaseHiveRepository<PlantasInfHive> {
  PlantasInfHiveRepository() : super('receituagro_plantas_inf');

  @override
  PlantasInfHive createFromJson(Map<String, dynamic> json) {
    return PlantasInfHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(PlantasInfHive entity) {
    return entity.idReg;
  }

  /// Busca informações de uma planta
  PlantasInfHive? findByIdReg(String idReg) {
    return getById(idReg);
  }
}