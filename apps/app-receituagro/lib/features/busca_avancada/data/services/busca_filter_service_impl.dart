

import '../../domain/entities/busca_entity.dart';
import '../../domain/services/i_busca_filter_service.dart';

/// Implementação do serviço de filtragem de busca

class BuscaFilterService implements IBuscaFilterService {
  @override
  List<BuscaResultEntity> filterByType(
    List<BuscaResultEntity> results,
    String type,
  ) {
    return results.where((r) => r.tipo == type).toList();
  }

  @override
  List<BuscaResultEntity> filterByTypes(
    List<BuscaResultEntity> results,
    List<String> types,
  ) {
    if (types.isEmpty) return results;
    return results.where((r) => types.contains(r.tipo)).toList();
  }

  @override
  List<BuscaResultEntity> filterByRelevance(
    List<BuscaResultEntity> results,
    double minRelevance,
  ) {
    return results.where((r) => r.relevancia >= minRelevance).toList();
  }

  @override
  List<BuscaResultEntity> sortByRelevance(List<BuscaResultEntity> results) {
    final sorted = List<BuscaResultEntity>.from(results);
    sorted.sort((a, b) => b.relevancia.compareTo(a.relevancia));
    return sorted;
  }

  @override
  List<BuscaResultEntity> sortByTitle(List<BuscaResultEntity> results) {
    final sorted = List<BuscaResultEntity>.from(results);
    sorted.sort((a, b) => a.titulo.compareTo(b.titulo));
    return sorted;
  }

  @override
  List<BuscaResultEntity> removeDuplicates(List<BuscaResultEntity> results) {
    final seen = <String>{};
    return results.where((r) => seen.add(r.id)).toList();
  }

  @override
  List<BuscaResultEntity> filterByQuery(
    List<BuscaResultEntity> results,
    String query,
  ) {
    if (query.isEmpty) return results;

    final queryLower = query.toLowerCase();
    return results.where((r) {
      return r.titulo.toLowerCase().contains(queryLower) ||
          (r.subtitulo?.toLowerCase().contains(queryLower) ?? false) ||
          (r.descricao?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  @override
  List<BuscaResultEntity> applyFilters(
    List<BuscaResultEntity> results,
    BuscaFiltersEntity filters,
  ) {
    var filtered = results;

    if (filters.tipos.isNotEmpty) {
      filtered = filterByTypes(filtered, filters.tipos);
    }

    if (filters.query != null && filters.query!.isNotEmpty) {
      filtered = filterByQuery(filtered, filters.query!);
    }

    filtered = removeDuplicates(filtered);

    filtered = sortByRelevance(filtered);

    return filtered;
  }
}
