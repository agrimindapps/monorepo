import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/usecases/get_defensivos_params.dart';
import '../../domain/usecases/get_defensivos_usecase.dart';
import 'defensivos_state.dart';

part 'defensivos_notifier.g.dart';

/// Notifier para gerenciar estado dos defensivos - REFATORADO
/// Usa novo GetDefensivosUseCase consolidado com typed params
@riverpod
class DefensivosNotifier extends _$DefensivosNotifier {
  late final GetDefensivosUseCase _getDefensivosUseCase;

  @override
  Future<DefensivosState> build() async {
    _getDefensivosUseCase = di.sl<GetDefensivosUseCase>();
    return await _loadDefensivos();
  }

  /// Carrega todos os defensivos
  Future<DefensivosState> _loadDefensivos() async {
    final result = await _getDefensivosUseCase.call(
      const GetAllDefensivosParams(),
    );

    return await result.fold(
      (Failure failure) async => DefensivosState.initial().copyWith(
        error: _mapFailureToMessage(failure),
      ),
      (dynamic data) async {
        final defensivosMap = data as Map<String, dynamic>? ?? {};
        final defensivos = defensivosMap['defensivos'] is List
            ? (defensivosMap['defensivos'] as List).cast<DefensivoEntity>()
            : <DefensivoEntity>[];
        final classes = defensivosMap['classes'] is List
            ? (defensivosMap['classes'] as List).cast<String>()
            : <String>[];
        final fabricantes = defensivosMap['fabricantes'] is List
            ? (defensivosMap['fabricantes'] as List).cast<String>()
            : <String>[];

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

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    final newState = await _loadDefensivos();
    state = AsyncValue.data(newState);
  }

  /// Pesquisa defensivos
  Future<void> searchDefensivos(String query) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(searchQuery: query, isLoading: true).clearError(),
    );

    final result = await _getDefensivosUseCase.call(
      SearchDefensivosParams(query),
    );

    result.fold(
      (Failure failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
          ),
        );
      },
      (dynamic defensivos) {
        final defensivosList = defensivos is List
            ? defensivos.cast<DefensivoEntity>()
            : <DefensivoEntity>[];
        state = AsyncValue.data(
          currentState
              .copyWith(isLoading: false, filteredDefensivos: defensivosList)
              .clearError(),
        );
      },
    );
  }

  /// Filtra defensivos por classe
  Future<void> filterByClasse(String classe) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState
          .copyWith(selectedClasse: classe, isLoading: true)
          .clearError(),
    );

    if (classe.isEmpty) {
      state = AsyncValue.data(
        currentState
            .copyWith(
              filteredDefensivos: currentState.defensivos,
              isLoading: false,
            )
            .clearError(),
      );
      return;
    }

    final result = await _getDefensivosUseCase.call(
      GetDefensivosByClasseParams(classe),
    );

    result.fold(
      (Failure failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
          ),
        );
      },
      (dynamic defensivos) {
        final defensivosList = defensivos is List
            ? defensivos.cast<DefensivoEntity>()
            : <DefensivoEntity>[];
        state = AsyncValue.data(
          currentState
              .copyWith(isLoading: false, filteredDefensivos: defensivosList)
              .clearError(),
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
