// Dart imports:
import 'dart:convert';
import 'dart:developer' as developer;

// Project imports:
import '../exceptions/repository_exceptions.dart';

/// Níveis de log suportados
enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warning(2, 'WARN'),
  error(3, 'ERROR'),
  critical(4, 'CRITICAL');

  const LogLevel(this.priority, this.label);

  final int priority;
  final String label;

  /// Compara se este nível é igual ou maior que outro
  bool isAtLeast(LogLevel other) => priority >= other.priority;
}

/// Interface para diferentes outputs de log (console, file, remote)
abstract class LogOutput {
  /// Escreve entrada de log
  void write(LogEntry entry);

  /// Limpa/reseta o output se suportado
  void clear() {}

  /// Fecha o output liberando recursos
  void dispose() {}
}

/// Implementação para log no console usando developer.log
class ConsoleLogOutput implements LogOutput {
  @override
  void write(LogEntry entry) {
    // Usar developer.log para melhor integração com Flutter DevTools
    developer.log(
      entry.message,
      time: entry.timestamp,
      level: entry.level.priority,
      name: entry.logger,
      error: entry.exception,
      stackTrace: entry.stackTrace,
    );

    // Também print para visibilidade imediata no console
    print('[${entry.level.label}] ${entry.logger}: ${entry.message}');

    // Se há contextual data, imprimir formatado
    if (entry.data.isNotEmpty) {
      print('  Data: ${_formatData(entry.data)}');
    }

    // Se há exception, imprimir detalhes
    if (entry.exception != null) {
      print('  Exception: ${entry.exception}');
      if (entry.stackTrace != null) {
        print('  StackTrace: ${entry.stackTrace}');
      }
    }
  }

  String _formatData(Map<String, dynamic> data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  @override
  void clear() {
    // Console log não precisa ser limpo
  }

  @override
  void dispose() {
    // Console log não precisa liberar recursos
  }
}

/// Entrada de log estruturada
class LogEntry {
  /// Timestamp quando o log foi criado
  final DateTime timestamp;

  /// Nível do log
  final LogLevel level;

  /// Nome do logger (normalmente nome do repository)
  final String logger;

  /// Mensagem principal do log
  final String message;

  /// Dados contextuais estruturados
  final Map<String, dynamic> data;

  /// Exception associada (se houver)
  final dynamic exception;

  /// Stack trace associado (se houver)
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.logger,
    required this.message,
    DateTime? timestamp,
    this.data = const {},
    this.exception,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.label,
      'logger': logger,
      'message': message,
      'data': data,
      if (exception != null) 'exception': exception.toString(),
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    };
  }

  /// Cria entrada de log a partir de RepositoryException
  factory LogEntry.fromException(
    String logger,
    RepositoryException exception, {
    StackTrace? stackTrace,
    String? additionalMessage,
  }) {
    final message = additionalMessage != null
        ? '$additionalMessage: ${exception.message}'
        : exception.message;

    return LogEntry(
      level: LogLevel.error,
      logger: logger,
      message: message,
      data: exception.toLogMap(),
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return '[${level.label}] $logger: $message';
  }
}

/// Logger estruturado para repositories
class RepositoryLogger {
  /// Nome do logger (normalmente nome do repository)
  final String name;

  /// Nível mínimo de log a ser processado
  final LogLevel minLevel;

  /// Lista de outputs onde logs serão escritos
  final List<LogOutput> outputs;

  RepositoryLogger({
    required this.name,
    this.minLevel = LogLevel.info,
    List<LogOutput>? outputs,
  }) : outputs = outputs ?? [ConsoleLogOutput()];

  /// Registra log de debug
  void debug(
    String message, {
    Map<String, dynamic> data = const {},
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, data, exception, stackTrace);
  }

  /// Registra log de informação
  void info(
    String message, {
    Map<String, dynamic> data = const {},
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, message, data, exception, stackTrace);
  }

  /// Registra log de warning
  void warning(
    String message, {
    Map<String, dynamic> data = const {},
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, message, data, exception, stackTrace);
  }

  /// Registra log de erro
  void error(
    String message, {
    Map<String, dynamic> data = const {},
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, data, exception, stackTrace);
  }

  /// Registra log crítico
  void critical(
    String message, {
    Map<String, dynamic> data = const {},
    dynamic exception,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.critical, message, data, exception, stackTrace);
  }

  /// Registra exception com contexto
  void logException(
    RepositoryException exception, {
    StackTrace? stackTrace,
    String? additionalMessage,
  }) {
    final entry = LogEntry.fromException(
      name,
      exception,
      stackTrace: stackTrace,
      additionalMessage: additionalMessage,
    );

    _writeEntry(entry);
  }

