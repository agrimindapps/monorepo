import '../entities/busca_entity.dart';

/// Interface para serviço de filtragem de busca
/// Principle: Interface Segregation - Only filter operations
abstract class IBuscaFilterService {
  /// Filtra resultados por tipo (diagnostico, praga, defensivo, cultura)
  List<BuscaResultEntity> filterByType(
    List<BuscaResultEntity> results,
    String type,
  );

  /// Filtra resultados por múltiplos tipos
  List<BuscaResultEntity> filterByTypes(
    List<BuscaResultEntity> results,
    List<String> types,
  );

  /// Filtra resultados por relevância mínima
  List<BuscaResultEntity> filterByRelevance(
    List<BuscaResultEntity> results,
    double minRelevance,
  );

  /// Ordena resultados por relevância (decrescente)
  List<BuscaResultEntity> sortByRelevance(List<BuscaResultEntity> results);

  /// Ordena resultados por título (alfabético)
  List<BuscaResultEntity> sortByTitle(List<BuscaResultEntity> results);

  /// Remove resultados duplicados baseado no ID
  List<BuscaResultEntity> removeDuplicates(List<BuscaResultEntity> results);

  /// Filtra resultados baseado em query de texto
  List<BuscaResultEntity> filterByQuery(
    List<BuscaResultEntity> results,
    String query,
  );

  /// Aplica todos os filtros de uma entidade de filtros
  List<BuscaResultEntity> applyFilters(
    List<BuscaResultEntity> results,
    BuscaFiltersEntity filters,
  );
}
