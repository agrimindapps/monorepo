// Logging
import 'package:logger/logger.dart';

import '../../services/domain/tasks/simple_task_service.dart';
// Project imports:
import '../../services/shared/interfaces/i_task_service.dart';

/// Service Locator para gerenciamento de dependências
///
/// Implementa Inversion of Control (IoC) permitindo:
/// - Dependency injection para repositories
/// - Mocking fácil para testes unitários
/// - Configuração flexível de implementações
/// - Desacoplamento entre camadas
class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();

  ServiceLocator._();

  // Registry de services com lazy initialization
  final Map<Type, Object Function()> _services = <Type, Object Function()>{};
  final Map<Type, Object> _singletons = <Type, Object>{};

  /// Registra uma implementação para uma interface
  void register<T extends Object>(T Function() factory,
      {bool singleton = true}) {
    _services[T] = factory;

    if (singleton) {
      // Para singletons, não instanciamos agora, apenas marcamos
      _singletons.remove(T); // Limpa instância anterior se houver
    }
  }

  /// Registra uma instância específica (singleton)
  void registerInstance<T extends Object>(T instance) {
    _services[T] = () => instance;
    _singletons[T] = instance;
  }

  /// Resolve uma dependência
  T get<T extends Object>() {
    final factory = _services[T];
    if (factory == null) {
      throw Exception(
          'Service of type $T is not registered. Please register it first.');
    }

    // Se é singleton e já foi criado, retorna a instância existente
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Cria nova instância
    final instance = factory() as T;

    // Se deve ser singleton, armazena para reuso
    if (_services.containsKey(T)) {
      _singletons[T] = instance;
    }

    return instance;
  }

  /// Verifica se um serviço está registrado
  bool isRegistered<T extends Object>() {
    return _services.containsKey(T);
  }

  /// Remove um serviço do registry
  void unregister<T extends Object>() {
    _services.remove(T);
    _singletons.remove(T);
  }

  /// Limpa todos os serviços (útil para testes)
  void clear() {
    _services.clear();
    _singletons.clear();
  }

  /// Configura os serviços padrão do app
  void setupDefaultServices() {
    // Registra SimpleTaskService como implementação padrão de ITaskService
    register<ITaskService>(() => SimpleTaskService.instance, singleton: true);
  }

  /// Configura serviços para testes (mocks)
  void setupTestServices() {
    // Remove configuração padrão
    clear();

    // Registra mocks (a serem implementados conforme necessário)
    // register<ITaskService>(() => MockTaskService(), singleton: true);
  }

  /// Inicializa todos os serviços registrados que implementam initialize()
  Future<void> initializeServices() async {
    final List<Future<void>> initializations = [];

    for (final entry in _services.entries) {
      try {
        // Criar instância usando factory diretamente
        final instance = entry.value();

        // Se o serviço tem método initialize, chama ele
        if (instance is ITaskService) {
          initializations.add(instance.initialize());
        }
      } catch (e) {
        // Log error mas continua inicializando outros serviços
        // Logger removed
        Logger().w('Failed to initialize service ${entry.key}', error: e);
      }
    }

    // Aguarda todas as inicializações completarem
    await Future.wait(initializations);
  }

  /// Dispõe todos os serviços que implementam dispose()
  void disposeServices() {
    for (final instance in _singletons.values) {
      try {
        // Se o serviço tem método dispose, chama ele
        if (instance is ITaskService) {
          instance.dispose();
        }
      } catch (e) {
        Logger().w('Failed to dispose service ${instance.runtimeType}', error: e);
      }
    }

    clear();
  }

  /// Obtém informações de debug sobre serviços registrados
  Map<String, dynamic> getDebugInfo() {
    return {
      'registered_services': _services.keys.map((k) => k.toString()).toList(),
      'singleton_instances': _singletons.keys.map((k) => k.toString()).toList(),
      'total_services': _services.length,
      'total_singletons': _singletons.length,
    };
  }
}

/// Extension para facilitar acesso ao ServiceLocator
extension ServiceLocatorExtension on ServiceLocator {
  /// Shortcut para obter ITaskService
  ITaskService get taskService => get<ITaskService>();
}
