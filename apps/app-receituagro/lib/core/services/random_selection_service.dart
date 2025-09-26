import 'dart:math';

import '../models/fitossanitario_hive.dart';

/// Service for random selection and filtering logic
/// Updated to implement proper "new items" logic based on createdAt
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
  
  static List<FitossanitarioHive> selectNewDefensivos(List<FitossanitarioHive> defensivos, {int count = 5}) {
    if (defensivos.isEmpty || count <= 0) return [];
    
    // Filter defensivos that have createdAt timestamps (and are not null/0)
    final defensivosWithCreatedAt = defensivos.where((d) => d.createdAt != null && d.createdAt! > 0).toList();
    
    if (defensivosWithCreatedAt.isEmpty) {
      // If no createdAt data, return random selection as fallback
      print('⚠️ Nenhum defensivo com createdAt válido. Usando seleção aleatória para "Novos Defensivos"');
      return selectRandom(defensivos, count).cast<FitossanitarioHive>();
    }
    
    // Sort by createdAt descending (newest first) - timestamps are usually in milliseconds
    defensivosWithCreatedAt.sort((a, b) {
      final aCreatedAt = a.createdAt ?? 0;
      final bCreatedAt = b.createdAt ?? 0;
      return bCreatedAt.compareTo(aCreatedAt); // Descending order
    });
    
    // Debug: Print a few samples to verify ordering
    if (defensivosWithCreatedAt.length > 3) {
      print('📅 DEBUG: Primeiros "Novos Defensivos":');
      for (int i = 0; i < 3 && i < defensivosWithCreatedAt.length; i++) {
        final d = defensivosWithCreatedAt[i];
        final createdAtDate = DateTime.fromMillisecondsSinceEpoch(d.createdAt ?? 0);
        print('  ${i+1}. ${d.nomeComum} - criado em: $createdAtDate (timestamp: ${d.createdAt})');
      }
    }
    
    // Take the newest items up to the requested count
    return defensivosWithCreatedAt.take(count).toList();
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