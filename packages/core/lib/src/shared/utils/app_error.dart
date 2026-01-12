import 'package:equatable/equatable.dart';
import '../enums/error_severity.dart';
import 'failure.dart';

/// Classe base para todos os erros da aplicação
/// Fornece uma estrutura padronizada para tratamento de erros
/// Sistema mais rico que substitui gradualmente Failure
abstract class AppError extends Equatable {
  final String message;
  final String? code;
  final String? details;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final ErrorCategory category;

  AppError({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
    DateTime? timestamp,
    this.severity = ErrorSeverity.medium,
    this.category = ErrorCategory.general,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory method para criar erro customizado
  factory AppError.custom({
    required String message,
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return _CustomError(
      message: message,
      code: code,
      details: details?.toString(),
      stackTrace: stackTrace,
      timestamp: timestamp,
      severity: severity ?? ErrorSeverity.medium,
      category: category ?? ErrorCategory.general,
    );
  }

  /// Factory method para erro desconhecido
  factory AppError.unknown(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
  }) {
    return UnknownError(
      message: message,
      code: code,
      stackTrace: stackTrace,
      timestamp: timestamp,
      severity: severity ?? ErrorSeverity.medium,
      originalError: originalError,
    );
  }

  /// Converte o erro para um mapa para logging
  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'category': category.name,
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// Converte para JSON para APIs/logging
  Map<String, dynamic> toJson() => toMap();

  /// Cria uma cópia do erro com novos valores
  AppError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  });

  /// Retorna uma mensagem user-friendly baseada na categoria
  String get userMessage {
    switch (category) {
      case ErrorCategory.network:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';
      case ErrorCategory.authentication:
        return 'Erro de autenticação. Faça login novamente.';
      case ErrorCategory.validation:
        return message; // Mensagens de validação já são user-friendly
      case ErrorCategory.permission:
        return 'Você não tem permissão para esta ação.';
      case ErrorCategory.storage:
        return 'Erro ao acessar dados locais. Tente novamente.';
      case ErrorCategory.business:
        return message; // Regras de negócio têm mensagens específicas
      case ErrorCategory.external:
        return 'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
      case ErrorCategory.general:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Verifica se é um erro crítico que precisa de ação imediata
  bool get isCritical => severity == ErrorSeverity.critical;

  /// Verifica se é um erro de rede
  bool get isNetworkError => category == ErrorCategory.network;

  /// Verifica se é um erro de autenticação
  bool get isAuthenticationError => category == ErrorCategory.authentication;

  /// Verifica se é um erro de validação
  bool get isValidationError => category == ErrorCategory.validation;

  @override
  List<Object?> get props => [
    message,
    code,
    details,
    timestamp,
    severity,
    category,
  ];

  @override
  String toString() =>
      'AppError(message: $message, code: $code, category: ${category.name})';
}

/// Categoria do erro para melhor organização
enum ErrorCategory {
  /// Erros gerais
  general,

  /// Problemas de rede/conectividade
  network,

  /// Problemas de autenticação
  authentication,

  /// Erros de validação de dados
  validation,

  /// Problemas de armazenamento
  storage,

  /// Problemas de permissão
  permission,

  /// Regras de negócio violadas
  business,

  /// Erros de serviços externos
  external,
}

/// Erro de rede/conectividade
class NetworkError extends AppError {
  NetworkError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
  }) : super(category: ErrorCategory.network);

  @override
  NetworkError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return NetworkError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }
}

/// Erro de autenticação
class AuthenticationError extends AppError {
  AuthenticationError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.high,
  }) : super(category: ErrorCategory.authentication);

  @override
  AuthenticationError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return AuthenticationError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }
}

/// Erro de validação
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  ValidationError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.low,
    this.fieldErrors,
  }) : super(category: ErrorCategory.validation);

  @override
  ValidationError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
    Map<String, List<String>>? fieldErrors,
  }) {
    return ValidationError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['fieldErrors'] = fieldErrors;
    return map;
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Erro de armazenamento
class StorageError extends AppError {
  StorageError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
  }) : super(category: ErrorCategory.storage);

  @override
  StorageError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return StorageError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }
}

/// Erro de permissão
class PermissionError extends AppError {
  final String? requiredPermission;

  PermissionError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
    this.requiredPermission,
  }) : super(category: ErrorCategory.permission);

  @override
  PermissionError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
    String? requiredPermission,
  }) {
    return PermissionError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      requiredPermission: requiredPermission ?? this.requiredPermission,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['requiredPermission'] = requiredPermission;
    return map;
  }

  @override
  List<Object?> get props => [...super.props, requiredPermission];
}

/// Erro de regra de negócio
class BusinessError extends AppError {
  final String? businessRule;

