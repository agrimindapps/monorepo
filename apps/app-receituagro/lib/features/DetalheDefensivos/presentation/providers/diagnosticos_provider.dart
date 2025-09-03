import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/repositories/diagnostico_repository_impl.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/usecases/get_diagnosticos_by_defensivo_usecase.dart';

/// Provider para o repositório de diagnósticos
final diagnosticoRepositoryProvider = Provider((ref) {
  return DiagnosticoRepositoryImpl(sl());
});

/// Provider para o caso de uso de buscar diagnósticos por defensivo
final getDiagnosticosByDefensivoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(diagnosticoRepositoryProvider);
  return GetDiagnosticosByDefensivoUseCase(repository);
});

/// Estado para os diagnósticos
class DiagnosticosState {
  final List<DiagnosticoEntity> diagnosticos;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedCultura;
  final Map<String, List<DiagnosticoEntity>> diagnosticosGrouped;

  const DiagnosticosState({
    this.diagnosticos = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCultura,
    this.diagnosticosGrouped = const {},
  });

  DiagnosticosState copyWith({
    List<DiagnosticoEntity>? diagnosticos,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCultura,
    Map<String, List<DiagnosticoEntity>>? diagnosticosGrouped,
  }) {
    return DiagnosticosState(
      diagnosticos: diagnosticos ?? this.diagnosticos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCultura: selectedCultura ?? this.selectedCultura,
      diagnosticosGrouped: diagnosticosGrouped ?? this.diagnosticosGrouped,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasData => diagnosticos.isNotEmpty;
  bool get isEmpty => diagnosticos.isEmpty && !isLoading && !hasError;
}

/// Notifier para gerenciar o estado dos diagnósticos
class DiagnosticosNotifier extends StateNotifier<DiagnosticosState> {
  DiagnosticosNotifier(this._getDiagnosticosUseCase) 
      : super(const DiagnosticosState());

  final GetDiagnosticosByDefensivoUseCase _getDiagnosticosUseCase;
  List<DiagnosticoEntity> _originalDiagnosticos = [];

  /// Carrega diagnósticos para um defensivo
  Future<void> loadDiagnosticos(String idDefensivo) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final params = GetDiagnosticosByDefensivoParams(
      idDefensivo: idDefensivo,
      cultura: state.selectedCultura,
      searchQuery: state.searchQuery,
    );

    final result = await _getDiagnosticosUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (diagnosticos) {
        _originalDiagnosticos = diagnosticos;
        final grouped = _groupDiagnosticosByCultura(diagnosticos);
        state = state.copyWith(
          isLoading: false,
          diagnosticos: diagnosticos,
          diagnosticosGrouped: grouped,
          errorMessage: null,
        );
      },
    );
  }

  /// Aplica filtro de pesquisa
  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Seleciona uma cultura específica
  void setSelectedCultura(String? cultura) {
    if (state.selectedCultura == cultura) return;
    
    state = state.copyWith(selectedCultura: cultura);
    _applyFilters();
  }

  /// Aplica filtros aos dados já carregados
  void _applyFilters() {
    var filteredDiagnosticos = List<DiagnosticoEntity>.from(_originalDiagnosticos);

    // Filtro por cultura
    if (state.selectedCultura != null && 
        state.selectedCultura!.isNotEmpty && 
        state.selectedCultura != 'Todas') {
      filteredDiagnosticos = filteredDiagnosticos
          .where((d) => d.cultura.toLowerCase() == state.selectedCultura!.toLowerCase())
          .toList();
    }

    // Filtro por query de busca
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredDiagnosticos = filteredDiagnosticos
          .where((d) =>
              d.nome.toLowerCase().contains(query) ||
              d.cultura.toLowerCase().contains(query) ||
              d.grupo.toLowerCase().contains(query) ||
              d.ingredienteAtivo.toLowerCase().contains(query))
          .toList();
    }

    final grouped = _groupDiagnosticosByCultura(filteredDiagnosticos);
    
    state = state.copyWith(
      diagnosticos: filteredDiagnosticos,
      diagnosticosGrouped: grouped,
    );
  }

  /// Agrupa diagnósticos por cultura
  Map<String, List<DiagnosticoEntity>> _groupDiagnosticosByCultura(
    List<DiagnosticoEntity> diagnosticos,
  ) {
    final Map<String, List<DiagnosticoEntity>> grouped = {};

    for (final diagnostico in diagnosticos) {
      if (!grouped.containsKey(diagnostico.cultura)) {
        grouped[diagnostico.cultura] = [];
      }
      grouped[diagnostico.cultura]!.add(diagnostico);
    }

    // Ordenar as culturas alfabeticamente
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<DiagnosticoEntity>> sortedGrouped = {};

    for (final key in sortedKeys) {
      // Ordenar diagnósticos dentro de cada cultura
      grouped[key]!.sort((a, b) => a.nome.compareTo(b.nome));
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  /// Lista de culturas disponíveis
  List<String> get availableCulturas {
    final culturas = {'Todas'};
    for (final diagnostico in _originalDiagnosticos) {
      culturas.add(diagnostico.cultura);
    }
    return culturas.toList()..sort();
  }

  /// Limpa os dados
  void clearData() {
    state = const DiagnosticosState();
    _originalDiagnosticos = [];
  }
}

/// Provider para o notifier de diagnósticos
final diagnosticosNotifierProvider = 
    StateNotifierProvider<DiagnosticosNotifier, DiagnosticosState>((ref) {
  final useCase = ref.watch(getDiagnosticosByDefensivoUseCaseProvider);
  return DiagnosticosNotifier(useCase);
});

/// Provider conveniente para lista de diagnósticos
final diagnosticosListProvider = Provider<List<DiagnosticoEntity>>((ref) {
  final state = ref.watch(diagnosticosNotifierProvider);
  return state.diagnosticos;
});

/// Provider conveniente para diagnósticos agrupados
final diagnosticosGroupedProvider = Provider<Map<String, List<DiagnosticoEntity>>>((ref) {
  final state = ref.watch(diagnosticosNotifierProvider);
  return state.diagnosticosGrouped;
});

/// Provider conveniente para culturas disponíveis
final availableCulturasProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(diagnosticosNotifierProvider.notifier);
  return notifier.availableCulturas;
});

/// Provider conveniente para estado de loading
final isLoadingDiagnosticosProvider = Provider<bool>((ref) {
  final state = ref.watch(diagnosticosNotifierProvider);
  return state.isLoading;
});

/// Provider conveniente para erros
final diagnosticosErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(diagnosticosNotifierProvider);
  return state.errorMessage;
});