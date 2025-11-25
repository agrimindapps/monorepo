import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_search_state.freezed.dart';

/// State para gerenciamento de busca de diagnósticos
@freezed
class DiagnosticosSearchState with _$DiagnosticosSearchState {
  const DiagnosticosSearchState._();

  const factory DiagnosticosSearchState({
    /// Query de busca atual
    @Default('') String searchQuery,

    /// Resultados de busca
    @Default([]) List<DiagnosticoEntity> searchResults,

    /// Indica carregamento
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosSearchState;

  /// Factory para estado inicial
  factory DiagnosticosSearchState.initial() => const DiagnosticosSearchState();

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há dados
  bool get hasData => searchResults.isNotEmpty;

  /// Verifica se há busca ativa
  bool get isSearchActive => searchQuery.isNotEmpty;

  /// Limpa mensagem de erro
  DiagnosticosSearchState clearError() => copyWith(errorMessage: null);

  /// Limpa busca
  DiagnosticosSearchState clearSearch() => copyWith(
        searchQuery: '',
        searchResults: const [],
        errorMessage: null,
      );
}
