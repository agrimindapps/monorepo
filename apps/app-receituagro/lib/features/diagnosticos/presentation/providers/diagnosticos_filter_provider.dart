import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../notifiers/diagnosticos_filter_notifier.dart';
import '../state/diagnosticos_filter_state.dart';

part 'diagnosticos_filter_provider.g.dart';

/// Riverpod provider para gerenciamento de filtros de diagnósticos
@riverpod
class DiagnosticosFilter extends _$DiagnosticosFilter {
  @override
  DiagnosticosFilterState build() {
    return DiagnosticosFilterState.initial();
  }

  /// Filtra por defensivo
  Future<void> filterByDefensivo(
    String idDefensivo, {
    String? nomeDefensivo,
  }) async {
    final notifier = ref.read(diagnosticosFilterProvider.notifier);
    await notifier.filterByDefensivo(
      idDefensivo,
      nomeDefensivo: nomeDefensivo,
    );
  }

  /// Filtra por cultura
  Future<void> filterByCultura(
    String idCultura, {
    String? nomeCultura,
  }) async {
    final notifier = ref.read(diagnosticosFilterProvider.notifier);
    await notifier.filterByCultura(
      idCultura,
      nomeCultura: nomeCultura,
    );
  }

  /// Filtra por praga
  Future<void> filterByPraga(
    String idPraga, {
    String? nomePraga,
  }) async {
    final notifier = ref.read(diagnosticosFilterProvider.notifier);
    await notifier.filterByPraga(
      idPraga,
      nomePraga: nomePraga,
    );
  }

  /// Limpa filtros
  void clearFilters() {
    final notifier = ref.read(diagnosticosFilterProvider.notifier);
    notifier.clearFilters();
  }
}
