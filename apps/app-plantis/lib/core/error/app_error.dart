import 'package:equatable/equatable.dart';

/// Classe base para todos os erros da aplicação
/// Fornece uma estrutura padronizada para tratamento de erros
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

  @override
  List<Object?> get props => [message, code, details, timestamp, severity, category];
}

/// Severidade do erro
enum ErrorSeverity {
  low,      // Avisos, informações não críticas
  medium,   // Erros que não impedem o funcionamento
  high,     // Erros críticos que afetam funcionalidades
  critical, // Erros que podem causar crash ou perda de dados
}

/// Categoria do erro para melhor organização
enum ErrorCategory {
  general,      // Erros gerais
  network,      // Problemas de rede/conectividade
  authentication, // Problemas de autenticação
  validation,   // Erros de validação de dados
  storage,      // Problemas de armazenamento
  permission,   // Problemas de permissão
  business,     // Regras de negócio violadas
  external,     // Erros de serviços externos
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