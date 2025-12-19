/// Base class for all failures
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Failure from server/remote operations
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);
}

/// Failure from cache/local operations
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

/// Failure from network connectivity
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message);
}

/// Failure from validation
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

/// Failure from authentication
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}
