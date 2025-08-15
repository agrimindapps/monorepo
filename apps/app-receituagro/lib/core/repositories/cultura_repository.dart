import '../models/cultura_hive.dart';
import 'base_hive_repository.dart';

/// Repositório específico para Culturas
/// Princípios: Single Responsibility + Open/Closed
class CulturaRepository extends BaseHiveRepository<CulturaHive> {
  CulturaRepository() : super('receituagro_culturas_static');

  @override
  CulturaHive createFromJson(Map<String, dynamic> json) {
    return CulturaHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(CulturaHive entity) {
    return entity.idReg;
  }

  // Métodos específicos para Cultura (se necessário)
  List<CulturaHive> findByName(String nome) {
    return findBy((cultura) => 
      cultura.cultura.toLowerCase().contains(nome.toLowerCase())
    );
  }
}