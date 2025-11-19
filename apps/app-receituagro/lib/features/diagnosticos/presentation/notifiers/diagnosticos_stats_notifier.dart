import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../domain/services/stats/i_diagnosticos_stats_service.dart';
import '../state/diagnosticos_stats_state.dart';

/// Notifier para gerenciamento de estatísticas de diagnósticos
/// Responsabilidade: Handle statistics
/// Métodos: loadStatistics(), refresh(), getStatistics()
class DiagnosticosStatsNotifier extends StateNotifier<DiagnosticosStatsState> {
  DiagnosticosStatsNotifier()
      : super(DiagnosticosStatsState.initial()) {
    _statsService = di.sl<IDiagnosticosStatsService>();
    _metadataService = di.sl<IDiagnosticosMetadataService>();
    _failureMessageService = di.sl<FailureMessageService>();
  }

  late final IDiagnosticosStatsService _statsService;
  late final IDiagnosticosMetadataService _metadataService;
  late final FailureMessageService _failureMessageService;

  /// Carrega estatísticas dos diagnósticos
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _statsService.getStatistics();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (stats) {
          state = state.copyWith(
            isLoading: false,
            stats: stats,
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

  /// Carrega dados de filtros disponíveis
  Future<void> loadFiltersData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _metadataService.getFiltersData();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (filtersData) {
          state = state.copyWith(
            isLoading: false,
            filtersData: filtersData,
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

  /// Atualiza estatísticas e dados de filtros
  Future<void> refresh() async {
    state = state.copyWith(errorMessage: null);
    await Future.wait([
      loadStatistics(),
      loadFiltersData(),
    ]);
  }
}

/// Provider para DiagnosticosStatsNotifier
final diagnosticosStatsNotifierProvider =
    StateNotifierProvider<DiagnosticosStatsNotifier, DiagnosticosStatsState>(
  (ref) => DiagnosticosStatsNotifier(),
);
