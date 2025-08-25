import 'package:core/core.dart';

import '../models/cultura_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para CulturaHive usando Core Package
/// Substitui CulturaHiveRepository que usava Hive diretamente
class CulturaCoreRepository extends CoreBaseHiveRepository<CulturaHive> {
  CulturaCoreRepository(ILocalStorageRepository storageService)
      : super(storageService, 'receituagro_culturas');

  @override
  CulturaHive createFromJson(Map<String, dynamic> json) {
    return CulturaHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(CulturaHive entity) {
    return entity.idReg;
  }

  /// Busca cultura por nome de forma assíncrona
  Future<CulturaHive?> findByName(String cultura) async {
    final results = findBy((item) => 
        item.cultura.toLowerCase() == cultura.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  /// Busca cultura por nome de forma síncrona (para compatibilidade)
  Future<CulturaHive?> findByNameSync(String cultura) async {
    return await findByName(cultura);
  }

  /// Lista todas as culturas ativas de forma assíncrona
  Future<List<CulturaHive>> getActiveCulturas() async {
    return getAll();
  }

  /// Busca culturas por padrão no nome
  Future<List<CulturaHive>> searchByName(String pattern) async {
    final lowerPattern = pattern.toLowerCase();
    return findBy((cultura) => 
        cultura.cultura.toLowerCase().contains(lowerPattern));
  }

  /// Busca culturas por múltiplos critérios
  Future<List<CulturaHive>> searchByCriteria({
    String? nome,
    String? familia,
    bool? isAtiva,
  }) async {
    return findBy((cultura) {
      bool matches = true;
      
      if (nome != null) {
        matches = matches && cultura.cultura.toLowerCase().contains(nome.toLowerCase());
      }
      
      // Adicionar outros critérios conforme necessário
      // if (familia != null) { ... }
      // if (isAtiva != null) { ... }
      
      return matches;
    });
  }

  /// Obter estatísticas das culturas
  Future<Map<String, dynamic>> getCulturaStats() async {
    final culturas = getAll();
    
    return {
      'total': culturas.length,
      'ativas': culturas.length, // Assuming all are active for now
      'topCulturas': _getTopCulturas(culturas),
    };
  }

  /// Helper para obter as culturas mais comuns
  List<Map<String, dynamic>> _getTopCulturas(List<CulturaHive> culturas, {int limit = 10}) {
    final culturasMap = <String, int>{};
    
    for (final cultura in culturas) {
      final nome = cultura.cultura;
      culturasMap[nome] = (culturasMap[nome] ?? 0) + 1;
    }
    
    final sorted = culturasMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((entry) => {
      'nome': entry.key,
      'count': entry.value,
    }).toList();
  }

  /// Validar se cultura existe
  Future<bool> culturaExists(String nome) async {
    final cultura = await findByName(nome);
    return cultura != null;
  }

  /// Buscar cultura por ID
  Future<CulturaHive?> findByIdReg(String idReg) async {
    return getById(idReg);
  }
}