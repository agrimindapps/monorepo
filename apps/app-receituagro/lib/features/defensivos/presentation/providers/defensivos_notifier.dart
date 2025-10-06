import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';

part 'defensivos_notifier.g.dart';

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

  factory DefensivosState.initial() {
    return const DefensivosState();
  }

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

  DefensivosState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier para gerenciar estado dos defensivos
/// Segue padrões Clean Architecture + Riverpod
@riverpod
class DefensivosNotifier extends _$DefensivosNotifier {
  late final GetDefensivosUseCase _getDefensivosUseCase;
  late final GetDefensivosByClasseUseCase _getDefensivosByClasseUseCase;
  late final SearchDefensivosUseCase _searchDefensivosUseCase;
  late final GetClassesAgronomicasUseCase _getClassesAgronomicasUseCase;
  late final GetFabricantesUseCase _getFabricantesUseCase;

  @override
  Future<DefensivosState> build() async {
    _getDefensivosUseCase = di.sl<GetDefensivosUseCase>();
    _getDefensivosByClasseUseCase = di.sl<GetDefensivosByClasseUseCase>();
    _searchDefensivosUseCase = di.sl<SearchDefensivosUseCase>();
    _getClassesAgronomicasUseCase = di.sl<GetClassesAgronomicasUseCase>();
    _getFabricantesUseCase = di.sl<GetFabricantesUseCase>();
    return await _loadDefensivos();
  }

  /// Carrega todos os defensivos
  Future<DefensivosState> _loadDefensivos() async {
    final result = await _getDefensivosUseCase.call(const NoParams());

    return await result.fold(
      (failure) async => DefensivosState.initial().copyWith(
        error: _mapFailureToMessage(failure),
      ),
      (defensivos) async {
        final classesResult = await _getClassesAgronomicasUseCase.call(const NoParams());
        final fabricantesResult = await _getFabricantesUseCase.call(const NoParams());

        final classes = classesResult.fold(
          (failure) {
            print('Erro ao carregar classes: ${failure.toString()}');
            return <String>[];
          },
          (classes) => classes,
        );

        final fabricantes = fabricantesResult.fold(
          (failure) {
            print('Erro ao carregar fabricantes: ${failure.toString()}');
            return <String>[];
          },
          (fabricantes) => fabricantes,
        );

        return DefensivosState(
          defensivos: defensivos,
          filteredDefensivos: defensivos,
          classes: classes,
          fabricantes: fabricantes,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Reload defensivos
  Future<void> loadDefensivos() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    final newState = await _loadDefensivos();
    state = AsyncValue.data(newState);
  }

  /// Pesquisa defensivos
  Future<void> searchDefensivos(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(searchQuery: query, isLoading: true).clearError());

    final result = await _searchDefensivosUseCase.call(query);

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
          ),
        );
      },
      (defensivos) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            filteredDefensivos: defensivos,
          ).clearError(),
        );
      },
    );
  }

  /// Filtra defensivos por classe
  Future<void> filterByClasse(String classe) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(selectedClasse: classe, isLoading: true).clearError());

    if (classe.isEmpty) {
      state = AsyncValue.data(
        currentState.copyWith(
          filteredDefensivos: currentState.defensivos,
          isLoading: false,
        ).clearError(),
      );
      return;
    }

    final result = await _getDefensivosByClasseUseCase.call(classe);

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
          ),
        );
      },
      (defensivos) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            filteredDefensivos: defensivos,
          ).clearError(),
        );
      },
    );
  }

  /// Limpa filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        selectedClasse: '',
        selectedFabricante: '',
        filteredDefensivos: currentState.defensivos,
      ),
    );
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
