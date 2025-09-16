import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';

/// Serviço de gerenciamento de calculadoras favoritas
/// 
/// Implementa persistência local e sincronização para favoritos
/// com backup e recovery automático
class CalculatorFavoritesService {
  static const String _favoritesKey = 'calculator_favorites';
  static const String _favoritesBackupKey = 'calculator_favorites_backup';
  static const String _lastSyncKey = 'calculator_favorites_last_sync';
  
  final SharedPreferences _prefs;
  
  CalculatorFavoritesService(this._prefs);

  /// Obtém lista de IDs das calculadoras favoritas
  Future<List<String>> getFavoriteIds() async {
    try {
      final favoritesJson = _prefs.getString(_favoritesKey);
      if (favoritesJson == null) return [];
      
      final favoritesList = jsonDecode(favoritesJson) as List;
      return favoritesList.cast<String>();
    } catch (e) {
      // Tentar backup em caso de erro
      return await _restoreFromBackup();
    }
  }

  /// Verifica se uma calculadora é favorita
  Future<bool> isFavorite(String calculatorId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(calculatorId);
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    try {
      final favorites = await getFavoriteIds();
      
      if (!favorites.contains(calculatorId)) {
        favorites.add(calculatorId);
        await _saveFavorites(favorites);
        await _createBackup(favorites);
        return true;
      }
      
      return false; // Já estava nos favoritos
    } catch (e) {
      return false;
    }
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    try {
      final favorites = await getFavoriteIds();
      
      if (favorites.contains(calculatorId)) {
        favorites.remove(calculatorId);
        await _saveFavorites(favorites);
        await _createBackup(favorites);
        return true;
      }
      
      return false; // Não estava nos favoritos
    } catch (e) {
      return false;
    }
  }

  /// Alterna status de favorito
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFav = await isFavorite(calculatorId);
    
