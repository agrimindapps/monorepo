// Dart imports
import 'dart:async';

// Package imports
import 'package:logging/logging.dart';

// Project imports:
import '../../services/shared/interfaces/i_task_service.dart';
import '../interfaces/i_espaco_repository.dart';
import '../interfaces/i_planta_config_repository.dart';
import '../interfaces/i_planta_repository.dart';
import '../interfaces/i_tarefa_repository.dart';

// Logging setup
final logger = Logger('EnhancedServiceLocator');

/// Escopo de vida do serviço
enum ServiceScope {
  application,  // Vive durante toda aplicação
  session,      // Vive durante sessão do usuário
  request,      // Vive apenas durante uma operação
}

/// Metadata de um serviço registrado
class ServiceRegistration {
  final Object Function() factory;
  final bool singleton;
  final List<Type> dependencies;
  final String? name;
  final ServiceScope scope;

  ServiceRegistration({
    required this.factory,
    this.singleton = true,
    this.dependencies = const [],
    this.name,
    this.scope = ServiceScope.application,
  });
}

/// Enhanced Service Locator com suporte a interfaces de repositories
/// 
/// Implementa Dependency Injection avançado com:
/// - Registration de interfaces e implementações
/// - Lazy initialization com thread safety
/// - Dependency resolution automático
/// - Lifecycle management
/// - Configuration por ambiente (prod/test/dev)
class EnhancedServiceLocator {
  static EnhancedServiceLocator? _instance;
  static EnhancedServiceLocator get instance => _instance ??= EnhancedServiceLocator._();

  EnhancedServiceLocator._() {
    // Construtor privado para singleton
  }

  EnhancedServiceLocator.internal(Object _) {
    // Construtor nomeado privado para compatibilidade
  }

  // Registry avançado com metadata
  final Map<Type, ServiceRegistration> _services = <Type, ServiceRegistration>{};
  final Map<Type, Object> _singletons = <Type, Object>{};
  bool _isInitialized = false;

  /// Registra uma implementação para uma interface
  void register<TInterface extends Object>({
    required TInterface Function() factory,
    bool singleton = true,
    List<Type> dependencies = const [],
    String? name,
    ServiceScope scope = ServiceScope.application,
  }) {
    _services[TInterface] = ServiceRegistration(
      factory: factory,
      singleton: singleton,
      dependencies: dependencies,
      name: name,
      scope: scope,
    );
    
    if (singleton) {
      _singletons.remove(TInterface);
    }
  }

  /// Registra uma instância específica
  void registerInstance<TInterface extends Object>(
    TInterface instance, {
    String? name,
    ServiceScope scope = ServiceScope.application,
  }) {
    _services[TInterface] = ServiceRegistration(
      factory: () => instance,
      singleton: true,
      name: name,
      scope: scope,
    );
    _singletons[TInterface] = instance;
  }

  /// Resolve uma dependência com verification de dependências circulares
  T resolve<T extends Object>({String? name}) {
    return _resolveInternal<T>(name: name, resolutionStack: []);
  }

