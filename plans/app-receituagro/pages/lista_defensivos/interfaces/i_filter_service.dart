/// Interface para serviços de filtro de defensivos
abstract class IFilterService {
  /// Filtra lista de defensivos baseado no texto de busca
  List<T> filterByText<T>(List<T> sourceList, String searchText,
      String Function(T) getLine1, String Function(T) getLine2);

  /// Ordena lista de defensivos baseado no campo e direção
  List<T> sortList<T>(List<T> inputList, String sortField, bool isAscending,
      String Function(T) getLine1, String Function(T) getLine2);

  /// Valida se o texto de busca é válido
  bool isSearchValid(String searchText);

  /// Calcula quantos itens adicionar à lista paginada
  int calculateItemsToAdd(int currentPage, int currentFilteredLength,
      int totalFilteredLength, int itemsPerScroll);
}
