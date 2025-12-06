import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/get_calculators.dart';
import 'calculators_di_providers.dart';

part 'calculator_search_provider.g.dart';

/// State class for CalculatorSearch
class CalculatorSearchState {
  final bool isSearching;
  final String searchQuery;
  final CalculatorCategory? selectedCategory;
  final List<CalculatorEntity> filteredCalculators;
  final String? errorMessage;
  final List<String> searchHistory;

  const CalculatorSearchState({
    this.isSearching = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.filteredCalculators = const [],
    this.errorMessage,
    this.searchHistory = const [],
  });

  CalculatorSearchState copyWith({
    bool? isSearching,
    String? searchQuery,
    CalculatorCategory? selectedCategory,
    List<CalculatorEntity>? filteredCalculators,
    String? errorMessage,
    List<String>? searchHistory,
    bool clearCategory = false,
    bool clearResults = false,
    bool clearError = false,
  }) {
    return CalculatorSearchState(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: clearResults ? '' : (searchQuery ?? this.searchQuery),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      filteredCalculators: clearResults ? const [] : (filteredCalculators ?? this.filteredCalculators),
      errorMessage: (clearError || clearResults) ? null : (errorMessage ?? this.errorMessage),
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  bool get hasResults => filteredCalculators.isNotEmpty;
  bool get hasActiveFilters => searchQuery.isNotEmpty || selectedCategory != null;
  int get totalResults => filteredCalculators.length;
}

/// Provider especializado para busca e filtros de calculadoras
/// 
/// Responsabilidade única: Gerenciar busca e filtros de calculadoras
/// Seguindo Single Responsibility Principle
@riverpod
class CalculatorSearchNotifier extends _$CalculatorSearchNotifier {
  SearchCalculators get _searchCalculators {
    // Fallback implementation if provider not available
    final repository = ref.read(calculatorRepositoryProvider);
    return SearchCalculators(repository);
  }

  @override
  CalculatorSearchState build() {
    return const CalculatorSearchState();
  }

  // Convenience getters for backward compatibility
  bool get isSearching => state.isSearching;
  String get searchQuery => state.searchQuery;
  CalculatorCategory? get selectedCategory => state.selectedCategory;
  List<CalculatorEntity> get filteredCalculators => state.filteredCalculators;
  String? get errorMessage => state.errorMessage;
  bool get hasResults => state.hasResults;
  bool get hasActiveFilters => state.hasActiveFilters;
  int get totalResults => state.totalResults;
  List<String> get searchHistory => state.searchHistory;

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Atualiza filtro de categoria
  void updateCategoryFilter(CalculatorCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  /// Busca calculadoras por termo
  Future<void> searchCalculators(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      clearError: true,
    );

    final result = await _searchCalculators.call(query);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isSearching: false,
        );
        debugPrint('CalculatorSearchNotifier: Erro ao buscar calculadoras - ${failure.message}');
      },
      (calculators) {
        state = state.copyWith(
          filteredCalculators: calculators,
          isSearching: false,
        );
        debugPrint('CalculatorSearchNotifier: Busca concluída - ${calculators.length} resultados');
      },
    );
  }

  /// Aplica filtros a uma lista de calculadoras
  List<CalculatorEntity> applyFilters(List<CalculatorEntity> calculators) {
    var filtered = List<CalculatorEntity>.from(calculators);
    
    if (state.selectedCategory != null) {
      filtered = filtered.where((calc) => calc.category == state.selectedCategory).toList();
    }
    
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((calc) =>
        calc.name.toLowerCase().contains(query) ||
        calc.description.toLowerCase().contains(query)
      ).toList();
    }

    state = state.copyWith(filteredCalculators: filtered);
    return filtered;
  }

  /// Busca e aplica filtros
  Future<void> searchAndFilter(List<CalculatorEntity> allCalculators) async {
    state = state.copyWith(isSearching: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    applyFilters(allCalculators);

    state = state.copyWith(isSearching: false);
  }

  /// Busca avançada com múltiplos critérios
  List<CalculatorEntity> advancedSearch({
    required List<CalculatorEntity> calculators,
    String? nameQuery,
    String? descriptionQuery,
    CalculatorCategory? category,
    List<String>? tags,
  }) {
    var filtered = List<CalculatorEntity>.from(calculators);
    
    if (nameQuery != null && nameQuery.isNotEmpty) {
      final query = nameQuery.toLowerCase();
      filtered = filtered.where((calc) =>
        calc.name.toLowerCase().contains(query)
      ).toList();
    }
    
    if (descriptionQuery != null && descriptionQuery.isNotEmpty) {
      final query = descriptionQuery.toLowerCase();
      filtered = filtered.where((calc) =>
        calc.description.toLowerCase().contains(query)
      ).toList();
    }
    
    if (category != null) {
      filtered = filtered.where((calc) => calc.category == category).toList();
    }

    state = state.copyWith(filteredCalculators: filtered);
    return filtered;
  }

  /// Busca por popularidade (se implementado)
  List<CalculatorEntity> searchByPopularity(
    List<CalculatorEntity> calculators,
    {bool mostPopular = true}
  ) {
    return calculators;
  }

  /// Busca por calculadoras recentes
  List<CalculatorEntity> searchRecent(
    List<CalculatorEntity> calculators,
    {int daysBack = 30}
  ) {
    return calculators.where((calc) {
      return true; // Por enquanto, retorna todos
    }).toList();
  }

  /// Limpa todos os filtros
  void clearAllFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearCategory: true,
      clearResults: true,
    );
    debugPrint('CalculatorSearchNotifier: Todos os filtros limpos');
  }

  /// Limpa apenas a busca de texto
  void clearTextSearch() {
    state = state.copyWith(searchQuery: '');
    debugPrint('CalculatorSearchNotifier: Busca de texto limpa');
  }

  /// Limpa apenas o filtro de categoria
  void clearCategoryFilter() {
    state = state.copyWith(clearCategory: true);
    debugPrint('CalculatorSearchNotifier: Filtro de categoria limpo');
  }

  /// Limpa resultados de busca
  void clearSearchResults() {
    state = state.copyWith(clearResults: true);
  }

  /// Obtém sugestões de busca baseadas em calculadoras existentes
  List<String> getSearchSuggestions(List<CalculatorEntity> calculators) {
    final suggestions = <String>{};
    
    for (final calculator in calculators) {
      suggestions.add(calculator.name);
      final nameWords = calculator.name.split(' ');
      if (nameWords.length > 1) {
        suggestions.addAll(nameWords.where((word) => word.length > 2));
      }
      suggestions.add(calculator.category.displayName);
    }
    
    return suggestions.toList()..sort();
  }

  /// Filtra sugestões baseadas na query atual
  List<String> filterSuggestions(List<String> suggestions, String query) {
    if (query.trim().isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    return suggestions
        .where((suggestion) => 
          suggestion.toLowerCase().contains(queryLower) &&
          suggestion.toLowerCase() != queryLower
        )
        .take(5)
        .toList();
  }

  /// Adiciona termo ao histórico de busca
  void addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    final updatedHistory = List<String>.from(state.searchHistory);
    updatedHistory.remove(query);
    updatedHistory.insert(0, query);
    if (updatedHistory.length > 10) {
      updatedHistory.removeRange(10, updatedHistory.length);
    }
    
    state = state.copyWith(searchHistory: updatedHistory);
    debugPrint('CalculatorSearchNotifier: Termo adicionado ao histórico - $query');
  }

  /// Limpa histórico de busca
  void clearSearchHistory() {
    state = state.copyWith(searchHistory: []);
    debugPrint('CalculatorSearchNotifier: Histórico de busca limpo');
  }

  /// Limpa mensagens de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset completo do estado
  void resetState() {
    state = const CalculatorSearchState();
  }
}
