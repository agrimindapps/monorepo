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
  const CacheFailure([String message = 'Cache operation failed']) : super(message);
}

/// Failure related to game logic validation
class GameLogicFailure extends Failure {
  const GameLogicFailure(String message) : super(message);
}

/// Failure related to validation of input data
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Failure related to data loading/parsing operations
class DataFailure extends Failure {
  const DataFailure([String message = 'Data operation failed']) : super(message);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'Unexpected error occurred']) : super(message);
}
