// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/pluviometros_models.dart';
import '../interfaces/repository_interface.dart';
import '../interfaces/service_interface.dart';
import '../managers/data_coordinator.dart';
import '../managers/state_manager.dart';
import '../managers/ui_notifier.dart';
import '../model/resultados_pluviometro_model.dart';

/// Controller facade que coordena os diferentes managers
/// Mantém compatibilidade com código existente
class ResultadosPluviometroController extends ChangeNotifier {
  late final StateManager _stateManager;
  late final DataCoordinator _dataCoordinator;
  late final UINotifier _uiNotifier;

  ResultadosPluviometroController({
    IResultadosPluviometroRepository? repository,
    IValidationService? validationService,
  }) {
    _stateManager = StateManager();
    _dataCoordinator = DataCoordinator(
      stateManager: _stateManager,
      repository: repository,
      validationService: validationService,
    );
    _uiNotifier = UINotifier(stateManager: _stateManager);

    // Configurar listeners
    _stateManager.addListener(notifyListeners);
    _uiNotifier.addListener(notifyListeners);
  }

  // Getters para manter compatibilidade
  ResultadosPluviometroState get state => _stateManager.state;
  List<UINotification> get notifications => _uiNotifier.notifications;

  // Delegar métodos para os managers apropriados

  void updateScreenSize(bool isSmallScreen) {
    _stateManager.setScreenSize(isSmallScreen);
  }

  void selecionarPluviometro(Pluviometro? pluviometro) {
    _stateManager.selectPluviometro(pluviometro);

    if (pluviometro != null) {
      carregarMedicoes(pluviometro.id);
    }
  }

  void alterarTipoVisualizacao(String tipo) {
    _stateManager.setVisualizationType(tipo);
  }

  void alterarAno(int ano) {
    _stateManager.setSelectedYear(ano);
  }

  void alterarMes(int mes) {
    _stateManager.setSelectedMonth(mes);
  }

  Future<void> carregarDadosIniciais() async {
    await _dataCoordinator.loadInitialData();
  }

  Future<void> carregarMedicoes(String pluviometroId) async {
    await _dataCoordinator.loadMedicoes(pluviometroId);
  }

  Future<void> carregarMedicoesPorPeriodo(
    String pluviometroId,
    DateTime inicio,
    DateTime fim,
  ) async {
    await _dataCoordinator.loadMedicoesPorPeriodo(pluviometroId, inicio, fim);
  }

  Future<Map<String, dynamic>> carregarEstatisticasBasicas(
      String pluviometroId) async {
    return await _dataCoordinator.loadEstatisticasBasicas(pluviometroId);
  }

  void clearError() {
    _stateManager.clearError();
  }

  // Métodos para UINotifier
  void notifySuccess(String message,
      {String? actionLabel, VoidCallback? action}) {
    _uiNotifier.notifySuccess(message,
        actionLabel: actionLabel, action: action);
  }

  void notifyError(String message,
      {String? actionLabel, VoidCallback? action}) {
    _uiNotifier.notifyError(message, actionLabel: actionLabel, action: action);
  }

  void notifyWarning(String message,
      {String? actionLabel, VoidCallback? action}) {
    _uiNotifier.notifyWarning(message,
        actionLabel: actionLabel, action: action);
  }

  void notifyInfo(String message, {String? actionLabel, VoidCallback? action}) {
    _uiNotifier.notifyInfo(message, actionLabel: actionLabel, action: action);
  }

  void clearNotifications() {
    _uiNotifier.clearAllNotifications();
  }

  // Métodos utilitários
  Future<void> reloadData() async {
    await _dataCoordinator.reloadData();
  }

  Map<String, dynamic> getDataSummary() {
    return _dataCoordinator.getDataSummary();
  }

  @override
  void dispose() {
    _stateManager.dispose();
    _uiNotifier.dispose();
    super.dispose();
  }
}
