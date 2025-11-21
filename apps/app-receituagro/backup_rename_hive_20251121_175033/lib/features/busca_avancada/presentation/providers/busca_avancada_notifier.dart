import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/diagnostico_integration_service.dart';
import '../../domain/entities/busca_entity.dart';
import '../../domain/services/i_busca_metadata_service.dart';
import '../../domain/services/i_busca_validation_service.dart';
import 'busca_avancada_providers.dart';

part 'busca_avancada_notifier.g.dart';

/// Busca Avancada state
class BuscaAvancadaState {
  final bool isLoading;
  final bool hasError;
  final bool hasSearched;
  final String? errorMessage;
  final String? culturaIdSelecionada;
  final String? pragaIdSelecionada;
  final String? defensivoIdSelecionado;
  final List<DiagnosticoDetalhado> resultados;
  final List<Map<String, String>> culturas;
  final List<Map<String, String>> pragas;
  final List<Map<String, String>> defensivos;
  final bool dadosCarregados;

  const BuscaAvancadaState({
    required this.isLoading,
    required this.hasError,
    required this.hasSearched,
    this.errorMessage,
    this.culturaIdSelecionada,
    this.pragaIdSelecionada,
    this.defensivoIdSelecionado,
    required this.resultados,
    required this.culturas,
    required this.pragas,
    required this.defensivos,
    required this.dadosCarregados,
  });

  factory BuscaAvancadaState.initial() {
    return const BuscaAvancadaState(
      isLoading: false,
      hasError: false,
      hasSearched: false,
      errorMessage: null,
      culturaIdSelecionada: null,
      pragaIdSelecionada: null,
      defensivoIdSelecionado: null,
      resultados: [],
      culturas: [],
      pragas: [],
      defensivos: [],
      dadosCarregados: false,
    );
  }

  BuscaAvancadaState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? hasSearched,
    String? errorMessage,
    String? culturaIdSelecionada,
    String? pragaIdSelecionada,
    String? defensivoIdSelecionado,
    List<DiagnosticoDetalhado>? resultados,
    List<Map<String, String>>? culturas,
    List<Map<String, String>>? pragas,
    List<Map<String, String>>? defensivos,
    bool? dadosCarregados,
  }) {
    return BuscaAvancadaState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasSearched: hasSearched ?? this.hasSearched,
      errorMessage: errorMessage ?? this.errorMessage,
      culturaIdSelecionada: culturaIdSelecionada ?? this.culturaIdSelecionada,
      pragaIdSelecionada: pragaIdSelecionada ?? this.pragaIdSelecionada,
      defensivoIdSelecionado:
          defensivoIdSelecionado ?? this.defensivoIdSelecionado,
      resultados: resultados ?? this.resultados,
      culturas: culturas ?? this.culturas,
      pragas: pragas ?? this.pragas,
      defensivos: defensivos ?? this.defensivos,
      dadosCarregados: dadosCarregados ?? this.dadosCarregados,
    );
  }

  BuscaAvancadaState clearError() {
    return copyWith(hasError: false, errorMessage: null);
  }

  bool get temResultados => resultados.isNotEmpty;
}

