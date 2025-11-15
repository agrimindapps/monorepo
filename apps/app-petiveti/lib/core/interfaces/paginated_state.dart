/// **OCP - Open/Closed Principle**
/// Base interface for paginated list states
/// Open for extension: different features can extend with their own state
abstract class PaginatedState<T> {
  List<T> get items;
  bool get isLoading;
  bool get hasError;
  String? get errorMessage;
  int get currentPage;
  int get pageSize;
  bool get hasMoreData;

  /// Whether pagination is at end
  bool get isAtEnd => !hasMoreData;

  /// Total items count (may be null if unknown)
  int? get totalCount;
}

/// **OCP - Open/Closed Principle**
/// Base abstract class for paginated state implementation
/// Open for extension through copyWith pattern
abstract class PaginatedStateBase<T> implements PaginatedState<T> {
  @override
  final List<T> items;

  @override
  final bool isLoading;

  @override
  final bool hasError;

  @override
  final String? errorMessage;

  @override
  final int currentPage;

  @override
  final int pageSize;

  @override
  final int? totalCount;

  const PaginatedStateBase({
    this.items = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.currentPage = 0,
    this.pageSize = 20,
    this.totalCount,
  });

  @override
  bool get hasMoreData {
    if (totalCount == null) return items.length >= pageSize;
    return items.length < totalCount!;
  }

  /// Common copyWith pattern for all paginated states
  PaginatedStateBase<T> copyWithPaginated({
    List<T>? items,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? currentPage,
    int? pageSize,
    int? totalCount,
    bool clearError = false,
  });
}
