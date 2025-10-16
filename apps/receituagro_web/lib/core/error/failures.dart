import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Server/Network related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Permission/Auth failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Unknown/Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
