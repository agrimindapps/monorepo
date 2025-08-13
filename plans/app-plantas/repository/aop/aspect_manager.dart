// Dart imports:
import 'dart:async';

// Project imports:
import 'aspect_interface.dart';
import 'aspects/logging_aspect.dart';
import 'aspects/statistics_aspect.dart';
import 'aspects/validation_aspect.dart';

/// Gerenciador de aspectos para repositories
///
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
/// Centraliza o gerenciamento de aspectos AOP, permitindo:
/// - Registro e configuração de aspectos
/// - Aplicação dinâmica de aspectos por repository
/// - Configuração por ambiente (prod/dev/test)
/// - Hot-swapping de aspectos em runtime
/// - Profiling e debugging de aspectos
class RepositoryAspectManager {
  static RepositoryAspectManager? _instance;
  static RepositoryAspectManager get instance =>
      _instance ??= RepositoryAspectManager._();

  RepositoryAspectManager._();

  /// Registry global de aspectos disponíveis
  final Map<String, RepositoryAspectFactory> _aspectFactories = {};

  /// Configurações de aspectos por repository
  final Map<String, List<AspectConfiguration>> _repositoryConfigurations = {};

  /// Instâncias de aspectos ativas por repository
  final Map<String, List<RepositoryAspect>> _activeAspects = {};

  /// Configuração global do manager
  AspectManagerConfig _config = const AspectManagerConfig();

  /// Flag de inicialização
  bool _isInitialized = false;

  /// Inicializa o manager com aspectos padrão
  Future<void> initialize({AspectManagerConfig? config}) async {
    if (_isInitialized) return;

    _config = config ?? const AspectManagerConfig();

    // Registrar aspectos padrão
    await _registerBuiltInAspects();

    _isInitialized = true;
  }

  /// Registra uma factory de aspecto
  void registerAspectFactory(
      String aspectName, RepositoryAspectFactory factory) {
    _aspectFactories[aspectName] = factory;
  }

  /// Configura aspectos para um repository específico
  void configureRepository(
      String repositoryName, List<AspectConfiguration> configurations) {
    _repositoryConfigurations[repositoryName] = List.from(configurations);

    // Se já há aspectos ativos para este repository, recriar
    if (_activeAspects.containsKey(repositoryName)) {
      _recreateAspectsForRepository(repositoryName);
    }
  }

  /// Obtém aspectos configurados para um repository
  List<RepositoryAspect> getAspectsForRepository(String repositoryName) {
    // Lazy creation dos aspectos
    if (!_activeAspects.containsKey(repositoryName)) {
      _createAspectsForRepository(repositoryName);
    }

    return List.from(_activeAspects[repositoryName] ?? []);
  }

  /// Habilita um aspecto específico para um repository
  void enableAspect(String repositoryName, String aspectName) {
    final configurations = _repositoryConfigurations[repositoryName] ?? [];

    // Encontrar configuração existente ou criar nova
    AspectConfiguration? config;
    for (final cfg in configurations) {
      if (cfg.aspectName == aspectName) {
        config = cfg;
        break;
      }
    }

    if (config != null) {
      config.enabled = true;
    } else {
      // Criar nova configuração com settings padrão
      configurations.add(AspectConfiguration(
        aspectName: aspectName,
        enabled: true,
      ));
      _repositoryConfigurations[repositoryName] = configurations;
    }

    _recreateAspectsForRepository(repositoryName);
  }

  /// Desabilita um aspecto específico para um repository
  void disableAspect(String repositoryName, String aspectName) {
    final configurations = _repositoryConfigurations[repositoryName] ?? [];

    for (final config in configurations) {
      if (config.aspectName == aspectName) {
        config.enabled = false;
        break;
      }
    }

    _recreateAspectsForRepository(repositoryName);
  }

  /// Obtém configuração atual de um repository
  List<AspectConfiguration> getRepositoryConfiguration(String repositoryName) {
    return List.from(_repositoryConfigurations[repositoryName] ?? []);
  }

