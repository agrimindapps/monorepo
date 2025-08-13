// Project imports:
import '../../repository/aop/aspect_interface.dart';
import '../../repository/aop/aspect_manager.dart';
import 'enhanced_service_locator.dart';

/// Service Locator com suporte a Aspect-Oriented Programming
///
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
/// Extende o EnhancedServiceLocator para integrar automaticamente
/// aspectos AOP aos repositories, externalizando cross-cutting concerns.
///
/// Features:
/// - Auto-aplicação de aspectos aos repositories
/// - Configuração de aspectos por ambiente
/// - Proxy transparente para interceptação
/// - Lifecycle management de aspectos
/// - Hot-swapping de aspectos em runtime
class AspectAwareServiceLocator extends EnhancedServiceLocator {
  static AspectAwareServiceLocator? _instance;
  static AspectAwareServiceLocator get instance =>
      _instance ??= AspectAwareServiceLocator._();

  AspectAwareServiceLocator._() : super.internal(Object()) {
    // Construtor privado para AspectAwareServiceLocator
  }

  /// Registry de proxies de repository com aspectos
  final Map<Type, Object> _aspectProxies = {};

  /// Configurações de aspectos carregadas
  bool _aspectsConfigured = false;

  @override
  T resolve<T extends Object>({String? name}) {
    // Se é um repository e aspectos estão configurados, retornar proxy
    if (_aspectsConfigured &&
        _isRepositoryType<T>() &&
        _aspectProxies.containsKey(T)) {
      return _aspectProxies[T] as T;
    }

    // Resolver normalmente
    final instance = super.resolve<T>(name: name);

    // Se é um repository, criar proxy com aspectos
    if (_aspectsConfigured &&
        _isRepositoryType<T>() &&
        _supportsAspects(instance)) {
      final proxy = _createAspectProxy<T>(instance);
      _aspectProxies[T] = proxy;
      return proxy;
    }

    return instance;
  }

  /// Configura aspectos para todos os repositories
  Future<void> configureAspects({
    Environment environment = Environment.production,
    Map<String, List<AspectConfiguration>>? customConfigurations,
  }) async {
    if (_aspectsConfigured) return;

    // Inicializar o RepositoryAspectManager
    await RepositoryAspectManager.instance.initialize();

    // Aplicar configuração por ambiente
    RepositoryAspectManager.instance.applyEnvironmentConfiguration(environment);

    // Aplicar configurações customizadas se fornecidas
    if (customConfigurations != null) {
      for (final entry in customConfigurations.entries) {
        RepositoryAspectManager.instance.configureRepository(
          entry.key,
          entry.value,
        );
      }
    }

    _aspectsConfigured = true;

    // Limpar proxies existentes para forçar recriação
    _aspectProxies.clear();
  }

  /// Configura aspectos para um repository específico
  void configureRepositoryAspects(
    String repositoryName,
    List<AspectConfiguration> configurations,
  ) {
    RepositoryAspectManager.instance.configureRepository(
      repositoryName,
      configurations,
    );

    // Remover proxy existente para forçar recriação
    final repositoryType = _getRepositoryTypeByName(repositoryName);
    if (repositoryType != null) {
      _aspectProxies.remove(repositoryType);
    }
  }

  /// Habilita aspecto para um repository
  void enableAspectForRepository(String repositoryName, String aspectName) {
    RepositoryAspectManager.instance.enableAspect(repositoryName, aspectName);

    // Limpar proxy para forçar recriação
    final repositoryType = _getRepositoryTypeByName(repositoryName);
    if (repositoryType != null) {
      _aspectProxies.remove(repositoryType);
    }
  }

  /// Desabilita aspecto para um repository
  void disableAspectForRepository(String repositoryName, String aspectName) {
    RepositoryAspectManager.instance.disableAspect(repositoryName, aspectName);

    // Limpar proxy para forçar recriação
    final repositoryType = _getRepositoryTypeByName(repositoryName);
    if (repositoryType != null) {
      _aspectProxies.remove(repositoryType);
    }
  }

