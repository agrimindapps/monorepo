// Package imports:
import 'package:logging/logging.dart';

import '../../repository/espaco_repository.dart';
import '../../repository/planta_config_repository.dart';
import '../../repository/planta_repository.dart';
import '../../repository/tarefa_repository.dart';
import '../../services/domain/tasks/simple_task_service.dart';
import '../../services/shared/interfaces/i_task_service.dart';
// Project imports:
import '../di/enhanced_service_locator.dart';
import '../events/domain_event.dart';
import '../events/domain_events.dart';
import '../events/event_bus.dart';
import '../interfaces/i_espaco_repository.dart';
import '../interfaces/i_planta_config_repository.dart';
import '../interfaces/i_planta_repository.dart';
import '../interfaces/i_tarefa_repository.dart';

/// Configuração centralizada de dependências para resolver dependências circulares
///
/// Esta classe implementa a solução para Issue #16:
/// - Mapeia todas dependências entre repositories e services
/// - Implementa dependency injection para quebrar acoplamentos
/// - Cria interfaces para abstrair dependências
/// - Usa event bus para comunicação desacoplada
class DependencyConfiguration {
  static DependencyConfiguration? _instance;
  static DependencyConfiguration get instance =>
      _instance ??= DependencyConfiguration._();

  DependencyConfiguration._();

  bool _isConfigured = false;

  /// Configura todas as dependências para ambiente de produção
  Future<void> configureForProduction() async {
    if (_isConfigured) return;

    final serviceLocator = EnhancedServiceLocator.instance;
    final eventBus = EventBus.instance;

    // Limpar configurações anteriores
    serviceLocator.clear();

    // 1. REGISTRAR REPOSITORIES COM INTERFACES
    // Isso quebra dependências circulares permitindo injection de abstrações

    serviceLocator.register<IEspacoRepository>(
      factory: () => EspacoRepository.instance,
      singleton: true,
      dependencies: [], // Sem dependências diretas de outros repositories
      scope: ServiceScope.application,
    );

    serviceLocator.register<IPlantaRepository>(
      factory: () => PlantaRepository.instance,
      singleton: true,
      dependencies: [ITaskService], // Apenas interface, não implementação
      scope: ServiceScope.application,
    );

    serviceLocator.register<ITarefaRepository>(
      factory: () => TarefaRepository.instance,
      singleton: true,
      dependencies: [], // Sem dependências de outros repositories
      scope: ServiceScope.application,
      // Remoção de parâmetro não suportado
    );

    serviceLocator.register<IPlantaConfigRepository>(
      factory: () => PlantaConfigRepository.instance,
      singleton: true,
      dependencies: [], // Sem dependências de outros repositories
      scope: ServiceScope.application,
      // Remoção de parâmetro não suportado
    );

    // 2. REGISTRAR SERVICES COM INTERFACES
    // SimpleTaskService agora usa interfaces ao invés de implementações concretas

    serviceLocator.register<ITaskService>(
      factory: () => SimpleTaskService.instance,
      singleton: true,
      dependencies: [ITarefaRepository, IPlantaConfigRepository],
      scope: ServiceScope.application,
    );

    // 3. CONFIGURAR EVENT HANDLERS PARA COMUNICAÇÃO DESACOPLADA
    await _setupEventHandlers(eventBus, serviceLocator);

    // 4. VALIDAR GRAFO DE DEPENDÊNCIAS
    final validation = serviceLocator.validateDependencyGraph();
    if (!validation.isValid) {
      throw DependencyConfigurationException(
          'Dependency graph validation failed: ${validation.issues.join(', ')}');
    }

    // 5. INICIALIZAR SERVIÇOS NA ORDEM CORRETA
    await serviceLocator.initializeServices();

    _isConfigured = true;

    final logger = Logger('DependencyConfiguration');
    logger.info('Dependency configuration completed successfully');
    logger.fine(serviceLocator.getDebugInfo().toString());
  }

