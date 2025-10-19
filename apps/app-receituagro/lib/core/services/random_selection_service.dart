import 'dart:math';

import '../data/models/fitossanitario_hive.dart';

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
    return selectRandom(items, count);
  }
  
  static void setSeed(int seed) {
  }
  static List<T> selectRandomDefensivos<T>(List<T> defensivos, {int count = 5}) {
    return selectRandom(defensivos, count);
  }
  
  static List<FitossanitarioHive> selectNewDefensivos(List<FitossanitarioHive> defensivos, {int count = 5}) {
    if (defensivos.isEmpty || count <= 0) return [];
    final defensivosWithCreatedAt = defensivos.where((d) => d.createdAt != null && d.createdAt! > 0).toList();
    
    if (defensivosWithCreatedAt.isEmpty) {
      print('⚠️ Nenhum defensivo com createdAt válido. Usando seleção aleatória para "Novos Defensivos"');
      return selectRandom(defensivos, count).cast<FitossanitarioHive>();
    }
    defensivosWithCreatedAt.sort((a, b) {
      final aCreatedAt = a.createdAt ?? 0;
      final bCreatedAt = b.createdAt ?? 0;
      return bCreatedAt.compareTo(aCreatedAt); // Descending order
    });
    if (defensivosWithCreatedAt.length > 3) {
      print('📅 DEBUG: Primeiros "Novos Defensivos":');
      for (int i = 0; i < 3 && i < defensivosWithCreatedAt.length; i++) {
        final d = defensivosWithCreatedAt[i];
        final createdAtDate = DateTime.fromMillisecondsSinceEpoch(d.createdAt ?? 0);
        print('  ${i+1}. ${d.nomeComum} - criado em: $createdAtDate (timestamp: ${d.createdAt})');
      }
    }
    return defensivosWithCreatedAt.take(count).toList();
  }
  static List<T> selectRandomPragas<T>(List<T> pragas, {int count = 5}) {
    return selectRandom(pragas, count);
  }
  
  static List<T> selectSuggestedPragas<T>(List<T> pragas, {int count = 5}) {
    return selectRandom(pragas, count);
  }
  
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

  /// Seleciona itens aleatórios excluindo os que já estão no histórico
  /// Garante que sempre retorne exatamente [count] itens (histórico + aleatórios)
  static List<T> selectRandomExcluding<T>({
    required List<T> allItems,
    required List<T> excludeItems,
    required int count,
    required bool Function(T, T) areEqual,
  }) {
    if (allItems.isEmpty) return [];

    // Filtrar itens que não estão no histórico
    final availableItems = allItems.where((item) {
      return !excludeItems.any((excluded) => areEqual(item, excluded));
    }).toList();

    if (availableItems.isEmpty) {
      // Se não há itens disponíveis, retornar aleatórios de todos
      return selectRandom(allItems, count);
    }

    // Selecionar aleatoriamente dos itens disponíveis
    return selectRandom(availableItems, count);
  }

  /// Completa uma lista de histórico com aleatórios até atingir exatamente [targetCount]
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
}
