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

/// Estado dos diagnósticos da praga
class DiagnosticosPragaState {
  final List<DiagnosticoModel> diagnosticos;
  final String searchQuery;
  final String selectedCultura;
  final List<String> culturas;
  final bool isLoading;
  final bool isLoadingFilters;
  final String? errorMessage;

  const DiagnosticosPragaState({
    required this.diagnosticos,
    required this.searchQuery,
    required this.selectedCultura,
    required this.culturas,
    required this.isLoading,
    required this.isLoadingFilters,
    this.errorMessage,
  });

  factory DiagnosticosPragaState.initial() {
    return const DiagnosticosPragaState(
      diagnosticos: [],
      searchQuery: '',
      selectedCultura: 'Todas',
      culturas: ['Todas'],
      isLoading: false,
      isLoadingFilters: false,
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
    String? errorMessage,
  }) {
    return DiagnosticosPragaState(
      diagnosticos: diagnosticos ?? this.diagnosticos,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCultura: selectedCultura ?? this.selectedCultura,
      culturas: culturas ?? this.culturas,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DiagnosticosPragaState clearError() => copyWith(errorMessage: null);

  bool get hasData => diagnosticos.isNotEmpty;
  bool get hasError => errorMessage != null;

  /// Diagnósticos filtrados por pesquisa e cultura
  List<DiagnosticoModel> get filteredDiagnosticos {
    return diagnosticos.where((d) {
      final matchesSearch = searchQuery.isEmpty ||
          d.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
          d.ingredienteAtivo.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCulture = selectedCultura == 'Todas' || d.cultura == selectedCultura;

      return matchesSearch && matchesCulture;
    }).toList();
  }

  /// Diagnósticos agrupados por cultura
  Map<String, List<DiagnosticoModel>> get groupedDiagnosticos {
    final grouped = <String, List<DiagnosticoModel>>{};
    for (final d in filteredDiagnosticos) {
      grouped.putIfAbsent(d.cultura, () => []).add(d);
    }
    return grouped;
  }
}

/// Notifier para gerenciar diagnósticos relacionados à praga
/// 
/// Responsabilidade: carregar, filtrar e buscar diagnósticos por praga.
/// Usa keepAlive para manter o estado entre navegações de tabs.
@Riverpod(keepAlive: true)
class DiagnosticosPragaNotifier extends _$DiagnosticosPragaNotifier {
  @override
  Future<DiagnosticosPragaState> build() async {
    return DiagnosticosPragaState.initial();
  }

  /// Verifica se o notifier ainda está ativo
  bool _isMounted() {
    try {
      // ignore: unnecessary_statements
      state;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Carrega diagnósticos para uma praga específica
  Future<void> loadDiagnosticos(String pragaId, {String? pragaName}) async {
    if (!_isMounted()) return;

    final currentState = state.value;
    if (currentState == null) return;

    // Set loading state
    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      final diagnosticosRepository = ref.read(iDiagnosticosRepositoryProvider);
      final result = await diagnosticosRepository.queryByPraga(pragaId);

      if (!_isMounted()) return;

      await result.fold(
        (failure) async {
          if (!_isMounted()) return;
          final freshState = state.value ?? DiagnosticosPragaState.initial();
          state = AsyncValue.data(
            freshState.copyWith(
              isLoading: false,
              errorMessage: 'Erro ao carregar diagnósticos: ${failure.message}',
              diagnosticos: [],
            ),
          );
        },
        (entities) async {
          if (!_isMounted()) return;
          
          final diagnosticosList = <DiagnosticoModel>[];

          for (final entity in entities) {
            if (!_isMounted()) return;
            
            // Resolve nomes das entidades relacionadas
            final culturaNome = entity.idCultura.isNotEmpty
                ? await _resolveCulturaNome(entity.idCultura)
                : 'Não especificado';
            
            var pragaNome = pragaName ?? '';
            if (pragaNome.isEmpty && entity.idPraga.isNotEmpty) {
              pragaNome = await _resolvePragaNome(entity.idPraga);
            }
            pragaNome = pragaNome.isEmpty ? 'Praga não identificada' : pragaNome;
            
            var (defensivoNome, ingredienteAtivo) = ('', 'Não especificado');
            if (entity.idDefensivo.isNotEmpty) {
              (defensivoNome, ingredienteAtivo) = await _resolveDefensivoData(entity.idDefensivo);
            }
            defensivoNome = defensivoNome.isEmpty ? 'Defensivo não especificado' : defensivoNome;

            diagnosticosList.add(
              DiagnosticoModel(
                id: entity.id,
                nome: defensivoNome,
                ingredienteAtivo: ingredienteAtivo,
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

          if (!_isMounted()) return;

          // Extrai culturas únicas dos diagnósticos
          final culturasUnicas = diagnosticosList
              .map((d) => d.cultura)
              .where((c) => c.isNotEmpty && c != 'Não especificado' && c != 'Todas')
              .toSet()
              .toList()
            ..sort();

          final freshState = state.value ?? DiagnosticosPragaState.initial();
          state = AsyncValue.data(
            freshState.copyWith(
              isLoading: false,
              diagnosticos: diagnosticosList,
              culturas: ['Todas', ...culturasUnicas],
            ).clearError(),
          );
        },
      );
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      
      if (kDebugMode) {
        debugPrint('❌ [DIAGNOSTICOS_PRAGA] Erro: $e');
      }
      
      final freshState = state.value ?? DiagnosticosPragaState.initial();
      state = AsyncValue.data(
        freshState.copyWith(
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
  /// 
  /// NOTA: idPraga aqui é na verdade o pragaId (FK int) convertido para string
  Future<String> _resolvePragaNome(String idPraga) async {
    try {
      final pragaIdInt = int.tryParse(idPraga);
      if (pragaIdInt == null) return '';
      
      final pragasRepository = ref.read(pragasRepositoryProvider);
      final pragaData = await pragasRepository.findById(pragaIdInt);
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
      final defensivoIdInt = int.tryParse(idDefensivo);
      if (defensivoIdInt == null) return ('', 'Não especificado');
      
      final defensivoRepository = ref.read(fitossanitariosRepositoryProvider);
      final defensivoData = await defensivoRepository.findById(defensivoIdInt);
      
      if (defensivoData != null) {
        final nome = defensivoData.nome;
        final ingrediente = defensivoData.ingredienteAtivo?.isNotEmpty == true
            ? defensivoData.ingredienteAtivo!
            : 'Não especificado';
        return (nome, ingrediente);
      }
    } catch (e) {
      // Erro silencioso
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
