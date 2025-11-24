import 'package:flutter/foundation.dart';


import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_entity.dart';
import '../../domain/usecases/get_calculators.dart';

/// Provider especializado para busca e filtros de calculadoras
/// 
/// Responsabilidade única: Gerenciar busca e filtros de calculadoras
/// Seguindo Single Responsibility Principle
class CalculatorSearchProvider extends ChangeNotifier {
  final SearchCalculators _searchCalculators;

  CalculatorSearchProvider({
    required SearchCalculators searchCalculators,
  }) : _searchCalculators = searchCalculators;

  bool _isSearching = false;
  String _searchQuery = '';
  CalculatorCategory? _selectedCategory;
  List<CalculatorEntity> _filteredCalculators = [];
  String? _errorMessage;

  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  CalculatorCategory? get selectedCategory => _selectedCategory;
  List<CalculatorEntity> get filteredCalculators => _filteredCalculators;
  String? get errorMessage => _errorMessage;
  
  bool get hasResults => _filteredCalculators.isNotEmpty;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _selectedCategory != null;
  int get totalResults => _filteredCalculators.length;

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Atualiza filtro de categoria
  void updateCategoryFilter(CalculatorCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Busca calculadoras por termo
  Future<void> searchCalculators(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();

    final result = await _searchCalculators.call(query);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('CalculatorSearchProvider: Erro ao buscar calculadoras - ${failure.message}');
      },
      (calculators) {
        _filteredCalculators = calculators;
        debugPrint('CalculatorSearchProvider: Busca concluída - ${calculators.length} resultados');
      },
    );

    _isSearching = false;
    notifyListeners();
  }

  /// Aplica filtros a uma lista de calculadoras
  List<CalculatorEntity> applyFilters(List<CalculatorEntity> calculators) {
    var filtered = List<CalculatorEntity>.from(calculators);
    if (_selectedCategory != null) {
      filtered = filtered.where((calc) => calc.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((calc) =>
        calc.name.toLowerCase().contains(query) ||
        calc.description.toLowerCase().contains(query)
      ).toList();
    }

    _filteredCalculators = filtered;
    return filtered;
  }

  /// Busca e aplica filtros
  Future<void> searchAndFilter(List<CalculatorEntity> allCalculators) async {
    _isSearching = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    applyFilters(allCalculators);

    _isSearching = false;
    notifyListeners();
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

    _filteredCalculators = filtered;
    notifyListeners();
    
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
    _searchQuery = '';
    _selectedCategory = null;
    _filteredCalculators.clear();
    notifyListeners();
    debugPrint('CalculatorSearchProvider: Todos os filtros limpos');
  }

  /// Limpa apenas a busca de texto
  void clearTextSearch() {
    _searchQuery = '';
    notifyListeners();
    debugPrint('CalculatorSearchProvider: Busca de texto limpa');
  }

  /// Limpa apenas o filtro de categoria
  void clearCategoryFilter() {
    _selectedCategory = null;
    notifyListeners();
    debugPrint('CalculatorSearchProvider: Filtro de categoria limpo');
  }

  /// Limpa resultados de busca
  void clearSearchResults() {
    _filteredCalculators.clear();
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
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

  final List<String> _searchHistory = [];
  
  List<String> get searchHistory => _searchHistory.toList();
  
  /// Adiciona termo ao histórico de busca
  void addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory.removeRange(10, _searchHistory.length);
    }
    
    debugPrint('CalculatorSearchProvider: Termo adicionado ao histórico - $query');
  }

  /// Limpa histórico de busca
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
    debugPrint('CalculatorSearchProvider: Histórico de busca limpo');
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset completo do estado
  void resetState() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredCalculators.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('CalculatorSearchProvider: Disposed');
    super.dispose();
  }
}