  /// Configura dependências para ambiente de teste com mocks
  Future<void> configureForTesting({
    IEspacoRepository? mockEspacoRepository,
    IPlantaRepository? mockPlantaRepository,
    ITarefaRepository? mockTarefaRepository,
    IPlantaConfigRepository? mockPlantaConfigRepository,
    ITaskService? mockTaskService,
  }) async {
    final serviceLocator = EnhancedServiceLocator.instance;
    final eventBus = EventBus.instance;

    // Limpar configurações anteriores
    serviceLocator.clear();

    // Registrar mocks ou implementações padrão
    if (mockEspacoRepository != null) {
      serviceLocator.registerInstance<IEspacoRepository>(mockEspacoRepository);
    } else {
      serviceLocator.register<IEspacoRepository>(
          factory: () => EspacoRepository.instance);
    }

    if (mockPlantaRepository != null) {
      serviceLocator.registerInstance<IPlantaRepository>(mockPlantaRepository);
    } else {
      serviceLocator.register<IPlantaRepository>(
          factory: () => PlantaRepository.instance);
    }

    if (mockTarefaRepository != null) {
      serviceLocator.registerInstance<ITarefaRepository>(mockTarefaRepository);
    } else {
      serviceLocator.register<ITarefaRepository>(
          factory: () => TarefaRepository.instance);
    }

    if (mockPlantaConfigRepository != null) {
      serviceLocator.registerInstance<IPlantaConfigRepository>(
          mockPlantaConfigRepository);
    } else {
      serviceLocator.register<IPlantaConfigRepository>(
          factory: () => PlantaConfigRepository.instance);
    }

    if (mockTaskService != null) {
      serviceLocator.registerInstance<ITaskService>(mockTaskService);
    } else {
      serviceLocator.register<ITaskService>(
          factory: () => SimpleTaskService.instance);
    }

    // Configurar event handlers (pode ser desabilitado para alguns testes)
    await _setupEventHandlers(eventBus, serviceLocator);

    await serviceLocator.initializeServices();
    _isConfigured = true;
  }

  /// Configura event handlers para comunicação desacoplada
  Future<void> _setupEventHandlers(
    EventBus eventBus,
    EnhancedServiceLocator serviceLocator,
  ) async {
    // HANDLERS PARA ESPAÇOS
    // Quando espaço é removido, remover plantas relacionadas
    eventBus.on<EspacoRemovido>((event) async {
      final logger = Logger('EventHandler');
      try {
        final plantaRepo = serviceLocator.resolve<IPlantaRepository>();
        await plantaRepo.removerPorEspaco(event.espacoId);
        logger.info('Plantas removidas para espaço ${event.espacoId}');
      } catch (e) {
        logger.severe('Error handling EspacoRemovido', e);
      }
    });

    // HANDLERS PARA PLANTAS
    // Quando planta é criada, criar configuração padrão
    eventBus.on<PlantaCriada>((event) async {
      final logger = Logger('EventHandler');
      try {
        final configRepo = serviceLocator.resolve<IPlantaConfigRepository>();
        await configRepo.criarPadrao(event.plantaId);
        logger.info('Configuração padrão criada para planta ${event.plantaId}');
      } catch (e) {
        logger.severe('Error handling PlantaCriada', e);
      }
    });

    // Quando planta é removida, remover configuração e tarefas
    eventBus.on<PlantaRemovida>((event) async {
      final logger = Logger('EventHandler');
      try {
        final configRepo = serviceLocator.resolve<IPlantaConfigRepository>();
        final tarefaRepo = serviceLocator.resolve<ITarefaRepository>();

        await Future.wait([
          configRepo.removerPorPlanta(event.plantaId),
          tarefaRepo.removerPorPlanta(event.plantaId),
        ]);

        logger.info('Configuração e tarefas removidas para planta ${event.plantaId}');
      } catch (e) {
        logger.severe('Error handling PlantaRemovida', e);
      }
    });

    // HANDLERS PARA CONFIGURAÇÕES
    // Quando tipo de cuidado é alterado, criar ou remover tarefas futuras
    eventBus.on<TipoCuidadoAlterado>((event) async {
      final logger = Logger('EventHandler');
      try {
        final taskService = serviceLocator.resolve<ITaskService>();

        if (event.ativo && event.intervaloDias != null) {
          // Criar tarefa inicial se cuidado foi ativado
          final now = DateTime.now();
          final proximaData = now.add(Duration(days: event.intervaloDias!));

          await taskService.createTaskForPlantAndCareType(
            plantaId: event.plantaId,
            tipoCuidado: event.tipoCuidado,
            dataExecucao: proximaData,
          );
        } else if (!event.ativo) {
          // Remover tarefas futuras se cuidado foi desativado
          await taskService.removeFutureTasksForPlantAndCareType(
            plantaId: event.plantaId,
            tipoCuidado: event.tipoCuidado,
          );
        }

        logger.info('Tarefas gerenciadas para ${event.tipoCuidado} da planta ${event.plantaId}');
      } catch (e) {
        logger.severe('Error handling TipoCuidadoAlterado', e);
      }
    });

    // HANDLERS PARA TAREFAS
    // Quando tarefa é concluída, criar próxima tarefa se cuidado ainda está ativo
    eventBus.on<TarefaConcluida>((event) async {
      final logger = Logger('EventHandler');
      try {
        final configRepo = serviceLocator.resolve<IPlantaConfigRepository>();
        final taskService = serviceLocator.resolve<ITaskService>();

        final config = await configRepo.findByPlantaId(event.plantaId);
        if (config != null) {
          final proximaData = await taskService.calculateNextTaskDate(
            plantaId: event.plantaId,
            tipoCuidado: event.tipoCuidado,
            config: config,
          );

          if (proximaData != null) {
            await taskService.createTaskForPlantAndCareType(
              plantaId: event.plantaId,
              tipoCuidado: event.tipoCuidado,
              dataExecucao: proximaData,
            );
          }
        }

        logger.info('Próxima tarefa criada para ${event.tipoCuidado} da planta ${event.plantaId}');
      } catch (e) {
        logger.severe('Error handling TarefaConcluida', e);
      }
    });

    // HANDLER GENÉRICO PARA LOGGING/AUDIT
    // Usar stream para capturar todos os eventos
    final logger = Logger('EventHandler');
    eventBus.eventStream.listen((event) {
      // Log todos eventos para auditoria/debugging
      logger.fine('Domain Event: ${event.eventType} - ${event.eventId} - ${event.timestamp}');
    });

    logger.info('Event handlers configured successfully');
  }

