// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Project imports:
import '../exceptions/repository_exceptions.dart';
import '../logging/repository_logger.dart';

/// Configuração para retry de operações
class RetryConfig {
  /// Número máximo de tentativas (incluindo tentativa inicial)
  final int maxAttempts;

  /// Delay inicial entre tentativas
  final Duration initialDelay;

  /// Multiplicador para exponential backoff
  final double backoffMultiplier;

  /// Delay máximo entre tentativas
  final Duration maxDelay;

  /// Jitter máximo para randomizar delays (evita thundering herd)
  final Duration maxJitter;

  /// Predicate para determinar se exception é retryable
  final bool Function(Exception) shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.maxJitter = const Duration(milliseconds: 100),
    this.shouldRetry = _defaultShouldRetry,
  });

  /// Configuração padrão para operações de network
  static const network = RetryConfig(
    maxAttempts: 4,
    initialDelay: Duration(milliseconds: 1000),
    backoffMultiplier: 2.0,
    maxDelay: Duration(seconds: 15),
    maxJitter: Duration(milliseconds: 200),
  );

  /// Configuração para operações rápidas
  static const fast = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(milliseconds: 100),
    backoffMultiplier: 1.5,
    maxDelay: Duration(seconds: 2),
    maxJitter: Duration(milliseconds: 50),
  );

  /// Configuração para operações críticas
  static const critical = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 2000),
    backoffMultiplier: 1.8,
    maxDelay: Duration(minutes: 1),
    maxJitter: Duration(milliseconds: 500),
  );

  /// Predicado padrão para determinar se deve retentar
  static bool _defaultShouldRetry(Exception exception) {
    // NetworkException e TimeoutException são sempre retryable
    if (exception is NetworkException) {
      return exception.isRetryable;
    }
    if (exception is TimeoutException) {
      return true;
    }
    if (exception is SyncException) {
      return exception.isTemporary;
    }

    // Outros repository exceptions baseado no tipo
    if (exception is RepositoryInitializationException ||
        exception is DataAccessException ||
        exception is InvalidStateException) {
      return false; // Estas precisam ser corrigidas, não retentadas
    }

    // Para exceptions genéricas, tentar baseado na mensagem
    final message = exception.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('temporary');
  }

  /// Calcula delay para uma tentativa específica
  Duration calculateDelay(int attemptNumber) {
    if (attemptNumber <= 1) return Duration.zero;

    // Exponential backoff
    final baseDelay = initialDelay.inMilliseconds *
        math.pow(backoffMultiplier, attemptNumber - 2);

    // Aplicar max delay
    final clampedDelay = math.min(baseDelay, maxDelay.inMilliseconds);

    // Adicionar jitter aleatório
    final random = math.Random();
    final jitterMs = random.nextInt(maxJitter.inMilliseconds + 1);

    final finalDelayMs = clampedDelay.toInt() + jitterMs;
    return Duration(milliseconds: finalDelayMs);
  }

  @override
  String toString() {
    return 'RetryConfig(maxAttempts: $maxAttempts, initialDelay: $initialDelay, '
        'backoffMultiplier: $backoffMultiplier, maxDelay: $maxDelay, '
        'maxJitter: $maxJitter)';
  }
}

/// Informações sobre tentativa de retry
class RetryAttempt {
  /// Número da tentativa (1-based)
  final int attemptNumber;

  /// Configuração de retry usada
  final RetryConfig config;

  /// Exception da tentativa anterior (se houver)
  final Exception? previousException;

  /// Delay aplicado antes desta tentativa
  final Duration delay;

  /// Timestamp do início da tentativa
  final DateTime timestamp;

