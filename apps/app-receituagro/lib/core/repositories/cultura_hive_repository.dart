import '../models/cultura_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para CulturaHive
/// Implementa os métodos abstratos do BaseHiveRepository
class CulturaHiveRepository extends BaseHiveRepository<CulturaHive> {
  CulturaHiveRepository() : super('receituagro_culturas');

  @override
  CulturaHive createFromJson(Map<String, dynamic> json) {
    return CulturaHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(CulturaHive entity) {
    return entity.idReg;
  }

  /// Busca cultura por nome
  CulturaHive? findByName(String cultura) {
    return findBy((item) => item.cultura.toLowerCase() == cultura.toLowerCase())
        .isNotEmpty 
        ? findBy((item) => item.cultura.toLowerCase() == cultura.toLowerCase()).first 
        : null;
  }

  /// Lista todas as culturas ativas
  List<CulturaHive> getActiveCulturas() {
    return getAll();
  }
}