/// Provider especializado para gerenciar estado complexo da busca avançada (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class BuscaAvancadaNotifier extends _$BuscaAvancadaNotifier {
  late final DiagnosticoIntegrationService _integrationService;
  late final IBuscaMetadataService _metadataService;
  late final IBuscaValidationService _validationService;

  @override
  Future<BuscaAvancadaState> build() async {
    _integrationService = ref.watch(diagnosticoIntegrationServiceProvider);
    _metadataService = ref.watch(buscaMetadataServiceProvider);
    _validationService = ref.watch(buscaValidationServiceProvider);

    return BuscaAvancadaState.initial();
  }

  /// Carrega dados iniciais dos dropdowns
  Future<void> carregarDadosDropdowns() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.dadosCarregados) return;

    try {
      final result = await _metadataService.loadAllDropdownData();

      result.fold(
        (failure) {
          // Silently fail - dropdowns will be empty
        },
        (dropdownData) {
          final culturas = dropdownData['culturas']
                  ?.map((item) => {'id': item.id, 'nome': item.nome})
                  .toList() ??
              [];
          final pragas = dropdownData['pragas']
                  ?.map((item) => {'id': item.id, 'nome': item.nome})
                  .toList() ??
              [];
          final defensivos = dropdownData['defensivos']
                  ?.map((item) => {'id': item.id, 'nome': item.nome})
                  .toList() ??
              [];

          state = AsyncValue.data(
            currentState.copyWith(
              culturas: culturas,
              pragas: pragas,
              defensivos: defensivos,
              dadosCarregados: true,
            ),
          );
        },
      );
    } catch (e) {
      // Silently fail - dropdowns will be empty
    }
  }

  /// Atualiza filtro de cultura
  void setCulturaId(String? id) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.culturaIdSelecionada != id) {
      state = AsyncValue.data(currentState.copyWith(culturaIdSelecionada: id));
    }
  }

  /// Atualiza filtro de praga
  void setPragaId(String? id) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.pragaIdSelecionada != id) {
      state = AsyncValue.data(currentState.copyWith(pragaIdSelecionada: id));
    }
  }

  /// Atualiza filtro de defensivo
  void setDefensivoId(String? id) {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.defensivoIdSelecionado != id) {
      state = AsyncValue.data(
        currentState.copyWith(defensivoIdSelecionado: id),
      );
    }
  }

  /// Realiza busca com filtros atuais
  Future<String?> realizarBusca() async {
    final currentState = state.value;
    if (currentState == null) return 'Estado não inicializado';

    // Create filter entity
    final filters = BuscaFiltersEntity(
      culturaId: currentState.culturaIdSelecionada,
      pragaId: currentState.pragaIdSelecionada,
      defensivoId: currentState.defensivoIdSelecionado,
    );

    // Validate search parameters
    final validationError = _validationService.validateSearchParams(filters);

    if (validationError != null) {
      return validationError.message;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: null,
      ),
    );

    try {
      final resultados = await _integrationService.buscarComFiltros(
        culturaId: currentState.culturaIdSelecionada,
        pragaId: currentState.pragaIdSelecionada,
        defensivoId: currentState.defensivoIdSelecionado,
      );

      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          hasSearched: true,
          resultados: resultados,
        ),
      );

      return null; // Sucesso
    } catch (e) {
      final errorMessage = 'Erro ao realizar busca: $e';
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: errorMessage,
        ),
      );

      return errorMessage;
    }
  }

  void limparFiltros() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        culturaIdSelecionada: null,
        pragaIdSelecionada: null,
        defensivoIdSelecionado: null,
        resultados: [],
        hasSearched: false,
        hasError: false,
        errorMessage: null,
      ),
    );
    _integrationService.clearCache();
  }

  /// Reset do estado de erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.hasError) {
      state = AsyncValue.data(currentState.clearError());
    }
  }

  /// Helper methods that delegate to services

  /// Checks if at least one filter is active
  bool temFiltrosAtivos() {
    final currentState = state.value;
    if (currentState == null) return false;

    final filters = BuscaFiltersEntity(
      culturaId: currentState.culturaIdSelecionada,
      pragaId: currentState.pragaIdSelecionada,
      defensivoId: currentState.defensivoIdSelecionado,
    );

    return _validationService.hasActiveFilters(filters);
  }

  /// Builds a text description of active filters
  String filtrosAtivosTexto() {
    final currentState = state.value;
    if (currentState == null) return '';

    final filters = BuscaFiltersEntity(
      culturaId: currentState.culturaIdSelecionada,
      pragaId: currentState.pragaIdSelecionada,
      defensivoId: currentState.defensivoIdSelecionado,
    );

    return _validationService.buildFilterDescription(filters);
  }

  /// Builds a map of active filters with their display names
  Map<String, String> filtrosDetalhados() {
    final currentState = state.value;
    if (currentState == null) return {};

    // TODO: Implement filtrosDetalhados using metadata service
    // _dataLoadingService was removed - need to rebuild this using _metadataService
    final filtros = <String, String>{};

    if (currentState.culturaIdSelecionada != null) {
      final cultura = currentState.culturas.firstWhere(
        (c) => c['id'] == currentState.culturaIdSelecionada,
        orElse: () => {'nome': 'Desconhecido'},
      );
      filtros['Cultura'] = cultura['nome'] ?? 'Desconhecido';
    }

    if (currentState.pragaIdSelecionada != null) {
      final praga = currentState.pragas.firstWhere(
        (p) => p['id'] == currentState.pragaIdSelecionada,
        orElse: () => {'nome': 'Desconhecido'},
      );
      filtros['Praga'] = praga['nome'] ?? 'Desconhecido';
    }

    if (currentState.defensivoIdSelecionado != null) {
      final defensivo = currentState.defensivos.firstWhere(
        (d) => d['id'] == currentState.defensivoIdSelecionado,
        orElse: () => {'nome': 'Desconhecido'},
      );
      filtros['Defensivo'] = defensivo['nome'] ?? 'Desconhecido';
    }

    return filtros;
  }
}
