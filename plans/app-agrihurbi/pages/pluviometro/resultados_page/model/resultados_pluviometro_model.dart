// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../widgets/pluviometria_models.dart';
import '../widgets/pluviometria_service.dart';

/// Estados de inicialização para controle fino do estado
enum InitializationState {
  notInitialized,
  initializing,
  initialized,
  failed,
}

class ResultadosPluviometroState {
  final String tipoVisualizacao;
  final bool isSmallScreen;
  final Pluviometro? pluviometroSelecionado;
  final int anoSelecionado;
  final int mesSelecionado;
  final bool isLoading;
  final List<Pluviometro> pluviometros;
  final List<Medicoes> medicoes;
  final String? errorMessage;
  final InitializationState initState;

  ResultadosPluviometroState({
    this.tipoVisualizacao = 'Ano',
    this.isSmallScreen = true,
    this.pluviometroSelecionado,
    int? anoSelecionado,
    int? mesSelecionado,
    this.isLoading = false,
    this.pluviometros = const [],
    this.medicoes = const [],
    this.errorMessage,
    this.initState = InitializationState.notInitialized,
  })  : anoSelecionado = anoSelecionado ?? _getDefaultYear(),
        mesSelecionado = mesSelecionado ?? _getDefaultMonth();

  /// Construtor nomeado para criar estado não inicializado
  const ResultadosPluviometroState.notInitialized()
      : tipoVisualizacao = 'Ano',
        isSmallScreen = true,
        pluviometroSelecionado = null,
        anoSelecionado = -1, // Valor especial para indicar não inicializado
        mesSelecionado = -1, // Valor especial para indicar não inicializado
        isLoading = false,
        pluviometros = const [],
        medicoes = const [],
        errorMessage = null,
        initState = InitializationState.notInitialized;

  /// Construtor nomeado para criar estado inicializando
  ResultadosPluviometroState.initializing()
      : tipoVisualizacao = 'Ano',
        isSmallScreen = true,
        pluviometroSelecionado = null,
        anoSelecionado = _getDefaultYear(),
        mesSelecionado = _getDefaultMonth(),
        isLoading = true,
        pluviometros = const [],
        medicoes = const [],
        errorMessage = null,
        initState = InitializationState.initializing;

  /// Obtém ano padrão baseado na data atual
  static int _getDefaultYear() => DateTime.now().year;

  /// Obtém mês padrão baseado na data atual
  static int _getDefaultMonth() => DateTime.now().month;

  /// Verifica se o estado está devidamente inicializado
  bool get isValidState {
    return initState == InitializationState.initialized &&
        anoSelecionado > 0 &&
        mesSelecionado > 0 &&
        mesSelecionado <= 12;
  }

  /// Verifica se está em estado não inicializado
  bool get isNotInitialized => initState == InitializationState.notInitialized;

  /// Verifica se pode processar dados de forma segura
  bool get canProcessData {
    return isValidState &&
        anoSelecionado >= 1900 &&
        anoSelecionado <= DateTime.now().year + 10;
  }

  /// Obtém valores seguros para processamento (fallback para valores atuais)
  int get safeAnoSelecionado =>
      (anoSelecionado > 0) ? anoSelecionado : DateTime.now().year;

  int get safeMesSelecionado => (mesSelecionado > 0 && mesSelecionado <= 12)
      ? mesSelecionado
      : DateTime.now().month;

  ResultadosPluviometroState copyWith({
    String? tipoVisualizacao,
    bool? isSmallScreen,
    Pluviometro? pluviometroSelecionado,
    int? anoSelecionado,
    int? mesSelecionado,
    bool? isLoading,
    List<Pluviometro>? pluviometros,
    List<Medicoes>? medicoes,
    String? errorMessage,
    InitializationState? initState,
  }) {
    return ResultadosPluviometroState(
      tipoVisualizacao: tipoVisualizacao ?? this.tipoVisualizacao,
      isSmallScreen: isSmallScreen ?? this.isSmallScreen,
      pluviometroSelecionado:
          pluviometroSelecionado ?? this.pluviometroSelecionado,
      anoSelecionado: anoSelecionado ?? this.anoSelecionado,
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      isLoading: isLoading ?? this.isLoading,
      pluviometros: pluviometros ?? this.pluviometros,
      medicoes: medicoes ?? this.medicoes,
      errorMessage: errorMessage ?? this.errorMessage,
      initState: initState ?? this.initState,
    );
  }

  // Dados processados com validação de estado
  List<DadoPluviometrico> get dadosPorPeriodo {
    if (!canProcessData) {
      return []; // Retorna lista vazia se estado não for válido
    }

    return tipoVisualizacao == 'Ano'
        ? PluviometriaService.processarDadosAnuais(medicoes, safeAnoSelecionado)
        : PluviometriaService.processarDadosMensais(
            medicoes, safeAnoSelecionado, safeMesSelecionado);
  }

  List<DadoComparativo> get dadosComparativos {
    if (!canProcessData) {
      return []; // Retorna lista vazia se estado não for válido
    }

    return PluviometriaService.processarDadosComparativos(
        medicoes, safeAnoSelecionado, tipoVisualizacao, safeMesSelecionado);
  }

  EstatisticasPluviometria get estatisticas {
    if (!canProcessData) {
      return EstatisticasPluviometria(); // Retorna estatísticas vazias se estado não for válido
    }

    return PluviometriaService.calcularEstatisticas(
        medicoes, tipoVisualizacao, safeAnoSelecionado, safeMesSelecionado);
  }

  String get tituloAnalise {
    if (isNotInitialized) {
      return 'Carregando análise...';
    }

    if (!isValidState) {
      return 'Estado inválido - aguarde inicialização';
    }

    return tipoVisualizacao == 'Ano'
        ? 'Análise Anual de $safeAnoSelecionado'
        : 'Análise de ${obterNomeMes(safeMesSelecionado)} de $safeAnoSelecionado';
  }

  String obterNomeMes(int mes) =>
      mes >= 1 && mes <= 12 ? mesesCompletos[mes - 1] : '';
}
