import 'dart:developer' as developer;
import 'dart:math';

/// Generic service for random selection and filtering logic
/// Can be used by any app in the monorepo
///
/// This service provides reusable random selection utilities that work with
/// any data type. Apps can create their own extensions for domain-specific
/// logic (e.g., selecting newest items based on timestamps).
class RandomSelectionService {
  RandomSelectionService._(); // Private constructor - static utility class

  static final Random _random = Random();

  /// Select [count] random items from [items]
  ///
  /// Returns empty list if items is empty or count <= 0
  /// Returns all items if count >= items.length
  static List<T> selectRandom<T>(List<T> items, int count) {
    if (items.isEmpty || count <= 0) return [];
    if (count >= items.length) return List.from(items);

    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Select a single random item
  ///
  /// Returns null if items is empty
  static T? selectRandomSingle<T>(List<T> items) {
    if (items.isEmpty) return null;
    return items[_random.nextInt(items.length)];
  }

  /// Select newest items based on a timestamp extractor
  /// Generic version - works with any model that has a timestamp
  ///
  /// [timestampExtractor] should return the timestamp as int (milliseconds since epoch)
  /// Falls back to random selection if no items have valid timestamps (> 0)
  static List<T> selectNewest<T>(
    List<T> items, {
    required int Function(T) timestampExtractor,
    int count = 5,
  }) {
    if (items.isEmpty || count <= 0) return [];

    final itemsWithTimestamp = items
        .where((item) => timestampExtractor(item) > 0)
        .toList();

    if (itemsWithTimestamp.isEmpty) {
      developer.log(
        'No items with valid timestamp. Using random selection.',
        name: 'RandomSelectionService.selectNewest',
        level: 800, // Warning
      );
      return selectRandom(items, count);
    }

    itemsWithTimestamp.sort((a, b) {
      final aTimestamp = timestampExtractor(a);
      final bTimestamp = timestampExtractor(b);
      return bTimestamp.compareTo(aTimestamp); // Descending order (newest first)
    });

    return itemsWithTimestamp.take(count).toList();
  }

  /// Select random items excluding specified items
  ///
  /// [areEqual] function should define equality between items
  /// Falls back to selecting from all items if no items are available after exclusion
  static List<T> selectRandomExcluding<T>({
    required List<T> allItems,
    required List<T> excludeItems,
    required int count,
    required bool Function(T, T) areEqual,
  }) {
    if (allItems.isEmpty) return [];

    // Filter items that are not in excludeItems
    final availableItems = allItems.where((item) {
      return !excludeItems.any((excluded) => areEqual(item, excluded));
    }).toList();

    if (availableItems.isEmpty) {
      // If no items available after exclusion, return random from all items
      return selectRandom(allItems, count);
    }

    return selectRandom(availableItems, count);
  }

  /// Fill history items with random items to reach target count
  ///
  /// If history already has targetCount or more items, returns only the first targetCount
  /// Otherwise, fills remaining slots with random items (excluding history items)
  static List<T> fillHistoryToCount<T>({
    required List<T> historyItems,
    required List<T> allItems,
    required int targetCount,
    required bool Function(T, T) areEqual,
  }) {
    if (historyItems.length >= targetCount) {
      return historyItems.take(targetCount).toList();
    }

    final needed = targetCount - historyItems.length;
    final randomItems = selectRandomExcluding<T>(
      allItems: allItems,
      excludeItems: historyItems,
      count: needed,
      areEqual: areEqual,
    );

    return [...historyItems, ...randomItems];
  }

  /// Combine history items with random items
  ///
  /// Takes half the count from history and fills remaining with random items
  /// Useful for creating mixed lists of recent and random suggestions
  static List<T> combineHistoryWithRandom<T>(
    List<T> historyItems,
    List<T> allItems,
    List<T> Function(List<T>, {int count}) randomSelector, {
    int count = 5,
  }) {
    final combined = <T>[];
    combined.addAll(historyItems.take(count ~/ 2));

    final remaining = count - combined.length;
    if (remaining > 0) {
      final randomItems = randomSelector(allItems, count: remaining);
      combined.addAll(randomItems);
    }

    return combined.take(count).toList();
  }
}
