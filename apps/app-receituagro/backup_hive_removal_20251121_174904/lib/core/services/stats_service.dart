/// Generic statistics and aggregation service
/// 
/// ✅ SINGLE RESPONSIBILITY PRINCIPLE (SRP):
/// - Provides ONLY statistical calculations and aggregations
/// - Does NOT handle data persistence or filtering
/// - Extracts statistics logic from notifiers and services
/// 
/// ✅ REUSABILITY & COMPOSITION:
/// - Static methods enable functional composition
/// - Generic <T> works with any model type
/// - Higher-order functions allow flexible value extraction:
///   - String Function(T): group/extract keys
///   - bool Function(T): define boolean conditions
///   - num Function(T): extract numeric values for aggregation
/// 
/// ✅ NO SIDE EFFECTS:
/// - All methods are pure functions
/// - Original lists are never modified
/// - Safe for use in providers, notifiers, and reactive systems
/// 
/// 📍 USAGE PATTERN:
/// ```dart
/// // Count operations
/// final total = StatsService.countTotal(items);
/// final active = StatsService.countWhere(items, (item) => !item.isDeleted);
/// 
/// // Aggregations
/// final sum = StatsService.sum(items, (item) => item.value);
/// final avg = StatsService.average(items, (item) => item.value);
/// 
/// // Grouping & statistics
/// final byCategory = StatsService.groupBy(items, (item) => item.category);
/// final summary = StatsService.summaryStats(items, (item) => item.value);
/// ```
// ignore: avoid_classes_with_only_static_members
class StatsService {
  /// Counts total items in list
  /// 
  /// Simple wrapper for list.length, provided for API consistency
  static int countTotal<T>(List<T> items) => items.length;

  /// Counts items by extracting category and tallying occurrences
  /// 
  /// Returns Map<category, count> for each unique category
  /// 
  /// Example:
  /// ```dart
  /// final counts = StatsService.countByCategory(
  ///   items,
  ///   (item) => item.type,
  /// );
  /// // Result: {'Fruit': 5, 'Vegetable': 3}
  /// ```
  static Map<String, int> countByCategory<T>(
    List<T> items,
    String Function(T) getCategory,
  ) {
    final counts = <String, int>{};
    for (final item in items) {
      final category = getCategory(item);
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Counts items matching a condition
  /// 
  /// Useful for conditional counting without full filtering
  /// 
  /// Example: Count active items without creating a filtered list
  static int countWhere<T>(
    List<T> items,
    bool Function(T) predicate,
  ) {
    return items.where(predicate).length;
  }

  /// Calculates percentage of items matching a condition
  /// 
  /// Returns 0.0 for empty lists (prevents division by zero)
  /// Returns percentage as 0-100
  /// 
  /// Example:
  /// ```dart
  /// final completion = StatsService.percentageWhere(
  ///   tasks,
  ///   (task) => task.isCompleted,
  /// ); // Result: 75.5
  /// ```
  static double percentageWhere<T>(
    List<T> items,
    bool Function(T) predicate,
  ) {
    if (items.isEmpty) return 0.0;
    final count = countWhere(items, predicate);
    return (count / items.length) * 100;
  }

  /// Groups items by a key
  static Map<String, List<T>> groupBy<T>(
    List<T> items,
    String Function(T) getKey,
  ) {
    final groups = <String, List<T>>{};
    for (final item in items) {
      final key = getKey(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  /// Gets unique values from items
  static Set<String> uniqueValues<T>(
    List<T> items,
    String Function(T) getValue,
  ) {
    return items.map((item) => getValue(item)).toSet();
  }

  /// Calculates average of numeric values
  static double average<T>(
    List<T> items,
    num Function(T) getValue,
  ) {
    if (items.isEmpty) return 0.0;
    final sum = items.fold<num>(0, (acc, item) => acc + getValue(item));
    return sum / items.length;
  }

  /// Finds min value
  static num? minValue<T>(
    List<T> items,
    num Function(T) getValue,
  ) {
    if (items.isEmpty) return null;
    num min = getValue(items.first);
    for (final item in items.skip(1)) {
      final value = getValue(item);
      if (value < min) min = value;
    }
    return min;
  }

  /// Finds max value
  static num? maxValue<T>(
    List<T> items,
    num Function(T) getValue,
  ) {
    if (items.isEmpty) return null;
    num max = getValue(items.first);
    for (final item in items.skip(1)) {
      final value = getValue(item);
      if (value > max) max = value;
    }
    return max;
  }

  /// Calculates sum of numeric values
  static num sum<T>(
    List<T> items,
    num Function(T) getValue,
  ) {
    return items.fold(0, (acc, item) => acc + getValue(item));
  }

  /// Gets statistics summary
  static Map<String, dynamic> summaryStats<T>(
    List<T> items,
    num Function(T) getValue,
  ) {
    if (items.isEmpty) {
      return {
        'count': 0,
        'sum': 0,
        'average': 0.0,
        'min': null,
        'max': null,
      };
    }

    return {
      'count': items.length,
      'sum': sum(items, getValue),
      'average': average(items, getValue),
      'min': minValue(items, getValue),
      'max': maxValue(items, getValue),
    };
  }

  /// Checks if all items match a condition
  static bool all<T>(
    List<T> items,
    bool Function(T) predicate,
  ) {
    return items.every(predicate);
  }

  /// Checks if any item matches a condition
  static bool any<T>(
    List<T> items,
    bool Function(T) predicate,
  ) {
    return items.any(predicate);
  }

  /// Gets distinct items by key
  static List<T> distinct<T>(
    List<T> items,
    String Function(T) getKey,
  ) {
    final seen = <String>{};
    final result = <T>[];

    for (final item in items) {
      final key = getKey(item);
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(item);
      }
    }

    return result;
  }

  /// Top N items by numeric value
  static List<T> topN<T>(
    List<T> items,
    int n,
    num Function(T) getValue,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) => getValue(b).compareTo(getValue(a)));
    return sorted.take(n).toList();
  }

  /// Bottom N items by numeric value
  static List<T> bottomN<T>(
    List<T> items,
    int n,
    num Function(T) getValue,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) => getValue(a).compareTo(getValue(b)));
    return sorted.take(n).toList();
  }
}
