/// **SRP - Single Responsibility Principle**
/// Filter Service: Handles all filtering operations
/// Extracted from UI notifiers to be reusable and testable
abstract class FilterService<T, F> {
  /// Apply filter criteria to items
  List<T> filter(List<T> items, F filterCriteria);

  /// Reset to default filter (no filtering)
  void reset();

  /// Clear specific filter
  void clearFilter(String key);
}

/// Generic implementation for common filtering patterns
class GenericFilterService<T, F> implements FilterService<T, F> {
  final List<T> Function(List<T>, F) filterFunction;
  final void Function()? resetCallback;
  final Map<String, dynamic> _activeFilters = {};

  GenericFilterService({
    required this.filterFunction,
    this.resetCallback,
  });

  @override
  List<T> filter(List<T> items, F filterCriteria) {
    return filterFunction(items, filterCriteria);
  }

  @override
  void reset() {
    _activeFilters.clear();
    resetCallback?.call();
  }

  @override
  void clearFilter(String key) {
    _activeFilters.remove(key);
  }

  /// Get active filters
  Map<String, dynamic> get activeFilters => Map.unmodifiable(_activeFilters);

  /// Set active filter
  void setActiveFilter(String key, dynamic value) {
    if (value == null) {
      _activeFilters.remove(key);
    } else {
      _activeFilters[key] = value;
    }
  }

  /// Check if any filter is active
  bool get hasActiveFilters => _activeFilters.isNotEmpty;
}
