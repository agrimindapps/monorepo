import 'dart:math';

/// Stub for RandomSelectionService - removed service
/// This stub provides the same interface for compatibility
/// TODO: Remove references to this service or implement proper random selection logic
class RandomSelectionService {
  static final Random _random = Random();
  
  static List<T> selectRandom<T>(List<T> items, int count) {
    if (items.isEmpty || count <= 0) return [];
    if (count >= items.length) return List.from(items);
    
    final shuffled = List<T>.from(items)..shuffle(_random);
    return shuffled.take(count).toList();
  }
  
  static T? selectRandomSingle<T>(List<T> items) {
    if (items.isEmpty) return null;
    return items[_random.nextInt(items.length)];
  }
  
  static List<T> selectRandomWeighted<T>(List<T> items, List<double> weights, int count) {
    // Simplified implementation for stub
    return selectRandom(items, count);
  }
  
  static void setSeed(int seed) {
    // Stub implementation - would set random seed in real implementation
  }
  
  // Specific methods for defensivos
  static List<T> selectRandomDefensivos<T>(List<T> defensivos, {int count = 5}) {
    return selectRandom(defensivos, count);
  }
  
  static List<T> selectNewDefensivos<T>(List<T> defensivos, {int count = 5}) {
    // Stub implementation - in real version would filter by "new" criteria
    return selectRandom(defensivos, count);
  }
  
  // Specific methods for pragas
  static List<T> selectRandomPragas<T>(List<T> pragas, {int count = 5}) {
    return selectRandom(pragas, count);
  }
  
  static List<T> selectSuggestedPragas<T>(List<T> pragas, {int count = 5}) {
    // Stub implementation - in real version would use suggestion algorithm
    return selectRandom(pragas, count);
  }
  
  static List<T> combineHistoryWithRandom<T>(
    List<T> historyItems,
    List<T> allItems,
    List<T> Function(List<T>, {int count}) randomSelector, {
    int count = 5,
  }) {
    // Stub implementation - combine history with random items
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