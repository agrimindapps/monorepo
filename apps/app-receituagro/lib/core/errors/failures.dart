import 'package:core/core.dart';

/// Server failure específico para este app
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code, dynamic details}) 
      : super(message: message, code: code, details: details);
}

/// Cache failure específico para este app  
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code, dynamic details})
      : super(message: message, code: code, details: details);
}

/// Validation failure específico para este app
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code, dynamic details})
      : super(message: message, code: code, details: details);
}

/// Network failure específico para este app
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code, dynamic details})
      : super(message: message, code: code, details: details);
}