  BusinessError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
    this.businessRule,
  }) : super(category: ErrorCategory.business);

  @override
  BusinessError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
    String? businessRule,
  }) {
    return BusinessError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      businessRule: businessRule ?? this.businessRule,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['businessRule'] = businessRule;
    return map;
  }

  @override
  List<Object?> get props => [...super.props, businessRule];
}

/// Erro de serviço externo
class ExternalServiceError extends AppError {
  final String? serviceName;
  final int? statusCode;

  ExternalServiceError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
    this.serviceName,
    this.statusCode,
  }) : super(category: ErrorCategory.external);

  @override
  ExternalServiceError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
    String? serviceName,
    int? statusCode,
  }) {
    return ExternalServiceError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      serviceName: serviceName ?? this.serviceName,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['serviceName'] = serviceName;
    map['statusCode'] = statusCode;
    return map;
  }

  @override
  List<Object?> get props => [...super.props, serviceName, statusCode];
}

/// Erro desconhecido/genérico
class UnknownError extends AppError {
  final dynamic originalError;

  UnknownError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
    this.originalError,
  }) : super(category: ErrorCategory.general);

  @override
  UnknownError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
    dynamic originalError,
  }) {
    return UnknownError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['originalError'] = originalError?.toString();
    return map;
  }

  @override
  List<Object?> get props => [...super.props, originalError];
}

/// Extensões utilitários para AppError
extension AppErrorExtensions on AppError {
  /// Converte AppError para Failure (compatibilidade retroativa)
  Failure toFailure() {
    switch (category) {
      case ErrorCategory.network:
        return NetworkFailure(message, code: code, details: details);
      case ErrorCategory.external:
        return ServerFailure(message, code: code, details: details);
      case ErrorCategory.storage:
        return CacheFailure(message, code: code, details: details);
      case ErrorCategory.authentication:
        return AuthFailure(message, code: code, details: details);
      case ErrorCategory.validation:
        return ValidationFailure(message, code: code, details: details);
      case ErrorCategory.permission:
        return PermissionFailure(message, code: code, details: details);
      case ErrorCategory.business:
        if (this is BusinessError &&
            (this as BusinessError).businessRule == 'RESOURCE_NOT_FOUND') {
          return NotFoundFailure(message, code: code, details: details);
        }
        return UnknownFailure(message, code: code, details: details);
      case ErrorCategory.general:
        return UnknownFailure(message, code: code, details: details);
    }
  }
}

/// Implementação privada para erro customizado
class _CustomError extends AppError {
  _CustomError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    super.severity = ErrorSeverity.medium,
    super.category = ErrorCategory.general,
  });

  @override
  _CustomError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  }) {
    return _CustomError(
      message: message ?? this.message,
      code: code ?? this.code,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      category: category ?? this.category,
    );
  }
}

/// Factory para criar AppErrors a partir de Failures
class AppErrorFactory {
  /// Converte Failure para AppError
  static AppError fromFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return NetworkError(
          message: failure.message,
          code: failure.code ?? 'NETWORK_ERROR',
          details: failure.details?.toString(),
        );

      case ServerFailure:
        return ExternalServiceError(
          message: failure.message,
          code: failure.code ?? 'SERVER_ERROR',
          details: failure.details?.toString(),
          serviceName: 'API',
        );

      case CacheFailure:
        return StorageError(
          message: failure.message,
          code: failure.code ?? 'CACHE_ERROR',
          details: failure.details?.toString(),
        );

      case NotFoundFailure:
        return BusinessError(
          message: failure.message,
          code: failure.code ?? 'NOT_FOUND',
          details: failure.details?.toString(),
          businessRule: 'RESOURCE_NOT_FOUND',
        );

      case AuthFailure:
        return AuthenticationError(
          message: failure.message,
          code: failure.code ?? 'UNAUTHORIZED',
          details: failure.details?.toString(),
        );

      case ValidationFailure:
        return ValidationError(
          message: failure.message,
          code: failure.code ?? 'VALIDATION_ERROR',
          details: failure.details?.toString(),
        );

      case PermissionFailure:
        return PermissionError(
          message: failure.message,
          code: failure.code ?? 'PERMISSION_ERROR',
          details: failure.details?.toString(),
        );

      case UnknownFailure:
      default:
        return UnknownError(
          message: failure.message,
          code: failure.code ?? 'UNKNOWN_ERROR',
          details: failure.details?.toString(),
          originalError: failure,
        );
    }
  }

  /// Cria AppError a partir de Exception genérica
  static AppError fromException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? customMessage,
  }) {
    if (exception is AppError) {
      return exception;
    }

    return UnknownError(
      message: customMessage ?? 'Erro inesperado: ${exception.toString()}',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}
