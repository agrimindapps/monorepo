import 'package:core/core.dart';

import '../models/pragas_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para PragasHive usando core package
/// Substitui PragasHiveRepository que usava Hive diretamente
class PragasCoreRepository extends CoreBaseHiveRepository<PragasHive> {
  PragasCoreRepository(ILocalStorageRepository storageService)
      : super(storageService, 'receituagro_pragas');

  @override
  PragasHive createFromJson(Map<String, dynamic> json) {
    return PragasHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(PragasHive entity) {
    return entity.idReg;
  }

  /// Busca praga por nome comum
  Future<PragasHive?> findByNomeComum(String nomeComum) async {
    final results = await findByAsync((item) => 
        item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  /// Busca praga por nome científico
  Future<PragasHive?> findByNomeCientifico(String nomeCientifico) async {
    final results = await findByAsync((item) => 
        item.nomeCientifico.toLowerCase() == nomeCientifico.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  /// Lista pragas por tipo
  Future<List<PragasHive>> findByTipo(String tipoPraga) async {
    return await findByAsync((item) => 
        item.tipoPraga.toLowerCase() == tipoPraga.toLowerCase());
  }

  /// Lista pragas por família
  Future<List<PragasHive>> findByFamilia(String familia) async {
    return await findByAsync((item) => 
        item.familia?.toLowerCase() == familia.toLowerCase());
  }

  /// Busca pragas que contêm o texto no nome comum
  Future<List<PragasHive>> searchByNomeComum(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    return await findByAsync((item) => 
        item.nomeComum.toLowerCase().contains(lowerSearchTerm));
  }

  /// Busca pragas que contêm o texto no nome científico
  Future<List<PragasHive>> searchByNomeCientifico(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    return await findByAsync((item) => 
        item.nomeCientifico.toLowerCase().contains(lowerSearchTerm));
  }

  /// Lista todos os tipos de praga únicos
  Future<List<String>> getAllTiposPraga() async {
    final all = await getAllAsync();
    final tipos = all.map((item) => item.tipoPraga).toSet().toList();
    tipos.sort();
    return tipos;
  }

  /// Lista todas as famílias únicas (não nulas)
  Future<List<String>> getAllFamilias() async {
    final all = await getAllAsync();
    final familias = all
        .where((item) => item.familia != null && item.familia!.isNotEmpty)
        .map((item) => item.familia!)
        .toSet()
        .toList();
    familias.sort();
    return familias;
  }
}