  /// Verifica se o sistema está configurado corretamente
  bool get isConfigured => _isConfigured;

  /// Obtém estatísticas das dependências
  Map<String, dynamic> getDependencyStatistics() {
    if (!_isConfigured) {
      return {'status': 'not_configured'};
    }

    final serviceLocator = EnhancedServiceLocator.instance;
    final eventBus = EventBus.instance;

    return {
      'status': 'configured',
      'service_locator': serviceLocator.getDebugInfo(),
      'event_bus': eventBus.getStatistics(),
      'validation': serviceLocator.validateDependencyGraph().isValid,
    };
  }

  /// Dispose de todos os recursos
  void dispose() {
    final logger = Logger('DependencyConfiguration');
    if (!_isConfigured) return;

    EnhancedServiceLocator.instance.disposeServices();
    EventBus.instance.dispose();
    _isConfigured = false;

    logger.info('Dependency configuration disposed');
  }

  /// Reset para reconfiguração (útil para testes)
  void reset() {
    dispose();
    EnhancedServiceLocator.instance.clear();
    EventBus.instance.reset();
    _instance = DependencyConfiguration._();
  }
}

/// Exception para erros de configuração de dependências
class DependencyConfigurationException implements Exception {
  final String message;
  DependencyConfigurationException(this.message);

  @override
  String toString() => 'DependencyConfigurationException: $message';
}

/// Extension para facilitar uso
extension DependencyConfigurationExtensions on DependencyConfiguration {
  /// Verifica se todas dependências estão healthy
  Future<bool> healthCheck() async {
    if (!isConfigured) return false;

    try {
      final serviceLocator = EnhancedServiceLocator.instance;

      // Tentar resolver todas interfaces principais
      serviceLocator.resolve<IEspacoRepository>();
      serviceLocator.resolve<IPlantaRepository>();
      serviceLocator.resolve<ITarefaRepository>();
      serviceLocator.resolve<IPlantaConfigRepository>();
      serviceLocator.resolve<ITaskService>();

      return true;
    } catch (e) {
      final logger = Logger('DependencyConfiguration');
      logger.severe('Dependency health check failed', e);
      return false;
    }
  }
}
