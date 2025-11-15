import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_params.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';
import '../state/diagnosticos_recommendations_state.dart';

/// Notifier para gerenciamento de recomendações de diagnósticos
/// Responsabilidade: Handle recommendations
/// Métodos: getRecommendations(), clearRecommendations()
class DiagnosticosRecommendationsNotifier
    extends StateNotifier<DiagnosticosRecommendationsState> {
  DiagnosticosRecommendationsNotifier()
      : super(DiagnosticosRecommendationsState.initial()) {
    _getDiagnosticosUseCase = di.sl<GetDiagnosticosUseCase>();
    _failureMessageService = di.sl<FailureMessageService>();
  }

  late final GetDiagnosticosUseCase _getDiagnosticosUseCase;
  late final FailureMessageService _failureMessageService;

  /// Obtém recomendações por cultura e praga
  Future<void> getRecommendations({
    required String idCultura,
    required String idPraga,
    String? nomeCultura,
    String? nomePraga,
    int limit = 10,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      culturaNome: nomeCultura ?? idCultura,
      pragaNome: nomePraga ?? idPraga,
    );

    try {
      final result = await _getDiagnosticosUseCase(
        GetRecomendacoesParams(
          idCultura: idCultura,
          idPraga: idPraga,
          limit: limit,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                _failureMessageService.mapFailureToMessage(failure),
          );
        },
        (diagnosticos) {
          state = state.copyWith(
            isLoading: false,
            recommendations: diagnosticos as List<DiagnosticoEntity>,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Obtém recomendações por defensivo
  Future<void> getRecommendationsByDefensivo({
    required String idDefensivo,
    String? nomeDefensivo,
    int limit = 10,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      defensivoNome: nomeDefensivo ?? idDefensivo,
    );

    try {
      // This could use a specialized use case if available
      // For now, storing defensivo context for reference
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Limpa recomendações
  void clearRecommendations() {
    state = state.clear();
  }
}

/// Provider para DiagnosticosRecommendationsNotifier
final diagnosticosRecommendationsNotifierProvider =
    StateNotifierProvider<DiagnosticosRecommendationsNotifier, DiagnosticosRecommendationsState>(
  (ref) => DiagnosticosRecommendationsNotifier(),
);
