import 'package:core/core.dart';

import '../models/fitossanitario_hive.dart';
import 'core_base_hive_repository.dart';

/// Repositório para FitossanitarioHive usando core package
/// Substitui FitossanitarioHiveRepository que usava Hive diretamente
class FitossanitarioCoreRepository extends CoreBaseHiveRepository<FitossanitarioHive> {
  FitossanitarioCoreRepository(ILocalStorageRepository storageService)
      : super(storageService, 'receituagro_fitossanitarios');

  @override
  FitossanitarioHive createFromJson(Map<String, dynamic> json) {
    return FitossanitarioHive.fromJson(json);
  }

  @override
  String getKeyFromEntity(FitossanitarioHive entity) {
    return entity.idReg;
  }

  /// Busca defensivo por nome comum
  Future<FitossanitarioHive?> findByNomeComum(String nomeComum) async {
    final results = await findBy((item) => 
        item.nomeComum.toLowerCase() == nomeComum.toLowerCase());
    return results.isNotEmpty ? results.first : null;
  }

  /// Lista defensivos por classe agronômica
  Future<List<FitossanitarioHive>> findByClasseAgronomica(String classeAgronomica) async {
    return await findBy((item) => 
        item.classeAgronomica?.toLowerCase() == classeAgronomica.toLowerCase());
  }

  /// Lista defensivos por fabricante
  Future<List<FitossanitarioHive>> findByFabricante(String fabricante) async {
    return await findBy((item) => 
        item.fabricante?.toLowerCase() == fabricante.toLowerCase());
  }

  /// Lista defensivos ativos/comercializados
  Future<List<FitossanitarioHive>> getActiveDefensivos() async {
    return await findBy((item) => item.status && item.comercializado == 1);
  }

  /// Lista defensivos elegíveis
  Future<List<FitossanitarioHive>> getElegibleDefensivos() async {
    return await findBy((item) => item.elegivel);
  }

  /// Busca defensivos que contêm o texto no nome comum
  Future<List<FitossanitarioHive>> searchByNomeComum(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    return await findByAsync((item) => 
        item.nomeComum.toLowerCase().contains(lowerSearchTerm));
  }

  /// Versão async do searchByNomeComum
  Future<List<FitossanitarioHive>> searchByNomeComumAsync(String searchTerm) async {
    return await searchByNomeComum(searchTerm);
  }

  /// Busca defensivos que contêm o texto no ingrediente ativo
  Future<List<FitossanitarioHive>> searchByIngredienteAtivo(String searchTerm) async {
    final lowerSearchTerm = searchTerm.toLowerCase();
    return await findByAsync((item) => 
        item.ingredienteAtivo?.toLowerCase().contains(lowerSearchTerm) ?? false);
  }

  /// Versão async do searchByIngredienteAtivo
  Future<List<FitossanitarioHive>> searchByIngredienteAtivoAsync(String searchTerm) async {
    return await searchByIngredienteAtivo(searchTerm);
  }

  /// Busca por múltiplos critérios - versão async
  Future<List<FitossanitarioHive>> searchByMultipleCriteriaAsync({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgronomica,
    bool? status,
    int? comercializado,
    bool? elegivel,
  }) async {
    return await findByAsync((item) {
      bool matches = true;
      
      if (nomeComum != null) {
        matches = matches && item.nomeComum.toLowerCase().contains(nomeComum.toLowerCase());
      }
      
      if (ingredienteAtivo != null) {
        matches = matches && (item.ingredienteAtivo?.toLowerCase().contains(ingredienteAtivo.toLowerCase()) ?? false);
      }
      
      if (fabricante != null) {
        matches = matches && (item.fabricante?.toLowerCase().contains(fabricante.toLowerCase()) ?? false);
      }
      
      if (classeAgronomica != null) {
        matches = matches && (item.classeAgronomica?.toLowerCase().contains(classeAgronomica.toLowerCase()) ?? false);
      }
      
      if (status != null) {
        matches = matches && item.status == status;
      }
      
      if (comercializado != null) {
        matches = matches && item.comercializado == comercializado;
      }
      
      if (elegivel != null) {
        matches = matches && item.elegivel == elegivel;
      }
      
      return matches;
    });
  }

  /// Lista todas as classes agronômicas únicas (não nulas)
  Future<List<String>> getAllClassesAgronomicas() async {
    final all = await getAll();
    final classes = all
        .where((item) => item.classeAgronomica != null && item.classeAgronomica!.isNotEmpty)
        .map((item) => item.classeAgronomica!)
        .toSet()
        .toList();
    classes.sort();
    return classes;
  }

  /// Lista todos os fabricantes únicos (não nulos)
  Future<List<String>> getAllFabricantes() async {
    final all = await getAll();
    final fabricantes = all
        .where((item) => item.fabricante != null && item.fabricante!.isNotEmpty)
        .map((item) => item.fabricante!)
        .toSet()
        .toList();
    fabricantes.sort();
    return fabricantes;
  }

