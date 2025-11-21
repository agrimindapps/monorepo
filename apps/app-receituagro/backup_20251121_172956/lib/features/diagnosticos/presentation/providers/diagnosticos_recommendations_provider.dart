import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/diagnosticos_recommendations_state.dart';

part 'diagnosticos_recommendations_provider.g.dart';

/// Riverpod provider para gerenciamento de recomendações de diagnósticos
@riverpod
class DiagnosticosRecommendations extends _$DiagnosticosRecommendations {
  @override
  DiagnosticosRecommendationsState build() {
    return DiagnosticosRecommendationsState.initial();
  }

  /// Obtém recomendações
  Future<void> getRecommendations({
    required String idCultura,
    required String idPraga,
    String? nomeCultura,
    String? nomePraga,
    int limit = 10,
  }) async {
    final notifier = ref.read(diagnosticosRecommendationsProvider.notifier);
    await notifier.getRecommendations(
      idCultura: idCultura,
      idPraga: idPraga,
      nomeCultura: nomeCultura,
      nomePraga: nomePraga,
      limit: limit,
    );
  }

  /// Obtém recomendações por defensivo
  Future<void> getRecommendationsByDefensivo({
    required String idDefensivo,
    String? nomeDefensivo,
    int limit = 10,
  }) async {
    final notifier = ref.read(diagnosticosRecommendationsProvider.notifier);
    await notifier.getRecommendationsByDefensivo(
      idDefensivo: idDefensivo,
      nomeDefensivo: nomeDefensivo,
      limit: limit,
    );
  }

  /// Limpa recomendações
  void clearRecommendations() {
    final notifier = ref.read(diagnosticosRecommendationsProvider.notifier);
    notifier.clearRecommendations();
  }
}
