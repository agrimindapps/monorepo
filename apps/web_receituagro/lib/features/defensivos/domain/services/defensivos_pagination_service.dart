import '../entities/defensivo.dart';

/// Service responsible for pagination logic (SOLID - SRP)
class DefensivosPaginationService {
  static const int defaultPageSize = 12;

  /// Get a specific page of defensivos
  List<Defensivo> getPage(
    List<Defensivo> items,
    int page, {
    int pageSize = defaultPageSize,
  }) {
    if (page < 0) return [];

    final start = page * pageSize;
    final end = start + pageSize;

    if (start >= items.length) return [];

    final validEnd = end > items.length ? items.length : end;
    return items.sublist(start, validEnd);
  }

  /// Calculate total number of pages
  int getTotalPages(int totalItems, {int pageSize = defaultPageSize}) {
    if (totalItems <= 0) return 1;
    return (totalItems / pageSize).ceil();
  }

  /// Check if there's a next page
  bool hasNextPage(int currentPage, int totalPages) {
    return currentPage < totalPages - 1;
  }

  /// Check if there's a previous page
  bool hasPreviousPage(int currentPage) {
    return currentPage > 0;
  }

  /// Get page numbers to display (for pagination UI)
  List<int> getPageNumbers(
    int currentPage,
    int totalPages, {
    int maxVisiblePages = 5,
  }) {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (index) => index);
    }

    final halfVisible = maxVisiblePages ~/ 2;
    int start = currentPage - halfVisible;
    int end = currentPage + halfVisible;

    // Adjust start if it's negative
    if (start < 0) {
      end += (0 - start);
      start = 0;
    }

    // Adjust end if it exceeds total pages
    if (end >= totalPages) {
      start -= (end - totalPages + 1);
      end = totalPages - 1;
      if (start < 0) start = 0;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  /// Get start index for current page
  int getStartIndex(int page, {int pageSize = defaultPageSize}) {
    return page * pageSize;
  }

  /// Get end index for current page
  int getEndIndex(
    int page,
    int totalItems, {
    int pageSize = defaultPageSize,
  }) {
    final start = getStartIndex(page, pageSize: pageSize);
    final end = start + pageSize;
    return end > totalItems ? totalItems : end;
  }
}
