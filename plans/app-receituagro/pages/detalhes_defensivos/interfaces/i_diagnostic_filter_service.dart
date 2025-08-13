/// Interface para serviços de filtro de diagnóstico
abstract class IDiagnosticFilterService {
  /// Filtra diagnósticos baseado no texto de busca
  List<dynamic> filterDiagnosticos({
    required List<dynamic> diagnosticos,
    required String searchText,
    String? selectedCultura,
  });
  
  /// Adiciona um termo ao histórico de busca
  void addToSearchHistory(String searchTerm);
  
  /// Obtém sugestões de busca baseadas no histórico
  List<String> getSearchSuggestions(String currentTerm);
  
  /// Limpa o histórico de busca
  void clearSearchHistory();
  
  /// Obtém o histórico completo de busca
  List<String> get searchHistory;
}