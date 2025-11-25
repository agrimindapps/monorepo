import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/diagnostico_entity.dart';

part 'diagnosticos_recommendations_state.freezed.dart';

/// State para gerenciamento de recomendações de diagnósticos
@freezed
sealed class DiagnosticosRecommendationsState with _$DiagnosticosRecommendationsState {
  const DiagnosticosRecommendationsState._();

  const factory DiagnosticosRecommendationsState({
    /// Recomendações carregadas
    @Default([]) List<DiagnosticoEntity> recommendations,

    /// Contexto da cultura
    String? culturaNome,

    /// Contexto da praga
    String? pragaNome,

    /// Contexto do defensivo
    String? defensivoNome,

    /// Indica carregamento
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? errorMessage,
  }) = _DiagnosticosRecommendationsState;

  /// Factory para estado inicial
  factory DiagnosticosRecommendationsState.initial() =>
      const DiagnosticosRecommendationsState();

  /// Verifica se há erro
  bool get hasError => errorMessage != null;

  /// Verifica se há dados
  bool get hasData => recommendations.isNotEmpty;

  /// Resumo do contexto
  String get contextSummary {
    final parts = <String>[];
    if (culturaNome != null) parts.add(culturaNome!);
    if (pragaNome != null) parts.add(pragaNome!);
    if (defensivoNome != null) parts.add(defensivoNome!);
    return parts.join(' + ');
  }

  /// Limpa mensagem de erro
  DiagnosticosRecommendationsState clearError() =>
      copyWith(errorMessage: null);

  /// Limpa recomendações
  DiagnosticosRecommendationsState clear() => copyWith(
        recommendations: const [],
        culturaNome: null,
        pragaNome: null,
        defensivoNome: null,
        errorMessage: null,
      );
}
