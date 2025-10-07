import 'package:equatable/equatable.dart';

/// An abstract base class for representing failures in the application.
///
/// This is part of a legacy error-handling system that uses `Either<Failure, Success>`.
/// It is being gradually replaced by the [AppError] system.
abstract class Failure extends Equatable {
  /// The user-friendly error message.
  final String message;

  /// An optional error code, e.g., from an API.
  final String? code;

  /// Optional technical details about the error.
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Represents a failure due to a server or network-related issue.
class ServerFailure extends Failure {
  const ServerFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure related to local cache or storage.
class CacheFailure extends Failure {
  const CacheFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure due to invalid data.
class ValidationFailure extends Failure {
  const ValidationFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure related to authentication or authorization.
class AuthFailure extends Failure {
  const AuthFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure due to insufficient permissions.
class PermissionFailure extends Failure {
  const PermissionFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure due to a network connectivity issue.
class NetworkFailure extends Failure {
  const NetworkFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure in parsing or converting data.
class ParseFailure extends Failure {
  const ParseFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a generic or unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure specific to a Firebase operation.
class FirebaseFailure extends Failure {
  const FirebaseFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure specific to a RevenueCat operation.
class RevenueCatFailure extends Failure {
  const RevenueCatFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure during a data synchronization process.
class SyncFailure extends Failure {
  const SyncFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Represents a failure when a requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(
    String message, {
    super.code,
    super.details,
  }) : super(message: message);
}

/// Utility extensions for the [Failure] class.
extension FailureExtension on Failure {
  /// Returns `true` if the failure is related to network or server issues.
  bool get isNetworkFailure => this is NetworkFailure || this is ServerFailure;

  /// Returns `true` if the failure is related to authentication.
  bool get isAuthFailure => this is AuthFailure;

  /// Returns `true` if the failure is related to data validation.
  bool get isValidationFailure => this is ValidationFailure;

  /// Returns a user-friendly message based on the failure type.
  String get userMessage {
    if (this is NetworkFailure || this is ServerFailure) {
      return 'Problema de conexão. Verifique sua internet e tente novamente.';
    }
    if (this is AuthFailure) {
      return 'Erro de autenticação. Faça login novamente.';
    }
    if (this is ValidationFailure) {
      return message; // Validation messages are typically user-friendly.
    }
    if (this is PermissionFailure) {
      return 'Você não tem permissão para esta ação.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}