import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/result.dart';

/// The base class for all use cases.
///
/// Defines the implementation pattern with optional parameters.
/// [Type] is the return type of the use case.
/// [Params] is the type of the parameters.
abstract class UseCase<Type, Params> {
  /// Executes the use case.
  ///
  /// [params] The parameters for the use case.
  /// Returns a [Future] with an [Either] containing a [Failure] or the [Type].
  Future<Either<Failure, Type>> call(Params params);
}

/// The base class for use cases that use the `Result` pattern.
///
/// [Type] is the return type of the use case.
/// [Params] is the type of the parameters.
abstract class ResultUseCase<Type, Params> {
  /// Executes the use case.
  ///
  /// [params] The parameters for the use case.
  /// Returns a [Future] with a [Result] containing the [Type].
  Future<Result<Type>> call(Params params);
}

/// A use case that takes no parameters.
///
/// [Type] is the return type of the use case.
abstract class NoParamsUseCase<Type> {
  /// Executes the use case.
  ///
  /// Returns a [Future] with an [Either] containing a [Failure] or the [Type].
  Future<Either<Failure, Type>> call();
}

/// A use case that takes no parameters and uses the `Result` pattern.
///
/// [Type] is the return type of the use case.
abstract class NoParamsResultUseCase<Type> {
  /// Executes the use case.
  ///
  /// Returns a [Future] with a [Result] containing the [Type].
  Future<Result<Type>> call();
}

/// A class to represent the absence of parameters for a use case.
class NoParams {
  /// Creates a new instance of [NoParams].
  const NoParams();
}
