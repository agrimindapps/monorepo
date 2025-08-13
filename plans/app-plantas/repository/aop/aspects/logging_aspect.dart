// Dart imports:
import 'dart:async';

import '../../logging/repository_logger.dart';
// Project imports:
import '../aspect_interface.dart';

/// Aspecto para logging de operações de repository
///
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
/// Externaliza a responsabilidade de logging dos repositories core,
/// aplicando logging de forma consistente através de AOP.
///
/// Features:
/// - Logging automático de início/fim de operações
/// - Medição de performance de operações
/// - Logging estruturado com contexto rico
/// - Logging de exceptions com stack traces
/// - Configuração flexível de níveis de log
class LoggingAspect implements RepositoryAspect {
  /// Logger específico para este aspecto
  final RepositoryLogger _logger;

  /// Configurações do aspecto
  final LoggingAspectConfig config;

  LoggingAspect({
    required String repositoryName,
    LoggingAspectConfig? config,
  })  : _logger =
            RepositoryLogManager.instance.getLogger('${repositoryName}_Aspect'),
        config = config ?? const LoggingAspectConfig();

  @override
  String get name => 'LoggingAspect';

  @override
  int get priority => 10; // Alta prioridade para capturar tudo

  @override
  bool get enabled => config.enabled;

  @override
  Future<AdviceResult> beforeOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required OperationContext context,
  }) async {
    if (!_shouldLogOperation(operationName)) {
      return AdviceResult.proceed();
    }

    final logContext = _createLogContext(operationName, parameters, context);

    // Log início da operação
    if (config.logOperationStart) {
      _logger.info(
        'Starting $operationName operation',
        data: logContext,
      );
    }

    // Adicionar timestamp para medição de performance
    context.addMetric(
        'logging_start_time', DateTime.now().millisecondsSinceEpoch);

    // Debug detalhado se configurado
    if (config.logParameters && config.detailedLogging) {
      _logger.debug(
        'Operation parameters for $operationName',
        data: {
          'operation': operationName,
          'parameters': _sanitizeParameters(parameters),
          'context': context.toMap(),
        },
      );
    }

    return AdviceResult.proceed(
      additionalContext: {
        'logging_enabled': true,
        'log_level': config.defaultLogLevel.label,
      },
    );
  }

  @override
  Future<AdviceResult> afterOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic result,
    required OperationContext context,
  }) async {
    if (!_shouldLogOperation(operationName)) {
      return AdviceResult.proceed(result: result);
    }

    final duration = _calculateDuration(context);
    final logContext = _createLogContext(operationName, parameters, context);

    // Adicionar métricas de performance
    logContext.addAll({
      'duration_ms': duration.inMilliseconds,
      'success': true,
    });

    // Log sucesso da operação
    if (config.logOperationEnd) {
      _logger.info(
        'Completed $operationName operation successfully',
        data: logContext,
      );
    }

    // Log de performance se operação foi lenta
    if (config.logSlowOperations && duration > config.slowOperationThreshold) {
      _logger.warning(
        'Slow operation detected: $operationName',
        data: {
          ...logContext,
          'performance_warning': true,
          'threshold_ms': config.slowOperationThreshold.inMilliseconds,
        },
      );
    }

    // Debug do resultado se configurado
    if (config.logResults && config.detailedLogging) {
      _logger.debug(
        'Operation result for $operationName',
        data: {
          'operation': operationName,
          'result_type': result?.runtimeType.toString(),
          'result_summary': _summarizeResult(result),
          'duration_ms': duration.inMilliseconds,
        },
      );
    }

    return AdviceResult.proceed(result: result);
  }

  @override
  Future<AdviceResult> onException({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic exception,
    required StackTrace stackTrace,
    required OperationContext context,
  }) async {
    if (!_shouldLogOperation(operationName)) {
      return AdviceResult.throwException(exception);
    }

    final duration = _calculateDuration(context);
    final logContext = _createLogContext(operationName, parameters, context);

    // Adicionar informações da exception
    logContext.addAll({
      'duration_ms': duration.inMilliseconds,
      'success': false,
      'exception_type': exception.runtimeType.toString(),
      'exception_message': exception.toString(),
    });

    // Log da exception
    _logger.error(
      'Operation $operationName failed with exception',
      data: logContext,
      exception: exception,
      stackTrace: stackTrace,
    );

    // Log crítico se configurado para certos tipos de exception
    if (config.logCriticalExceptions && _isCriticalException(exception)) {
      _logger.critical(
        'CRITICAL: $operationName failed with critical exception',
        data: {
          ...logContext,
          'critical_failure': true,
          'requires_attention': true,
        },
        exception: exception,
        stackTrace: stackTrace,
      );
    }

    return AdviceResult.throwException(exception);
  }

  @override
  Future<void> finallyOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    dynamic result,
    dynamic exception,
    required OperationContext context,
  }) async {
    if (!_shouldLogOperation(operationName) || !config.logOperationSummary) {
      return;
    }

    final duration = _calculateDuration(context);
    final wasSuccessful = exception == null;

    // Log resumo final da operação
    _logger.debug(
      'Operation $operationName completed',
      data: {
        'operation': operationName,
        'success': wasSuccessful,
        'duration_ms': duration.inMilliseconds,
        'had_result': result != null,
        'had_exception': exception != null,
        'aspects_context': context.context,
      },
    );

    // Atualizar métricas globais se configurado
    if (config.updateGlobalMetrics) {
      _updateGlobalMetrics(operationName, duration, wasSuccessful);
    }
  }

  /// Cria contexto de log padronizado
  Map<String, dynamic> _createLogContext(
    String operationName,
    Map<String, dynamic> parameters,
    OperationContext context,
  ) {
    final logContext = <String, dynamic>{
      'operation': operationName,
      'repository': context.repositoryName,
      'operation_id': context.operationId,
      'timestamp': context.startTime.toIso8601String(),
    };

    // Adicionar parâmetros sanitizados se configurado
    if (config.logParameters) {
      logContext['parameters'] = _sanitizeParameters(parameters);
    }

    // Adicionar contexto de aspectos se disponível
    if (context.context.isNotEmpty && config.includeAspectContext) {
      logContext['aspect_context'] = context.context;
    }

    return logContext;
  }

  /// Sanitiza parâmetros removendo informações sensíveis
  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> parameters) {
    final sanitized = <String, dynamic>{};

    for (final entry in parameters.entries) {
      final key = entry.key.toLowerCase();

      // Mascarar campos sensíveis
      if (config.sensitiveFields
          .any((field) => key.contains(field.toLowerCase()))) {
        sanitized[entry.key] = '[MASKED]';
      } else if (entry.value is String &&
          (entry.value as String).length > config.maxParameterLength) {
        // Truncar valores muito longos
        sanitized[entry.key] =
            '${(entry.value as String).substring(0, config.maxParameterLength)}...';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Cria resumo do resultado para logging
  String _summarizeResult(dynamic result) {
    if (result == null) return 'null';

    if (result is List) {
      return 'List<${result.isNotEmpty ? result.first.runtimeType : 'dynamic'}>(${result.length})';
    }

    if (result is Map) {
      return 'Map<String, dynamic>(${result.length} keys)';
    }

    if (result is String && result.length > 100) {
      return '${result.substring(0, 97)}...';
    }

    return result.toString();
  }

  /// Calcula duração da operação
  Duration _calculateDuration(OperationContext context) {
    final startTime = context.getMetric<int>('logging_start_time');
    if (startTime != null) {
      return Duration(
          milliseconds: DateTime.now().millisecondsSinceEpoch - startTime);
    }
    return context.elapsed;
  }

  /// Verifica se deve fazer log desta operação
  bool _shouldLogOperation(String operationName) {
    if (config.excludedOperations.contains(operationName)) {
      return false;
    }

    if (config.includedOperations.isNotEmpty) {
      return config.includedOperations.contains(operationName);
    }

    return true;
  }

  /// Verifica se exception é crítica
  bool _isCriticalException(dynamic exception) {
    final exceptionType = exception.runtimeType.toString().toLowerCase();
    return config.criticalExceptionTypes
        .any((type) => exceptionType.contains(type.toLowerCase()));
  }

  /// Atualiza métricas globais de logging
  void _updateGlobalMetrics(
      String operationName, Duration duration, bool success) {
    // Implementação futura: integrar com sistema de métricas global
    // Por enquanto, apenas log debug
    _logger.debug(
      'Global metrics update',
      data: {
        'operation': operationName,
        'duration_ms': duration.inMilliseconds,
        'success': success,
        'metrics_updated': true,
      },
    );
  }
}

/// Configuração do LoggingAspect
class LoggingAspectConfig {
  /// Se o aspecto está habilitado
  final bool enabled;

  /// Nível de log padrão
  final LogLevel defaultLogLevel;

  /// Se deve fazer log do início das operações
  final bool logOperationStart;

  /// Se deve fazer log do fim das operações
  final bool logOperationEnd;

  /// Se deve fazer log de resumo das operações
  final bool logOperationSummary;

  /// Se deve fazer log dos parâmetros
  final bool logParameters;

  /// Se deve fazer log dos resultados
  final bool logResults;

  /// Se deve usar logging detalhado (debug)
  final bool detailedLogging;

  /// Se deve fazer log de operações lentas
  final bool logSlowOperations;

  /// Threshold para considerar operação lenta
  final Duration slowOperationThreshold;

  /// Se deve fazer log crítico de certas exceptions
  final bool logCriticalExceptions;

  /// Se deve incluir contexto de outros aspectos no log
  final bool includeAspectContext;

  /// Se deve atualizar métricas globais
  final bool updateGlobalMetrics;

  /// Operações a serem incluídas (se vazio, inclui todas)
  final Set<String> includedOperations;

  /// Operações a serem excluídas
  final Set<String> excludedOperations;

  /// Campos considerados sensíveis (serão mascarados)
  final Set<String> sensitiveFields;

  /// Tipos de exception considerados críticos
  final Set<String> criticalExceptionTypes;

  /// Tamanho máximo de parâmetro para log
  final int maxParameterLength;

  const LoggingAspectConfig({
    this.enabled = true,
    this.defaultLogLevel = LogLevel.info,
    this.logOperationStart = true,
    this.logOperationEnd = true,
    this.logOperationSummary = false,
    this.logParameters = true,
    this.logResults = false,
    this.detailedLogging = false,
    this.logSlowOperations = true,
    this.slowOperationThreshold = const Duration(milliseconds: 1000),
    this.logCriticalExceptions = true,
    this.includeAspectContext = false,
    this.updateGlobalMetrics = false,
    this.includedOperations = const {},
    this.excludedOperations = const {},
    this.sensitiveFields = const {
      'password',
      'token',
      'key',
      'secret',
      'credential'
    },
    this.criticalExceptionTypes = const {
      'SecurityException',
      'AuthenticationException',
      'AuthorizationException',
      'DataCorruptionException',
      'CriticalSystemException'
    },
    this.maxParameterLength = 500,
  });

  /// Configuração para produção (menos verbose)
  factory LoggingAspectConfig.production() {
    return const LoggingAspectConfig(
      logOperationStart: false,
      logOperationEnd: false,
      logOperationSummary: false,
      logParameters: false,
      logResults: false,
      detailedLogging: false,
      includeAspectContext: false,
      updateGlobalMetrics: true,
    );
  }

  /// Configuração para desenvolvimento (mais verbose)
  factory LoggingAspectConfig.development() {
    return const LoggingAspectConfig(
      logOperationStart: true,
      logOperationEnd: true,
      logOperationSummary: true,
      logParameters: true,
      logResults: true,
      detailedLogging: true,
      includeAspectContext: true,
      updateGlobalMetrics: false,
    );
  }

  /// Configuração para debugging (máximo detalhe)
  factory LoggingAspectConfig.debug() {
    return const LoggingAspectConfig(
      defaultLogLevel: LogLevel.debug,
      logOperationStart: true,
      logOperationEnd: true,
      logOperationSummary: true,
      logParameters: true,
      logResults: true,
      detailedLogging: true,
      includeAspectContext: true,
      updateGlobalMetrics: true,
      slowOperationThreshold: Duration(milliseconds: 500),
    );
  }
}
