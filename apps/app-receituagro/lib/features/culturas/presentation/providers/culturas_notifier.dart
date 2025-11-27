import 'package:core/core.dart' hide Column;

import '../../domain/entities/cultura_entity.dart';
import '../../domain/usecases/get_culturas_params.dart';
import 'culturas_providers.dart';
import 'culturas_state.dart';

part 'culturas_notifier.g.dart';

/// Notifier para gerenciar estado das culturas - REFATORADO
/// Usa novo GetCulturasUseCase consolidado com typed params
@riverpod
class CulturasNotifier extends _$CulturasNotifier {
  @override
  Future<CulturasState> build() async {
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
      final getCulturasUseCase = ref.read(getCulturasUseCaseProvider);
      final result = await getCulturasUseCase.call(
        const GetAllCulturasParams(),
      );

      result.fold(
        (Failure failure) {
          final failureMessageService = ref.read(failureMessageServiceProvider);
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failureMessageService.mapFailureToMessage(failure),
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
      final getCulturasUseCase = ref.read(getCulturasUseCaseProvider);
      final result = await getCulturasUseCase.call(
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
      final getCulturasUseCase = ref.read(getCulturasUseCaseProvider);
      final result = await getCulturasUseCase.call(
        SearchCulturasParams(query),
      );

      result.fold(
        (Failure failure) {
          final failureMessageService = ref.read(failureMessageServiceProvider);
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failureMessageService.mapFailureToMessage(failure),
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
      final getCulturasUseCase = ref.read(getCulturasUseCaseProvider);
      final result = await getCulturasUseCase.call(
        GetCulturasByGrupoParams(grupo),
      );

      result.fold(
        (Failure failure) {
          final failureMessageService = ref.read(failureMessageServiceProvider);
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: failureMessageService.mapFailureToMessage(failure),
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
}
