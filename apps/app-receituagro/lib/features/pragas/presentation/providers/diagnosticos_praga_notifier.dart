import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../diagnosticos/domain/repositories/i_diagnosticos_repository.dart';

part 'diagnosticos_praga_notifier.g.dart';

/// Model para diagnóstico usado na UI
class DiagnosticoModel {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String dosagem;
  final String cultura;
  final String grupo;

  const DiagnosticoModel({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    required this.dosagem,
    required this.cultura,
    required this.grupo,
  });
}

/// Diagnosticos Praga state
class DiagnosticosPragaState {
  final List<DiagnosticoModel> diagnosticos;
  final String searchQuery;
  final String selectedCultura;
  final List<String> culturas;
  final bool isLoading;
  final bool isLoadingFilters;
  final bool hasPartialData;
  final String? errorMessage;

  const DiagnosticosPragaState({
    required this.diagnosticos,
    required this.searchQuery,
    required this.selectedCultura,
    required this.culturas,
    required this.isLoading,
    required this.isLoadingFilters,
    required this.hasPartialData,
    this.errorMessage,
  });

  factory DiagnosticosPragaState.initial() {
    return const DiagnosticosPragaState(
      diagnosticos: [],
      searchQuery: '',
      selectedCultura: 'Todas',
      culturas: [
        'Todas',
        'Soja',
        'Milho',
        'Algodão',
        'Café',
        'Citros',
        'Cana-de-açúcar',
      ],
      isLoading: false,
      isLoadingFilters: false,
      hasPartialData: false,
      errorMessage: null,
    );
  }

