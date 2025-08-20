// Project imports:
import '../../../../models/16_vacina_model.dart';

/// Model for managing paginated vaccine data with virtualization support.
/// 
/// This model handles large lists of vaccines by implementing pagination
/// and lazy loading to improve performance and memory usage.
class PaginatedVaccineModel {
  final List<VacinaVet> items;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final bool isLoading;
  final String? errorMessage;

  const PaginatedVaccineModel({
    this.items = const [],
    this.totalCount = 0,
    this.currentPage = 0,
    this.pageSize = 20,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of this model with updated properties.
  PaginatedVaccineModel copyWith({
    List<VacinaVet>? items,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PaginatedVaccineModel(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Appends new items to the existing list (for infinite scroll).
  PaginatedVaccineModel appendItems(List<VacinaVet> newItems) {
    return copyWith(
      items: [...items, ...newItems],
      currentPage: currentPage + 1,
      hasPreviousPage: true,
    );
  }

  /// Replaces all items (for refresh or new search).
  PaginatedVaccineModel replaceItems(List<VacinaVet> newItems) {
    return copyWith(
      items: newItems,
      currentPage: 0,
      hasPreviousPage: false,
    );
  }

  /// Calculates the total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Checks if there are any items to display.
  bool get hasItems => items.isNotEmpty;

  /// Checks if this is the first page.
  bool get isFirstPage => currentPage == 0;

  /// Checks if this is the last page.
  bool get isLastPage => currentPage >= totalPages - 1;

  /// Gets the range of items currently loaded.
  String get itemRange {
    if (items.isEmpty) return '0 de 0';
    final start = (currentPage * pageSize) + 1;
    final end = (start + items.length - 1).clamp(start, totalCount);
    return '$start-$end de $totalCount';
  }

  @override
  String toString() {
    return 'PaginatedVaccineModel(items: ${items.length}, totalCount: $totalCount, '
        'currentPage: $currentPage, hasNextPage: $hasNextPage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedVaccineModel &&
        other.items == items &&
        other.totalCount == totalCount &&
        other.currentPage == currentPage &&
        other.pageSize == pageSize &&
        other.hasNextPage == hasNextPage &&
        other.hasPreviousPage == hasPreviousPage &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      items,
      totalCount,
      currentPage,
      pageSize,
      hasNextPage,
      hasPreviousPage,
      isLoading,
      errorMessage,
    );
  }
}

/// Configuration for pagination behavior.
class PaginationConfig {
  final int defaultPageSize;
  final int maxPageSize;
  final double scrollThreshold;
  final bool enableInfiniteScroll;
  final bool enablePullToRefresh;

  const PaginationConfig({
    this.defaultPageSize = 20,
    this.maxPageSize = 100,
    this.scrollThreshold = 0.8,
    this.enableInfiniteScroll = true,
    this.enablePullToRefresh = true,
  });

  /// Creates a config optimized for large datasets.
  factory PaginationConfig.optimized() {
    return const PaginationConfig(
      defaultPageSize: 50,
      maxPageSize: 200,
      scrollThreshold: 0.9,
      enableInfiniteScroll: true,
      enablePullToRefresh: true,
    );
  }

  /// Creates a config for memory-constrained environments.
  factory PaginationConfig.lightweight() {
    return const PaginationConfig(
      defaultPageSize: 10,
      maxPageSize: 50,
      scrollThreshold: 0.7,
      enableInfiniteScroll: true,
      enablePullToRefresh: false,
    );
  }
}
