import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pragas_providers.dart';

part 'diagnosticos_praga_notifier.g.dart';

/// Model para diagnóstico usado na UI
class DiagnosticoModel {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String dosagem;
  final String cultura;
  final String grupo;
  final String defensivoId;
  final String aplicacaoTerrestre;
  final String aplicacaoAerea;
  final String intervaloSeguranca;

  const DiagnosticoModel({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    required this.dosagem,
    required this.cultura,
    required this.grupo,
    this.defensivoId = '',
    this.aplicacaoTerrestre = '',
    this.aplicacaoAerea = '',
    this.intervaloSeguranca = '',
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

  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasError => errorMessage != null;

  List<DiagnosticoModel> get filteredDiagnosticos {
    return diagnosticos.where((diagnostic) {
      bool matchesSearch =
          searchQuery.isEmpty ||
          diagnostic.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
          diagnostic.ingredienteAtivo.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      bool matchesCulture =
          selectedCultura == 'Todas' || diagnostic.cultura == selectedCultura;

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
///
/// IMPORTANTE: keepAlive mantém o state mesmo quando não há listeners
/// Isso previne perda de dados ao navegar entre tabs ou fazer rebuilds temporários
@riverpod
class DiagnosticosPragaNotifier extends _$DiagnosticosPragaNotifier {
  @override
  Future<DiagnosticosPragaState> build() async {
    return DiagnosticosPragaState.initial();
  }

  /// Carrega diagnósticos para uma praga específica por ID e nome
  Future<void> loadDiagnosticos(String pragaId, {String? pragaName}) async {
    debugPrint('🔍 [DIAGNOSTICOS_PRAGA] loadDiagnosticos - pragaId: $pragaId, pragaName: $pragaName');
    
    final currentState = state.value;
    if (currentState == null) {
      debugPrint('⚠️ [DIAGNOSTICOS_PRAGA] currentState is null, returning');
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoading: true).clearError(),
    );

    try {
      // Use queryByPraga instead of deprecated getByPraga
      final diagnosticosRepository = ref.read(iDiagnosticosRepositoryProvider);
      debugPrint('🔍 [DIAGNOSTICOS_PRAGA] Chamando queryByPraga com pragaId: $pragaId');
      final result = await diagnosticosRepository.queryByPraga(pragaId);

      await result.fold(
        (failure) async {
          debugPrint('❌ [DIAGNOSTICOS_PRAGA] Erro: ${failure.toString()}');
          state = AsyncValue.data(
            currentState.copyWith(
              isLoading: false,
              errorMessage:
                  'Erro ao carregar diagnósticos: ${failure.toString()}',
              diagnosticos: [],
            ),
          );
        },
        (diagnosticosEntities) async {
          debugPrint('✅ [DIAGNOSTICOS_PRAGA] ${diagnosticosEntities.length} diagnósticos encontrados');
          final diagnosticosList = <DiagnosticoModel>[];

          for (final entity in diagnosticosEntities) {
            String culturaNome = 'Não especificado';
            if (entity.idCultura.isNotEmpty) {
              culturaNome = await _resolveCulturaNome(entity.idCultura);
            }
            String pragaNome = pragaName ?? '';
            if (pragaNome.isEmpty && entity.idPraga.isNotEmpty) {
              pragaNome = await _resolvePragaNome(entity.idPraga);
            }
            if (pragaNome.isEmpty) {
              pragaNome = 'Praga não identificada';
            }
            String defensivoNome = '';
            String ingredienteAtivo = 'Não especificado';
            if (entity.idDefensivo.isNotEmpty) {
              final defensivoData = await _resolveDefensivoData(
                entity.idDefensivo,
              );
              defensivoNome = defensivoData.$1; // Nome
              ingredienteAtivo = defensivoData.$2; // Ingrediente ativo
            }
            if (defensivoNome.isEmpty) {
              defensivoNome = 'Defensivo não especificado';
            }

            diagnosticosList.add(
              DiagnosticoModel(
                id: entity.id,
                nome: defensivoNome,
                ingredienteAtivo:
                    ingredienteAtivo, // Agora usa ingrediente ativo real
                dosagem: entity.dosagem.displayDosagem,
                cultura: culturaNome,
                grupo: pragaNome,
                defensivoId: entity.idDefensivo,
                aplicacaoTerrestre: entity.aplicacao.terrestre?.displayVolume ?? '',
                aplicacaoAerea: entity.aplicacao.aerea?.displayVolume ?? '',
                intervaloSeguranca: entity.aplicacao.intervaloReaplicacao ?? '',
              ),
            );
          }

          // CORREÇÃO: Extrair culturas únicas dos diagnósticos carregados
          // ao invés de usar lista hard-coded
          final culturasUnicas =
              diagnosticosList
                  .map((d) => d.cultura)
                  .where(
                    (c) =>
                        c.isNotEmpty && c != 'Não especificado' && c != 'Todas',
                  )
                  .toSet()
                  .toList()
                ..sort();

          // Adiciona "Todas" no início, garantindo sem duplicatas
          final culturasComTodas = ['Todas', ...culturasUnicas];

          state = AsyncValue.data(
            currentState
                .copyWith(
                  isLoading: false,
                  diagnosticos: diagnosticosList,
                  culturas: culturasComTodas, // Atualiza com culturas dinâmicas
                )
                .clearError(),
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
      final idCulturaInt = int.tryParse(idCultura);
      if (idCulturaInt == null) return 'Não especificado';

      final culturaRepository = ref.read(culturasRepositoryProvider);
      final culturaData = await culturaRepository.findById(idCulturaInt);
      if (culturaData != null && culturaData.nome.isNotEmpty) {
        return culturaData.nome;
      }
    } catch (e) {
      // Erro ao buscar cultura, retorna valor padrão
    }
    return 'Não especificado';
  }

  /// Resolve o nome da praga pelo ID usando o repository
  Future<String> _resolvePragaNome(String idPraga) async {
    try {
      final pragasRepository = ref.read(pragasRepositoryProvider);
      final pragaData = await pragasRepository.findByIdPraga(idPraga);
      if (pragaData != null && pragaData.nome.isNotEmpty) {
        return pragaData.nome;
      }
    } catch (e) {
      // Erro ao buscar praga, retorna valor padrão
    }
    return '';
  }

  /// Resolve o nome e ingrediente ativo do defensivo pelo ID
  /// Retorna (nome, ingredienteAtivo)
  Future<(String, String)> _resolveDefensivoData(String idDefensivo) async {
    try {
      final defensivoRepository = ref.read(fitossanitariosRepositoryProvider);
      final defensivoData = await defensivoRepository.findByIdDefensivo(
        idDefensivo,
      );
      if (defensivoData != null) {
        final nome = defensivoData.nome;
        final ingrediente = defensivoData.ingredienteAtivo?.isNotEmpty == true
            ? defensivoData.ingredienteAtivo!
            : 'Não especificado';
        return (nome, ingrediente);
      }
    } catch (e) {
      // Erro ao buscar defensivo, retorna valores padrão
    }
    return ('', 'Não especificado');
  }

  /// Atualiza query de pesquisa
  void updateSearchQuery(String query) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingFilters: true));

    state = AsyncValue.data(
      currentState.copyWith(searchQuery: query, isLoadingFilters: false),
    );
  }

  /// Atualiza cultura selecionada
  void updateSelectedCultura(String cultura) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingFilters: true));

    state = AsyncValue.data(
      currentState.copyWith(selectedCultura: cultura, isLoadingFilters: false),
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
      currentState.copyWith(searchQuery: '', selectedCultura: 'Todas'),
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

    state = AsyncValue.data(DiagnosticosPragaState.initial());
  }
}