  /// Registra operação de repository com timing
  Future<T> logOperation<T>(
    String operation,
    Future<T> Function() action, {
    Map<String, dynamic> context = const {},
  }) async {
    final stopwatch = Stopwatch()..start();

    info(
      'Starting $operation',
      data: {
        'operation': operation,
        ...context,
      },
    );

    try {
      final result = await action();
      stopwatch.stop();

      info(
        'Completed $operation successfully',
        data: {
          'operation': operation,
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...context,
        },
      );

      return result;
    } catch (exception, stackTrace) {
      stopwatch.stop();

      error(
        'Failed $operation',
        data: {
          'operation': operation,
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...context,
        },
        exception: exception,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Método interno para processar logs
  void _log(
    LogLevel level,
    String message,
    Map<String, dynamic> data,
    dynamic exception,
    StackTrace? stackTrace,
  ) {
    if (!level.isAtLeast(minLevel)) return;

    final entry = LogEntry(
      level: level,
      logger: name,
      message: message,
      data: data,
      exception: exception,
      stackTrace: stackTrace,
    );

    _writeEntry(entry);
  }

  /// Escreve entrada de log em todos os outputs
  void _writeEntry(LogEntry entry) {
    for (final output in outputs) {
      try {
        output.write(entry);
      } catch (e) {
        // Não podemos usar o logger aqui para evitar recursão
        print('Failed to write log entry to output: $e');
      }
    }
  }

  /// Libera recursos dos outputs
  void dispose() {
    for (final output in outputs) {
      output.dispose();
    }
  }
}

/// Gerenciador global de loggers para repositories
class RepositoryLogManager {
  static final RepositoryLogManager _instance = RepositoryLogManager._();

  /// Instância singleton
  static RepositoryLogManager get instance => _instance;

  RepositoryLogManager._();

  /// Cache de loggers por nome
  final Map<String, RepositoryLogger> _loggers = {};

  /// Configurações globais
  LogLevel _globalMinLevel = LogLevel.info;
  List<LogOutput> _globalOutputs = [ConsoleLogOutput()];

  /// Obtém logger para um repository específico
  RepositoryLogger getLogger(String repositoryName) {
    return _loggers.putIfAbsent(
      repositoryName,
      () => RepositoryLogger(
        name: repositoryName,
        minLevel: _globalMinLevel,
        outputs: _globalOutputs,
      ),
    );
  }

  /// Configura nível mínimo global
  void setGlobalLogLevel(LogLevel level) {
    _globalMinLevel = level;

    // Atualizar loggers existentes
    for (final logger in _loggers.values) {
      // Não podemos alterar final fields, mas podemos recriar loggers se necessário
    }
  }

  /// Configura outputs globais
  void setGlobalOutputs(List<LogOutput> outputs) {
    // Disposal dos outputs antigos
    for (final output in _globalOutputs) {
      output.dispose();
    }

    _globalOutputs = outputs;

    // Limpar cache para forçar recriação com novos outputs
    for (final logger in _loggers.values) {
      logger.dispose();
    }
    _loggers.clear();
  }

  /// Adiciona output adicional globalmente
  void addGlobalOutput(LogOutput output) {
    _globalOutputs.add(output);

    // Loggers existentes não são afetados automaticamente
    // Pode ser necessário recriar para usar novo output
  }

  /// Limpa todos os loggers
  void clearLoggers() {
    for (final logger in _loggers.values) {
      logger.dispose();
    }
    _loggers.clear();
  }

  /// Obtém estatísticas dos loggers
  Map<String, dynamic> getStatistics() {
    return {
      'total_loggers': _loggers.length,
      'logger_names': _loggers.keys.toList(),
      'global_min_level': _globalMinLevel.label,
      'global_outputs_count': _globalOutputs.length,
    };
  }
}

/// Extension para facilitar uso de logger nos repositories
extension RepositoryLoggerExtension on Object {
  /// Obtém logger para esta classe
  RepositoryLogger get logger {
    final className = runtimeType.toString();
    return RepositoryLogManager.instance.getLogger(className);
  }
}

/// Utilitários para logging em repositories
class RepositoryLogUtils {
  /// Cria mapa de contexto padronizado para operações CRUD
  static Map<String, dynamic> crudContext({
    String? entityId,
    String? entityType,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      if (entityId != null) 'entity_id': entityId,
      if (entityType != null) 'entity_type': entityType,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalData != null) ...additionalData,
    };
  }

  /// Cria contexto para operações batch
  static Map<String, dynamic> batchContext({
    required int totalItems,
    int? chunkSize,
    String? batchId,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'total_items': totalItems,
      if (chunkSize != null) 'chunk_size': chunkSize,
      if (batchId != null) 'batch_id': batchId,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalData != null) ...additionalData,
    };
  }

  /// Cria contexto para operações com retry
  static Map<String, dynamic> retryContext({
    required int attemptNumber,
    required int maxAttempts,
    Duration? delay,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      'attempt_number': attemptNumber,
      'max_attempts': maxAttempts,
      if (delay != null) 'delay_ms': delay.inMilliseconds,
      if (reason != null) 'retry_reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalData != null) ...additionalData,
    };
  }
}
