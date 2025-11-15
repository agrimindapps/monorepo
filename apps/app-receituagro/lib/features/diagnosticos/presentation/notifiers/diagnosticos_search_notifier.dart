import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/services/search/i_diagnosticos_search_service.dart';
import '../state/diagnosticos_search_state.dart';

/// Notifier para gerenciamento de busca de diagnósticos
/// Responsabilidade: Handle search operations
/// Métodos: search(), findSimilar(), clearSearch()
class DiagnosticosSearchNotifier
    extends StateNotifier<DiagnosticosSearchState> {
  DiagnosticosSearchNotifier()
      : super(DiagnosticosSearchState.initial()) {
    _searchService = di.sl<IDiagnosticosSearchService>();
    _failureMessageService = di.sl<FailureMessageService>();
  }

  late final IDiagnosticosSearchService _searchService;
  late final FailureMessageService _failureMessageService;

  /// Busca diagnósticos por padrão de texto
  Future<void> search(
    String pattern, {
    List<DiagnosticoEntity>? contexto,
  }) async {
    if (pattern.trim().isEmpty) {
      state = state.clearSearch();
      return;
    }

    state = state.copyWith(
      searchQuery: pattern,
      isLoading: true,
      errorMessage: null,
    );

    try {
      // Se há contexto (diagnósticos carregados), busca localmente
      if (contexto != null && contexto.isNotEmpty) {
        final localResults =
            _searchService.searchInList(contexto, pattern);

        state = state.copyWith(
          searchQuery: pattern,
          searchResults: localResults,
          isLoading: false,
        );
        return;
      }

      // Fallback: busca remota
      final result = await _searchService.searchByPattern(pattern);

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
            searchQuery: pattern,
            searchResults: diagnosticos,
            isLoading: false,
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

  /// Busca com filtros estruturados
  Future<void> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final result = await _searchService.searchWithFilters(filters);

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
            searchResults: diagnosticos,
            isLoading: false,
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

  /// Limpa busca
  void clearSearch() {
    state = state.clearSearch();
  }
}

/// Provider para DiagnosticosSearchNotifier
final diagnosticosSearchNotifierProvider =
    StateNotifierProvider<DiagnosticosSearchNotifier, DiagnosticosSearchState>(
  (ref) => DiagnosticosSearchNotifier(),
);
