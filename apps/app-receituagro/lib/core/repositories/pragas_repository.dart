import '../models/pragas_hive.dart';
import 'base_hive_repository.dart';

/// Repositório específico para Pragas
/// Princípios: Single Responsibility + Open/Closed
class PragasRepository extends BaseHiveRepository<PragasHive> {
  PragasRepository() : super('receituagro_pragas_static');

  @override
  PragasHive createFromJson(Map<String, dynamic> json) {
    return PragasHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(PragasHive entity) {
    return entity.idReg;
  }

  // Métodos específicos para Pragas
  List<PragasHive> findByTipo(String tipo) {
    return findBy((praga) => praga.tipoPraga == tipo);
  }

  List<PragasHive> searchByName(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return findBy((praga) =>
      praga.nomeComum.toLowerCase().contains(term) ||
      praga.nomeCientifico.toLowerCase().contains(term)
    );
  }

  List<PragasHive> findByFamilia(String familia) {
    return findBy((praga) => praga.familia == familia);
  }
}