  RetryAttempt({
    required this.attemptNumber,
    required this.config,
    this.previousException,
    this.delay = Duration.zero,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Verdadeiro se esta é a primeira tentativa
  bool get isFirstAttempt => attemptNumber == 1;

  /// Verdadeiro se esta é a última tentativa possível
  bool get isLastAttempt => attemptNumber >= config.maxAttempts;

  /// Contexto para logging
  Map<String, dynamic> toLogContext() {
    return {
      'attempt_number': attemptNumber,
      'max_attempts': config.maxAttempts,
      'is_first_attempt': isFirstAttempt,
      'is_last_attempt': isLastAttempt,
      'delay_ms': delay.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      if (previousException != null)
        'previous_exception': previousException.toString(),
    };
  }
}

/// Callback executado antes de cada tentativa de retry
typedef RetryCallback = void Function(RetryAttempt attempt);

/// Mecanismo de retry para operações de repository
class RetryMechanism {
  /// Configuração de retry
  final RetryConfig config;

  /// Logger para registrar tentativas
  final RepositoryLogger logger;

  /// Callback executado antes de cada retry (opcional)
  final RetryCallback? onRetry;

  const RetryMechanism({
    required this.config,
    required this.logger,
    this.onRetry,
  });

  /// Executa operação com retry automático
  Future<T> execute<T>({
    required Future<T> Function() operation,
    required String operationName,
    Map<String, dynamic> context = const {},
  }) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= config.maxAttempts; attempt++) {
      final retryAttempt = RetryAttempt(
        attemptNumber: attempt,
        config: config,
        previousException: lastException,
        delay: attempt > 1 ? config.calculateDelay(attempt) : Duration.zero,
      );

      // Log início da tentativa
      if (attempt == 1) {
        logger.info(
          'Starting $operationName',
          data: {
            'operation': operationName,
            'max_attempts': config.maxAttempts,
            ...context,
          },
        );
      } else {
        logger.info(
          'Retrying $operationName',
          data: {
            ...retryAttempt.toLogContext(),
            'operation': operationName,
            ...context,
          },
        );

        // Chamar callback se definido
        onRetry?.call(retryAttempt);
      }

      // Aplicar delay se não for primeira tentativa
      if (retryAttempt.delay > Duration.zero) {
        await Future.delayed(retryAttempt.delay);
      }

      try {
        // Executar operação
        final result = await operation();

        // Log sucesso
        if (attempt > 1) {
          logger.info(
            'Succeeded $operationName after retry',
            data: {
              'operation': operationName,
              'successful_attempt': attempt,
              'total_attempts': attempt,
              ...context,
            },
          );
        } else {
          logger.debug(
            'Completed $operationName successfully',
            data: {
              'operation': operationName,
              ...context,
            },
          );
        }

        return result;
      } catch (exception) {
        lastException = exception is Exception
            ? exception
            : Exception(exception.toString());

        // Verificar se deve retentar
        final shouldRetry =
            attempt < config.maxAttempts && config.shouldRetry(lastException);

        if (shouldRetry) {
          logger.warning(
            'Failed $operationName, will retry',
            data: {
              ...retryAttempt.toLogContext(),
              'operation': operationName,
              'will_retry': true,
              ...context,
            },
            exception: lastException,
          );
        } else {
          // Última tentativa ou não retryable
          logger.error(
            'Failed $operationName definitively',
            data: {
              ...retryAttempt.toLogContext(),
              'operation': operationName,
              'will_retry': false,
              'total_attempts': attempt,
              ...context,
            },
            exception: lastException,
          );

          // Se é NetworkException, incrementar contador de retry
          if (lastException is NetworkException) {
            throw lastException.withIncrementedRetry();
          }

          rethrow;
        }
      }
    }

    // Este código nunca deveria ser alcançado devido à lógica acima
    throw lastException ?? Exception('Unexpected retry mechanism failure');
  }

  /// Executa operação com timeout e retry
  Future<T> executeWithTimeout<T>({
    required Future<T> Function() operation,
    required String operationName,
    required Duration timeout,
    Map<String, dynamic> context = const {},
  }) async {
    return execute<T>(
      operation: () async {
        return await operation().timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              repository: logger.name,
              operation: operationName,
              timeoutDuration: timeout,
            );
          },
        );
      },
      operationName: operationName,
      context: {
        'timeout_ms': timeout.inMilliseconds,
        ...context,
      },
    );
  }
}

/// Gerenciador global de retry mechanisms
class RetryManager {
  static final RetryManager _instance = RetryManager._();

  /// Instância singleton
  static RetryManager get instance => _instance;

  RetryManager._();

  /// Configurações de retry por tipo de operação
  final Map<String, RetryConfig> _configs = {
    'network': RetryConfig.network,
    'fast': RetryConfig.fast,
    'critical': RetryConfig.critical,
  };

  /// Registra configuração customizada
  void registerConfig(String name, RetryConfig config) {
    _configs[name] = config;
  }

  /// Obtém configuração por nome
  RetryConfig getConfig(String name) {
    return _configs[name] ?? const RetryConfig();
  }

  /// Cria mechanism para um repository específico
  RetryMechanism createMechanism({
    required String repositoryName,
    String configName = 'network',
    RetryCallback? onRetry,
  }) {
    final config = getConfig(configName);
    final logger = RepositoryLogManager.instance.getLogger(repositoryName);

    return RetryMechanism(
      config: config,
      logger: logger,
      onRetry: onRetry,
    );
  }

  /// Utilitário para executar operação com retry padrão
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    required String repositoryName,
    required String operationName,
    String configName = 'network',
    Map<String, dynamic> context = const {},
    RetryCallback? onRetry,
  }) async {
    final mechanism = instance.createMechanism(
      repositoryName: repositoryName,
      configName: configName,
      onRetry: onRetry,
    );

    return mechanism.execute<T>(
      operation: operation,
      operationName: operationName,
      context: context,
    );
  }

  /// Utilitário para executar com timeout e retry
  static Future<T> retryWithTimeout<T>({
    required Future<T> Function() operation,
    required String repositoryName,
    required String operationName,
    required Duration timeout,
    String configName = 'network',
    Map<String, dynamic> context = const {},
    RetryCallback? onRetry,
  }) async {
    final mechanism = instance.createMechanism(
      repositoryName: repositoryName,
      configName: configName,
      onRetry: onRetry,
    );

    return mechanism.executeWithTimeout<T>(
      operation: operation,
      operationName: operationName,
      timeout: timeout,
      context: context,
    );
  }

  /// Obtém estatísticas de configurações registradas
  Map<String, dynamic> getStatistics() {
    return {
      'registered_configs': _configs.keys.toList(),
      'total_configs': _configs.length,
      'configs_detail': _configs.map(
        (name, config) => MapEntry(name, config.toString()),
      ),
    };
  }
}
