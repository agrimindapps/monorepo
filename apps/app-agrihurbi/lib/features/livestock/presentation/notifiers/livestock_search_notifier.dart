import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/animal_base_entity.dart';
import '../../domain/usecases/search_animals.dart' as search_use_case;
import 'livestock_search_state.dart';

part 'livestock_search_notifier.g.dart';

/// Riverpod notifier for livestock search
///
/// Single Responsibility: Manage search and filters of animals
@riverpod
class LivestockSearchNotifier extends _$LivestockSearchNotifier {
  late final search_use_case.SearchAnimalsUseCase _searchAnimals;

  @override
  LivestockSearchState build() {
    _searchAnimals = getIt<search_use_case.SearchAnimalsUseCase>();
    return const LivestockSearchState();
  }

  /// Computed properties
  bool get hasResults => state.searchResults.isNotEmpty;
  int get totalResults => state.searchResults.length;

  /// Updates search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Unified search across all animals
  Future<void> searchAllAnimals(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      errorMessage: null,
      searchQuery: query,
    );

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);

    result.fold(
      (failure) {
        debugPrint(
          'LivestockSearchNotifier: Erro ao buscar animais - ${failure.message}',
        );
        state = state.copyWith(
          isSearching: false,
          errorMessage: failure.message,
        );
      },
      (results) {
        debugPrint(
          'LivestockSearchNotifier: Resultados da busca - ${results.totalCount}',
        );
        state = state.copyWith(
          searchResults: results.allAnimals,
          isSearching: false,
        );
      },
    );
  }

  /// Clears search results
  void clearSearchResults() {
    state = const LivestockSearchState();
  }

  /// Clears error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Filters results by type
  List<T> getResultsByType<T extends AnimalBaseEntity>() {
    return state.searchResults.whereType<T>().toList();
  }
}
