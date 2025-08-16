import '../models/pragas_inf_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para PragasInfHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PragasInfHiveRepository extends BaseHiveRepository<PragasInfHive> {
  PragasInfHiveRepository() : super('receituagro_pragas_inf');

  @override
  PragasInfHive createFromJson(Map<String, dynamic> json) {
    return PragasInfHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(PragasInfHive entity) {
    return entity.idReg;
  }

  /// Busca informações complementares de uma praga
  PragasInfHive? findByIdReg(String idReg) {
    return getById(idReg);
  }
}