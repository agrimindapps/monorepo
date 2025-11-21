import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_filter_state.freezed.dart';

/// State para gerenciamento de filtros de diagnósticos
@freezed
class DiagnosticosFilterState with _$DiagnosticosFilterState {
  const DiagnosticosFilterState._();

  const factory DiagnosticosFilterState({
    /// Diagnósticos filtrados
    @Default([]) List<DiagnosticoEntity> filteredDiagnosticos,

    /// Contexto de defensivo (navegação)
    String? contextoDefensivo,

    /// Contexto de cultura (navegação)
    String? contextoCultura,

    /// Contexto de praga (navegação)
    String? contextoPraga,

    /// Indica carregamento
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosFilterState;

  /// Factory para estado inicial
  factory DiagnosticosFilterState.initial() => const DiagnosticosFilterState();

  /// Verifica se há contexto ativo
  bool get hasContext =>
      contextoDefensivo != null || contextoCultura != null || contextoPraga != null;

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há dados
  bool get hasData => filteredDiagnosticos.isNotEmpty;

  /// Limpa mensagem de erro
  DiagnosticosFilterState clearError() => copyWith(errorMessage: null);

  /// Limpa contextos
  DiagnosticosFilterState clearContexts() => copyWith(
        contextoDefensivo: null,
        contextoCultura: null,
        contextoPraga: null,
        filteredDiagnosticos: const [],
      );
}
