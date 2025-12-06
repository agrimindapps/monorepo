import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/animal_base_entity.dart';
import '../../domain/usecases/search_animals.dart' as search_use_case;
import 'livestock_di_providers.dart';

part 'livestock_search_provider.g.dart';

/// State class for LivestockSearch
class LivestockSearchState {
  final bool isSearching;
  final List<AnimalBaseEntity> searchResults;
  final String searchQuery;
  final String? errorMessage;

  const LivestockSearchState({
    this.isSearching = false,
    this.searchResults = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  LivestockSearchState copyWith({
    bool? isSearching,
    List<AnimalBaseEntity>? searchResults,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return LivestockSearchState(
      isSearching: isSearching ?? this.isSearching,
      searchResults: clearResults ? const [] : (searchResults ?? this.searchResults),
      searchQuery: clearResults ? '' : (searchQuery ?? this.searchQuery),
      errorMessage: (clearError || clearResults) ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get hasResults => searchResults.isNotEmpty;
  int get totalResults => searchResults.length;
}

/// Provider especializado para busca e filtros de animais
///
/// Responsabilidade única: Gerenciar busca e filtros de animais
/// Seguindo Single Responsibility Principle
@riverpod
class LivestockSearchNotifier extends _$LivestockSearchNotifier {
  search_use_case.SearchAnimalsUseCase get _searchAnimals => 
      ref.read(searchAnimalsUseCaseProvider);

  @override
  LivestockSearchState build() {
    return const LivestockSearchState();
  }

  // Convenience getters for backward compatibility
  bool get isSearching => state.isSearching;
  List<AnimalBaseEntity> get searchResults => state.searchResults;
  String get searchQuery => state.searchQuery;
  String? get errorMessage => state.errorMessage;
  bool get hasResults => state.hasResults;
  int get totalResults => state.totalResults;

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Busca unificada em todos os animais
  Future<void> searchAllAnimals(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      clearError: true,
    );

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isSearching: false,
        );
        debugPrint(
            'LivestockSearchNotifier: Erro ao buscar animais - ${failure.message}');
      },
      (results) {
        state = state.copyWith(
          searchResults: results.allAnimals,
          isSearching: false,
        );
        debugPrint(
            'LivestockSearchNotifier: Resultados da busca - ${results.totalCount}');
      },
    );
  }

  /// Limpa resultados de busca
  void clearSearchResults() {
    state = state.copyWith(clearResults: true);
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Filtra resultados por tipo
  List<T> getResultsByType<T extends AnimalBaseEntity>() {
    return state.searchResults.whereType<T>().toList();
  }
}
