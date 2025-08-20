/// Base class para exceções relacionadas a medições
abstract class MedicoesException implements Exception {
  final String message;
  final String? details;
  final DateTime timestamp;
  final String? stackTrace;

  MedicoesException({
    required this.message,
    this.details,
    DateTime? timestamp,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'MedicoesException: $message';
}

/// Exceção para erros de validação
class ValidationException extends MedicoesException {
  final Map<String, String> fieldErrors;

  ValidationException({
    required super.message,
    super.details,
    this.fieldErrors = const {},
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exceção para erros de persistência
class PersistenceException extends MedicoesException {
  final String operation;

  PersistenceException({
    required super.message,
    required this.operation,
    super.details,
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() => 'PersistenceException [$operation]: $message';
}

/// Exceção para erros de negócio
class BusinessLogicException extends MedicoesException {
  final String rule;

  BusinessLogicException({
    required super.message,
    required this.rule,
    super.details,
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() => 'BusinessLogicException [$rule]: $message';
}

/// Exceção para erros de conectividade
class NetworkException extends MedicoesException {
  final int? statusCode;

  NetworkException({
    required super.message,
    this.statusCode,
    super.details,
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() =>
      'NetworkException ${statusCode != null ? '($statusCode)' : ''}: $message';
}

/// Exceção para erros de timeout
class TimeoutException extends MedicoesException {
  final Duration timeout;

  TimeoutException({
    required super.message,
    required this.timeout,
    super.details,
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() => 'TimeoutException (${timeout.inSeconds}s): $message';
}

/// Exceção para erros de configuração
class ConfigurationException extends MedicoesException {
  final String configKey;

  ConfigurationException({
    required super.message,
    required this.configKey,
    super.details,
    super.timestamp,
    super.stackTrace,
  });

  @override
  String toString() => 'ConfigurationException [$configKey]: $message';
}
