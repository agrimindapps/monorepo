import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/diagnosticos_list_state.dart';

part 'diagnosticos_list_provider.g.dart';

/// Riverpod provider para gerenciamento de lista de diagnósticos
@riverpod
class DiagnosticosList extends _$DiagnosticosList {
  @override
  DiagnosticosListState build() {
    return DiagnosticosListState.initial();
  }

  /// Carrega todos os diagnósticos
  Future<void> loadAll({int? limit, int? offset}) async {
    final notifier = ref.read(diagnosticosListProvider.notifier);
    await notifier.loadAll(limit: limit, offset: offset);
  }

  /// Busca diagnóstico por ID
  Future<void> loadById(String id) async {
    final notifier = ref.read(diagnosticosListProvider.notifier);
    await notifier.loadById(id);
  }

  /// Atualiza lista
  Future<void> refresh() async {
    final notifier = ref.read(diagnosticosListProvider.notifier);
    await notifier.refresh();
  }

  /// Limpa estado
  void clear() {
    final notifier = ref.read(diagnosticosListProvider.notifier);
    notifier.clear();
  }
}
