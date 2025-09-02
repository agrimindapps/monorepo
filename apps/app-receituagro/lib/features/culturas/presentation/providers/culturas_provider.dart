import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_culturas_usecase.dart';

/// State para gerenciar dados de culturas
class CulturasState {
  final List<CulturaEntity> culturas;
  final List<CulturaEntity> filteredCulturas;
  final List<String> grupos;
  final String searchQuery;
  final String selectedGrupo;
  final bool isLoading;
  final String? error;

  const CulturasState({
    this.culturas = const [],
    this.filteredCulturas = const [],
    this.grupos = const [],
    this.searchQuery = '',
    this.selectedGrupo = '',
    this.isLoading = false,
    this.error,
  });

  CulturasState copyWith({
    List<CulturaEntity>? culturas,
    List<CulturaEntity>? filteredCulturas,
    List<String>? grupos,
    String? searchQuery,
    String? selectedGrupo,
    bool? isLoading,
    String? error,
  }) {
    return CulturasState(
      culturas: culturas ?? this.culturas,
      filteredCulturas: filteredCulturas ?? this.filteredCulturas,
      grupos: grupos ?? this.grupos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGrupo: selectedGrupo ?? this.selectedGrupo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Provider para gerenciar estado das culturas
/// Segue padrões Clean Architecture + ChangeNotifier
class CulturasProvider extends ChangeNotifier {
  final GetCulturasUseCase _getCulturasUseCase;
  final GetCulturasByGrupoUseCase _getCulturasByGrupoUseCase;
  final SearchCulturasUseCase _searchCulturasUseCase;
  final GetGruposCulturasUseCase _getGruposCulturasUseCase;

  CulturasState _state = const CulturasState();
  CulturasState get state => _state;

  CulturasProvider({
    required GetCulturasUseCase getCulturasUseCase,
    required GetCulturasByGrupoUseCase getCulturasByGrupoUseCase,
    required SearchCulturasUseCase searchCulturasUseCase,
    required GetGruposCulturasUseCase getGruposCulturasUseCase,
  })  : _getCulturasUseCase = getCulturasUseCase,
        _getCulturasByGrupoUseCase = getCulturasByGrupoUseCase,
        _searchCulturasUseCase = searchCulturasUseCase,
        _getGruposCulturasUseCase = getGruposCulturasUseCase;

  /// Carrega todas as culturas
  Future<void> loadCulturas() async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await _getCulturasUseCase.call(NoParams());
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (culturas) {
        _updateState(_state.copyWith(
          isLoading: false,
          culturas: culturas,
          filteredCulturas: culturas,
          error: null,
        ));
        _loadGrupos();
      },
    );
  }

  /// Carrega grupos de culturas
  Future<void> _loadGrupos() async {
    final result = await _getGruposCulturasUseCase.call(NoParams());
    
    result.fold(
      (failure) => debugPrint('Erro ao carregar grupos: ${failure.toString()}'),
      (grupos) => _updateState(_state.copyWith(grupos: grupos)),
    );
  }

  /// Filtra culturas por pesquisa
  Future<void> searchCulturas(String query) async {
    _updateState(_state.copyWith(searchQuery: query, isLoading: true));

    final result = await _searchCulturasUseCase.call(query);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (culturas) => _updateState(_state.copyWith(
        isLoading: false,
        filteredCulturas: culturas,
        error: null,
      )),
    );
  }

  /// Filtra culturas por grupo
  Future<void> filterByGrupo(String grupo) async {
    _updateState(_state.copyWith(selectedGrupo: grupo, isLoading: true));

    if (grupo.isEmpty) {
      _updateState(_state.copyWith(
        filteredCulturas: _state.culturas,
        isLoading: false,
      ));
      return;
    }

    final result = await _getCulturasByGrupoUseCase.call(grupo);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      )),
      (culturas) => _updateState(_state.copyWith(
        isLoading: false,
        filteredCulturas: culturas,
        error: null,
      )),
    );
  }

  /// Limpa filtros
  void clearFilters() {
    _updateState(_state.copyWith(
      searchQuery: '',
      selectedGrupo: '',
      filteredCulturas: _state.culturas,
    ));
  }

  void _updateState(CulturasState newState) {
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