  T _resolveInternal<T extends Object>({
    String? name,
    required List<Type> resolutionStack,
  }) {
    // Verificar dependência circular
    if (resolutionStack.contains(T)) {
      throw CircularDependencyException(
        'Circular dependency detected: ${resolutionStack.join(' -> ')} -> $T'
      );
    }

    final registration = _services[T];
    if (registration == null) {
      throw ServiceNotRegisteredException(
        'Service of type $T${name != null ? ' (name: $name)' : ''} is not registered'
      );
    }

    // Se é singleton e já foi criado, retorna instância existente
    if (registration.singleton && _singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Adicionar tipo atual ao stack de resolução
    final newStack = [...resolutionStack, T];

    // Resolver dependências primeiro (se existirem)
    for (final type in registration.dependencies) {
      _resolveInternal<Object>(resolutionStack: newStack, name: type.toString());
    }

    // Criar nova instância
    final instance = registration.factory() as T;
    
    // Se é singleton, armazenar para reuso
    if (registration.singleton) {
      _singletons[T] = instance;
    }

    return instance;
  }

  /// Verifica se um serviço está registrado
  bool isRegistered<T extends Object>({String? name}) {
    return _services.containsKey(T);
  }

  /// Remove um serviço do registry
  void unregister<T extends Object>({String? name}) {
    _services.remove(T);
    _singletons.remove(T);
  }

  /// Limpa todos os serviços
  void clear() {
    // Dispose all singletons que implementam dispose
    for (final instance in _singletons.values) {
      _disposeSafely(instance);
    }
    
    _services.clear();
    _singletons.clear();
    _isInitialized = false;
  }

  /// Configura serviços padrão para produção
  void configureForProduction() {
    clear();
    
    // Repositories serão registrados pelas implementações concretas
    // Services básicos
    // register<ITaskService>(() => SimpleTaskService.instance);
    
    _isInitialized = true;
  }

  /// Configura serviços para testes com mocks
  void configureForTesting() {
    clear();
    
    // Registrar mocks aqui quando necessário
    // register<IEspacoRepository>(() => MockEspacoRepository());
    // register<IPlantaRepository>(() => MockPlantaRepository());
    // register<ITarefaRepository>(() => MockTarefaRepository());
    // register<IPlantaConfigRepository>(() => MockPlantaConfigRepository());
    // register<ITaskService>(() => MockTaskService());
    
    _isInitialized = true;
  }

  /// Inicializa todos os serviços registrados
  Future<void> initializeServices() async {
    if (_isInitialized) return;
    
    final List<Future<void>> initializations = [];
    
    // Inicializar repositories primeiro (ordem de dependência)
    final repositoryOrder = [
      IEspacoRepository,
      IPlantaRepository,
      IPlantaConfigRepository,
      ITarefaRepository,
    ];
    
    for (final repoType in repositoryOrder) {
      if (_services.containsKey(repoType)) {
        try {
          final instance = resolve<Object>();
          if (instance is IEspacoRepository) {
            initializations.add(instance.initialize());
          } else if (instance is IPlantaRepository) {
            initializations.add(instance.initialize());
          } else if (instance is ITarefaRepository) {
            initializations.add(instance.initialize());
          } else if (instance is IPlantaConfigRepository) {
            initializations.add(instance.initialize());
          }
        } catch (e) {
          final logger = Logger('EnhancedServiceLocator');
          logger.warning('Failed to initialize repository $repoType', e);
        }
      }
    }
    
    // Aguardar repositórios
    await Future.wait(initializations);
    initializations.clear();
    
    // Inicializar services
    for (final entry in _services.entries) {
      if (!repositoryOrder.contains(entry.key)) {
        try {
          final instance = resolve<Object>();
          if (instance is ITaskService) {
            initializations.add(instance.initialize());
          }
        } catch (e) {
          logger.warning('Failed to initialize service ${entry.key}', e);
        }
      }
    }
    
    await Future.wait(initializations);
    _isInitialized = true;
  }

  /// Dispose de todos os serviços
  void disposeServices() {
    for (final instance in _singletons.values) {
      _disposeSafely(instance);
    }
    
    clear();
  }

  void _disposeSafely(Object instance) {
    try {
      if (instance is IEspacoRepository) {
        instance.dispose();
      } else if (instance is IPlantaRepository) {
        instance.dispose();
      } else if (instance is ITarefaRepository) {
        instance.dispose();
      } else if (instance is IPlantaConfigRepository) {
        instance.dispose();
      } else if (instance is ITaskService) {
        instance.dispose();
      }
    } catch (e) {
      logger.warning('Failed to dispose ${instance.runtimeType}', e);
    }
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'is_initialized': _isInitialized,
      'total_registrations': _services.length,
      'singleton_instances': _singletons.length,
      'registered_services': _services.entries.map((e) => {
        'type': e.key.toString(),
        'singleton': e.value.singleton,
        'dependencies_count': e.value.dependencies.length,
        'scope': e.value.scope.toString(),
        'name': e.value.name,
        'has_instance': _singletons.containsKey(e.key),
      }).toList(),
    };
  }

  /// Valida o grafo de dependências
  ValidationResult validateDependencyGraph() {
    final issues = <String>[];
    
    for (final entry in _services.entries) {
      final type = entry.key;
      final registration = entry.value;
      
      // Verificar se dependências estão registradas
      for (final depType in registration.dependencies) {
        if (!_services.containsKey(depType)) {
          issues.add('$type depends on unregistered service $depType');
        }
      }
      
      // Verificar possíveis ciclos (simplified check)
      try {
        _checkForCycles(type, [], {});
      } on CircularDependencyException catch (e) {
        issues.add(e.message);
      }
    }
    
    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  void _checkForCycles(Type type, List<Type> path, Set<Type> visited) {
    if (path.contains(type)) {
      throw CircularDependencyException(
        'Circular dependency: ${path.join(' -> ')} -> $type'
      );
    }
    
    if (visited.contains(type)) return;
    visited.add(type);
    
    final registration = _services[type];
    if (registration == null) return;
    
    final newPath = [...path, type];
    for (final depType in registration.dependencies) {
      _checkForCycles(depType, newPath, visited);
    }
  }
}

/// Resultado da validação do grafo de dependências
class ValidationResult {
  final bool isValid;
  final List<String> issues;

  ValidationResult({required this.isValid, required this.issues});
}

/// Exception para dependências circulares
class CircularDependencyException implements Exception {
  final String message;
  CircularDependencyException(this.message);
  
  @override
  String toString() => 'CircularDependencyException: $message';
}

/// Exception para serviço não registrado
class ServiceNotRegisteredException implements Exception {
  final String message;
  ServiceNotRegisteredException(this.message);
  
  @override
  String toString() => 'ServiceNotRegisteredException: $message';
}

/// Extensions para facilitar uso
extension EnhancedServiceLocatorExtensions on EnhancedServiceLocator {
  /// Shortcuts para repositories
  IEspacoRepository get espacoRepository => resolve<IEspacoRepository>();
  IPlantaRepository get plantaRepository => resolve<IPlantaRepository>();
  ITarefaRepository get tarefaRepository => resolve<ITarefaRepository>();
  IPlantaConfigRepository get plantaConfigRepository => resolve<IPlantaConfigRepository>();
  
  /// Shortcuts para services
  ITaskService get taskService => resolve<ITaskService>();
}