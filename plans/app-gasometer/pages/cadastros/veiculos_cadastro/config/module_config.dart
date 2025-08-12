/// Configuração centralizada do módulo de veículos
///
/// Define padrões e configurações para:
/// - Dependency injection
/// - Error handling
/// - Performance tuning
/// - Debug settings
class VeiculosModuleConfig {
  /// Configurações de dependency injection
  static const DependencyConfig dependencies = DependencyConfig(
    useLazyPut: true,
    enableFenix: false, // Desabilita fenix para prevenir vazamentos
    checkInterval: Duration(seconds: 30),
    timeoutDuration: Duration(seconds: 5),
  );

  /// Configurações de performance
  static const PerformanceConfig performance = PerformanceConfig(
    debounceDelay: Duration(milliseconds: 100),
    updateDelay: Duration(milliseconds: 50),
    maxRetryAttempts: 3,
    enableDiagnostics: true,
  );

  /// Configurações de error handling
  static const ErrorConfig errorHandling = ErrorConfig(
    enableSilentFallbacks: false, // Desabilita fallbacks silenciosos
    logErrors: true,
    throwOnCriticalErrors: true,
    enableDependencyValidation: true,
  );

  /// Configurações de debug (apenas em desenvolvimento)
  static const DebugConfig debug = DebugConfig(
    enableVerboseLogging: false,
    enableDependencyDiagnostics: true,
    enablePerformanceMetrics: true,
    logControllerLifecycle: false,
  );

  /// Padrões de ID para GetBuilder updates
  static const Map<String, String> updateIds = {
    'loading_state': 'loading_state',
    'vehicle_info': 'vehicle_info',
    'form_fields': 'form_fields',
    'validation_errors': 'validation_errors',
  };

  /// Lista de dependências críticas que devem estar sempre disponíveis
  static const List<String> criticalDependencies = [
    'VeiculosRepository',
    'VeiculosPageController',
    'VeiculosCadastroFormController',
  ];

  /// Lista de dependências opcionais
  static const List<String> optionalDependencies = [
    'VeiculoPersistenceService',
    'VeiculosCadastroFormController',
  ];
}

/// Configuração de dependency injection
class DependencyConfig {
  final bool useLazyPut;
  final bool enableFenix;
  final Duration checkInterval;
  final Duration timeoutDuration;

  const DependencyConfig({
    required this.useLazyPut,
    required this.enableFenix,
    required this.checkInterval,
    required this.timeoutDuration,
  });
}

/// Configuração de performance
class PerformanceConfig {
  final Duration debounceDelay;
  final Duration updateDelay;
  final int maxRetryAttempts;
  final bool enableDiagnostics;

  const PerformanceConfig({
    required this.debounceDelay,
    required this.updateDelay,
    required this.maxRetryAttempts,
    required this.enableDiagnostics,
  });
}

/// Configuração de error handling
class ErrorConfig {
  final bool enableSilentFallbacks;
  final bool logErrors;
  final bool throwOnCriticalErrors;
  final bool enableDependencyValidation;

  const ErrorConfig({
    required this.enableSilentFallbacks,
    required this.logErrors,
    required this.throwOnCriticalErrors,
    required this.enableDependencyValidation,
  });
}

/// Configuração de debug
class DebugConfig {
  final bool enableVerboseLogging;
  final bool enableDependencyDiagnostics;
  final bool enablePerformanceMetrics;
  final bool logControllerLifecycle;

  const DebugConfig({
    required this.enableVerboseLogging,
    required this.enableDependencyDiagnostics,
    required this.enablePerformanceMetrics,
    required this.logControllerLifecycle,
  });
}