  DiagnosticosPragaState copyWith({
    List<DiagnosticoModel>? diagnosticos,
    String? searchQuery,
    String? selectedCultura,
    List<String>? culturas,
    bool? isLoading,
    bool? isLoadingFilters,
    bool? hasPartialData,
    String? errorMessage,
  }) {
    return DiagnosticosPragaState(
      diagnosticos: diagnosticos ?? this.diagnosticos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCultura: selectedCultura ?? this.selectedCultura,
      culturas: culturas ?? this.culturas,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
      hasPartialData: hasPartialData ?? this.hasPartialData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DiagnosticosPragaState clearError() {
    return copyWith(errorMessage: null);
  }

  // Getters de conveniência
  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasError => errorMessage != null;

  List<DiagnosticoModel> get filteredDiagnosticos {
    return diagnosticos.where((diagnostic) {
      bool matchesSearch = searchQuery.isEmpty ||
          diagnostic.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
          diagnostic.ingredienteAtivo.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesCulture = selectedCultura == 'Todas' ||
          diagnostic.cultura == selectedCultura;

      return matchesSearch && matchesCulture;
    }).toList();
  }

  Map<String, List<DiagnosticoModel>> get groupedDiagnosticos {
    final filtered = filteredDiagnosticos;
    final grouped = <String, List<DiagnosticoModel>>{};

    for (final diagnostic in filtered) {
      grouped.putIfAbsent(diagnostic.cultura, () => []).add(diagnostic);
    }

    return grouped;
  }

  Map<String, int> get dataStats {
    final stats = <String, int>{};
    stats['total'] = diagnosticos.length;
    stats['filtered'] = filteredDiagnosticos.length;

    final culturaGroups = groupedDiagnosticos;
    stats['culturas'] = culturaGroups.keys.length;

    return stats;
  }
}

/// Notifier para gerenciar diagnósticos relacionados à praga
/// Responsabilidade única: filtros e busca de diagnósticos
@riverpod
class DiagnosticosPragaNotifier extends _$DiagnosticosPragaNotifier {
  late final IDiagnosticosRepository _diagnosticosRepository;
  late final CulturaHiveRepository _culturaRepository;
  late final PragasHiveRepository _pragasRepository;
  late final FitossanitarioHiveRepository _defensivoRepository;

  @override
  Future<DiagnosticosPragaState> build() async {
    // Get repositories from DI
    _diagnosticosRepository = di.sl<IDiagnosticosRepository>();
    _culturaRepository = di.sl<CulturaHiveRepository>();
    _pragasRepository = di.sl<PragasHiveRepository>();
    _defensivoRepository = di.sl<FitossanitarioHiveRepository>();

    return DiagnosticosPragaState.initial();
  }

  /// Carrega diagnósticos para uma praga específica por ID e nome
  Future<void> loadDiagnosticos(String pragaId, {String? pragaName}) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final result = await _diagnosticosRepository.getByPraga(pragaId);

      await result.fold(
        (failure) async {
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao carregar diagnósticos: ${failure.toString()}',
              diagnosticos: [],
            ),
          );
        },
        (diagnosticosEntities) async {
          // Converte entidades para o modelo usado na UI
          final diagnosticosList = <DiagnosticoModel>[];

          for (final entity in diagnosticosEntities) {
            // SEMPRE resolver nome da cultura usando fkIdCultura
            String culturaNome = 'Não especificado';
            if (entity.idCultura.isNotEmpty) {
              culturaNome = await _resolveCulturaNome(entity.idCultura);
            }

            // SEMPRE resolver nome da praga usando fkIdPraga
            String pragaNome = pragaName ?? '';
            if (pragaNome.isEmpty && entity.idPraga.isNotEmpty) {
              pragaNome = await _resolvePragaNome(entity.idPraga);
            }
            if (pragaNome.isEmpty) {
              pragaNome = 'Praga não identificada';
            }

            // SEMPRE resolver nome do defensivo usando fkIdDefensivo
            String defensivoNome = '';
            if (entity.idDefensivo.isNotEmpty) {
              defensivoNome = await _resolveDefensivoNome(entity.idDefensivo);
            }
            if (defensivoNome.isEmpty) {
              defensivoNome = 'Defensivo não especificado';
            }

            diagnosticosList.add(
              DiagnosticoModel(
                id: entity.id,
                nome: defensivoNome,
                ingredienteAtivo: entity.idDefensivo,
                dosagem: entity.dosagem.displayDosagem,
                cultura: culturaNome,
                grupo: pragaNome,
              ),
            );
          }

          state = AsyncValue.data(
            currentState.copyWith(isLoading: false, diagnosticos: diagnosticosList).clearError(),
          );
        },
      );
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar diagnósticos: $e',
          diagnosticos: [],
        ),
      );
    }
  }

  /// Resolve o nome da cultura pelo ID usando o repository
  Future<String> _resolveCulturaNome(String idCultura) async {
    try {
      final culturaData = await _culturaRepository.getById(idCultura);
      if (culturaData != null && culturaData.cultura.isNotEmpty) {
        return culturaData.cultura;
      }
    } catch (e) {
      // Error logged internally
    }
    return 'Não especificado';
  }

  /// Resolve o nome da praga pelo ID usando o repository
  Future<String> _resolvePragaNome(String idPraga) async {
    try {
      final pragaData = await _pragasRepository.getById(idPraga);
      if (pragaData != null && pragaData.nomeComum.isNotEmpty) {
        return pragaData.nomeComum;
      }
    } catch (e) {
      // Error logged internally
    }
    return '';
  }

  /// Resolve o nome do defensivo pelo ID usando o repository
  Future<String> _resolveDefensivoNome(String idDefensivo) async {
    try {
      final defensivoData = await _defensivoRepository.getById(idDefensivo);
      if (defensivoData != null && defensivoData.nomeComum.isNotEmpty) {
        return defensivoData.nomeComum;
      }
    } catch (e) {
      // Error logged internally
    }
    return '';
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoadingFilters: true,
      ),
    );

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: query,
        isLoadingFilters: false,
      ),
    );
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        isLoadingFilters: true,
      ),
    );

    state = AsyncValue.data(
      currentState.copyWith(
        selectedCultura: cultura,
        isLoadingFilters: false,
      ),
    );
  }

  /// Obtém dados do defensivo por nome (mock implementation)
  Map<String, dynamic>? getDefensivoData(String nome) {
    return {
      'fabricante': 'Fabricante Desconhecido',
      'registro': 'Registro não disponível',
    };
  }

  /// Limpa filtros
  void clearFilters() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        searchQuery: '',
        selectedCultura: 'Todas',
      ),
    );
  }

  /// Limpa mensagem de erro
  void clearError() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.clearError());
  }

  /// Limpa dados em memória para otimização
  void clearData() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      DiagnosticosPragaState.initial(),
    );
  }
}
