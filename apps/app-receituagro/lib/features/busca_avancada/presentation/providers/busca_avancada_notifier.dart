import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/repositories/cultura_hive_repository.dart';
import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/diagnostico_integration_service.dart';

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
      defensivoIdSelecionado: defensivoIdSelecionado ?? this.defensivoIdSelecionado,
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

  // Estado computado
  bool get temFiltrosAtivos =>
      culturaIdSelecionada != null || pragaIdSelecionada != null || defensivoIdSelecionado != null;

  bool get temResultados => resultados.isNotEmpty;

  String get filtrosAtivosTexto {
    final filtros = <String>[];
    if (culturaIdSelecionada != null) filtros.add('Cultura');
    if (pragaIdSelecionada != null) filtros.add('Praga');
    if (defensivoIdSelecionado != null) filtros.add('Defensivo');
    return filtros.join(', ');
  }

  Map<String, String> get filtrosDetalhados {
    final filtros = <String, String>{};

    if (culturaIdSelecionada != null) {
      final cultura = culturas.firstWhere(
        (c) => c['id'] == culturaIdSelecionada,
        orElse: () => {'nome': 'Desconhecida'},
      );
      filtros['Cultura'] = cultura['nome']!;
    }

    if (pragaIdSelecionada != null) {
      final praga = pragas.firstWhere(
        (p) => p['id'] == pragaIdSelecionada,
        orElse: () => {'nome': 'Desconhecida'},
      );
      filtros['Praga'] = praga['nome']!;
    }

    if (defensivoIdSelecionado != null) {
      final defensivo = defensivos.firstWhere(
        (d) => d['id'] == defensivoIdSelecionado,
        orElse: () => {'nome': 'Desconhecido'},
      );
      filtros['Defensivo'] = defensivo['nome']!;
    }

    return filtros;
  }
}

/// Provider especializado para gerenciar estado complexo da busca avançada (Presentation Layer)
/// Princípios: Single Responsibility + Dependency Inversion
@riverpod
class BuscaAvancadaNotifier extends _$BuscaAvancadaNotifier {
  late final DiagnosticoIntegrationService _integrationService;
  late final CulturaHiveRepository _culturaRepo;
  late final PragasHiveRepository _pragasRepo;
  late final FitossanitarioHiveRepository _fitossanitarioRepo;

  @override
  Future<BuscaAvancadaState> build() async {
    // Get dependencies from DI
    _integrationService = di.sl<DiagnosticoIntegrationService>();
    _culturaRepo = di.sl<CulturaHiveRepository>();
    _pragasRepo = di.sl<PragasHiveRepository>();
    _fitossanitarioRepo = di.sl<FitossanitarioHiveRepository>();

    return BuscaAvancadaState.initial();
  }

  /// Carrega dados iniciais dos dropdowns
  Future<void> carregarDadosDropdowns() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.dadosCarregados) return;

    try {
      List<Map<String, String>> culturas = [];
      List<Map<String, String>> pragas = [];
      List<Map<String, String>> defensivos = [];

      // Carregar culturas
      final culturasResult = await _culturaRepo.getAll();
      culturasResult.fold(
        (error) {
          // Erro ao carregar culturas
        },
        (culturasData) {
          culturas = culturasData
              .map((c) => {
                    'id': c.idReg,
                    'nome': c.cultura,
                  })
              .toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));
        },
      );

      // Carregar pragas
      final pragasResult = await _pragasRepo.getAll();
      pragasResult.fold(
        (error) {
          // Erro ao carregar pragas
        },
        (pragasData) {
          pragas = pragasData
              .map((p) => {
                    'id': p.idReg,
                    'nome': p.nomeComum.isNotEmpty ? p.nomeComum : p.nomeCientifico,
                  })
              .toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));
        },
      );

      // Carregar defensivos
      final defensivosResult = await _fitossanitarioRepo.getAll();
      defensivosResult.fold(
        (error) {
          // Erro ao carregar defensivos
        },
        (defensivosData) {
          defensivos = defensivosData
              .map((d) => {
                    'id': d.idReg,
                    'nome': d.nomeComum.isNotEmpty ? d.nomeComum : d.nomeTecnico,
                  })
              .toList()
            ..sort((a, b) => a['nome']!.compareTo(b['nome']!));
        },
      );

      state = AsyncValue.data(
        currentState.copyWith(
          culturas: culturas,
          pragas: pragas,
          defensivos: defensivos,
          dadosCarregados: true,
        ),
      );
    } catch (e) {
      // Erro ao carregar dados dos dropdowns
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
      state = AsyncValue.data(currentState.copyWith(defensivoIdSelecionado: id));
    }
  }

  /// Realiza busca com filtros atuais
  Future<String?> realizarBusca() async {
    final currentState = state.value;
    if (currentState == null) return 'Estado não inicializado';

    if (!currentState.temFiltrosAtivos) {
      return 'Selecione pelo menos um filtro para realizar a busca';
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

  /// Limpa todos os filtros e resultados
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

    // Limpar cache do serviço
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
}
