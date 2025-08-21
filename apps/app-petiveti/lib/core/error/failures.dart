import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;
  
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    details: details,
  );
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    details: details,
  );
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    details: details,
  );
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    details: details,
  );
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
    message: message,
    code: code,
    details: details,
  );
}