// Project imports:
import '../interfaces/i_scroll_service.dart';

/// Serviço responsável pelo gerenciamento de scroll e paginação
class ScrollService implements IScrollService {
  @override
  bool shouldLoadMore(double currentPixels, double maxScrollExtent,
      double threshold, bool isLoading, bool finalPage, bool hasItems) {
    return currentPixels >= maxScrollExtent - threshold &&
        !isLoading &&
        !finalPage &&
        hasItems;
  }

  @override
  int calculateNextPage(int currentPage) {
    return currentPage + 1;
  }

  @override
  PageIndices calculatePageIndices(
      int currentPage, int itemsPerScroll, int totalItems) {
    final startIndex = currentPage * itemsPerScroll;

    if (startIndex >= totalItems) {
      return PageIndices(startIndex: startIndex, endIndex: startIndex);
    }

    final endIndex = ((currentPage + 1) * itemsPerScroll < totalItems)
        ? (currentPage + 1) * itemsPerScroll
        : totalItems;

    return PageIndices(startIndex: startIndex, endIndex: endIndex);
  }
}
