import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_culturas_usecase.dart';

part 'culturas_notifier.g.dart';

/// State para gerenciar dados de culturas
class CulturasState {
  final List<CulturaEntity> culturas;
  final List<CulturaEntity> filteredCulturas;
  final List<String> grupos;
  final String searchQuery;
  final String selectedGrupo;
  final bool isLoading;
  final String? errorMessage;

  const CulturasState({
    required this.culturas,
    required this.filteredCulturas,
    required this.grupos,
    required this.searchQuery,
    required this.selectedGrupo,
    required this.isLoading,
    this.errorMessage,
  });

  factory CulturasState.initial() {
    return const CulturasState(
      culturas: [],
      filteredCulturas: [],
      grupos: [],
      searchQuery: '',
      selectedGrupo: '',
      isLoading: false,
      errorMessage: null,
    );
  }

  CulturasState copyWith({
    List<CulturaEntity>? culturas,
    List<CulturaEntity>? filteredCulturas,
    List<String>? grupos,
    String? searchQuery,
    String? selectedGrupo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CulturasState(
      culturas: culturas ?? this.culturas,
      filteredCulturas: filteredCulturas ?? this.filteredCulturas,
      grupos: grupos ?? this.grupos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGrupo: selectedGrupo ?? this.selectedGrupo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  CulturasState clearError() {
    return copyWith(errorMessage: null);
  }

  // UI helpers
  bool get hasData => culturas.isNotEmpty;
  bool get hasFilteredData => filteredCulturas.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get isFiltered => searchQuery.isNotEmpty || selectedGrupo.isNotEmpty;

  CulturasViewState get viewState {
    if (isLoading) return CulturasViewState.loading;
    if (hasError) return CulturasViewState.error;
    if (filteredCulturas.isEmpty) return CulturasViewState.empty;
    return CulturasViewState.loaded;
  }
}

/// Estados da view de culturas
enum CulturasViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Notifier para gerenciar estado das culturas
/// Segue padrões Clean Architecture + Riverpod
@riverpod
class CulturasNotifier extends _$CulturasNotifier {
  late final GetCulturasUseCase _getCulturasUseCase;
  late final GetCulturasByGrupoUseCase _getCulturasByGrupoUseCase;
  late final SearchCulturasUseCase _searchCulturasUseCase;
  late final GetGruposCulturasUseCase _getGruposCulturasUseCase;

  @override
  Future<CulturasState> build() async {
    // Get use cases from DI
    _getCulturasUseCase = di.sl<GetCulturasUseCase>();
    _getCulturasByGrupoUseCase = di.sl<GetCulturasByGrupoUseCase>();
    _searchCulturasUseCase = di.sl<SearchCulturasUseCase>();
    _getGruposCulturasUseCase = di.sl<GetGruposCulturasUseCase>();

    return CulturasState.initial();
  }

  /// Carrega todas as culturas
  Future<void> loadCulturas() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _getCulturasUseCase.call(const NoParams());

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (culturas) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              culturas: culturas,
              filteredCulturas: culturas,
            ).clearError(),
          );
          // Load grupos after culturas
          _loadGrupos();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Carrega grupos de culturas
  Future<void> _loadGrupos() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _getGruposCulturasUseCase.call(const NoParams());

      result.fold(
        (failure) {
          // Silent failure for grupos
          print('Erro ao carregar grupos: ${failure.toString()}');
        },
        (grupos) {
          state = AsyncValue.data(currentState.copyWith(grupos: grupos));
        },
      );
    } catch (e) {
      print('Erro ao carregar grupos: $e');
    }
  }

  /// Filtra culturas por pesquisa
  Future<void> searchCulturas(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query, isLoading: true).clearError());

    try {
      final result = await _searchCulturasUseCase.call(query);

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (culturas) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredCulturas: culturas,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Filtra culturas por grupo
  Future<void> filterByGrupo(String grupo) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedGrupo: grupo, isLoading: true).clearError());

    if (grupo.isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(
          filteredCulturas: currentState.culturas,
          isLoading: false,
        ).clearError(),
      );
      return;
    }

    try {
      final result = await _getCulturasByGrupoUseCase.call(grupo);

      result.fold(
        (failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (culturas) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              filteredCulturas: culturas,
            ).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Limpa filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        selectedGrupo: '',
        filteredCulturas: currentState.culturas,
      ),
    );
  }

  /// Limpa erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
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
