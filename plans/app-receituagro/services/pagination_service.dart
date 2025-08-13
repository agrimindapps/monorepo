/// Service responsável pela lógica de paginação e carregamento incremental
/// Centraliza toda a lógica de paginação que estava espalhada nos controllers
class PaginationService {
  
  /// Calcula o número de itens a adicionar baseado na página atual
  int calculateItemsToAdd(
    int currentPage,
    int currentItemsCount,
    int totalItemsCount,
    int itemsPerPage,
  ) {
    if (currentItemsCount >= totalItemsCount) return 0;
    
    final remainingItems = totalItemsCount - currentItemsCount;
    return remainingItems < itemsPerPage ? remainingItems : itemsPerPage;
  }
  
  /// Calcula os índices de início e fim para uma página
  ({int startIndex, int endIndex}) calculatePageIndices(
    int page,
    int itemsPerPage,
    int totalItems,
  ) {
    final startIndex = page * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
    
    return (startIndex: startIndex, endIndex: endIndex);
  }
  
  /// Calcula a próxima página
  int calculateNextPage(int currentPage) {
    return currentPage + 1;
  }
  
  /// Verifica se deve carregar mais itens baseado na posição do scroll
  bool shouldLoadMore(
    double pixels,
    double maxScrollExtent,
    double threshold,
    bool isLoading,
    bool isFinalPage,
    bool hasItems,
  ) {
    if (isLoading || isFinalPage || !hasItems) return false;
    
    return (pixels >= maxScrollExtent - threshold);
  }
  
  /// Obtém um lote de itens para uma página específica
  List<T> getPageItems<T>(
    List<T> allItems,
    int page,
    int itemsPerPage,
  ) {
    final indices = calculatePageIndices(page, itemsPerPage, allItems.length);
    
    if (indices.startIndex >= allItems.length) return [];
    
    return allItems.sublist(indices.startIndex, indices.endIndex);
  }
  
  /// Verifica se é a página final
  bool isFinalPage(int currentItemsCount, int totalItemsCount) {
    return currentItemsCount >= totalItemsCount;
  }
  
  /// Reseta paginação para o estado inicial
  ({int page, bool isFinalPage}) resetPagination() {
    return (page: 0, isFinalPage: false);
  }
}