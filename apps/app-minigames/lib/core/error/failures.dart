import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Used with Either<Failure, T> pattern for error handling
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Failure related to cache/local storage operations
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Failure related to game logic validation
class GameLogicFailure extends Failure {
  const GameLogicFailure(super.message);
}

/// Failure related to validation of input data
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure related to data loading/parsing operations
class DataFailure extends Failure {
  const DataFailure([super.message = 'Data operation failed']);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