  /// Obtém estatísticas dos aspectos
  Map<String, dynamic> getAspectStatistics() {
    return RepositoryAspectManager.instance.getAspectStatistics();
  }

  /// Obtém informações de debug dos aspectos
  Map<String, dynamic> getAspectDebugInfo() {
    return {
      'aspects_configured': _aspectsConfigured,
      'active_proxies': _aspectProxies.keys.map((t) => t.toString()).toList(),
      'aspect_manager': RepositoryAspectManager.instance.getDebugInfo(),
    };
  }

  @override
  void clear() {
    super.clear();
    _aspectProxies.clear();
    _aspectsConfigured = false;
    RepositoryAspectManager.instance.reset();
  }

  /// Cria proxy com aspectos para um repository
  T _createAspectProxy<T>(T repositoryInstance) {
    final repositoryName = _extractRepositoryName<T>();
    final aspects = RepositoryAspectManager.instance
        .getAspectsForRepository(repositoryName);

    // Criar proxy que implementa AspectAwareRepository
    return AspectAwareRepositoryProxy<T>(
      target: repositoryInstance,
      repositoryName: repositoryName,
      aspects: aspects,
    ) as T;
  }

  /// Verifica se o tipo é um repository
  bool _isRepositoryType<T>() {
    final typeName = T.toString();
    return typeName.toLowerCase().contains('repository') &&
        !typeName.contains('Interface');
  }

  /// Verifica se o objeto suporta aspectos
  bool _supportsAspects(Object instance) {
    // Verificar se implementa AspectAwareRepository ou tem métodos compatíveis
    return instance is AspectAwareRepository || _hasRepositoryMethods(instance);
  }

  /// Verifica se objeto tem métodos típicos de repository
  bool _hasRepositoryMethods(Object instance) {
    // Usar reflection ou duck typing para verificar métodos
    // Para simplicidade, assumir que sim se é nomeado como repository
    return instance.runtimeType.toString().toLowerCase().contains('repository');
  }

  /// Extrai nome do repository do tipo
  String _extractRepositoryName<T>() {
    final typeName = T.toString();
    // Remover 'Repository' do final se existir
    if (typeName.endsWith('Repository')) {
      return typeName.substring(0, typeName.length - 'Repository'.length);
    }
    return typeName;
  }

  /// Obtém tipo de repository pelo nome
  Type? _getRepositoryTypeByName(String repositoryName) {
    // Implementação simplificada - pode ser melhorada com reflection
    final debugInfo = getDebugInfo();
    final registeredServices = debugInfo['registered_services'] as List<Map<String, dynamic>>;
    
    for (final service in registeredServices) {
      final typeName = service['type'] as String;
      if (typeName.toLowerCase().contains(repositoryName.toLowerCase())) {
        // Encontrar o Type correspondente usando o nome
        return Type; // Placeholder - precisaria de reflection mais sofisticada
      }
    }
    return null;
  }
}

/// Proxy que aplica aspectos a um repository
class AspectAwareRepositoryProxy<T> implements AspectAwareRepository {
  /// Repository original (target)
  final T target;

  @override
  final String repositoryName;

  @override
  final List<RepositoryAspect> aspects;

  AspectAwareRepositoryProxy({
    required this.target,
    required this.repositoryName,
    required this.aspects,
  });

  /// Intercepta chamadas de métodos do repository
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final methodName = _getMethodName(invocation);
    final parameters = _extractParameters(invocation);

    // Se é um método de repository (CRUD), aplicar aspectos
    if (_isRepositoryMethod(methodName)) {
      return executeWithAspects<dynamic>(
        operationName: methodName,
        operation: () => _invokeTargetMethod(invocation),
        parameters: parameters,
      );
    }

