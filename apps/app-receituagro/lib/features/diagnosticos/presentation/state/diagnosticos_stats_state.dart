import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_stats_state.freezed.dart';

/// State para gerenciamento de estatísticas de diagnósticos
@freezed
sealed class DiagnosticosStatsState with _$DiagnosticosStatsState {
  const DiagnosticosStatsState._();

  const factory DiagnosticosStatsState({
    /// Estatísticas dos diagnósticos
    DiagnosticosStats? stats,

    /// Dados para filtros disponíveis
    DiagnosticoFiltersData? filtersData,

    /// Indica carregamento
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosStatsState;

  /// Factory para estado inicial
  factory DiagnosticosStatsState.initial() => const DiagnosticosStatsState();

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há dados
  bool get hasData => stats != null;

  /// Limpa mensagem de erro
  DiagnosticosStatsState clearError() => copyWith(errorMessage: null);
}
