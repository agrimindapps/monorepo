import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/manage_favorites.dart';

/// Provider especializado para favoritos de calculadoras
/// 
/// Responsabilidade única: Gerenciar favoritos de calculadoras
/// Seguindo Single Responsibility Principle
@singleton
class CalculatorFavoritesProvider extends ChangeNotifier {
  final ManageFavorites _manageFavorites;

  CalculatorFavoritesProvider({
    required ManageFavorites manageFavorites,
  }) : _manageFavorites = manageFavorites;

  List<String> _favoriteCalculatorIds = [];
  bool _isLoadingFavorites = false;
  bool _isUpdatingFavorite = false;
  String? _errorMessage;

  List<String> get favoriteCalculatorIds => _favoriteCalculatorIds;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isUpdatingFavorite => _isUpdatingFavorite;
  String? get errorMessage => _errorMessage;
  
  int get totalFavorites => _favoriteCalculatorIds.length;
  bool get hasFavorites => _favoriteCalculatorIds.isNotEmpty;
  
  /// Verifica se uma calculadora é favorita
  bool isCalculatorFavorite(String calculatorId) {
    return _favoriteCalculatorIds.contains(calculatorId);
  }

  /// Filtra calculadoras favoritas de uma lista
  List<CalculatorEntity> getFavoriteCalculators(List<CalculatorEntity> allCalculators) {
    return allCalculators
        .where((calc) => _favoriteCalculatorIds.contains(calc.id))
        .toList();
  }

  /// Carrega favoritos
  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _manageFavorites.call(const GetFavoritesParams());
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorFavoritesProvider: Erro ao carregar favoritos - ${failure.message}');
      },
      (favorites) {
        _favoriteCalculatorIds = favorites is List ? List<String>.from(favorites) : <String>[];
        debugPrint('CalculatorFavoritesProvider: Favoritos carregados - ${favorites.length} itens');
      },
    );

    _isLoadingFavorites = false;
    notifyListeners();
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    if (_favoriteCalculatorIds.contains(calculatorId)) {
      debugPrint('CalculatorFavoritesProvider: Calculadora já está nos favoritos - $calculatorId');
      return true;
    }

    _isUpdatingFavorite = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _manageFavorites.call(AddFavoriteParams(calculatorId));

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorFavoritesProvider: Erro ao adicionar favorito - ${failure.message}');
      },
      (_) {
        _favoriteCalculatorIds.add(calculatorId);
        success = true;
        debugPrint('CalculatorFavoritesProvider: Favorito adicionado - $calculatorId');
      },
    );

    _isUpdatingFavorite = false;
    notifyListeners();
    return success;
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    if (!_favoriteCalculatorIds.contains(calculatorId)) {
      debugPrint('CalculatorFavoritesProvider: Calculadora não está nos favoritos - $calculatorId');
      return true;
    }

    _isUpdatingFavorite = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _manageFavorites.call(RemoveFavoriteParams(calculatorId));

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorFavoritesProvider: Erro ao remover favorito - ${failure.message}');
      },
      (_) {
        _favoriteCalculatorIds.remove(calculatorId);
        success = true;
        debugPrint('CalculatorFavoritesProvider: Favorito removido - $calculatorId');
      },
    );

    _isUpdatingFavorite = false;
    notifyListeners();
    return success;
  }

  /// Alterna estado de favorito (adiciona/remove)
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFavorite = _favoriteCalculatorIds.contains(calculatorId);
    
    if (isFavorite) {
      return await removeFromFavorites(calculatorId);
    } else {
      return await addToFavorites(calculatorId);
    }
  }

  /// Adiciona múltiplas calculadoras aos favoritos
  Future<bool> addMultipleToFavorites(List<String> calculatorIds) async {
    bool allSuccess = true;
    
    for (final calculatorId in calculatorIds) {
      if (!await addToFavorites(calculatorId)) {
        allSuccess = false;
      }
    }
    
    return allSuccess;
  }

  /// Remove múltiplas calculadoras dos favoritos
  Future<bool> removeMultipleFromFavorites(List<String> calculatorIds) async {
    bool allSuccess = true;
    
    for (final calculatorId in calculatorIds) {
      if (!await removeFromFavorites(calculatorId)) {
        allSuccess = false;
      }
    }
    
    return allSuccess;
  }

  /// Limpa todos os favoritos
  Future<bool> clearAllFavorites() async {
    if (_favoriteCalculatorIds.isEmpty) {
      return true;
    }

    final calculatorIds = List<String>.from(_favoriteCalculatorIds);
    return await removeMultipleFromFavorites(calculatorIds);
  }

  /// Sincroniza favoritos locais com o servidor
  Future<void> syncFavorites() async {
    await loadFavorites();
  }

  /// Obtém estatísticas dos favoritos
  FavoritesStatistics getFavoritesStatistics() {
    return FavoritesStatistics(
      totalFavorites: _favoriteCalculatorIds.length,
      favoriteIds: List<String>.from(_favoriteCalculatorIds),
    );
  }

  /// Verifica se lista de calculadoras tem favoritos
  bool hasAnyFavorites(List<CalculatorEntity> calculators) {
    return calculators.any((calc) => isCalculatorFavorite(calc.id));
  }

  /// Conta quantos favoritos existem em uma lista
  int countFavorites(List<CalculatorEntity> calculators) {
    return calculators.where((calc) => isCalculatorFavorite(calc.id)).length;
  }

  /// Ordena calculadoras colocando favoritas primeiro
  List<CalculatorEntity> sortByFavorites(List<CalculatorEntity> calculators) {
    final favorites = <CalculatorEntity>[];
    final nonFavorites = <CalculatorEntity>[];
    
    for (final calculator in calculators) {
      if (isCalculatorFavorite(calculator.id)) {
        favorites.add(calculator);
      } else {
        nonFavorites.add(calculator);
      }
    }
    
    return [...favorites, ...nonFavorites];
  }

  /// Refresh completo dos favoritos
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _favoriteCalculatorIds.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorFavoritesProvider: Disposed');
    super.dispose();
  }
}

class FavoritesStatistics {
  final int totalFavorites;
  final List<String> favoriteIds;

  const FavoritesStatistics({
    required this.totalFavorites,
    required this.favoriteIds,
  });

  bool get hasFavorites => totalFavorites > 0;
}