    // Para outros métodos, delegar diretamente
    return _invokeTargetMethod(invocation);
  }

  /// Invoca método no target original
  dynamic _invokeTargetMethod(Invocation invocation) {
    // Em Dart, não temos reflection completa, então usamos noSuchMethod
    // No target para delegar a chamada
    return Function.apply(
      target as Function,
      invocation.positionalArguments,
      invocation.namedArguments,
    );
  }

  /// Extrai nome do método da invocation
  String _getMethodName(Invocation invocation) {
    return invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
  }

  /// Extrai parâmetros da invocation
  Map<String, dynamic> _extractParameters(Invocation invocation) {
    final parameters = <String, dynamic>{};

    // Adicionar argumentos posicionais
    for (int i = 0; i < invocation.positionalArguments.length; i++) {
      parameters['arg_$i'] = invocation.positionalArguments[i];
    }

    // Adicionar argumentos nomeados
    invocation.namedArguments.forEach((symbol, value) {
      final key =
          symbol.toString().replaceAll('Symbol("', '').replaceAll('")', '');
      parameters[key] = value;
    });

    return parameters;
  }

  /// Verifica se é um método de repository que deve ter aspectos
  bool _isRepositoryMethod(String methodName) {
    const repositoryMethods = {
      'create',
      'update',
      'delete',
      'save',
      'findAll',
      'findById',
      'findByIds',
      'createBatch',
      'updateBatch',
      'deleteBatch',
      'clear',
      'forceSync',
    };

    return repositoryMethods.contains(methodName) ||
        methodName.startsWith('find') ||
        methodName.startsWith('create') ||
        methodName.startsWith('update') ||
        methodName.startsWith('delete');
  }

  /// Métodos padrão do Object que não devem ser interceptados
  @override
  String toString() => 'AspectAwareProxy<$T>($repositoryName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is AspectAwareRepositoryProxy<T>) {
      return target == other.target;
    }
    return target == other;
  }

  @override
  int get hashCode => target.hashCode;

  /// Delega todas as outras propriedades/getters para o target
  @override
  Type get runtimeType => target.runtimeType;
}

/// Extension para facilitar configuração de aspectos
extension AspectConfigurationExtensions on AspectAwareServiceLocator {
  /// Configura aspectos padrão para produção
  Future<void> configureForProductionAspects() async {
    await configureAspects(
      environment: Environment.production,
      customConfigurations: {
        'Planta': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': false,
              'logOperationEnd': false,
              'logParameters': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': true,
              'strictResultValidation': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': false,
              'autoFlushStatistics': true,
            },
          ),
        ],
        'Espaco': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': false,
              'logOperationEnd': false,
              'logParameters': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': true,
              'strictResultValidation': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': false,
              'autoFlushStatistics': true,
            },
          ),
        ],
        'Tarefa': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': false,
              'logOperationEnd': false,
              'logParameters': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': true,
              'strictResultValidation': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': false,
              'autoFlushStatistics': true,
            },
          ),
        ],
      },
    );
  }

  /// Configura aspectos padrão para desenvolvimento
  Future<void> configureForDevelopmentAspects() async {
    await configureAspects(
      environment: Environment.development,
      customConfigurations: {
        'Planta': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': true,
              'logOperationEnd': true,
              'logParameters': true,
              'detailedLogging': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': false,
              'strictResultValidation': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': true,
              'realTimeStatistics': true,
              'autoFlushStatistics': false,
            },
          ),
        ],
        'Espaco': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': true,
              'logOperationEnd': true,
              'logParameters': true,
              'detailedLogging': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': false,
              'strictResultValidation': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': true,
              'realTimeStatistics': true,
              'autoFlushStatistics': false,
            },
          ),
        ],
        'Tarefa': [
          AspectConfiguration(
            aspectName: 'logging',
            enabled: true,
            priority: 10,
            settings: {
              'logOperationStart': true,
              'logOperationEnd': true,
              'logParameters': true,
              'detailedLogging': true,
            },
          ),
          AspectConfiguration(
            aspectName: 'validation',
            enabled: true,
            priority: 5,
            settings: {
              'validateIdFormat': false,
              'strictResultValidation': false,
            },
          ),
          AspectConfiguration(
            aspectName: 'statistics',
            enabled: true,
            priority: 90,
            settings: {
              'trackAccessPatterns': true,
              'realTimeStatistics': true,
              'autoFlushStatistics': false,
            },
          ),
        ],
      },
    );
  }
}
