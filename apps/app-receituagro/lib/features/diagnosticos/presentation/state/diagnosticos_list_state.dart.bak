import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_list_state.freezed.dart';

/// State para gerenciamento de lista de diagnósticos
@freezed
class DiagnosticosListState with _$DiagnosticosListState {
  const DiagnosticosListState._();

  const factory DiagnosticosListState({
    /// Todos os diagnósticos carregados
    @Default([]) List<DiagnosticoEntity> diagnosticos,

    /// Diagnóstico atualmente selecionado
    DiagnosticoEntity? selectedDiagnostico,

    /// Indica carregamento
    @Default(false) bool isLoading,

    /// Indica carregamento de mais itens (paginação)
    @Default(false) bool isLoadingMore,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosListState;

  /// Factory para estado inicial
  factory DiagnosticosListState.initial() => const DiagnosticosListState();

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há dados
  bool get hasData => diagnosticos.isNotEmpty;

  /// Limpa mensagem de erro
  DiagnosticosListState clearError() => copyWith(errorMessage: null);
}
