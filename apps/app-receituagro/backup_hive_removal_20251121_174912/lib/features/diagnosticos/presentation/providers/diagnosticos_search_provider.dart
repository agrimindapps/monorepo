import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';
import '../state/diagnosticos_search_state.dart';

part 'diagnosticos_search_provider.g.dart';

/// Riverpod provider para gerenciamento de busca de diagnósticos
@riverpod
class DiagnosticosSearch extends _$DiagnosticosSearch {
  @override
  DiagnosticosSearchState build() {
    return DiagnosticosSearchState.initial();
  }

  /// Busca por padrão de texto
  Future<void> search(
    String pattern, {
    List<DiagnosticoEntity>? contexto,
  }) async {
    final notifier = ref.read(diagnosticosSearchProvider.notifier);
    await notifier.search(pattern, contexto: contexto);
  }

  /// Busca com filtros estruturados
  Future<void> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    final notifier = ref.read(diagnosticosSearchProvider.notifier);
    await notifier.searchWithFilters(filters);
  }

  /// Limpa busca
  void clearSearch() {
    final notifier = ref.read(diagnosticosSearchProvider.notifier);
    notifier.clearSearch();
  }
}
