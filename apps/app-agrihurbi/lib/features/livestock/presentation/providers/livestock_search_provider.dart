import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/animal_base_entity.dart';
import '../../domain/usecases/search_animals.dart' as search_use_case;

/// Provider especializado para busca e filtros de animais
/// 
/// Responsabilidade única: Gerenciar busca e filtros de animais
/// Seguindo Single Responsibility Principle
@singleton
class LivestockSearchProvider extends ChangeNotifier {
  final search_use_case.SearchAnimalsUseCase _searchAnimals;

  LivestockSearchProvider({
    required search_use_case.SearchAnimalsUseCase searchAnimals,
  }) : _searchAnimals = searchAnimals;
  
  bool _isSearching = false;
  List<AnimalBaseEntity> _searchResults = [];
  String _searchQuery = '';
  String? _errorMessage;
  
  bool get isSearching => _isSearching;
  List<AnimalBaseEntity> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  
  bool get hasResults => _searchResults.isNotEmpty;
  int get totalResults => _searchResults.length;

  /// Atualiza query de busca
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Busca unificada em todos os animais
  Future<void> searchAllAnimals(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();

    final params = search_use_case.SearchAnimalsParams(query: query);
    final result = await _searchAnimals(params);
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        debugPrint('LivestockSearchProvider: Erro ao buscar animais - ${failure.message}');
      },
      (results) {
        _searchResults = results.allAnimals;
        debugPrint('LivestockSearchProvider: Resultados da busca - ${results.totalCount}');
      },
    );

    _isSearching = false;
    notifyListeners();
  }

  /// Limpa resultados de busca
  void clearSearchResults() {
    _searchResults.clear();
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Filtra resultados por tipo
  List<T> getResultsByType<T extends AnimalBaseEntity>() {
    return _searchResults.whereType<T>().toList();
  }

  @override
  void dispose() {
    debugPrint('LivestockSearchProvider: Disposed');
    super.dispose();
  }
}
