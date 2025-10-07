import 'package:equatable/equatable.dart';
import 'failure.dart';

/// An abstract base class for all application-specific errors.
///
/// It provides a standardized structure for error handling, including
/// properties for a message, code, severity, and category. This class is
/// intended to gradually replace the simpler [Failure] system.
abstract class AppError extends Equatable {
  /// A human-readable message describing the error.
  final String message;

  /// An optional error code (e.g., from an API response).
  final String? code;

  /// Optional detailed information about the error.
  final String? details;

  /// The stack trace associated with the error, if available.
  final StackTrace? stackTrace;

  /// The timestamp when the error occurred.
  final DateTime timestamp;

  /// The severity level of the error.
  final ErrorSeverity severity;

  /// The category that the error belongs to.
  final ErrorCategory category;

  AppError({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
    DateTime? timestamp,
    this.severity = ErrorSeverity.medium,
    required this.category,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a custom error with the specified properties.
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

  /// Creates an error representing an unknown or unexpected issue.
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

  /// Converts the error to a map for logging or serialization.
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

  /// Converts the error to a JSON map. Alias for [toMap].
  Map<String, dynamic> toJson() => toMap();

  /// Creates a copy of this error with the given fields replaced with new values.
  AppError copyWith({
    String? message,
    String? code,
    String? details,
    StackTrace? stackTrace,
    DateTime? timestamp,
    ErrorSeverity? severity,
    ErrorCategory? category,
  });

  /// A user-friendly message appropriate for display in the UI.
  String get userMessage {
    switch (category) {
      case ErrorCategory.network:
        return 'Problema de conexão. Verifique sua internet e tente novamente.';
      case ErrorCategory.authentication:
        return 'Erro de autenticação. Faça login novamente.';
      // Validation and business errors often have user-friendly messages already.
      case ErrorCategory.validation:
        return message;
      case ErrorCategory.business:
        return message;
      case ErrorCategory.permission:
        return 'Você não tem permissão para esta ação.';
      case ErrorCategory.storage:
        return 'Erro ao acessar dados locais. Tente novamente.';
      case ErrorCategory.external:
        return 'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
      case ErrorCategory.general:
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Returns `true` if the error is critical.
  bool get isCritical => severity == ErrorSeverity.critical;

  /// Returns `true` if the error is related to network connectivity.
  bool get isNetworkError => category == ErrorCategory.network;

  /// Returns `true` if the error is related to authentication.
  bool get isAuthenticationError => category == ErrorCategory.authentication;

  /// Returns `true` if the error is related to data validation.
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

/// Defines the severity level of an [AppError].
enum ErrorSeverity {
  /// Low-impact issues, such as warnings or informational messages.
  low,

  /// Default severity. Errors that do not prevent the app from continuing.
  medium,

  /// Errors that critically affect a feature.
  high,

  /// Errors that can cause a crash or data loss.
  critical,
}

/// Defines the category of an [AppError] for better organization and handling.
enum ErrorCategory {
  /// Uncategorized or general errors.
  general,

  /// Network or connectivity-related problems.
  network,

  /// Authentication or authorization issues.
  authentication,

  /// Data validation failures.
  validation,

  /// Local storage or caching problems.
  storage,

  /// Permission-related issues (e.g., file access, camera).
  permission,

  /// Violations of business logic or rules.
  business,

  /// Errors originating from external services or APIs.
  external,
}

/// An error indicating a network or connectivity problem.
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

/// An error indicating an authentication or authorization failure.
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

/// An error indicating a data validation failure.
class ValidationError extends AppError {
  /// A map of field names to a list of their validation errors.
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
    return super.toMap()..['fieldErrors'] = fieldErrors;
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// An error indicating a problem with local storage or caching.
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

/// An error indicating that a required permission was not granted.
class PermissionError extends AppError {
  /// The specific permission that was denied, if known.
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
    return super.toMap()..['requiredPermission'] = requiredPermission;
  }

  @override
  List<Object?> get props => [...super.props, requiredPermission];
}

/// An error indicating a violation of a business rule.
class BusinessError extends AppError {
  /// The specific business rule that was violated, if known.
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
    return super.toMap()..['businessRule'] = businessRule;
  }

  @override
  List<Object?> get props => [...super.props, businessRule];
}

/// An error indicating a problem with an external service or API.
class ExternalServiceError extends AppError {
  /// The name of the external service that failed.
  final String? serviceName;

  /// The HTTP status code, if the error came from an HTTP response.
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
    return super.toMap()
      ..['serviceName'] = serviceName
      ..['statusCode'] = statusCode;
  }

  @override
  List<Object?> get props => [...super.props, serviceName, statusCode];
}

/// An error for unknown or uncategorized issues.
class UnknownError extends AppError {
  /// The original exception or error that was caught.
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
    return super.toMap()..['originalError'] = originalError?.toString();
  }

  @override
  List<Object?> get props => [...super.props, originalError];
}

/// Utility extensions for [AppError].
extension AppErrorExtensions on AppError {
  /// Converts an [AppError] to a [Failure] for backward compatibility.
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

/// A private implementation for the [AppError.custom] factory.
class _CustomError extends AppError {
  _CustomError({
    required super.message,
    super.code,
    super.details,
    super.stackTrace,
    super.timestamp,
    required super.severity,
    required super.category,
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

/// A factory for creating [AppError] instances from other error types.
class AppErrorFactory {
  /// Converts a [Failure] to a corresponding [AppError].
  static AppError fromFailure(Failure failure) {
    final details = failure.details?.toString();
    switch (failure) {
      case NetworkFailure f:
        return NetworkError(
            message: f.message, code: f.code ?? 'NETWORK_ERROR', details: details);
      case ServerFailure f:
        return ExternalServiceError(
            message: f.message,
            code: f.code ?? 'SERVER_ERROR',
            details: details,
            serviceName: 'API');
      case CacheFailure f:
        return StorageError(
            message: f.message, code: f.code ?? 'CACHE_ERROR', details: details);
      case NotFoundFailure f:
        return BusinessError(
            message: f.message,
            code: f.code ?? 'NOT_FOUND',
            details: details,
            businessRule: 'RESOURCE_NOT_FOUND');
      case AuthFailure f:
        return AuthenticationError(
            message: f.message,
            code: f.code ?? 'UNAUTHORIZED',
            details: details);
      case ValidationFailure f:
        return ValidationError(
            message: f.message,
            code: f.code ?? 'VALIDATION_ERROR',
            details: details);
      case PermissionFailure f:
        return PermissionError(
            message: f.message,
            code: f.code ?? 'PERMISSION_ERROR',
            details: details);
      case UnknownFailure f:
      default:
        return UnknownError(
            message: failure.message,
            code: failure.code ?? 'UNKNOWN_ERROR',
            details: details,
            originalError: failure);
    }
  }

  /// Creates an [AppError] from a generic [Exception] or [Error].
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