  /// Lista todos os ingredientes ativos únicos (não nulos)
  Future<List<String>> getAllIngredientesAtivos() async {
    final all = await getAll();
    final ingredientes = all
        .where((item) => item.ingredienteAtivo != null && item.ingredienteAtivo!.isNotEmpty)
        .map((item) => item.ingredienteAtivo!)
        .toSet()
        .toList();
    ingredientes.sort();
    return ingredientes;
  }

  /// Busca defensivos por múltiplos critérios
  Future<List<FitossanitarioHive>> searchMultipleCriteria({
    String? nomeComum,
    String? classeAgronomica,
    String? fabricante,
    String? ingredienteAtivo,
    bool? apenasAtivos,
    bool? apenasElegiveis,
  }) async {
    final all = await getAll();
    
    return all.where((item) {
      // Filtro por nome comum
      if (nomeComum != null && nomeComum.isNotEmpty) {
        if (!item.nomeComum.toLowerCase().contains(nomeComum.toLowerCase())) {
          return false;
        }
      }
      
      // Filtro por classe agronômica
      if (classeAgronomica != null && classeAgronomica.isNotEmpty) {
        if (item.classeAgronomica?.toLowerCase() != classeAgronomica.toLowerCase()) {
          return false;
        }
      }
      
      // Filtro por fabricante
      if (fabricante != null && fabricante.isNotEmpty) {
        if (item.fabricante?.toLowerCase() != fabricante.toLowerCase()) {
          return false;
        }
      }
      
      // Filtro por ingrediente ativo
      if (ingredienteAtivo != null && ingredienteAtivo.isNotEmpty) {
        if (!(item.ingredienteAtivo?.toLowerCase().contains(ingredienteAtivo.toLowerCase()) ?? false)) {
          return false;
        }
      }
      
      // Filtro apenas ativos
      if (apenasAtivos == true) {
        if (!(item.status && item.comercializado == 1)) {
          return false;
        }
      }
      
      // Filtro apenas elegíveis
      if (apenasElegiveis == true) {
        if (!item.elegivel) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // ===== MÉTODOS ASYNC ADICIONAIS PARA CLEAN ARCHITECTURE =====

  /// Versão async de getActiveDefensivos
  Future<List<FitossanitarioHive>> getActiveDefensivosAsync() async {
    return await findByAsync((item) => item.status && item.comercializado == 1);
  }

  /// Versão async de getElegibleDefensivos
  Future<List<FitossanitarioHive>> getElegibleDefensivosAsync() async {
    return await findByAsync((item) => item.elegivel);
  }

  /// Versões async dos métodos de listas únicas
  Future<List<String>> getAllClassesAgronomicasAsync() async {
    final all = await getAllAsync();
    final classes = all
        .where((item) => item.classeAgronomica != null && item.classeAgronomica!.isNotEmpty)
        .map((item) => item.classeAgronomica!)
        .toSet()
        .toList();
    classes.sort();
    return classes;
  }

  Future<List<String>> getAllFabricantesAsync() async {
    final all = await getAllAsync();
    final fabricantes = all
        .where((item) => item.fabricante != null && item.fabricante!.isNotEmpty)
        .map((item) => item.fabricante!)
        .toSet()
        .toList();
    fabricantes.sort();
    return fabricantes;
  }

  Future<List<String>> getAllIngredientesAtivosAsync() async {
    final all = await getAllAsync();
    final ingredientes = all
        .where((item) => item.ingredienteAtivo != null && item.ingredienteAtivo!.isNotEmpty)
        .map((item) => item.ingredienteAtivo!)
        .toSet()
        .toList();
    ingredientes.sort();
    return ingredientes;
  }

  /// Obter estatísticas dos defensivos
  Future<Map<String, dynamic>> getDefensivosStatsAsync() async {
    final all = await getAllAsync();
    
    final ativos = all.where((item) => item.status && item.comercializado == 1).length;
    final elegiveis = all.where((item) => item.elegivel).length;
    
    // Contar por classe agronômica
    final byClasseAgronomica = <String, int>{};
    for (final item in all) {
      if (item.classeAgronomica?.isNotEmpty == true) {
        final classe = item.classeAgronomica!;
        byClasseAgronomica[classe] = (byClasseAgronomica[classe] ?? 0) + 1;
      }
    }
    
    // Contar por fabricante
    final byFabricante = <String, int>{};
    for (final item in all) {
      if (item.fabricante?.isNotEmpty == true) {
        final fabricante = item.fabricante!;
        byFabricante[fabricante] = (byFabricante[fabricante] ?? 0) + 1;
      }
    }
    
    return {
      'total': all.length,
      'ativos': ativos,
      'elegiveis': elegiveis,
      'byClasseAgronomica': byClasseAgronomica,
      'byFabricante': byFabricante,
    };
  }
}