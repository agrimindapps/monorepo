import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/manage_favorites.dart';
import 'calculators_di_providers.dart';

part 'calculator_favorites_provider.g.dart';

/// FavoritesStatistics class
class FavoritesStatistics {
  final int totalFavorites;
  final List<String> favoriteIds;

  const FavoritesStatistics({
    required this.totalFavorites,
    required this.favoriteIds,
  });

  bool get hasFavorites => totalFavorites > 0;
}

/// State class for CalculatorFavorites
class CalculatorFavoritesState {
  final List<String> favoriteCalculatorIds;
  final bool isLoadingFavorites;
  final bool isUpdatingFavorite;
  final String? errorMessage;

  const CalculatorFavoritesState({
    this.favoriteCalculatorIds = const [],
    this.isLoadingFavorites = false,
    this.isUpdatingFavorite = false,
    this.errorMessage,
  });

  CalculatorFavoritesState copyWith({
    List<String>? favoriteCalculatorIds,
    bool? isLoadingFavorites,
    bool? isUpdatingFavorite,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalculatorFavoritesState(
      favoriteCalculatorIds: favoriteCalculatorIds ?? this.favoriteCalculatorIds,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      isUpdatingFavorite: isUpdatingFavorite ?? this.isUpdatingFavorite,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get totalFavorites => favoriteCalculatorIds.length;
  bool get hasFavorites => favoriteCalculatorIds.isNotEmpty;

  bool isCalculatorFavorite(String calculatorId) {
    return favoriteCalculatorIds.contains(calculatorId);
  }

  List<CalculatorEntity> getFavoriteCalculators(List<CalculatorEntity> allCalculators) {
    return allCalculators
        .where((calc) => favoriteCalculatorIds.contains(calc.id))
        .toList();
  }
}

/// Provider especializado para favoritos de calculadoras
/// 
/// Responsabilidade única: Gerenciar favoritos de calculadoras
/// Seguindo Single Responsibility Principle
@riverpod
class CalculatorFavoritesNotifier extends _$CalculatorFavoritesNotifier {
  ManageFavorites get _manageFavorites => ref.read(manageFavoritesUseCaseProvider);

  @override
  CalculatorFavoritesState build() {
    return const CalculatorFavoritesState();
  }

  // Convenience getters for backward compatibility
  List<String> get favoriteCalculatorIds => state.favoriteCalculatorIds;
  bool get isLoadingFavorites => state.isLoadingFavorites;
  bool get isUpdatingFavorite => state.isUpdatingFavorite;
  String? get errorMessage => state.errorMessage;
  int get totalFavorites => state.totalFavorites;
  bool get hasFavorites => state.hasFavorites;

  /// Verifica se uma calculadora é favorita
  bool isCalculatorFavorite(String calculatorId) {
    return state.isCalculatorFavorite(calculatorId);
  }

  /// Filtra calculadoras favoritas de uma lista
  List<CalculatorEntity> getFavoriteCalculators(List<CalculatorEntity> allCalculators) {
    return state.getFavoriteCalculators(allCalculators);
  }

  /// Carrega favoritos
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingFavorites: true, clearError: true);

    final result = await _manageFavorites.call(const GetFavoritesParams());
    
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoadingFavorites: false,
        );
        debugPrint('CalculatorFavoritesNotifier: Erro ao carregar favoritos - ${failure.message}');
      },
      (favorites) {
        state = state.copyWith(
          favoriteCalculatorIds: favorites is List ? List<String>.from(favorites) : <String>[],
          isLoadingFavorites: false,
        );
        debugPrint('CalculatorFavoritesNotifier: Favoritos carregados - ${favorites.length} itens');
      },
    );
  }

  /// Adiciona calculadora aos favoritos
  Future<bool> addToFavorites(String calculatorId) async {
    if (state.favoriteCalculatorIds.contains(calculatorId)) {
      debugPrint('CalculatorFavoritesNotifier: Calculadora já está nos favoritos - $calculatorId');
      return true;
    }

    state = state.copyWith(isUpdatingFavorite: true, clearError: true);

    final result = await _manageFavorites.call(AddFavoriteParams(calculatorId));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isUpdatingFavorite: false,
        );
        debugPrint('CalculatorFavoritesNotifier: Erro ao adicionar favorito - ${failure.message}');
      },
      (_) {
        final updatedFavorites = [...state.favoriteCalculatorIds, calculatorId];
        state = state.copyWith(
          favoriteCalculatorIds: updatedFavorites,
          isUpdatingFavorite: false,
        );
        success = true;
        debugPrint('CalculatorFavoritesNotifier: Favorito adicionado - $calculatorId');
      },
    );

    return success;
  }

  /// Remove calculadora dos favoritos
  Future<bool> removeFromFavorites(String calculatorId) async {
    if (!state.favoriteCalculatorIds.contains(calculatorId)) {
      debugPrint('CalculatorFavoritesNotifier: Calculadora não está nos favoritos - $calculatorId');
      return true;
    }

    state = state.copyWith(isUpdatingFavorite: true, clearError: true);

    final result = await _manageFavorites.call(RemoveFavoriteParams(calculatorId));

    bool success = false;
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isUpdatingFavorite: false,
        );
        debugPrint('CalculatorFavoritesNotifier: Erro ao remover favorito - ${failure.message}');
      },
      (_) {
        final updatedFavorites = state.favoriteCalculatorIds
            .where((id) => id != calculatorId)
            .toList();
        state = state.copyWith(
          favoriteCalculatorIds: updatedFavorites,
          isUpdatingFavorite: false,
        );
        success = true;
        debugPrint('CalculatorFavoritesNotifier: Favorito removido - $calculatorId');
      },
    );

    return success;
  }

  /// Alterna estado de favorito (adiciona/remove)
  Future<bool> toggleFavorite(String calculatorId) async {
    final isFavorite = state.favoriteCalculatorIds.contains(calculatorId);
    
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
    if (state.favoriteCalculatorIds.isEmpty) {
      return true;
    }

    final calculatorIds = List<String>.from(state.favoriteCalculatorIds);
    return await removeMultipleFromFavorites(calculatorIds);
  }

  /// Sincroniza favoritos locais com o servidor
  Future<void> syncFavorites() async {
    await loadFavorites();
  }

  /// Obtém estatísticas dos favoritos
  FavoritesStatistics getFavoritesStatistics() {
    return FavoritesStatistics(
      totalFavorites: state.favoriteCalculatorIds.length,
      favoriteIds: List<String>.from(state.favoriteCalculatorIds),
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
    state = state.copyWith(clearError: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorFavoritesState();
  }
}
