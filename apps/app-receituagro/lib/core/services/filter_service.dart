/// Generic filtering service for list operations
/// 
/// ✅ SINGLE RESPONSIBILITY PRINCIPLE (SRP):
/// - Provides ONLY filtering and pagination operations
/// - Does NOT handle persistence, sorting (though it provides sorting helpers)
/// - Extracts filtering logic from repositories, notifiers, and providers
/// 
/// ✅ REUSABILITY & COMPOSITION:
/// - Static methods allow for functional composition
/// - Generic T enables use across any model type
/// - Higher-order functions (callbacks) provide flexibility:
///   - String Function(T): extract display text/value
///   - bool Function(T): define predicates
///   - DateTime Function(T): get date for sorting
/// 
/// ✅ NO SIDE EFFECTS:
/// - All methods are pure functions (except pagination creates new list)
/// - Methods don't modify input lists
/// - Safe for use in providers and notifiers
/// 
/// 📍 USAGE PATTERN:
/// ```dart
/// // In notifiers/providers, use FilterService for in-memory filtering:
/// final filtered = FilterService.filterBySearchTerm(items, query, (item) => item.name);
/// 
/// // For database queries, use repository query methods instead:
/// // final filtered = await repository.findByUserAndType(userId, tipo);
/// ```
/// 
/// ⚠️ PERFORMANCE NOTE:
/// - For large datasets, prefer database-level filtering (repositories)
/// - Use FilterService for: UI filtering, notifier transformations, small datasets
// ignore: avoid_classes_with_only_static_members
class FilterService {
  /// Filters a list of items by search term
  /// 
  /// Parameters:
  ///   - items: List to filter
  ///   - searchTerm: Search query (case-insensitive)
  ///   - getDisplayText: Callback to extract searchable text from item
  /// 
  /// Returns: New list containing only matching items
  /// 
  /// Example:
  /// ```dart
  /// final results = FilterService.filterBySearchTerm(
  ///   plants,
  ///   'rose',
  ///   (plant) => plant.name,
  /// );
  /// ```
  static List<T> filterBySearchTerm<T>(
    List<T> items,
    String searchTerm,
    String Function(T) getDisplayText,
  ) {
    if (searchTerm.isEmpty) return items;

    final lowerSearchTerm = searchTerm.toLowerCase();
    return items.where((item) {
      final displayText = getDisplayText(item).toLowerCase();
      return displayText.contains(lowerSearchTerm);
    }).toList();
  }

  /// Filters favorites by type
  /// Generic version that works with any type T
  /// 
  /// Parameters:
  ///   - items: List to filter
  ///   - targetType: Type to match
  ///   - getType: Callback to extract type from item
  /// 
  /// Returns: New list with only items matching targetType
  static List<T> filterByType<T>(
    List<T> items,
    String targetType,
    String Function(T) getType,
  ) {
    return items.where((item) => getType(item) == targetType).toList();
  }

  /// Filters items by multiple types
  static List<T> filterByTypes<T>(
    List<T> items,
    List<String> targetTypes,
    String Function(T) getType,
  ) {
    return items
        .where((item) => targetTypes.contains(getType(item)))
        .toList();
  }

  /// Filters items by user ID
  static List<T> filterByUserId<T>(
    List<T> items,
    String userId,
    String Function(T) getUserId,
  ) {
    if (userId.isEmpty) return [];
    return items.where((item) => getUserId(item) == userId).toList();
  }

  /// Filters items by user ID and type combined
  /// Useful for complex queries at presentation layer
  /// 
  /// Returns empty list if userId is empty (validates precondition)
  static List<T> filterByUserIdAndType<T>(
    List<T> items,
    String userId,
    String tipo,
    String Function(T) getUserId,
    String Function(T) getType,
  ) {
    if (userId.isEmpty) return [];
    return items
        .where(
          (item) => getUserId(item) == userId && getType(item) == tipo,
        )
        .toList();
  }

  /// Filters deleted items
  static List<T> filterActiveOnly<T>(
    List<T> items,
    bool Function(T) isDeleted,
  ) {
    return items.where((item) => !isDeleted(item)).toList();
  }

  /// Combines multiple filters using AND logic
  /// All predicates must return true for item to be included
  /// 
  /// Example:
  /// ```dart
  /// final results = FilterService.combineFilters(items, [
  ///   (item) => item.userId == userId,
  ///   (item) => !item.isDeleted,
  ///   (item) => item.type == 'premium',
  /// ]);
  /// ```
  static List<T> combineFilters<T>(
    List<T> items,
    List<bool Function(T)> predicates,
  ) {
    return items
        .where((item) => predicates.every((predicate) => predicate(item)))
        .toList();
  }

  /// Sorts items by creation date descending
  static List<T> sortByCreatedAtDesc<T>(
    List<T> items,
    DateTime Function(T) getCreatedAt,
  ) {
    final sortedItems = [...items];
    sortedItems.sort((a, b) => getCreatedAt(b).compareTo(getCreatedAt(a)));
    return sortedItems;
  }

  /// Sorts items by creation date ascending
  static List<T> sortByCreatedAtAsc<T>(
    List<T> items,
    DateTime Function(T) getCreatedAt,
  ) {
    final sortedItems = [...items];
    sortedItems.sort((a, b) => getCreatedAt(a).compareTo(getCreatedAt(b)));
    return sortedItems;
  }

  /// Paginates a list
  static List<T> paginate<T>(
    List<T> items, {
    required int page,
    required int pageSize,
  }) {
    final startIndex = page * pageSize;
    final endIndex = (page + 1) * pageSize;

    if (startIndex >= items.length) return [];
    if (endIndex > items.length) {
      return items.sublist(startIndex);
    }

    return items.sublist(startIndex, endIndex);
  }
}
