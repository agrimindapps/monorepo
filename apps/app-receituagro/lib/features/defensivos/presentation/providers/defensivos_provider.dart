import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';

/// State para gerenciar dados de defensivos
class DefensivosState {
  final List<DefensivoEntity> defensivos;
  final List<DefensivoEntity> filteredDefensivos;
  final List<String> classes;
  final List<String> fabricantes;
  final String searchQuery;
  final String selectedClasse;
  final String selectedFabricante;
  final bool isLoading;
  final String? error;

  const DefensivosState({
    this.defensivos = const [],
    this.filteredDefensivos = const [],
    this.classes = const [],
    this.fabricantes = const [],
    this.searchQuery = '',
    this.selectedClasse = '',
    this.selectedFabricante = '',
    this.isLoading = false,
    this.error,
  });

  DefensivosState copyWith({
    List<DefensivoEntity>? defensivos,
    List<DefensivoEntity>? filteredDefensivos,
    List<String>? classes,
    List<String>? fabricantes,
    String? searchQuery,
    String? selectedClasse,
    String? selectedFabricante,
    bool? isLoading,
    String? error,
  }) {
    return DefensivosState(
      defensivos: defensivos ?? this.defensivos,
      filteredDefensivos: filteredDefensivos ?? this.filteredDefensivos,
      classes: classes ?? this.classes,
      fabricantes: fabricantes ?? this.fabricantes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedClasse: selectedClasse ?? this.selectedClasse,
      selectedFabricante: selectedFabricante ?? this.selectedFabricante,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider para gerenciar estado dos defensivos
/// Segue padrões Clean Architecture + ChangeNotifier
class DefensivosProvider extends ChangeNotifier {
  final GetDefensivosUseCase _getDefensivosUseCase;
  final GetDefensivosByClasseUseCase _getDefensivosByClasseUseCase;
  final SearchDefensivosUseCase _searchDefensivosUseCase;
  final GetClassesAgronomicasUseCase _getClassesAgronomicasUseCase;
  final GetFabricantesUseCase _getFabricantesUseCase;

  DefensivosState _state = const DefensivosState();
  DefensivosState get state => _state;

  DefensivosProvider({
    required GetDefensivosUseCase getDefensivosUseCase,
    required GetDefensivosByClasseUseCase getDefensivosByClasseUseCase,
    required SearchDefensivosUseCase searchDefensivosUseCase,
    required GetClassesAgronomicasUseCase getClassesAgronomicasUseCase,
    required GetFabricantesUseCase getFabricantesUseCase,
  })  : _getDefensivosUseCase = getDefensivosUseCase,
        _getDefensivosByClasseUseCase = getDefensivosByClasseUseCase,
        _searchDefensivosUseCase = searchDefensivosUseCase,
        _getClassesAgronomicasUseCase = getClassesAgronomicasUseCase,
        _getFabricantesUseCase = getFabricantesUseCase;

  /// Carrega todos os defensivos
  Future<void> loadDefensivos() async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await _getDefensivosUseCase.call(const NoParams());
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (defensivos) {
        _updateState(_state.copyWith(
          isLoading: false,
          defensivos: defensivos,
          filteredDefensivos: defensivos,
          error: null,
        ));
        _loadMetadata();
      },
    );
  }

  /// Carrega metadados (classes e fabricantes)
  Future<void> _loadMetadata() async {
    // Carrega classes
    final classesResult = await _getClassesAgronomicasUseCase.call(const NoParams());
    classesResult.fold(
      (failure) => debugPrint('Erro ao carregar classes: ${failure.toString()}'),
      (classes) => _updateState(_state.copyWith(classes: classes)),
    );

    // Carrega fabricantes
    final fabricantesResult = await _getFabricantesUseCase.call(const NoParams());
    fabricantesResult.fold(
      (failure) => debugPrint('Erro ao carregar fabricantes: ${failure.toString()}'),
      (fabricantes) => _updateState(_state.copyWith(fabricantes: fabricantes)),
    );
  }

  /// Pesquisa defensivos
  Future<void> searchDefensivos(String query) async {
    _updateState(_state.copyWith(searchQuery: query, isLoading: true));

    final result = await _searchDefensivosUseCase.call(query);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (defensivos) => _updateState(_state.copyWith(
        isLoading: false,
        filteredDefensivos: defensivos,
        error: null,
      )),
    );
  }

  /// Filtra defensivos por classe
  Future<void> filterByClasse(String classe) async {
    _updateState(_state.copyWith(selectedClasse: classe, isLoading: true));

    if (classe.isEmpty) {
      _updateState(_state.copyWith(
        filteredDefensivos: _state.defensivos,
        isLoading: false,
      ));
      return;
    }

    final result = await _getDefensivosByClasseUseCase.call(classe);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (defensivos) => _updateState(_state.copyWith(
        isLoading: false,
        filteredDefensivos: defensivos,
        error: null,
      )),
    );
  }

  /// Limpa filtros
  void clearFilters() {
    _updateState(_state.copyWith(
      searchQuery: '',
      selectedClasse: '',
      selectedFabricante: '',
      filteredDefensivos: _state.defensivos,
    ));
  }

  void _updateState(DefensivosState newState) {
    _state = newState;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro do servidor. Tente novamente.';
      case CacheFailure:
        return 'Erro ao acessar dados locais.';
      case NetworkFailure:
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}