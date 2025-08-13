/// Interface para serviços de scroll e paginação
abstract class IScrollService {
  /// Verifica se deve carregar mais itens baseado na posição do scroll
  bool shouldLoadMore(double currentPixels, double maxScrollExtent,
      double threshold, bool isLoading, bool finalPage, bool hasItems);

  /// Calcula a nova página baseada na página atual
  int calculateNextPage(int currentPage);

  /// Calcula os índices de início e fim para paginação
  PageIndices calculatePageIndices(
      int currentPage, int itemsPerScroll, int totalItems);
}

/// Classe auxiliar para índices de paginação
class PageIndices {
  final int startIndex;
  final int endIndex;

  const PageIndices({
    required this.startIndex,
    required this.endIndex,
  });
}