  /// Aplica configuração padrão baseada no ambiente
  void applyEnvironmentConfiguration(Environment environment) {
    switch (environment) {
      case Environment.production:
        _applyProductionConfiguration();
        break;
      case Environment.development:
        _applyDevelopmentConfiguration();
        break;
      case Environment.testing:
        _applyTestingConfiguration();
        break;
      case Environment.debug:
        _applyDebugConfiguration();
        break;
    }
  }

  /// Configura aspectos globalmente para todos os repositories
  void configureGlobally(
      Map<String, Map<String, dynamic>> aspectConfigurations) {
    // Limpar configurações existentes
    _repositoryConfigurations.clear();
    _activeAspects.clear();

    // Aplicar nova configuração global
    for (final entry in aspectConfigurations.entries) {
      final aspectName = entry.key;
      final settings = entry.value;

      final config = AspectConfiguration(
        aspectName: aspectName,
        enabled: settings['enabled'] as bool? ?? true,
        priority: settings['priority'] as int?,
        settings: Map<String, dynamic>.from(settings),
      );

      // Aplicar a todos os repositories conhecidos
      for (final repoName in _getAllKnownRepositories()) {
        final repoConfigs =
            _repositoryConfigurations.putIfAbsent(repoName, () => []);

        // Remover configuração anterior deste aspecto
        repoConfigs.removeWhere((cfg) => cfg.aspectName == aspectName);

        // Adicionar nova configuração
        repoConfigs.add(config);
      }
    }

    // Recriar todos os aspectos ativos
    for (final repoName in _activeAspects.keys.toList()) {
      _recreateAspectsForRepository(repoName);
    }
  }

