import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/failure_message_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_params.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';
import '../providers/diagnosticos_providers.dart' as diagnosticosProviders;
import '../state/diagnosticos_list_state.dart';

/// Notifier para gerenciamento de lista de diagnósticos
/// Responsabilidade: Load and manage list of diagnosticos
/// Métodos: loadAll(), loadById(), refresh(), clear()
class DiagnosticosListNotifier extends StateNotifier<DiagnosticosListState> {
  DiagnosticosListNotifier({
    required GetDiagnosticosUseCase getDiagnosticosUseCase,
    required FailureMessageService failureMessageService,
  })  : _getDiagnosticosUseCase = getDiagnosticosUseCase,
        _failureMessageService = failureMessageService,
        super(DiagnosticosListState.initial());

  final GetDiagnosticosUseCase _getDiagnosticosUseCase;
  final FailureMessageService _failureMessageService;

  /// Carrega todos os diagnósticos
  Future<void> loadAll({int? limit, int? offset}) async {
    if (offset == null || offset == 0) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _getDiagnosticosUseCase(
        GetAllDiagnosticosParams(limit: limit, offset: offset),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnosticos) {
          final List<DiagnosticoEntity> updatedList;
          if (offset == null || offset == 0) {
            updatedList = diagnosticos as List<DiagnosticoEntity>;
          } else {
            updatedList = [
              ...state.diagnosticos,
              ...(diagnosticos as List<DiagnosticoEntity>),
            ];
          }

          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            diagnosticos: updatedList,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Busca diagnóstico por ID
  Future<void> loadById(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getDiagnosticosUseCase(
        GetDiagnosticoByIdParams(id),
      );
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnostico) {
          state = state.copyWith(
            isLoading: false,
            selectedDiagnostico: diagnostico as DiagnosticoEntity?,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Atualiza lista (força reload)
  Future<void> refresh() async {
    state = state.copyWith(errorMessage: null);
    await loadAll();
  }

  /// Limpa estado
  void clear() {
    state = DiagnosticosListState.initial();
  }
}

/// Provider para DiagnosticosListNotifier
final diagnosticosListNotifierProvider =
    StateNotifierProvider<DiagnosticosListNotifier, DiagnosticosListState>(
  (ref) => DiagnosticosListNotifier(
    getDiagnosticosUseCase:
        ref.watch(diagnosticosProviders.getDiagnosticosUseCaseProvider),
    failureMessageService:
        ref.watch(diagnosticosProviders.failureMessageServiceProvider),
  ),
);
