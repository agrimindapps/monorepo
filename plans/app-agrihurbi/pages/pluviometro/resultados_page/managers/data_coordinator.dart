// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/medicoes_models.dart';
import '../../../../models/pluviometros_models.dart';
import '../dependency_injection/service_locator.dart';
import '../interfaces/repository_interface.dart';
import '../interfaces/service_interface.dart';
import '../services/error_handler_service.dart';
import 'state_manager.dart';

/// Coordenador para orquestrar carregamento de dados
class DataCoordinator {
  final IResultadosPluviometroRepository _repository;
  final IValidationService _validationService;
  final StateManager _stateManager;

  DataCoordinator({
    required StateManager stateManager,
    IResultadosPluviometroRepository? repository,
    IValidationService? validationService,
  })  : _stateManager = stateManager,
        _repository = repository ??
            ServiceLocator.instance.get<IResultadosPluviometroRepository>(),
        _validationService = validationService ??
            ServiceLocator.instance.get<IValidationService>();

  /// Carrega dados iniciais da aplicação
  Future<void> loadInitialData() async {
    _stateManager.startInitialization();

    try {
      final dados = await _repository.carregarDadosCompletos();

      final pluviometros = dados['pluviometros'] as List<Pluviometro>;
      final medicoes = dados['medicoes'] as List<Medicoes>;

      // Validar dados carregados
      await _validateLoadedData(medicoes);

      // Atualizar estado com dados carregados
      _stateManager.updatePartialState(
        pluviometros: pluviometros,
        medicoes: medicoes,
        pluviometroSelecionado: dados['pluviometroSelecionado'] as Pluviometro?,
      );

      _stateManager.completeInitialization();

      debugPrint(
          'Dados iniciais carregados com sucesso: ${pluviometros.length} pluviômetros, ${medicoes.length} medições');
    } catch (e, stackTrace) {
      final structuredError =
          ErrorHandlerService.instance.handleError(e, stackTrace);
      _stateManager.failInitialization(structuredError.userMessage);
      rethrow;
    }
  }

  /// Carrega medições para um pluviômetro específico
  Future<void> loadMedicoes(String pluviometroId) async {
    _stateManager.setLoading(true);

    try {
      final medicoes = await _repository.carregarMedicoes(pluviometroId);

      // Validar medições carregadas
      await _validateLoadedData(medicoes);

      _stateManager.setMedicoes(medicoes);
      _stateManager.clearError();

      debugPrint(
          'Medições carregadas para pluviômetro $pluviometroId: ${medicoes.length} registros');
    } catch (e, stackTrace) {
      final structuredError =
          ErrorHandlerService.instance.handleError(e, stackTrace);
      _stateManager.setError(structuredError.userMessage);
      rethrow;
    } finally {
      _stateManager.setLoading(false);
    }
  }

  /// Carrega medições por período
  Future<void> loadMedicoesPorPeriodo(
    String pluviometroId,
    DateTime inicio,
    DateTime fim,
  ) async {
    _stateManager.setLoading(true);

    try {
      final medicoes = await _repository.carregarMedicoesPorPeriodo(
        pluviometroId,
        inicio,
        fim,
      );

      await _validateLoadedData(medicoes);

      _stateManager.setMedicoes(medicoes);
      _stateManager.clearError();

      debugPrint(
          'Medições por período carregadas: ${medicoes.length} registros');
    } catch (e, stackTrace) {
      final structuredError =
          ErrorHandlerService.instance.handleError(e, stackTrace);
      _stateManager.setError(structuredError.userMessage);
      rethrow;
    } finally {
      _stateManager.setLoading(false);
    }
  }

  /// Carrega estatísticas básicas
  Future<Map<String, dynamic>> loadEstatisticasBasicas(
      String pluviometroId) async {
    try {
      final estatisticas =
          await _repository.carregarEstatisticasBasicas(pluviometroId);

      debugPrint('Estatísticas básicas carregadas para $pluviometroId');

      return estatisticas;
    } catch (e, stackTrace) {
      final structuredError =
          ErrorHandlerService.instance.handleError(e, stackTrace);
      debugPrint(
          'Erro ao carregar estatísticas básicas: ${structuredError.userMessage}');
      rethrow;
    }
  }

  /// Recarrega dados completos
  Future<void> reloadData() async {
    debugPrint('Recarregando dados...');
    await loadInitialData();
  }

  /// Recarrega dados se necessário
  Future<void> reloadIfNeeded() async {
    if (!_stateManager.isValidState ||
        _stateManager.state.pluviometros.isEmpty) {
      debugPrint('Estado inválido detectado, recarregando dados...');
      await reloadData();
    }
  }

  /// Valida dados carregados
  Future<void> _validateLoadedData(List<Medicoes> medicoes) async {
    if (medicoes.isNotEmpty) {
      final now = DateTime.now();
      final validationResult = _validationService.validateAndSanitizeInput(
        medicoes: medicoes,
        ano: now.year,
        mes: now.month,
      );

      if (!validationResult['isValid']) {
        final errors = validationResult['errors'] as List<String>;
        debugPrint(
            'Problemas encontrados nos dados carregados: ${errors.join(', ')}');

        // Se há erros críticos, falhar
        if (errors.any(
            (error) => error.contains('crítico') || error.contains('fatal'))) {
          throw Exception(
              'Dados carregados contêm erros críticos: ${errors.join(', ')}');
        }
      }

      if (validationResult['warnings'] != null) {
        final warnings = validationResult['warnings'] as List<String>;
        if (warnings.isNotEmpty) {
          debugPrint('Avisos nos dados carregados: ${warnings.join(', ')}');
        }
      }
    }
  }

  /// Limpa dados em cache
  Future<void> clearCache() async {
    debugPrint('Limpando cache de dados...');
    _stateManager.reset();
  }

  /// Obtém resumo dos dados carregados
  Map<String, dynamic> getDataSummary() {
    final state = _stateManager.state;

    return {
      'pluviometros_count': state.pluviometros.length,
      'medicoes_count': state.medicoes.length,
      'pluviometro_selecionado': state.pluviometroSelecionado?.id,
      'periodo_selecionado': {
        'ano': state.safeAnoSelecionado,
        'mes': state.safeMesSelecionado,
        'tipo': state.tipoVisualizacao,
      },
      'estado_inicializacao': state.initState.toString(),
      'pode_processar_dados': state.canProcessData,
    };
  }
}