  /// Obtém estatísticas de uso dos aspectos
  Map<String, dynamic> getAspectStatistics() {
    final stats = <String, dynamic>{
      'total_repositories': _repositoryConfigurations.length,
      'total_active_aspects': _activeAspects.values
          .fold<int>(0, (sum, aspects) => sum + aspects.length),
      'repositories': <String, dynamic>{},
      'aspect_usage': <String, int>{},
    };

    // Estatísticas por repository
    for (final entry in _activeAspects.entries) {
      final repoName = entry.key;
      final aspects = entry.value;

      stats['repositories'][repoName] = {
        'aspect_count': aspects.length,
        'aspects': aspects
            .map((a) => {
                  'name': a.name,
                  'priority': a.priority,
                  'enabled': a.enabled,
                })
            .toList(),
      };

      // Contar uso de cada aspecto
      for (final aspect in aspects) {
        stats['aspect_usage'][aspect.name] =
            (stats['aspect_usage'][aspect.name] as int? ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Obtém informações de debug sobre aspectos
  Map<String, dynamic> getDebugInfo() {
    return {
      'is_initialized': _isInitialized,
      'registered_factories': _aspectFactories.keys.toList(),
      'repository_configurations': _repositoryConfigurations.map(
        (repo, configs) =>
            MapEntry(repo, configs.map((c) => c.toMap()).toList()),
      ),
      'active_aspects_count': _activeAspects.map(
        (repo, aspects) => MapEntry(repo, aspects.length),
      ),
      'manager_config': _config.toMap(),
    };
  }

  /// Valida configuração de aspectos
  ValidationResult validateConfiguration() {
    final issues = <String>[];

    // Verificar se há aspectos registrados
    if (_aspectFactories.isEmpty) {
      issues.add('No aspect factories registered');
    }

    // Verificar configurações de repositories
    for (final entry in _repositoryConfigurations.entries) {
      final repoName = entry.key;
      final configs = entry.value;

      for (final config in configs) {
        // Verificar se factory existe
        if (!_aspectFactories.containsKey(config.aspectName)) {
          issues.add(
              'Repository $repoName references unknown aspect: ${config.aspectName}');
        }

        // Verificar configurações duplicadas
        final duplicates =
            configs.where((c) => c.aspectName == config.aspectName).length;
        if (duplicates > 1) {
          issues.add(
              'Repository $repoName has duplicate configurations for aspect: ${config.aspectName}');
        }
      }
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  /// Reseta todas as configurações
  void reset() {
    // Dispose de todos os aspectos ativos
    for (final aspects in _activeAspects.values) {
      for (final aspect in aspects) {
        if (aspect is StatisticsAspect) {
          aspect.dispose();
        }
      }
    }

    _repositoryConfigurations.clear();
    _activeAspects.clear();
    _isInitialized = false;
  }

  /// Dispose do manager
  void dispose() {
    reset();
    _aspectFactories.clear();
  }

  /// Registra aspectos built-in
  Future<void> _registerBuiltInAspects() async {
    // Registrar LoggingAspect
    registerAspectFactory('logging', (repositoryName, settings) {
      final config = _createLoggingConfig(settings);
      return LoggingAspect(
        repositoryName: repositoryName,
        config: config,
      );
    });

    // Registrar ValidationAspect
    registerAspectFactory('validation', (repositoryName, settings) {
      final config = _createValidationConfig(settings);
      return ValidationAspect(repositoryName: repositoryName, config: config);
    });

    // Registrar StatisticsAspect
    registerAspectFactory('statistics', (repositoryName, settings) {
      final config = _createStatisticsConfig(settings);
      return StatisticsAspect(config: config);
    });
  }

  /// Cria aspectos para um repository
  void _createAspectsForRepository(String repositoryName) {
    final configurations = _repositoryConfigurations[repositoryName] ??
        _getDefaultConfigurations();
    final aspects = <RepositoryAspect>[];

    for (final config in configurations) {
      if (!config.enabled) continue;

      final factory = _aspectFactories[config.aspectName];
      if (factory == null) continue;

      try {
        final aspect = factory(repositoryName, config.settings);
        aspects.add(aspect);
      } catch (e) {
        // Log erro mas continua criando outros aspectos
        if (_config.logErrors) {
          print(
              'Error creating aspect ${config.aspectName} for repository $repositoryName: $e');
        }
      }
    }

    // Ordenar por prioridade
    aspects.sort((a, b) => a.priority.compareTo(b.priority));

    _activeAspects[repositoryName] = aspects;
  }

  /// Recria aspectos para um repository
  void _recreateAspectsForRepository(String repositoryName) {
    // Dispose aspectos existentes
    final existingAspects = _activeAspects[repositoryName];
    if (existingAspects != null) {
      for (final aspect in existingAspects) {
        if (aspect is StatisticsAspect) {
          aspect.dispose();
        }
      }
    }

    // Recriar aspectos
    _createAspectsForRepository(repositoryName);
  }

  /// Obtém configurações padrão
  List<AspectConfiguration> _getDefaultConfigurations() {
    return [
      AspectConfiguration(aspectName: 'logging', enabled: true, priority: 10),
      AspectConfiguration(aspectName: 'validation', enabled: true, priority: 5),
      AspectConfiguration(
          aspectName: 'statistics', enabled: true, priority: 90),
    ];
  }

  /// Aplica configuração de produção
  void _applyProductionConfiguration() {
    final globalConfig = {
      'logging': {
        'enabled': true,
        'priority': 10,
        'logOperationStart': false,
        'logOperationEnd': false,
        'logParameters': false,
        'detailedLogging': false,
      },
      'validation': {
        'enabled': true,
        'priority': 5,
        'validateIdFormat': true,
        'strictResultValidation': true,
      },
      'statistics': {
        'enabled': true,
        'priority': 90,
        'trackAccessPatterns': false,
        'realTimeStatistics': false,
        'autoFlushStatistics': true,
      },
    };

    configureGlobally(globalConfig);
  }

  /// Aplica configuração de desenvolvimento
  void _applyDevelopmentConfiguration() {
    final globalConfig = {
      'logging': {
        'enabled': true,
        'priority': 10,
        'logOperationStart': true,
        'logOperationEnd': true,
        'logParameters': true,
        'detailedLogging': true,
      },
      'validation': {
        'enabled': true,
        'priority': 5,
        'validateIdFormat': false,
        'strictResultValidation': false,
      },
      'statistics': {
        'enabled': true,
        'priority': 90,
        'trackAccessPatterns': true,
        'realTimeStatistics': true,
        'autoFlushStatistics': false,
      },
    };

    configureGlobally(globalConfig);
  }

  /// Aplica configuração de teste
  void _applyTestingConfiguration() {
    final globalConfig = {
      'logging': {
        'enabled': false,
        'priority': 10,
      },
      'validation': {
        'enabled': true,
        'priority': 5,
        'validateIdFormat': false,
        'strictResultValidation': false,
      },
      'statistics': {
        'enabled': false,
        'priority': 90,
      },
    };

    configureGlobally(globalConfig);
  }

  /// Aplica configuração de debug
  void _applyDebugConfiguration() {
    final globalConfig = {
      'logging': {
        'enabled': true,
        'priority': 10,
        'logOperationStart': true,
        'logOperationEnd': true,
        'logParameters': true,
        'logResults': true,
        'detailedLogging': true,
        'includeAspectContext': true,
      },
      'validation': {
        'enabled': true,
        'priority': 5,
        'validateIdFormat': true,
        'validateResults': true,
        'strictResultValidation': true,
      },
      'statistics': {
        'enabled': true,
        'priority': 90,
        'trackAccessPatterns': true,
        'detectAnomalies': true,
        'realTimeStatistics': true,
        'autoFlushStatistics': false,
      },
    };

    configureGlobally(globalConfig);
  }

  /// Cria configuração de logging a partir de settings
  LoggingAspectConfig _createLoggingConfig(Map<String, dynamic> settings) {
    if (settings.isEmpty) return const LoggingAspectConfig();

    return LoggingAspectConfig(
      enabled: settings['enabled'] as bool? ?? true,
      logOperationStart: settings['logOperationStart'] as bool? ?? true,
      logOperationEnd: settings['logOperationEnd'] as bool? ?? true,
      logParameters: settings['logParameters'] as bool? ?? true,
      logResults: settings['logResults'] as bool? ?? false,
      detailedLogging: settings['detailedLogging'] as bool? ?? false,
      includeAspectContext: settings['includeAspectContext'] as bool? ?? false,
      slowOperationThreshold: Duration(
        milliseconds: settings['slowOperationThresholdMs'] as int? ?? 1000,
      ),
    );
  }

  /// Cria configuração de validation a partir de settings
  ValidationAspectConfig _createValidationConfig(
      Map<String, dynamic> settings) {
    if (settings.isEmpty) return ValidationAspectConfig();

    return ValidationAspectConfig(
      enabled: settings['enabled'] as bool? ?? true,
      validateIdFormat: settings['validateIdFormat'] as bool? ?? false,
      validateResults: settings['validateResults'] as bool? ?? false,
      strictResultValidation:
          settings['strictResultValidation'] as bool? ?? false,
      requiredFields: settings['requiredFields'] as List<String>? ?? const [],
    );
  }

  /// Cria configuração de statistics a partir de settings
  StatisticsAspectConfig _createStatisticsConfig(
      Map<String, dynamic> settings) {
    if (settings.isEmpty) return const StatisticsAspectConfig();

    return StatisticsAspectConfig(
      enabled: settings['enabled'] as bool? ?? true,
      trackAccessPatterns: settings['trackAccessPatterns'] as bool? ?? true,
      detectAnomalies: settings['detectAnomalies'] as bool? ?? true,
      realTimeStatistics: settings['realTimeStatistics'] as bool? ?? true,
      autoFlushStatistics: settings['autoFlushStatistics'] as bool? ?? false,
      slowOperationThreshold: Duration(
        milliseconds: settings['slowOperationThresholdMs'] as int? ?? 1000,
      ),
      maxRecentOperationsHistory:
          settings['maxRecentOperationsHistory'] as int? ?? 100,
    );
  }

  /// Obtém todos os repositories conhecidos
  Set<String> _getAllKnownRepositories() {
    final repos = <String>{};
    repos.addAll(_repositoryConfigurations.keys);
    repos.addAll(_activeAspects.keys);
    return repos;
  }
}

/// Factory para criar aspectos
typedef RepositoryAspectFactory = RepositoryAspect Function(
  String repositoryName,
  Map<String, dynamic> settings,
);

/// Configuração de um aspecto
class AspectConfiguration {
  final String aspectName;
  bool enabled;
  int? priority;
  final Map<String, dynamic> settings;

  AspectConfiguration({
    required this.aspectName,
    this.enabled = true,
    this.priority,
    this.settings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'aspect_name': aspectName,
      'enabled': enabled,
      'priority': priority,
      'settings': settings,
    };
  }

  factory AspectConfiguration.fromMap(Map<String, dynamic> map) {
    return AspectConfiguration(
      aspectName: map['aspect_name'] as String,
      enabled: map['enabled'] as bool? ?? true,
      priority: map['priority'] as int?,
      settings: Map<String, dynamic>.from(map['settings'] as Map? ?? {}),
    );
  }
}

/// Configuração do AspectManager
class AspectManagerConfig {
  final bool logErrors;
  final bool validateOnStartup;
  final bool autoConfigureByEnvironment;
  final Environment defaultEnvironment;

  const AspectManagerConfig({
    this.logErrors = true,
    this.validateOnStartup = true,
    this.autoConfigureByEnvironment = true,
    this.defaultEnvironment = Environment.production,
  });

  Map<String, dynamic> toMap() {
    return {
      'log_errors': logErrors,
      'validate_on_startup': validateOnStartup,
      'auto_configure_by_environment': autoConfigureByEnvironment,
      'default_environment': defaultEnvironment.toString(),
    };
  }
}

/// Ambientes suportados
enum Environment {
  production,
  development,
  testing,
  debug,
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> issues;

  ValidationResult({
    required this.isValid,
    required this.issues,
  });
}

/// Extension para facilitar uso do RepositoryAspectManager
extension RepositoryAspectManagerExtensions on RepositoryAspectManager {
  /// Configura aspectos padrão para um repository
  void configureStandardAspects(
    String repositoryName, {
    bool enableLogging = true,
    bool enableValidation = true,
    bool enableStatistics = true,
  }) {
    final configurations = <AspectConfiguration>[];

    if (enableLogging) {
      configurations.add(AspectConfiguration(
        aspectName: 'logging',
        enabled: true,
        priority: 10,
      ));
    }

    if (enableValidation) {
      configurations.add(AspectConfiguration(
        aspectName: 'validation',
        enabled: true,
        priority: 5,
      ));
    }

    if (enableStatistics) {
      configurations.add(AspectConfiguration(
        aspectName: 'statistics',
        enabled: true,
        priority: 90,
      ));
    }

    configureRepository(repositoryName, configurations);
  }

  /// Configuração rápida para produção
  void configureForProduction(String repositoryName) {
    configureRepository(repositoryName, [
      AspectConfiguration(
        aspectName: 'logging',
        enabled: true,
        priority: 10,
        settings: {
          'logOperationStart': false,
          'logOperationEnd': false,
          'logParameters': false,
          'detailedLogging': false,
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
          'realTimeStatistics': false,
          'autoFlushStatistics': true,
        },
      ),
    ]);
  }

  /// Configuração rápida para desenvolvimento
  void configureForDevelopment(String repositoryName) {
    configureRepository(repositoryName, [
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
    ]);
  }
}
