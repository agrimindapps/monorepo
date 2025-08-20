// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../model/resultados_pluviometro_model.dart';

/// Gerenciador de estado da aplicação
class StateManager extends ChangeNotifier {
  ResultadosPluviometroState _state =
      const ResultadosPluviometroState.notInitialized();

  ResultadosPluviometroState get state => _state;

  /// Atualiza o estado completo
  void updateState(ResultadosPluviometroState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// Atualiza o estado parcialmente usando copyWith
  void updatePartialState({
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
    final newState = _state.copyWith(
      tipoVisualizacao: tipoVisualizacao,
      isSmallScreen: isSmallScreen,
      pluviometroSelecionado: pluviometroSelecionado,
      anoSelecionado: anoSelecionado,
      mesSelecionado: mesSelecionado,
      isLoading: isLoading,
      pluviometros: pluviometros,
      medicoes: medicoes,
      errorMessage: errorMessage,
      initState: initState,
    );

    updateState(newState);
  }

  /// Inicia o processo de inicialização
  void startInitialization() {
    updatePartialState(
      initState: InitializationState.initializing,
      isLoading: true,
      errorMessage: null,
    );
  }

  /// Marca a inicialização como completa
  void completeInitialization() {
    final now = DateTime.now();
    updatePartialState(
      initState: InitializationState.initialized,
      isLoading: false,
      anoSelecionado: now.year,
      mesSelecionado: now.month,
      errorMessage: null,
    );
  }

  /// Marca a inicialização como falhada
  void failInitialization(String errorMessage) {
    updatePartialState(
      initState: InitializationState.failed,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  /// Atualiza o loading state
  void setLoading(bool loading) {
    updatePartialState(isLoading: loading);
  }

  /// Atualiza o pluviômetro selecionado
  void selectPluviometro(Pluviometro? pluviometro) {
    updatePartialState(pluviometroSelecionado: pluviometro);
  }

  /// Atualiza o tipo de visualização
  void setVisualizationType(String tipo) {
    updatePartialState(tipoVisualizacao: tipo);
  }

  /// Atualiza o ano selecionado
  void setSelectedYear(int ano) {
    updatePartialState(anoSelecionado: ano);
  }

  /// Atualiza o mês selecionado
  void setSelectedMonth(int mes) {
    updatePartialState(mesSelecionado: mes);
  }

  /// Atualiza o tamanho da tela
  void setScreenSize(bool isSmallScreen) {
    updatePartialState(isSmallScreen: isSmallScreen);
  }

  /// Atualiza dados de pluviômetros
  void setPluviometros(List<Pluviometro> pluviometros) {
    updatePartialState(pluviometros: pluviometros);
  }

  /// Atualiza dados de medições
  void setMedicoes(List<Medicoes> medicoes) {
    updatePartialState(medicoes: medicoes);
  }

  /// Limpa mensagem de erro
  void clearError() {
    if (_state.errorMessage != null) {
      updatePartialState(errorMessage: null);
    }
  }

  /// Define mensagem de erro
  void setError(String errorMessage) {
    updatePartialState(errorMessage: errorMessage);
  }

  /// Reseta o estado para não inicializado
  void reset() {
    updateState(const ResultadosPluviometroState.notInitialized());
  }

  /// Verifica se o estado atual é válido
  bool get isValidState => _state.isValidState;

  /// Verifica se pode processar dados
  bool get canProcessData => _state.canProcessData;

  /// Verifica se está não inicializado
  bool get isNotInitialized => _state.isNotInitialized;
}
