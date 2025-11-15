/// Interface para datasource de busca
/// Principle: Dependency Inversion - Repository depends on abstraction
abstract class IBuscaDatasource {
  /// Busca diagnósticos com filtros específicos
  Future<List<Map<String, dynamic>>> searchDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  });

  /// Busca por query de texto em múltiplas tabelas
  Future<List<Map<String, dynamic>>> searchByText(
    String query, {
    List<String>? tipos,
    int? limit,
  });

  /// Busca pragas relacionadas a uma cultura
  Future<List<Map<String, dynamic>>> searchPragasByCultura(String culturaId);

  /// Busca defensivos relacionados a uma praga
  Future<List<Map<String, dynamic>>> searchDefensivosByPraga(String pragaId);

  /// Busca com filtros avançados
  Future<List<Map<String, dynamic>>> searchAdvanced(
    Map<String, dynamic> filters,
  );

  /// Carrega todas as culturas
  Future<List<Map<String, dynamic>>> loadCulturas();

  /// Carrega todas as pragas
  Future<List<Map<String, dynamic>>> loadPragas();

  /// Carrega todos os defensivos
  Future<List<Map<String, dynamic>>> loadDefensivos();

  /// Busca sugestões baseadas em histórico
  Future<List<Map<String, dynamic>>> getSuggestions({int limit = 10});

  /// Salva histórico de busca
  Future<void> saveSearchHistory(Map<String, dynamic> searchData);

  /// Obtém histórico de buscas
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 20});

  /// Limpa cache local
  Future<void> clearCache();
}
