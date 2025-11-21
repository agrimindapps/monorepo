import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../state/diagnosticos_filter_state.dart';

part 'diagnosticos_filter_notifier.g.dart';

/// Notifier para gerenciamento de filtros de diagnósticos
/// Responsabilidade: Handle filtering by defensivo, cultura, praga
/// Métodos: filterByDefensivo(), filterByCultura(), filterByPraga(), clearFilters()
@riverpod
class DiagnosticosFilter extends _$DiagnosticosFilter {
  late final IDiagnosticosFilterService _filterService;
  late final FailureMessageService _failureMessageService;

  @override
  DiagnosticosFilterState build() {
    _filterService = di.sl<IDiagnosticosFilterService>();
    _failureMessageService = di.sl<FailureMessageService>();
    return DiagnosticosFilterState.initial();
  }

  /// Filtra diagnósticos por defensivo
  Future<void> filterByDefensivo(
    String idDefensivo, {
    String? nomeDefensivo,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      contextoDefensivo: nomeDefensivo ?? idDefensivo,
    );

    try {
      final result = await _filterService.filterByDefensivo(idDefensivo);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnosticos) {
          state = state.copyWith(
            isLoading: false,
            filteredDiagnosticos: diagnosticos,
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

  /// Filtra diagnósticos por cultura
  Future<void> filterByCultura(
    String idCultura, {
    String? nomeCultura,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      contextoCultura: nomeCultura ?? idCultura,
    );

    try {
      final result = await _filterService.filterByCultura(idCultura);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnosticos) {
          state = state.copyWith(
            isLoading: false,
            filteredDiagnosticos: diagnosticos,
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

  /// Filtra diagnósticos por praga
  Future<void> filterByPraga(
    String idPraga, {
    String? nomePraga,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      contextoPraga: nomePraga ?? idPraga,
    );

    try {
      final result = await _filterService.filterByPraga(idPraga);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnosticos) {
          state = state.copyWith(
            isLoading: false,
            filteredDiagnosticos: diagnosticos,
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

  /// Limpa todos os filtros
  void clearFilters() {
    state = DiagnosticosFilterState.initial();
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
