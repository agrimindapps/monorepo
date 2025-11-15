import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../state/diagnosticos_filter_state.dart';

/// Notifier para gerenciamento de filtros de diagnósticos
/// Responsabilidade: Handle filtering by defensivo, cultura, praga
/// Métodos: filterByDefensivo(), filterByCultura(), filterByPraga(), clearFilters()
class DiagnosticosFilterNotifier
    extends StateNotifier<DiagnosticosFilterState> {
  DiagnosticosFilterNotifier()
      : super(DiagnosticosFilterState.initial()) {
    _filterService = di.sl<IDiagnosticosFilterService>();
    _failureMessageService = di.sl<FailureMessageService>();
  }

  late final IDiagnosticosFilterService _filterService;
  late final FailureMessageService _failureMessageService;

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

  /// Limpa filtros e contextos
  void clearFilters() {
    state = state.clearContexts();
  }
}

/// Provider para DiagnosticosFilterNotifier
final diagnosticosFilterNotifierProvider =
    StateNotifierProvider<DiagnosticosFilterNotifier, DiagnosticosFilterState>(
  (ref) => DiagnosticosFilterNotifier(),
);