    if (isFav) {
      return await removeFromFavorites(calculatorId);
    } else {
      return await addToFavorites(calculatorId);
    }
  }

  /// Limpa todos os favoritos
  Future<bool> clearAllFavorites() async {
    try {
      await _prefs.remove(_favoritesKey);
      await _createBackup([]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Importa favoritos de uma lista
  Future<bool> importFavorites(List<String> favoriteIds) async {
    try {
      await _saveFavorites(favoriteIds);
      await _createBackup(favoriteIds);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exporta favoritos
  Future<List<String>> exportFavorites() async {
    return await getFavoriteIds();
  }

  /// Obtém estatísticas dos favoritos
  Future<FavoritesStats> getStats() async {
    final favorites = await getFavoriteIds();
    final lastSync = _prefs.getString(_lastSyncKey);
    
    return FavoritesStats(
      totalFavorites: favorites.length,
      lastSync: lastSync != null ? DateTime.parse(lastSync) : null,
      hasBackup: _prefs.containsKey(_favoritesBackupKey),
    );
  }

  /// Filtra calculadoras favoritas de uma lista
  Future<List<CalculatorEntity>> filterFavorites(
    List<CalculatorEntity> calculators,
  ) async {
    final favoriteIds = await getFavoriteIds();
    return calculators
        .where((calc) => favoriteIds.contains(calc.id))
        .toList();
  }

  /// Sincroniza favoritos (placeholder para sincronização remota)
  Future<bool> syncFavorites() async {
    try {
      // Aqui seria implementada a sincronização com servidor
      // Por enquanto, apenas atualiza timestamp local
      await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Métodos privados

  Future<void> _saveFavorites(List<String> favorites) async {
    final favoritesJson = jsonEncode(favorites);
    await _prefs.setString(_favoritesKey, favoritesJson);
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<void> _createBackup(List<String> favorites) async {
    try {
      final backupData = {
        'favorites': favorites,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final backupJson = jsonEncode(backupData);
      await _prefs.setString(_favoritesBackupKey, backupJson);
    } catch (e) {
      // Falha no backup não deve impedir operação principal
    }
  }

  Future<List<String>> _restoreFromBackup() async {
    try {
      final backupJson = _prefs.getString(_favoritesBackupKey);
      if (backupJson == null) return [];
      
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      final favorites = backupData['favorites'] as List;
      
      // Restaurar dados principais
      await _saveFavorites(favorites.cast<String>());
      
      return favorites.cast<String>();
    } catch (e) {
      return [];
    }
  }
}

/// Serviço de busca e filtros para calculadoras
class CalculatorSearchService {
  /// Busca calculadoras por termo
  static List<CalculatorEntity> searchCalculators(
    List<CalculatorEntity> calculators,
    String query,
  ) {
    if (query.trim().isEmpty) return calculators;
    
    final normalizedQuery = _normalizeText(query);
    
    return calculators.where((calculator) {
      // Busca no nome
      if (_normalizeText(calculator.name).contains(normalizedQuery)) {
        return true;
      }
      
      // Busca na descrição
      if (_normalizeText(calculator.description).contains(normalizedQuery)) {
        return true;
      }
      
      // Busca nas tags
      for (final tag in calculator.tags) {
        if (_normalizeText(tag).contains(normalizedQuery)) {
          return true;
        }
      }
      
      // Busca nos parâmetros
      for (final parameter in calculator.parameters) {
        if (_normalizeText(parameter.name).contains(normalizedQuery) ||
            _normalizeText(parameter.description).contains(normalizedQuery)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  /// Filtra calculadoras por categoria
  static List<CalculatorEntity> filterByCategory(
    List<CalculatorEntity> calculators,
    CalculatorCategory? category,
  ) {
    if (category == null) return calculators;
    
    return calculators
        .where((calculator) => calculator.category == category)
        .toList();
  }

  /// Filtra calculadoras por complexidade
  static List<CalculatorEntity> filterByComplexity(
    List<CalculatorEntity> calculators,
    CalculatorComplexity? complexity,
  ) {
    if (complexity == null) return calculators;
    
    return calculators
        .where((calculator) => calculator.complexity == complexity)
        .toList();
  }

  /// Filtra calculadoras por tags
  static List<CalculatorEntity> filterByTags(
    List<CalculatorEntity> calculators,
    List<String> tags,
  ) {
    if (tags.isEmpty) return calculators;
    
    return calculators.where((calculator) {
      return tags.any((tag) => calculator.tags.contains(tag));
    }).toList();
  }

  /// Ordena calculadoras
  static List<CalculatorEntity> sortCalculators(
    List<CalculatorEntity> calculators,
    CalculatorSortOrder sortOrder,
  ) {
    final sortedList = List<CalculatorEntity>.from(calculators);
    
    switch (sortOrder) {
      case CalculatorSortOrder.nameAsc:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CalculatorSortOrder.nameDesc:
        sortedList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CalculatorSortOrder.categoryAsc:
        sortedList.sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
      case CalculatorSortOrder.complexityAsc:
        sortedList.sort((a, b) => a.complexity.index.compareTo(b.complexity.index));
        break;
      case CalculatorSortOrder.complexityDesc:
        sortedList.sort((a, b) => b.complexity.index.compareTo(a.complexity.index));
        break;
    }
    
    return sortedList;
  }

  /// Sugere calculadoras relacionadas
  static List<CalculatorEntity> getSuggestions(
    List<CalculatorEntity> allCalculators,
    CalculatorEntity currentCalculator,
    {int maxSuggestions = 5}
  ) {
    final suggestions = <CalculatorEntity>[];
    
    // Prioridade 1: Mesma categoria
    final sameCategory = allCalculators
        .where((calc) => 
            calc.id != currentCalculator.id && 
            calc.category == currentCalculator.category)
        .toList();
    suggestions.addAll(sameCategory);
    
    // Prioridade 2: Tags em comum
    final commonTags = allCalculators
        .where((calc) => 
            calc.id != currentCalculator.id &&
            calc.tags.any((tag) => currentCalculator.tags.contains(tag)))
        .toList();
    
    for (final calc in commonTags) {
      if (!suggestions.contains(calc)) {
        suggestions.add(calc);
      }
    }
    
    // Prioridade 3: Complexidade similar
    final similarComplexity = allCalculators
        .where((calc) => 
            calc.id != currentCalculator.id &&
            calc.complexity == currentCalculator.complexity)
        .toList();
    
    for (final calc in similarComplexity) {
      if (!suggestions.contains(calc)) {
        suggestions.add(calc);
      }
    }
    
    return suggestions.take(maxSuggestions).toList();
  }

  /// Normaliza texto para busca
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .trim();
  }
}

/// Estatísticas dos favoritos
class FavoritesStats {
  final int totalFavorites;
  final DateTime? lastSync;
  final bool hasBackup;

  const FavoritesStats({
    required this.totalFavorites,
    this.lastSync,
    required this.hasBackup,
  });
}

/// Ordem de classificação das calculadoras
enum CalculatorSortOrder {
  nameAsc,
  nameDesc,
  categoryAsc,
  complexityAsc,
  complexityDesc,
}

