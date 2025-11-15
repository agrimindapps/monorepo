/// **SRP - Single Responsibility Principle**
/// Sort Service: Handles all sorting operations
/// Extracted from UI notifiers to be reusable and testable
abstract class SortService<T> {
  /// Sort items by criteria
  List<T> sort(List<T> items, dynamic sortOrder);

  /// Reset to default sort order
  void reset();
}

/// Generic implementation for common sorting patterns
class GenericSortService<T> implements SortService<T> {
  final List<T> Function(List<T>, dynamic) sortFunction;
  final void Function()? resetCallback;

  GenericSortService({
    required this.sortFunction,
    this.resetCallback,
  });

  @override
  List<T> sort(List<T> items, dynamic sortOrder) {
    return sortFunction(items, sortOrder);
  }

  @override
  void reset() {
    resetCallback?.call();
  }
}
