// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../model/medicoes_page_model.dart';
import '../services/data_service.dart';
import '../services/formatting_service.dart';
import '../services/pluviometro_state_service.dart';
import '../services/state_service.dart';
import '../services/statistics_service.dart';

/// Controller refatorado com responsabilidades bem definidas
class MedicoesPageController {
  late final DataService _dataService;
  late final StatisticsService _statisticsService;
  late final FormattingService _formattingService;
  late final StateService _stateService;
  late final PluviometroStateService _pluviometroStateService;

  MedicoesPageController({
    DataService? dataService,
    StatisticsService? statisticsService,
    FormattingService? formattingService,
    StateService? stateService,
    PluviometroStateService? pluviometroStateService,
  }) {
    _dataService = dataService ?? DataService();
    _statisticsService = statisticsService ?? StatisticsService();
    _formattingService = formattingService ?? FormattingService();
    _stateService = stateService ?? StateService();
    _pluviometroStateService =
        pluviometroStateService ?? PluviometroStateService();
  }

  // Getters para acesso ao estado
  MedicoesPageState get state => _stateService.state;
  StateService get stateService => _stateService;

  /// Inicializa dados da página
  Future<void> initializeData() async {
    try {
      _stateService.setLoading(true);
      _stateService.clearError();

      // Aguarda inicialização do pluviômetro state
      final isInitialized =
          await _pluviometroStateService.waitForInitialization();
      if (!isInitialized) {
        throw Exception('Falha na inicialização do sistema de pluviômetros');
      }

      // Carrega pluviômetros
      await loadPluviometros();

      // Carrega medições se há pluviômetro selecionado
      final selectedId = _pluviometroStateService.getSelectedPluviometroId();
      if (selectedId != null) {
        _stateService.setSelectedPluviometro(selectedId);
        await loadMedicoes(selectedId);
      }
    } catch (e) {
      _handleError('Erro ao inicializar dados', e);
    } finally {
      _stateService.setLoading(false);
    }
  }

  /// Carrega lista de pluviômetros
  Future<void> loadPluviometros() async {
    try {
      final pluviometros = await _dataService.getPluviometros();
      _stateService.setPluviometros(pluviometros);
    } catch (e) {
      _handleError('Erro ao carregar pluviômetros', e);
      rethrow;
    }
  }

  /// Carrega medições para um pluviômetro específico
  Future<void> loadMedicoes(String pluviometroId) async {
    try {
      _stateService.setLoading(true);

      if (!_pluviometroStateService.isValidPluviometroId(pluviometroId)) {
        throw ArgumentError('ID de pluviômetro inválido: $pluviometroId');
      }

      final medicoes = await _dataService.getMedicoes(pluviometroId);
      _stateService.setMedicoes(medicoes);
      _stateService.setSelectedPluviometro(pluviometroId);
    } catch (e) {
      _handleError('Erro ao carregar medições', e);
      rethrow;
    } finally {
      _stateService.setLoading(false);
    }
  }

  /// Recarrega dados quando pluviômetro é alterado
  Future<void> onPluviometroChanged(String pluviometroId) async {
    await loadMedicoes(pluviometroId);
  }

  /// Obtém lista de meses das medições
  List<DateTime> getMonthsList() {
    return _dataService.getMonthsList(state.medicoes);
  }

  /// Obtém medições de um mês específico
  List<Medicoes> getMedicoesDoMes(DateTime date) {
    return _dataService.getMedicoesDoMes(state.medicoes, date);
  }

  /// Calcula estatísticas de um mês
  MonthStatistics calculateMonthStatistics(
      DateTime date, List<Medicoes> medicoesDoMes) {
    return _statisticsService.calculateMonthStatistics(date, medicoesDoMes);
  }

  /// Encontra medição para uma data específica
  Medicoes findMedicaoForDate(
      List<Medicoes> medicoesDoMes, DateTime currentDate) {
    return _dataService.findMedicaoForDate(medicoesDoMes, currentDate);
  }

  /// Formata dia da semana
  String formatWeekDay(DateTime date) {
    return _formattingService.formatWeekDay(date);
  }

  /// Gera lista de dias do mês formatados
  List<String> generateDaysOfMonthList() {
    return _formattingService.generateFormattedDaysOfMonth();
  }

  /// Atualiza índice do carousel
  void setCarouselIndex(int index) {
    _stateService.setCarouselIndex(index);
  }

  /// Obtém ID do pluviômetro selecionado de forma segura
  String? getSelectedPluviometroId() {
    return _pluviometroStateService.getSelectedPluviometroId();
  }

  /// Trata erros de forma centralizada
  void _handleError(String context, dynamic error) {
    final errorMessage = '$context: ${error.toString()}';
    _stateService.setError(errorMessage);

    // Log para debugging
    if (kDebugMode) {
      debugPrint('MedicoesPageController Error: $errorMessage');
    }
  }

  /// Limpa erro atual
  void clearError() {
    _stateService.clearError();
  }

  /// Verifica se há dados válidos
  bool get hasValidData {
    return state.medicoes.isNotEmpty && !state.hasError;
  }

  /// Verifica se está em estado de carregamento
  bool get isLoading => state.isLoading;

  /// Verifica se há erro
  bool get hasError => state.hasError;

  /// Obtém mensagem de erro atual
  String? get errorMessage => state.errorMessage;

  /// Debug: obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'controller': {
        'hasValidData': hasValidData,
        'isLoading': isLoading,
        'hasError': hasError,
        'errorMessage': errorMessage,
      },
      'state': _stateService.stateDebugInfo,
      'pluviometroState': _pluviometroStateService.getDebugInfo(),
    };
  }

  /// Cleanup quando controller não é mais necessário
  void dispose() {
    _stateService.dispose();
  }
}
