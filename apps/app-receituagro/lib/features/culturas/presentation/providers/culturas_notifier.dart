import 'package:core/core.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_culturas_params.dart';
import '../../domain/usecases/get_culturas_usecase.dart';
import 'culturas_state.dart';

part 'culturas_notifier.g.dart';

/// Notifier para gerenciar estado das culturas - REFATORADO
/// Usa novo GetCulturasUseCase consolidado com typed params
@riverpod
class CulturasNotifier extends _$CulturasNotifier {
  late final GetCulturasUseCase _getCulturasUseCase;

  @override
  Future<CulturasState> build() async {
    _getCulturasUseCase = di.sl<GetCulturasUseCase>();
    return CulturasState.initial();
  }

  /// Carrega todas as culturas
  Future<void> loadCulturas() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      final result = await _getCulturasUseCase.call(
        const GetAllCulturasParams(),
      );

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (dynamic culturas) {
          final culturasList = culturas is List
              ? culturas.cast<CulturaEntity>()
              : <CulturaEntity>[];
          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  culturas: culturasList,
                  filteredCulturas: culturasList,
                )
                .clearError(),
          );
          _loadGrupos();
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Carrega grupos de culturas
  Future<void> _loadGrupos() async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await _getCulturasUseCase.call(
        const GetGruposCulturasParams(),
      );

      result.fold(
        (Failure failure) {
          print('Erro ao carregar grupos: ${failure.toString()}');
        },
        (dynamic grupos) {
          final gruposList = grupos is List
              ? grupos.cast<String>()
              : <String>[];
          state = AsyncValue.data(currentState.copyWith(grupos: gruposList));
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

    state = AsyncValue.data(
      currentState.copyWith(searchQuery: query, isLoading: true).clearError(),
    );

    try {
      final result = await _getCulturasUseCase.call(
        SearchCulturasParams(query),
      );

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (dynamic culturas) {
          final culturasList = culturas is List
              ? culturas.cast<CulturaEntity>()
              : <CulturaEntity>[];
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, filteredCulturas: culturasList)
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  /// Filtra culturas por grupo
  Future<void> filterByGrupo(String grupo) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(selectedGrupo: grupo, isLoading: true).clearError(),
    );

    if (grupo.isEmpty) {
      state = AsyncValue.data(
        currentState
            .copyWith(filteredCulturas: currentState.culturas, isLoading: false)
            .clearError(),
      );
      return;
    }

    try {
      final result = await _getCulturasUseCase.call(
        GetCulturasByGrupoParams(grupo),
      );

      result.fold(
        (Failure failure) {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure),
            ),
          );
        },
        (dynamic culturas) {
          final culturasList = culturas is List
              ? culturas.cast<CulturaEntity>()
              : <CulturaEntity>[];
          state = AsyncValue.data(
            currentState
                .copyWith(isLoading: false, filteredCulturas: culturasList)
                .clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, errorMessage: e.toString()),
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
