/// Tipos específicos de erros para tratamento diferenciado
abstract class PluviometroException implements Exception {
  final String message;
  final String? details;
  final DateTime timestamp;

  PluviometroException(this.message, {this.details})
      : timestamp = DateTime.now();

  @override
  String toString() => 'PluviometroException: $message';
}

/// Erro de validação de dados
class ValidationException extends PluviometroException {
  final String fieldName;
  final dynamic invalidValue;

  ValidationException({
    required this.fieldName,
    required String message,
    this.invalidValue,
    String? details,
  }) : super(message, details: details);

  @override
  String toString() => 'ValidationException[$fieldName]: $message';
}

/// Erro de persistência de dados
class PersistenceException extends PluviometroException {
  final String operation;
  final Exception? originalException;

  PersistenceException({
    required this.operation,
    required String message,
    this.originalException,
    String? details,
  }) : super(message, details: details);

  @override
  String toString() => 'PersistenceException[$operation]: $message';
}

/// Erro de rede/conectividade
class NetworkException extends PluviometroException {
  final int? statusCode;
  final String? endpoint;

  NetworkException({
    required String message,
    this.statusCode,
    this.endpoint,
    String? details,
  }) : super(message, details: details);

  @override
  String toString() =>
      'NetworkException${statusCode != null ? '[$statusCode]' : ''}: $message';
}

/// Erro de timeout
class TimeoutException extends PluviometroException {
  final Duration timeout;
  final String operation;

  TimeoutException({
    required this.operation,
    required this.timeout,
    String? details,
  }) : super('Operação $operation expirou após ${timeout.inSeconds}s',
            details: details);

  @override
  String toString() => 'TimeoutException[$operation]: $message';
}

/// Erro de permissão
class PermissionException extends PluviometroException {
  final String permission;
  final String action;

  PermissionException({
    required this.permission,
    required this.action,
    String? details,
  }) : super('Permissão $permission necessária para $action', details: details);

  @override
  String toString() => 'PermissionException[$permission]: $message';
}

/// Erro de configuração
class ConfigurationException extends PluviometroException {
  final String configKey;
  final String? expectedValue;

  ConfigurationException({
    required this.configKey,
    required String message,
    this.expectedValue,
    String? details,
  }) : super(message, details: details);

  @override
  String toString() => 'ConfigurationException[$configKey]: $message';
}

/// Erro de duplicação
class DuplicateException extends PluviometroException {
  final String duplicateField;
  final dynamic duplicateValue;

  DuplicateException({
    required this.duplicateField,
    required this.duplicateValue,
    String? details,
  }) : super('Valor duplicado para $duplicateField: $duplicateValue',
            details: details);

  @override
  String toString() => 'DuplicateException[$duplicateField]: $message';
}

/// Erro de formato
class FormatException extends PluviometroException {
  final String expectedFormat;
  final dynamic actualValue;

  FormatException({
    required this.expectedFormat,
    required this.actualValue,
    String? details,
  }) : super(
            'Formato inválido. Esperado: $expectedFormat, Recebido: $actualValue',
            details: details);

  @override
  String toString() => 'FormatException: $message';
}

/// Erro de limite excedido
class LimitExceededException extends PluviometroException {
  final String limitType;
  final dynamic currentValue;
  final dynamic maxValue;

  LimitExceededException({
    required this.limitType,
    required this.currentValue,
    required this.maxValue,
    String? details,
  }) : super('Limite $limitType excedido: $currentValue > $maxValue',
            details: details);

  @override
  String toString() => 'LimitExceededException[$limitType]: $message';
}

/// Erro de recurso não encontrado
class ResourceNotFoundException extends PluviometroException {
  final String resourceType;
  final String resourceId;

  ResourceNotFoundException({
    required this.resourceType,
    required this.resourceId,
    String? details,
  }) : super('$resourceType com ID $resourceId não encontrado',
            details: details);

  @override
  String toString() => 'ResourceNotFoundException[$resourceType]: $message';
}

/// Erro de estado inválido
class InvalidStateException extends PluviometroException {
  final String currentState;
  final String expectedState;
  final String operation;

  InvalidStateException({
    required this.currentState,
    required this.expectedState,
    required this.operation,
    String? details,
  }) : super(
            'Estado inválido para $operation. Estado atual: $currentState, Esperado: $expectedState',
            details: details);

  @override
  String toString() => 'InvalidStateException[$operation]: $message';
}

/// Erro de sistema
class SystemException extends PluviometroException {
  final String component;
  final Exception? originalException;

  SystemException({
    required this.component,
    required String message,
    this.originalException,
    String? details,
  }) : super(message, details: details);

  @override
  String toString() => 'SystemException[$component]: $message';
}
