// Logging
import 'package:logging/logging.dart';

// Project imports:
import '../../services/infrastructure/plantas_hive_service.dart';
import '../../services/shared/interfaces/i_task_service.dart';
import 'service_locator.dart';

/// Inicializador de serviços para configuração de dependency injection
///
/// Centraliza a configuração inicial dos serviços, permitindo:
/// - Setup fácil em environment de produção
/// - Configuração específica para testes
/// - Manutenção centralizada das dependências
class ServiceInitializer {
  /// Inicializa serviços para ambiente de produção
  static Future<void> initializeProductionServices() async {
    final serviceLocator = ServiceLocator.instance;

    // Inicializa PlantasHiveService primeiro (para registrar adaptadores)
    await PlantasHiveService.initialize();

    // Setup dos serviços padrão
    serviceLocator.setupDefaultServices();

    // Inicializa todos os serviços registrados
    await serviceLocator.initializeServices();
  }

  /// Inicializa serviços para testes (com mocks)
  static Future<void> initializeTestServices({
    ITaskService? mockTaskService,
  }) async {
    final serviceLocator = ServiceLocator.instance;

    // Limpa configuração anterior
    serviceLocator.clear();

    // Registra mocks se fornecidos
    if (mockTaskService != null) {
      serviceLocator.registerInstance<ITaskService>(mockTaskService);
    }

    // Inicializa serviços de teste
    await serviceLocator.initializeServices();
  }

  /// Verifica se todos os serviços essenciais estão registrados
  static bool validateServices() {
    final serviceLocator = ServiceLocator.instance;

    // Lista de serviços essenciais
    final essentialServices = [
      ITaskService,
    ];

    // Verifica se todos estão registrados
    for (final serviceType in essentialServices) {
      if (!serviceLocator.isRegistered<Object>()) {
        final logger = Logger('ServiceInitializer');
        logger.warning('Essential service $serviceType is not registered');
        return false;
      }
    }

    return true;
  }

  /// Obtém informações de debug sobre o estado dos serviços
  static Map<String, dynamic> getServicesStatus() {
    final serviceLocator = ServiceLocator.instance;
    final debugInfo = serviceLocator.getDebugInfo();

    return {
      ...debugInfo,
      'is_valid': validateServices(),
      'initialization_timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Reinicializa todos os serviços (útil para hot reload em desenvolvimento)
  static Future<void> reinitializeServices() async {
    final serviceLocator = ServiceLocator.instance;

    // Dispose dos serviços atuais
    serviceLocator.disposeServices();

    // Reinicializa
    await initializeProductionServices();
  }

  /// Limpa todos os serviços (útil para cleanup em testes)
  static void cleanupServices() {
    ServiceLocator.instance.disposeServices();
  }
}
