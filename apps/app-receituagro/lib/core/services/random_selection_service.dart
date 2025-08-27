import 'dart:math';

import '../../features/pragas/domain/entities/praga_entity.dart';
import '../models/fitossanitario_hive.dart';

/// Serviço para seleção aleatória de itens quando não há histórico
class RandomSelectionService {
  static final Random _random = Random();

  /// Seleciona defensivos aleatórios
  static List<FitossanitarioHive> selectRandomDefensivos(
    List<FitossanitarioHive> allDefensivos, {
    int count = 3,
  }) {
    if (allDefensivos.isEmpty) return [];
    
    final shuffled = List<FitossanitarioHive>.from(allDefensivos);
    shuffled.shuffle(_random);
    
    final selectedCount = count.clamp(0, shuffled.length);
    return shuffled.take(selectedCount).toList();
  }

  /// Seleciona pragas aleatórias
  static List<PragaEntity> selectRandomPragas(
    List<PragaEntity> allPragas, {
    int count = 3,
  }) {
    if (allPragas.isEmpty) return [];
    
    final shuffled = List<PragaEntity>.from(allPragas);
    shuffled.shuffle(_random);
    
    final selectedCount = count.clamp(0, shuffled.length);
    return shuffled.take(selectedCount).toList();
  }

  /// Seleciona defensivos "novos" (últimos adicionados ou aleatórios)
  static List<FitossanitarioHive> selectNewDefensivos(
    List<FitossanitarioHive> allDefensivos, {
    int count = 4,
  }) {
    if (allDefensivos.isEmpty) return [];
    
    // Ordena por data de criação se disponível, senão usa ordem aleatória
    final sorted = List<FitossanitarioHive>.from(allDefensivos);
    
    // Tenta ordenar por data de criação
    try {
      sorted.sort((a, b) {
        final aDate = a.createdAt ?? 0;
        final bDate = b.createdAt ?? 0;
        return bDate.compareTo(aDate); // Mais recentes primeiro
      });
    } catch (e) {
      // Se houver erro na ordenação, embaralha aleatoriamente
      sorted.shuffle(_random);
    }
    
    final selectedCount = count.clamp(0, sorted.length);
    return sorted.take(selectedCount).toList();
  }

  /// Seleciona pragas "sugeridas" (distribuídas por tipo)
  static List<PragaEntity> selectSuggestedPragas(
    List<PragaEntity> allPragas, {
    int count = 5,
  }) {
    if (allPragas.isEmpty) return [];
    
    // Separa por tipo
    final insetos = allPragas.where((p) => p.isInseto).toList();
    final doencas = allPragas.where((p) => p.isDoenca).toList();
    final plantas = allPragas.where((p) => p.isPlanta).toList();
    
    // Embaralha cada lista
    insetos.shuffle(_random);
    doencas.shuffle(_random);
    plantas.shuffle(_random);
    
    final List<PragaEntity> suggestions = [];
    
    // Distribui sugestões entre os tipos de forma equilibrada
    final typesAvailable = [
      if (insetos.isNotEmpty) insetos,
      if (doencas.isNotEmpty) doencas,
      if (plantas.isNotEmpty) plantas,
    ];
    
    if (typesAvailable.isEmpty) return [];
    
    var currentTypeIndex = 0;
    var itemsTaken = 0;
    
    while (suggestions.length < count && itemsTaken < allPragas.length) {
      final currentList = typesAvailable[currentTypeIndex];
      final indexInList = itemsTaken ~/ typesAvailable.length;
      
      if (indexInList < currentList.length) {
        final item = currentList[indexInList];
        if (!suggestions.contains(item)) {
          suggestions.add(item);
        }
      }
      
      currentTypeIndex = (currentTypeIndex + 1) % typesAvailable.length;
      itemsTaken++;
    }
    
    return suggestions;
  }

  /// Combina histórico com seleção aleatória para completar uma lista
  static List<T> combineHistoryWithRandom<T>(
    List<T> historyItems,
    List<T> allItems,
    int targetCount,
    List<T> Function(List<T>, {int count}) randomSelector,
  ) {
    final result = <T>[];
    
    // Adiciona itens do histórico primeiro
    result.addAll(historyItems.take(targetCount));
    
    if (result.length < targetCount) {
      // Filtra itens que já estão no resultado
      final remainingItems = allItems
          .where((item) => !result.contains(item))
          .toList();
      
      // Completa com itens aleatórios
      final needed = targetCount - result.length;
      final randomItems = randomSelector(remainingItems, count: needed);
      result.addAll(randomItems);
    }
    
    return result.take(targetCount).toList();
  }
}