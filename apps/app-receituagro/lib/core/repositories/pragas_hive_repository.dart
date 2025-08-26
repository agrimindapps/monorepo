import '../models/pragas_hive.dart';
import 'base_hive_repository.dart';

/// Repositório para PragasHive
/// Implementa os métodos abstratos do BaseHiveRepository
class PragasHiveRepository extends BaseHiveRepository<PragasHive> {
  PragasHiveRepository() : super('receituagro_pragas');


  @override
  PragasHive createFromJson(Map<String, dynamic> json) {
    return PragasHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(PragasHive entity) {
    return entity.idReg;
  }

  /// Busca praga por nome comum
  PragasHive? findByNomeComum(String nomeComum) {
    return findBy((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase())
        .isNotEmpty 
        ? findBy((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase()).first 
        : null;
  }

  /// Busca praga por nome científico
  PragasHive? findByNomeCientifico(String nomeCientifico) {
    return findBy((item) => item.nomeCientifico.toLowerCase() == nomeCientifico.toLowerCase())
        .isNotEmpty 
        ? findBy((item) => item.nomeCientifico.toLowerCase() == nomeCientifico.toLowerCase()).first 
        : null;
  }

  /// Lista pragas por tipo
  List<PragasHive> findByTipo(String tipoPraga) {
    return findBy((item) => item.tipoPraga.toLowerCase() == tipoPraga.toLowerCase());
  }

  /// Lista pragas por família
  List<PragasHive> findByFamilia(String familia) {
    return findBy((item) => item.familia?.toLowerCase() == familia.toLowerCase());
  }

  /// Métodos assíncronos para aguardar box estar aberto
  Future<List<PragasHive>> findByTipoAsync(String tipoPraga) async {
    return await findByAsync((item) => item.tipoPraga.toLowerCase() == tipoPraga.toLowerCase());
  }

  Future<List<PragasHive>> findByFamiliaAsync(String familia) async {
    return await findByAsync((item) => item.familia?.toLowerCase() == familia.toLowerCase());
  }

  Future<PragasHive?> findByNomeComumAsync(String nomeComum) async {
    final results = await findByAsync((item) => item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  Future<PragasHive?> findByNomeCientificoAsync(String nomeCientifico) async {
    final results = await findByAsync((item) => item.nomeCientifico.toLowerCase() == nomeCientifico.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }
}