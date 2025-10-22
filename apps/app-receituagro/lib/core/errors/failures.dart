import 'package:core/core.dart';

/// Server failure específico para este app
class ServerFailure extends Failure {
  const ServerFailure(String message, {super.code, super.details}) 
      : super(message: message);
}

/// Cache failure específico para este app  
class CacheFailure extends Failure {
  const CacheFailure(String message, {super.code, super.details})
      : super(message: message);
}

/// Validation failure específico para este app
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {super.code, super.details})
      : super(message: message);
}

/// Network failure específico para este app
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {super.code, super.details})
      : super(message: message);
}

/// Sync failure específico para este app
class SyncFailure extends Failure {
  const SyncFailure(String message, {super.code, super.details})
      : super(message: message);
}
