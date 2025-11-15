import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../notifiers/diagnosticos_stats_notifier.dart';
import '../state/diagnosticos_stats_state.dart';

part 'diagnosticos_stats_provider.g.dart';

/// Riverpod provider para gerenciamento de estatísticas de diagnósticos
@riverpod
class DiagnosticosStats extends _$DiagnosticosStats {
  @override
  DiagnosticosStatsState build() {
    return DiagnosticosStatsState.initial();
  }

  /// Carrega estatísticas
  Future<void> loadStatistics() async {
    final notifier = ref.read(diagnosticosStatsProvider.notifier);
    await notifier.loadStatistics();
  }

  /// Carrega dados de filtros
  Future<void> loadFiltersData() async {
    final notifier = ref.read(diagnosticosStatsProvider.notifier);
    await notifier.loadFiltersData();
  }

  /// Atualiza tudo
  Future<void> refresh() async {
    final notifier = ref.read(diagnosticosStatsProvider.notifier);
    await notifier.refresh();
  }
}
