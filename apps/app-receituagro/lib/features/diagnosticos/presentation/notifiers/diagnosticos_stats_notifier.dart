import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/failure_message_service.dart';
import '../../domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../domain/services/stats/i_diagnosticos_stats_service.dart';
import '../providers/diagnosticos_providers.dart' as providers;
import '../state/diagnosticos_stats_state.dart';

part 'diagnosticos_stats_notifier.g.dart';

/// Notifier para gerenciamento de estatísticas de diagnósticos
/// Responsabilidade: Handle statistics
/// Métodos: loadStatistics(), refresh(), getStatistics()
@riverpod
class DiagnosticosStatsNotifier extends _$DiagnosticosStatsNotifier {
  late final IDiagnosticosStatsService _statsService;
  late final IDiagnosticosMetadataService _metadataService;
  late final FailureMessageService _failureMessageService;

  @override
  DiagnosticosStatsState build() {
    _statsService = ref.watch(providers.diagnosticosStatsServiceProvider);
    _metadataService = ref.watch(providers.diagnosticosMetadataServiceProvider);
    _failureMessageService = ref.watch(providers.failureMessageServiceProvider);
    return DiagnosticosStatsState.initial();
  }

  /// Carrega estatísticas dos diagnósticos
  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _statsService.getStatistics();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: _failureMessageService.mapFailureToMessage(failure),
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
            errorMessage: _failureMessageService.mapFailureToMessage(failure),
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
