/// Exceções específicas para o módulo de pluviômetros
abstract class PluviometroException implements Exception {
  final String message;
  final String code;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  PluviometroException({
    required this.message,
    required this.code,
    this.metadata,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'PluviometroException($code): $message';
}

/// Exceção para erros de validação
class ValidationException extends PluviometroException {
  final List<ValidationError> validationErrors;

  ValidationException({
    required this.validationErrors,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: 'Dados inválidos fornecidos',
          code: 'VALIDATION_ERROR',
        );

  String get detailedMessage {
    final errorMessages = validationErrors.map((e) => e.message).join(', ');
    return 'Erros de validação: $errorMessages';
  }
}

/// Exceção para erros de rede
class NetworkException extends PluviometroException {
  final int? statusCode;
  final String? response;

  NetworkException({
    required super.message,
    this.statusCode,
    this.response,
    super.metadata,
    super.stackTrace,
  }) : super(
          code: 'NETWORK_ERROR',
        );

  bool get isTimeout => statusCode == 408 || message.contains('timeout');
  bool get isConnectivityIssue => statusCode == null;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

/// Exceção para erros de autorização
class AuthorizationException extends PluviometroException {
  AuthorizationException({
    super.message = 'Acesso negado',
    super.metadata,
    super.stackTrace,
  }) : super(
          code: 'AUTHORIZATION_ERROR',
        );
}

/// Exceção para erros de dados não encontrados
class DataNotFoundException extends PluviometroException {
  final String resourceType;
  final String? resourceId;

  DataNotFoundException({
    required this.resourceType,
    this.resourceId,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: 'Recurso não encontrado',
          code: 'DATA_NOT_FOUND',
        );

  String get detailedMessage {
    if (resourceId != null) {
      return '$resourceType com ID $resourceId não foi encontrado';
    }
    return '$resourceType não foi encontrado';
  }
}

/// Exceção para conflitos de dados
class DataConflictException extends PluviometroException {
  final String conflictingField;
  final dynamic conflictingValue;

  DataConflictException({
    required this.conflictingField,
    this.conflictingValue,
    String? message,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: message ?? 'Conflito de dados detectado',
          code: 'DATA_CONFLICT',
        );

  String get detailedMessage {
    return 'Conflito no campo $conflictingField${conflictingValue != null ? ' com valor $conflictingValue' : ''}';
  }
}

/// Exceção para erros de operação
class OperationException extends PluviometroException {
  final String operation;
  final String? reason;

  OperationException({
    required this.operation,
    this.reason,
    String? message,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: message ?? 'Falha na operação',
          code: 'OPERATION_FAILED',
        );

  String get detailedMessage {
    final reasonText = reason != null ? ': $reason' : '';
    return 'Operação $operation falhou$reasonText';
  }
}

/// Exceção para limitação de taxa (rate limiting)
class RateLimitException extends PluviometroException {
  final Duration retryAfter;
  final int requestCount;
  final int maxRequests;

  RateLimitException({
    required this.retryAfter,
    required this.requestCount,
    required this.maxRequests,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: 'Limite de requisições excedido',
          code: 'RATE_LIMIT_EXCEEDED',
        );

  String get detailedMessage {
    return 'Limite de $maxRequests requisições excedido ($requestCount). Tente novamente em ${retryAfter.inSeconds}s';
  }
}

/// Exceção para erros de configuração
class ConfigurationException extends PluviometroException {
  final String configKey;
  final String? expectedValue;

  ConfigurationException({
    required this.configKey,
    this.expectedValue,
    String? message,
    super.metadata,
    super.stackTrace,
  }) : super(
          message: message ?? 'Configuração inválida',
          code: 'CONFIGURATION_ERROR',
        );

  String get detailedMessage {
    final expectedText =
        expectedValue != null ? ' (esperado: $expectedValue)' : '';
    return 'Configuração inválida para $configKey$expectedText';
  }
}

/// Informações sobre erro de validação
class ValidationError {
  final String field;
  final String code;
  final String message;
  final ValidationSeverity severity;
  final Map<String, dynamic>? metadata;

  const ValidationError({
    required this.field,
    required this.code,
    required this.message,
    required this.severity,
    this.metadata,
  });

  @override
  String toString() => '$field: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          field == other.field &&
          code == other.code &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(field, code, severity);
}

/// Severidade do erro de validação
enum ValidationSeverity {
  error,
  warning,
  info,
}

/// Extensões para facilitar o uso
extension ValidationSeverityExtension on ValidationSeverity {
  bool get isError => this == ValidationSeverity.error;
  bool get isWarning => this == ValidationSeverity.warning;
  bool get isInfo => this == ValidationSeverity.info;

  String get displayName {
    switch (this) {
      case ValidationSeverity.error:
        return 'Erro';
      case ValidationSeverity.warning:
        return 'Aviso';
      case ValidationSeverity.info:
        return 'Informação';
    }
  }
}
